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

public struct PDFFullReport: PDFReporting {
    public let reportRecords: [ReportRecord]
    public var paperSize: PDFPageFormat = .a4
    public var landscape: Bool = false
   
    public var pdfHeader: PDFReportingHeader = PDFLogoImageHeader(
        logoImage: PlatformImage.image(named: "Reporting-Prototype-Icon.jpeg")!
        )
    
    public let pdfFooter: PDFReportingFooter = PDFPaginatedFooter()
    
    public  func addReport(to document: PDFDocument) async {
        let reportRecords = ReportRecords.mocks()
        let table = PDFRecordTable(reportRecords: reportRecords)
        table.addReport(to: document)
        
        for reportRecord in reportRecords {
            document.createNewPage()
            let pdfBooking = PDFBooking(reportRecord: reportRecord)
            await pdfBooking.addReport(to: document)
        }
    }
}
