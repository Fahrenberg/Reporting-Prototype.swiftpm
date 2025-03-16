#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import TPPDF
import ImageCompressionKit
import Extensions
import CoreGraphics
import OSLog

public struct SingleBookingReport: Report {
    public let reportRecord: ReportRecord
    public var paperSize: PDFPageFormat = .a4
    public var landscape: Bool = false
    
    public func addReport(to document: PDFDocument) {
        addHeader(to: document)
        addFullReportInfo(to: document)
        addScans(to: document)

    }
    
    private let logoSize = CGSize(width: 300, height: 70)
    private let digitStyle = PDFTableCellStyle(font: SingleBookingFonts.digit)
    private let boldTextStyle = PDFTableCellStyle(font: SingleBookingFonts.bold)
    private let textStyle = PDFTableCellStyle(font: SingleBookingFonts.regular)

    private let digitTableStyle = PDFTableCellStyle(
        borders: PDFTableCellBorders(top: PDFLineStyle(type: .full, color: .darkGray, width: 0.5)),
        font: SingleBookingFonts.digit
    )
    
    // Scans
    private func scansSize(document: PDFDocument) -> CGSize {
        CGSize(width: document.layout.width
               - document.layout.margin.left
               - document.layout.margin.right,
               height: document.layout.height 
               - document.layout.margin.top 
               - document.layout.margin.bottom
               -  10 // Spacer before scans
               - 220 // Report info & header
        )
    }
    
    private var logo: PDFImage {
        guard let resizedImage = logoImage.resized(to: logoSize, alignment: .right)
        else { fatalError() }
        let finalImage = resizedImage.fillFrame(frameColor: .white).addFrame(frameColor: .lightGray)
        return PDFImage(image: finalImage, options: [.none])
    }
    private var cashFlowFormatted: String {
            reportRecord.cashFlow
    }
    private var amountFormatted: String { 
        let amountValue = Decimal(reportRecord.amount) // Ensure Decimal type
        return "CHF " + amountValue.formatted(
            .number
            .precision(.fractionLength(2...2))
            .sign(strategy: .always()) // Ensures + or - sign
        )
    }
    private var dateFormatted: String {
        let style = Date.FormatStyle(date: .long, time: .omitted)
            .locale(Locale(identifier: "de-CH"))
        return reportRecord.date.formatted(style)
    }
    private var iconImage: PlatformImage {
        let symbolSize = CGSize(width: 40, height: 40)
        let symbolImage = UIImage(systemName: reportRecord.icon) ?? UIImage(systemName: "questionmark")!
        guard let resizedImage = symbolImage.resized(to: symbolSize, alignment: .left)
        else { fatalError() }
        let finalImage = resizedImage.fillFrame(frameColor: .white).addFrame(frameColor: .lightGray)
        return finalImage
    }
    

    private func addHeader(to document: PDFDocument) {
        // Logo Header
        document.add(.contentRight, image: logo)
        document.add(space: 20.0)
    }
    
    private func addFullReportInfo(to document: PDFDocument) {
        document.addLineSeparator(PDFContainer.contentLeft, style: ReportStyle.dividerLine)
        document.add(space: 5.0)
        // Add booking information as table
        let row1Table = PDFTable(rows: 1, columns: 2)
        row1Table.style = rowTableStyle
        let row1 = row1Table[row: 0]
        row1.content = [cashFlowFormatted , dateFormatted]
        row1.style = [boldTextStyle, textStyle]
        row1.alignment = [.left, .right]
        document.add(table: row1Table)
        
        let row2Table = PDFTable(rows: 1, columns: 3)
        row2Table.widths = [0.1, 0.6, 0.3]
        row2Table.style = rowTableStyle
        let row2 = row2Table[row: 0]
        row2.content = [iconImage, reportRecord.text, amountFormatted]
        row2.style = [textStyle, textStyle, digitStyle]
        row2.alignment = [.left, .left, .right] 
        // Set table padding and margin
        document.add(table: row2Table)
        
        document.add(space: 5.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: ReportStyle.dividerLine)
        
    }
    
    private func addReducedReportInfo(to document: PDFDocument, scanPage: Int, allScanPages: Int) {
        document.addLineSeparator(PDFContainer.contentLeft, style: ReportStyle.dividerLine)
        document.add(.contentLeft, text: "\(reportRecord.text) (\(scanPage)/\(allScanPages))")
        document.add(space: 50.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: ReportStyle.dividerLine)
        document.add(space: 10.0)
    }
    
