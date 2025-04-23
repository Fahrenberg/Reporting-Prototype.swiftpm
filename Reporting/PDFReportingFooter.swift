
//
//  PDFReportingHeader.swift
//  Reporting-Prototype
//
//  Created by Jean-Nicolas on 02.04.2025.
//
import Foundation
import Extensions
import TPPDF

public protocol PDFReportingFooter {
    ///  Customised Report Footer layout
    func add(to document: PDFDocument) async
    /// Height of footer in pixel
    var height: CGFloat { get }
}
/// Empty footer
///
/// - For printing external PDF.
/// - Skips pdf footer area .
public struct PDFEmptyFooter: PDFReportingFooter {
    public func add(to document: PDFDocument) async {}
    public let height: CGFloat = 0
}

/// Default footer with page numbers and printing date
public struct PDFPaginatedFooter: PDFReportingFooter  {
    public func add(to document: PDFDocument) async {
        document.set(textColor: .black)
        // Footer text right
        document.addLineSeparator(.footerCenter, style: PDFReportingStyle.dividerLine)
        document.set(.footerRight, font: PDFReportingStyle.footerRegular)
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
                                                         formatter: numberFormatter),
            textAttributes: [.font: PDFReportingStyle.footerRegular,
                             .foregroundColor: Color.black]
        )
        document.pagination = pagination
    }
     public let height: CGFloat = 0
}
