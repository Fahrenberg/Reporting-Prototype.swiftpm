//
//  ReportRecord.swift
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

public struct ReportRecord {
    let record: Record
    var closing: Closing? = nil  // WHY, it's included in record.closing_id
    let scanFilename: [String]
    
    var scansData: [Data] { 
        return scanFilename.map { imageData(filename: $0)}
    }
    static func mock(scanCount: Int = 5) -> ReportRecord {
        let longText = scanCount == 6 ? 
        """
         Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren est Lorem ipsum dolor sit amet.
         """ :  "Mock Report Record with \(scanCount) scan(s)"
        
        let record = Record(
            date: Date().addingTimeInterval(Double.random(in: -1_000_000_000 ... 0)),
            icon: "truck.box",
            amount: Double.random(in: 1000.0 ... 10000.00),
            cashFlow: .cashIn,
            shortText: "Mock \(scanCount)",
            longText: longText,
            closing_id: nil
            )
        return ReportRecord(
            record: record,
            closing: nil,
            // Randomly select scanCount scan images
            scanFilename: Array(allImageFilenames().shuffled().prefix(scanCount))
        )
    }
}

struct ReportRecords {
    static func mocks(count: Int = 6) -> [ReportRecord] {
        var reportRecords: [ReportRecord] = []
        for i in 0..<count + 1 {
            let reportRecord = ReportRecord.mock(scanCount: i)
            reportRecords.append( reportRecord )
        }
        return reportRecords
    }
    
    /// Group ReportRecords by Closing
    ///
    /// - Use it to print out reportings paginated by closings
    ///
    static func groupedByClosing(reportRecords: [ReportRecord]) -> [Closing: [ReportRecord]] {
        let emptyClosing = Closing()
        let groupedClosingReportRecords: [Closing: [ReportRecord]]   =
        Dictionary(grouping: reportRecords, by: { $0.closing ?? emptyClosing} )
        return groupedClosingReportRecords
    }
}