    private func addScans(to document: PDFDocument) {
        document.add(space: 10.0)
        
        switch reportRecord.scans.count {
        case 0:
            NoScan(document: document)
        case 1:
            OneScan(document: document)

        default:
            TwoByTwoScans(document: document)
        }
    }
    
    private func NoScan(document: PDFDocument) {
        guard let noScanSymbol = Image(named: "NoSca8n")
        else {
            let topSpacer = scansSize(document: document).height / 2
            document.add(.contentCenter ,space: topSpacer)
            document.add(.contentCenter, text: "No Scans") 
            return
        }
        document.add(.contentCenter ,space: 100)
        document.add(.contentCenter, image: PDFImage(image: noScanSymbol))
    }
    
    private func OneScan(document: PDFDocument) {
        let topSpacer = scansSize(document: document).height / 2 - 20
        document.add(.contentCenter ,space: topSpacer)
        document.add(.contentCenter ,text: "One Scan")
    }

    private func TwoByTwoScans(document: PDFDocument) {
        /// Four scans (2x2) per page, 5 point spacer between scans
        let spacer: Double = 5
        let scanWidth = scansSize(document: document).width / 2 - spacer
        let scanHeight = scansSize(document: document).height / 2
        
        
        let scanSize = CGSize(width: scanWidth, height: scanHeight)
        let pdfImages: [PlatformImage] = reportRecord.scans.compactMap { data in
            guard let resizedImage = PlatformImage(data: data)?.resized(to: scanSize) else {return nil}
            return resizedImage.fillFrame().addFrame()
        }
        
        let fourPDFImages = pdfImages.chunked(into: 4)
        let pageCount = fourPDFImages.count
        var currentPage = 1
        
        for pdfImages in fourPDFImages {
            let imageGroup = PDFGroup(allowsBreaks: false, backgroundColor: .white)
            var pdfImagesRow: [PDFImage] = []
            
            for image in pdfImages {
                // Retrieve the image data using the image name.
                let pdfImage = PDFImage(image: image, options: [.none])
                pdfImagesRow.append(pdfImage)
                
                // When two images have been collected, add them as a row and reset the temporary array.
                if pdfImagesRow.count == 2 {
                    imageGroup.add(.left, imagesInRow: pdfImagesRow)
                    imageGroup.add(space: spacer)
                    pdfImagesRow.removeAll()
                }
            }
            
            // If there's one image left after the loop, add it as a single-image row.
            if !pdfImagesRow.isEmpty {
                imageGroup.add(.left, imagesInRow: pdfImagesRow)
            }
            
            document.add(group: imageGroup)
            currentPage += 1
            if currentPage <= pageCount {
                document.createNewPage()
                addHeader(to: document)
                addReducedReportInfo(to: document, scanPage: currentPage, allScanPages: pageCount)
            }
        }
    }
}


fileprivate struct SingleBookingFonts {
    static let title = Font.systemFont(ofSize: 30, weight: .bold)
    static let regular = Font.systemFont(ofSize: 15, weight: .regular)
    static  let bold = Font.systemFont(ofSize: 15, weight: .bold)
#if canImport(UIKit)
    static  let digit = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
    static  let digitBold = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .bold)
#elseif canImport(AppKit)
    static  let digit = NSFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
    static  let digitBold = NSFont.monospacedDigitSystemFont(ofSize: 15, weight: .bold)
#endif
}
fileprivate var rowTableStyle: PDFTableStyle {
    PDFTableStyle(
        rowHeaderCount: 0,
        columnHeaderCount: 0,
        footerCount: 0,
        outline: PDFLineStyle(type: .none, color: .white, width: 0),
        rowHeaderStyle: PDFTableCellStyle(),
        columnHeaderStyle: PDFTableCellStyle(),
        footerStyle: PDFTableCellStyle(),
        contentStyle: PDFTableCellStyle(
            borders: PDFTableCellBorders(
                left: PDFLineStyle(type: .none),
                top: PDFLineStyle(type: .none),
                right: PDFLineStyle(type: .none),
                bottom: PDFLineStyle(type: .none)
            )),
        alternatingContentStyle: nil
    )
}

