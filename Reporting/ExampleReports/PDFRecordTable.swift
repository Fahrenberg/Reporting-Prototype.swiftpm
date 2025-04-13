//
//  TableReport.swift
//  PDF-Reporting
//
//  Created by Jean-Nicolas on 03.02.2025.
//
import Foundation
import TPPDF
import Extensions
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
/*
 public let pdfHeader: PDFReportingHeader = PDFLogoImageHeader(
     logoImage: PlatformImage.image(named: "Reporting-Prototype-Icon.jpeg")!
     )
 
 public let pdfFooter: PDFReportingFooter = PDFPaginatedFooter()
 
 */


struct PDFRecordTable: PDFReporting {
    public let reportRecords: [ReportRecord]
    public let paperSize: PDFPageFormat
    public let landscape: Bool
    public let pdfHeader: PDFReportingHeader = PDFLogoImageHeader(
        logoImage: PlatformImage.image(named: "Reporting-Prototype-Icon.jpeg")!
        )
    
    public let pdfFooter: PDFReportingFooter = PDFPaginatedFooter()
    
    
    public init(reportRecords: [ReportRecord],
                paperSize: PDFPageFormat = .a4,
                landscape: Bool = false) {
        self.reportRecords = reportRecords
        self.paperSize = paperSize
        self.landscape = landscape
    }
    
    public func addReport(to document: PDFDocument) {
        addPageHeader(to: document)
        
        // Add Record Table
        let table = PDFTable(rows: reportRecords.count + 2, columns: 5) // Records + 1 Header + 1 Footer
        table.style = PDFTableStyle() // set to default
        table.padding = 2.0
        table.widths = tableWidth
        
        addTableHeaderRow(table: table)
        addTableContent(table: table)
        addTotalRow(table: table)
        document.add(table: table)
    }
    
    private let dividerLineStyle = PDFLineStyle(type: .full, color: .darkGray, width: 0.5)
    private let tableWidth: [CGFloat] = [0.13, 0.05, 0.15, 0.52, 0.15]

    
    private func addPageHeader(to document: PDFDocument) {
        // Title
        document.add(space: 10.0)
        document.set(.contentLeft, textColor: .black)
        document.set(.contentLeft, font: TableFonts.title)
        document.add(.contentLeft, text: "Kontoauszug")
        document.add(space: 40.0)
    }
    
    /// Format Header Table Row at the table beginning.
    ///
    private func addTableHeaderRow(table: PDFTable) {
        table.showHeadersOnEveryPage = true
        table.style.rowHeaderCount = 1
        table[row:0].formatHeaderRow()
        let cellBorders = PDFTableCellBorders(bottom: dividerLineStyle)
        let textStyle = PDFTableCellStyle(borders: cellBorders, font: TableFonts.bold)
        table.style.columnHeaderStyle = textStyle
    }
    
    /// Adds records to table.
    ///
    /// - ```table``` is a var by reference (inout)
    /// - Table must have enough rows to add each record
    private func addTableContent(table: PDFTable) {
        guard reportRecords.count == table.size.rows - 2 else { return } // table content rows = reportRecords - 1 header line - 1 footer row, else wrong table size
        // Table Content
        reportRecords.enumerated().forEach { index, reportRecord in
            let row = table[row: index + 1]
            row.formatContentRow(reportRecord: reportRecord)
        }
    }
    
    /// Format Total Row at the table end.
    ///
    /// - ```table``` is a var by reference (inout)
    /// - Calculates sum of amount for all records
    ///
    private func addTotalRow(table: PDFTable)  {
        table.style.footerCount = 1 // needed?
        let lastRowIndex = table.size.rows - 1 //table.style.footerCount // zero based
        let totalRow = table[row: lastRowIndex]
        let sum = reportRecords.reduce(0) {$0 + $1.record.signedAmount }
        totalRow.formatTotalRow(totalAmount: sum, dividerLine: dividerLineStyle)
        
    }
    
    
    
    
}

fileprivate extension PDFTableRow {
    
    func formatHeaderRow() {
        self.content = [" Datum","", "Kategorie", "Buchungstext", "CHF"]
        self.alignment = [.left,.center, .left, .left, .center]
    }
    
    func formatContentRow(reportRecord: ReportRecord) {
        let amountFormatted = reportRecord.record.signedAmount.formatted(
            .number
                .grouping(.automatic)
                .precision(.fractionLength(2...2))
        )
        
        var tableRowContent: [(any PDFTableContentable)?]  {
            [
                defaultDateOnlyFormatter.string(from: reportRecord.record.date),
                iconImage(icon: reportRecord.record.icon),
                reportRecord.record.shortText,
                reportRecord.record.longText,
                amountFormatted
            ]
        }
        
        self.content = tableRowContent
        let digitStyle = PDFTableCellStyle(font: TableFonts.digit)
        let textStyle = PDFTableCellStyle(font: TableFonts.regular)
        let smallTextStyle = PDFTableCellStyle(font: TableFonts.regularSmall)
        self.style = [digitStyle,textStyle, textStyle,smallTextStyle,digitStyle]
        self.alignment = [.topLeft, .top, .topLeft,. topLeft, .topRight]
    }
    
    func formatTotalRow(totalAmount: Double, dividerLine: PDFLineStyle ) {
        let digitStyle = PDFTableCellStyle(
            borders: PDFTableCellBorders(top: dividerLine),
            font: TableFonts.digit
        )
        
        let textStyle = PDFTableCellStyle(
            font: TableFonts.bold
        )
        let totalAmountFormatted = totalAmount.formatted(
            .number
                .grouping(.automatic)
                .precision(.fractionLength(2...2))
        )
        self.content = ["", "", "","Total:", totalAmountFormatted]
        self.alignment = [.topRight, .topRight, .topRight, .topRight, .topRight]
        self.style = [textStyle, textStyle,textStyle,textStyle,digitStyle]
    }
        
    private func iconImage(icon: String) -> PlatformImage {
        let symbolSize = CGSize(width: 12, height: 12)
        let symbolImage = PlatformImage(systemName: icon)
            ?? PlatformImage(systemName: "questionmark")!
        
        guard let resizedImage = symbolImage.resized(to: symbolSize, alignment: .left)
        else { fatalError() }
        let finalImage = resizedImage.fillFrame(frameColor: .white)
        return finalImage
    }
}


fileprivate struct TableFonts {
    static let title = Font.systemFont(ofSize: 20, weight: .bold)
    static let regular = Font.systemFont(ofSize: 10, weight: .regular)
    static let regularSmall = Font.systemFont(ofSize: 8, weight: .regular)
    static  let bold = Font.systemFont(ofSize: 10, weight: .bold)
#if canImport(UIKit)
    static  let digit = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
    static  let digitBold = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
#elseif canImport(AppKit)
    static  let digit = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
    static  let digitBold = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
#endif
    
}

