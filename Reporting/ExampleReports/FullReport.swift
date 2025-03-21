//
//  MultipleLargeImageReport.swift
//  PDF-Reporting
//
//  Created by Jean-Nicolas on 31.01.2025.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import TPPDF
import ImageCompressionKit
import Extensions

public struct FullReport: PDFReporting {
    public var paperSize: PDFPageFormat = .a4
    public var landscape: Bool = false
    
    public  func addReport(to document: PDFDocument) {
        let reportRecords = ReportRecords.mocks()
        let table = TableReport(reportRecords: reportRecords)
        table.addReport(to: document)
        
        for reportRecord in reportRecords {
            document.createNewPage()
            SingleBookingReport(reportRecord: reportRecord).addReport(to: document)
        }
    }
    
    private func addPageHeader(to document: PDFDocument) {
        document.addLineSeparator(PDFContainer.contentLeft, style: PDFReportingStyle.dividerLine)
        // Title
        document.add(space: 10.0)
        document.set(.contentLeft, textColor: .black)
        document.set(.contentLeft, font: PDFReportingStyle.title)
        document.add(.contentLeft, text: "Kontoauszug")
        document.add(space: 40.0)
    }
}
