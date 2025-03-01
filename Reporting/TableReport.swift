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

struct TableReport: Report {
    let reportRecords: [ReportRecord]
    
    
    func addTableHeaderRow(table: PDFTable) {
        table.showHeadersOnEveryPage = true
        table.style.rowHeaderCount = 1
        table[row:0].formatHeaderRow()
        let cellBorders = PDFTableCellBorders(bottom: TableLines.greyDivider)
        let textStyle = PDFTableCellStyle(borders: cellBorders, font: TableFonts.bold)
        table.style.columnHeaderStyle = textStyle
    }
    
    /// Format Total Row at the end of table.
    ///
    /// - ```table``` is a var by reference (inout)
    /// - Calculates sum of amount for all records
    ///
    func addTotalRow(table: PDFTable)  {
        table.style.footerCount = 1 // needed?
        let lastRowIndex = table.size.rows - 1 //table.style.footerCount // zero based
        let totalRow = table[row: lastRowIndex]
        let sum = reportRecords.reduce(0) {$0 + $1.amount }
        totalRow.formatTotalRow(totalAmount: sum)
       
    }
    
    /// Adds records to table.
    ///
    /// - ```table``` is a var by reference (inout)
    /// - Table must have enough rows to add each record
    func addTableContent(table: PDFTable) {
        guard reportRecords.count == table.size.rows - 2 else { return } // table content rows = reportRecords - 1 header line - 1 footer row, else wrong table size
        // Table Content
        reportRecords.enumerated().forEach { index, reportRecord in
            let row = table[row: index + 1]
            row.formatContentRow(reportRecord: reportRecord)
        }
    }
    
    
    
    func generateDocument() -> [PDFDocument] {
        let document = PDFDocument(format: .a4)
        document.background.color = .white
        
        // Report Title
        document.set(.contentCenter, textColor: .blue)
        document.set(.contentCenter, font: TableFonts.title)
        document.add(.contentCenter, text: "ReportRecord Table")
        document.add(space: 10.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: TableLines.greyDivider)
        
        // Add Record Table
        let table = PDFTable(rows: reportRecords.count + 2, columns: 4) // Records + 1 Header + 1 Footer
        table.style = PDFTableStyle() // set to default
        table.padding = 2.0
        addTableHeaderRow(table: table)
        addTableContent(table: table)
        addTotalRow(table: table)
        document.add(table: table)
        return [document]
    }
}

extension TableReport {
    static var mockReportRecords: [ReportRecord] {
        return (0..<40).map { i in
            let record = ReportRecord.mockReportRecord
            return ReportRecord(date: record.date,
                                icon: record.icon + "-\(i)",
                                text: record.text,
                                amount: record.amount,
                                scans: record.scans
            )
        }
    }
}



fileprivate extension PDFTableRow {
    
    func formatContentRow(reportRecord: ReportRecord) {
        let amountFormatted = reportRecord.amount.formatted(
            .number
            .grouping(.automatic)
            .precision(.fractionLength(2...2))
        )
        
        
        var tableRowContent: [String] {
            [
                defaultDateOnlyFormatter.string(from: reportRecord.date),
                reportRecord.icon,
                reportRecord.text,
                amountFormatted
            ]
        }
        
        self.content = tableRowContent
        let digitStyle = PDFTableCellStyle(font: TableFonts.digit)
        let textStyle = PDFTableCellStyle(font: TableFonts.regular)
        self.style = [digitStyle,textStyle,textStyle,digitStyle]
        self.alignment = [.left, .center, .center, .right]
    }
    
    func formatHeaderRow() {
        self.content = [" Datum", "Icon", "Text", "Betrag"]
        self.alignment = [.left,.center, .center, .right]
    }
    
    
    func formatTotalRow(totalAmount: Double) {
        let digitStyle = PDFTableCellStyle(
            borders: PDFTableCellBorders(top: TableLines.greyDivider),
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
        self.content = ["", "", "Total:", totalAmountFormatted]
        self.alignment = [.right, .right, .right, .right]
        self.style = [textStyle,textStyle,textStyle,digitStyle]
    }
}


fileprivate struct TableFonts {
    static let title = Font.systemFont(ofSize: 30, weight: .bold)
    static let regular = Font.systemFont(ofSize: 10, weight: .regular)
    static  let bold = Font.systemFont(ofSize: 10, weight: .bold)
#if canImport(UIKit)
    static  let digit = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
    static  let digitBold = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
#elseif canImport(AppKit)
    static  let digit = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
    static  let digitBold = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
#endif
    
    
    
}

fileprivate struct TableLines {
    static let greyDivider = PDFLineStyle(type: .full, color: .darkGray, width: 0.5)
}


