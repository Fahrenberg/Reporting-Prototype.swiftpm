#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import TPPDF
import ImageCompressionKit
import Extensions
import CoreGraphics

struct SingleBookingReport: Report {
    let reportRecord: ReportRecord
    
    private let dividerLineStyle = PDFLineStyle(type: .full, color: .darkGray, width: 0.5)
    private let logoSize = CGSize(width: 100, height: 70)
    private let digitStyle = PDFTableCellStyle(font: SingleBookingFonts.digit)
    private let boldTextStyle = PDFTableCellStyle(font: SingleBookingFonts.bold)
    private let textStyle = PDFTableCellStyle(font: SingleBookingFonts.regular)

    private let digitTableStyle = PDFTableCellStyle(
        borders: PDFTableCellBorders(top: PDFLineStyle(type: .full, color: .darkGray, width: 0.5)),
        font: SingleBookingFonts.digit
    )
    
    private var logo: PDFImage {
        guard let resizedImage = logoImage.resized(to: logoSize, alignment: .right)
        else { fatalError() }
        let finalImage = resizedImage.fillFrame(frameColor: .white).addFrame(frameColor: .lightGray)
        return PDFImage(image: finalImage, quality: 1.0)
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
    
    func generateDocument() -> [PDFDocument] {
        let document = PDFDocument(format: .a4)
       
        // Logo Header
        document.add(.contentRight, image: logo)
        document.add(space: 20.0)
        
        document.addLineSeparator(PDFContainer.contentLeft, style: dividerLineStyle)
        // Add booking information as table
        let row1Table = PDFTable(rows: 1, columns: 2)
        row1Table.style = rowTableStyle
        let row1 = row1Table[row: 0]
        row1.content = [cashFlowFormatted , dateFormatted]
        row1.style = [boldTextStyle, textStyle]
        row1.alignment = [.left, .right]
        row1Table.margin = 5.0
        
        document.add(table: row1Table)
        
        let row2Table = PDFTable(rows: 1, columns: 3)
        row2Table.widths = [0.1, 0.6, 0.3]
        row2Table.style = rowTableStyle
        let row2 = row2Table[row: 0]
        row2.content = [iconImage, reportRecord.text, amountFormatted]
        row2.style = [textStyle, textStyle, digitStyle]
        row2.alignment = [.left, .left, .right] 
        // Set table padding and margin
        row2Table.margin = 5.0
        document.add(table: row2Table)
        //
        
        document.add(space: 10.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: dividerLineStyle)
       
        // add scans
        
        //

        return [document]
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
