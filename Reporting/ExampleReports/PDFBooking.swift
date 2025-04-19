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

//
//  PDFBooking.swift
//  Reporting
//
//  Created by Jean-Nicolas on 12.03.2025.
//

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

public struct PDFBooking: PDFReporting {
    public let reportRecord: ReportRecord
    public let paperSize: PDFPageFormat
    public let landscape: Bool
    
    public init(reportRecord: ReportRecord,
                paperSize: PDFPageFormat = .a4,
                landscape: Bool = false
            )
    {
        self.reportRecord = reportRecord
        self.paperSize = paperSize
        self.landscape = landscape
    }
    
    public func addReport(to document: PDFDocument) async {
        addFullReportInfo(to: document)
        await addScans(to: document)

    }
    public var pdfHeader: PDFReportingHeader = PDFLogoImageHeader(
        logoImage: PlatformImage.image(named: "ReportingDefaultLogo.png")!
        )
    
    public let pdfFooter: PDFReportingFooter = PDFPaginatedFooter()
    
    private let digitCellStyle = PDFTableCellStyle(font: PDFReportingStyle.digit)
    private let boldTextCellStyle = PDFTableCellStyle(font: PDFReportingStyle.bold)
    private let regularTextCellStyle = PDFTableCellStyle(font: PDFReportingStyle.regular)

    private let digitTableStyle = PDFTableCellStyle(
        borders: PDFTableCellBorders(top: PDFLineStyle(type: .full, color: .darkGray, width: 0.5)),
        font: PDFReportingStyle.digit
    )
    
    // Scans
    private func scansSize(document: PDFDocument) -> CGSize {
        CGSize(width: document.layout.width
               - document.layout.margin.left
               - document.layout.margin.right,
               height: document.layout.height
               - document.layout.margin.top
               - document.layout.margin.bottom
               - 210 // Report info & header
        )
    }
    
    private var categoryFormatted: NSAttributedString {
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: PDFReportingStyle.bold
        ]
        
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: PDFReportingStyle.regular
        ]
        
        let shortText = NSMutableAttributedString(
            string: reportRecord.record.shortText,
            attributes: boldAttributes
        )
        
        let cashFlowText = NSMutableAttributedString(
            string: " (" + reportRecord.record.cashFlow.rawValue + ")",
            attributes: regularAttributes
        )
        shortText.append(cashFlowText)
        return shortText
    }
    
    
    private var amountFormatted: String {
        let amountValue = Decimal(reportRecord.record.amount) // Ensure Decimal type
        return "CHF " + amountValue.formatted(
            .number
            .precision(.fractionLength(2...2))
            .sign(strategy: .always()) // Ensures + or - sign
        )
    }
    private var dateFormatted: String {
        let style = Date.FormatStyle(date: .long, time: .omitted)
            .locale(Locale(identifier: "de-CH"))
        return reportRecord.record.date.formatted(style)
    }
    private var iconImage: PlatformImage {
        let symbolSize = CGSize(width: 20, height: 20)
        let symbolImage = PlatformImage(systemName: reportRecord.record.icon) ?? PlatformImage(systemName: "questionmark")!
        guard let resizedImage = symbolImage.resized(to: symbolSize, alignment: .left)
        else { fatalError() }
        let finalImage = resizedImage.fillFrame(frameColor: .white)
        return finalImage
    }
    
    private func addFullReportInfo(to document: PDFDocument) {
        document.addLineSeparator(PDFContainer.contentLeft, style: PDFReportingStyle.dividerLine)
        document.add(space: 5.0)
        // Add booking information as table
        let row1Table = PDFTable(rows: 1, columns: 2)
        row1Table.style = rowTableStyle
        let row1 = row1Table[row: 0]
        row1.content = [categoryFormatted , dateFormatted]
        row1.style = [boldTextCellStyle, regularTextCellStyle]
        row1.alignment = [.left, .right]
        document.add(table: row1Table)
        
        let row2Table = PDFTable(rows: 1, columns: 3)
        row2Table.widths = [0.1, 0.6, 0.3]
        row2Table.style = rowTableStyle
        let row2 = row2Table[row: 0]
        row2.content = [iconImage, reportRecord.record.longText, amountFormatted]
        row2.style = [regularTextCellStyle, regularTextCellStyle, digitCellStyle]
        row2.alignment = [.left, .left, .right]
        // Set table padding and margin
        document.add(table: row2Table)
        
        document.add(space: 5.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: PDFReportingStyle.dividerLine)
        
    }
    
    private func addReducedReportInfo(to document: PDFDocument, scanPage: Int, allScanPages: Int) {
        document.addLineSeparator(PDFContainer.contentLeft, style: PDFReportingStyle.dividerLine)
        document.add(space: 5.0)
        
        // Add booking information as table
        let row1Table = PDFTable(rows: 1, columns: 2)
        row1Table.style = rowTableStyle
        let row1 = row1Table[row: 0]
        row1.content = [categoryFormatted , "Belege \(scanPage)/\(allScanPages)"]
        row1.style = [boldTextCellStyle, regularTextCellStyle]
        row1.alignment = [.left, .right]
        document.add(table: row1Table)
      
        document.add(space: 2.0)
        document.set(font: PDFReportingStyle.regular)
        document.add(.contentLeft, text: reportRecord.record.longText)
        document.add(space: 18.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: PDFReportingStyle.dividerLine)
        document.add(space: 5.0)
    }
    
    private func addScans(to document: PDFDocument) async {
        document.add(space: 10.0)
        let scansData = await reportRecord.scansData
            
        switch scansData.count {
        case 0:
            NoScan(document: document)
        case 1:
            await OneScan(document: document)

        default:
            await TwoByTwoScans(document: document)
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
    
    private func OneScan(document: PDFDocument) async {
        /// One scans per page
        let scanWidth = scansSize(document: document).width
        let scanHeight = scansSize(document: document).height
        let scanSize = CGSize(width: scanWidth, height: scanHeight)
        let scansData = await reportRecord.scansData
        guard let firstScanData = scansData.first,
              let resizedImage = PlatformImage(data: firstScanData)?.resized(to: scanSize)
        else { return }
        
        let scanImage = resizedImage.fillFrame().addFrame()
        let pdfImage = PDFImage(image: scanImage, options: [.none])
        document.add(image: pdfImage)
    }

    private func TwoByTwoScans(document: PDFDocument) async {
        /// Four scans (2x2) per page, 5 point spacer between scans
        let spacer: Double = 5
        let scanWidth = scansSize(document: document).width / 2 - spacer
        let scanHeight = scansSize(document: document).height / 2
        
        
        let scanSize = CGSize(width: scanWidth, height: scanHeight)
        let scansData = await reportRecord.scansData
        let pdfImages: [PlatformImage] = scansData.compactMap { data in
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
                addReducedReportInfo(to: document, scanPage: currentPage, allScanPages: pageCount)
            }
        }
    }
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


