//
//  PDFFullReport.swift
//  Reporting
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

public struct PDFAllBookings: PDFReporting {
    public let reportRecords: [ReportRecord]
    public var paperSize: PDFPageFormat = .a4
    public var landscape: Bool = false
   
    // Using default empty header
    public var pdfHeader: PDFReportingHeader = PDFLogoImageHeader(
        logoImage: PlatformImage.image(named: "ReportingDefaultLogo.png")!
        )
    
    public let pdfFooter: PDFReportingFooter = PDFPaginatedFooter()
    
    public  func addReport(to document: PDFDocument) async {
       
        for (i, reportRecord)in reportRecords.enumerated() {
            let pdfBooking = PDFBooking(
                reportRecord: reportRecord,
                paperSize: paperSize,
                landscape: landscape)
            await pdfBooking.addReport(to: document)
            if i < reportRecords.count - 1 {
                document.createNewPage()
            }
        }
    }
}
