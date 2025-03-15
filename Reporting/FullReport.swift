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
    
    func addReport(to document: PDFDocument) {
        
    }
    
    func generateDocument() -> [PDFDocument] {
        let document = PDFDocument(format: .a4)
        document.background.color = .white
        
        addFooter(to: document)
        
        
        let reportRecords = ReportRecords.mocks()
        let table = TableReport(reportRecords: reportRecords)
        table.addReport(to: document)
        
        for reportRecord in reportRecords {
            document.createNewPage()
            SingleBookingReport(reportRecord: reportRecord).addReport(to: document)
        }
        
        
        return [document]
    }
    
    private let logoSize = CGSize(width: 300, height: 70)
    private let dividerLineStyle = PDFLineStyle(type: .full, color: .darkGray, width: 0.5)
    
    private var logo: PDFImage {
        guard let resizedImage = logoImage.resized(to: logoSize, alignment: .right)
        else { fatalError() }
        let finalImage = resizedImage.fillFrame(frameColor: .white).addFrame(frameColor: .systemGray6)
        return PDFImage(image: finalImage, options: [.none])
    }
    
    
    
    
    private func addPageHeader(to document: PDFDocument) {
        // Logo Header
        document.add(.contentRight, image: logo)
        document.add(space: 20.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: dividerLineStyle)
        // Title
        document.add(space: 10.0)
        document.set(.contentLeft, textColor: .black)
        document.set(.contentLeft, font: FullReportFonts.title)
        document.add(.contentLeft, text: "Kontoauszug")
        document.add(space: 40.0)
    }
    
    
    func addFooter(to document: PDFDocument) {
        // Footer text right
        document.addLineSeparator(.footerCenter, style: dividerLineStyle)
        document.set(.footerRight, font: FullReportFonts.footerRegular)
        let date = Date()
        // Use the .dateTime format and localize to German
        let formattedDate = date.formatted(
            .dateTime
                .day(.twoDigits)
                .month(.twoDigits)
                .year(.defaultDigits)
                .hour(.defaultDigits(amPM: .abbreviated))
                .minute(.defaultDigits)
        )
        
        let footerRightText = "Druckdatum: \(formattedDate)"
        document.add(.footerRight, text: footerRightText)
        
        // Pagination
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        
        let pagination = PDFPagination(
            container: .footerCenter,
            style: PDFPaginationStyle.customNumberFormat(template: "%@/%@",
                                                         formatter: numberFormatter)
        )
        document.pagination = pagination
        
    }
}

fileprivate struct FullReportFonts {
    static let title = Font.systemFont(ofSize: 20, weight: .bold)
    static let regular = Font.systemFont(ofSize: 10, weight: .regular)
    static let footerRegular = Font.systemFont(ofSize: 10, weight: .regular)
    static let footerBold = Font.systemFont(ofSize: 10, weight: .bold)
}
