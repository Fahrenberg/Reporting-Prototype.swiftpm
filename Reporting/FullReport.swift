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

struct FullReport: Report {

    
    func generateDocument() -> [PDFDocument] {
        let reportRecords = TableReport.mockReportRecords
        let table = TableReport(reportRecords: reportRecords)
        var document = table.generateDocument()
        
        for reportRecord in reportRecords {
            let scanReport = SingleBookingReport(reportRecord: reportRecord).generateDocument()
            document += scanReport
        }
        
        
        return document
    }
}

