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

public struct ReportRecord {
    let record: Record
    let scanFilename: [String]
    
    var scansData: [Data] { 
        return scanFilename.map { imageData(filename: $0)}
    }
    static func mock(scanCount: Int = 5) -> ReportRecord {
        let record = Record(
            date: Date().addingTimeInterval(Double.random(in: -1_000_000_000 ... 0)),
            icon: "truck.box",
            amount: Double.random(in: 1000.0 ... 10000.00),
            cashFlow: .cashIn,
            shortText: "Mock \(scanCount)",
            longText: "Mock Report Record with \(scanCount) scan(s)"
            )
        return ReportRecord(
            record: record,
            // Randomly select scanCount scan images
            scanFilename: Array(allImageFilenames().shuffled().prefix(scanCount))
        )
    }
}

struct ReportRecords {
    static func mocks(count: Int = 6) -> [ReportRecord] {
        var reportRecords: [ReportRecord] = []
        for i in 0..<count {
            let reportRecord = ReportRecord.mock(scanCount: i)
            reportRecords.append( reportRecord )
        }
        return reportRecords
    }
}

public struct Record {
    
    public init(id: UUID = UUID(),
                date: Date = Date(),
                icon: Icon? = nil,
                hexColor: HexColor? = nil,
                amount: Double = 0.0,
                cashFlow: CashFlow = .cashIn,
                shortText: String = "",
                longText: String = "",
                closing_id: UUID? = nil) {
        self.id = id
        self.date = date
        self.icon = icon ?? defaultSFSymbol
        let recordColor = hexColor ?? defaultHexColor // nil = default
        self.hexColor = recordColor.hexColor ?? errorColor // invalid hex string = error
        self.amount = amount
        self.cashFlow = cashFlow
        self.shortText = shortText
        self.longText = longText
        self.closing_id = closing_id
    }
    
    
    public var id:UUID
    public var date: Date
    public var icon: String
    public var hexColor: HexColor
    public var amount: Double
    public var cashFlow: CashFlow
    public var shortText: String
    public var longText: String
    public var closing_id: UUID?
    
    public var signedAmount: Double { amount * (cashFlow == CashFlow.cashIn ? 1.0 : -1.0)}
    
    func convertToRecord() -> Record { return self }
}
// MARK: Alias Types
public typealias HexColor = String
public typealias recordID = UUID
public typealias Icon = String
//
//  -------------------------------------------------------------------
//  ---------------           Cash Flow  Model           --------------
//  ---------------                                      --------------
//  -------                    RuKa                             -------
//  -------------------------------------------------------------------
//

import Foundation

public enum CashFlow: String, CaseIterable, Codable  {
    case cashIn = "Einzahlung"
    case cashOut = "Auszahlung"
}

extension CashFlow: Identifiable {
    public var id: Self { self }
}
let defaultSFSymbol: Icon = "questionmark.square.fill"
let defaultHexColor: HexColor = "#34C759".hexColor!
let errorColor: HexColor = "#00000000".hexColor! // clear color alpha = 0
