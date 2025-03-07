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

struct ReportRecord {
    let date: Date
    let icon: String
    let text: String
    let amount: Double
    let scans: [Data]
    var cashFlow: String { amount >=  0 ? "Einzahlung" : "Auszahlung" }
    
    static var mock: ReportRecord {
        ReportRecord(
            date: Date().addingTimeInterval(Double.random(in: -1_000_000_000 ... 0)),
            icon: "truck.box",
            text: "Mock Report Record",
            amount: Double.random(in: 1000.0 ... 10000.00),
            scans: Array(allImageData().shuffled().prefix(5)) // Randomly select 5 images
        )
    }
}

struct ReportRecords {
    static func mocks(count: Int = 5) -> [ReportRecord] {
        var reportRecords: [ReportRecord] = []
        for i in 0...count {
            let reportRecord = ReportRecord.mock
            reportRecords.append( reportRecord )
        }
        return reportRecords
    }
}
