import Foundation
import TPPDF
import Extensions
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct Record: Hashable, Identifiable {
    
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
