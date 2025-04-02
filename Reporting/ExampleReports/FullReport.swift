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
    
    public func addDocument(to document: PDFDocument) async {
        PDFLogoImageHeader(logoImage: logoImage).addHeader(to: document)
        addReport(to: document)
        PDFPaginatedFooter().addFooter(to: document)
    }
}
