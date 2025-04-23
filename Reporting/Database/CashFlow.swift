//
//  -------------------------------------------------------------------
//  ---------------           Cash Flow  Model           --------------
//  ---------------                                      --------------
//  -------                    RuKa                             -------
//  -------------------------------------------------------------------
//

import Foundation

public enum CashFlow: String, CaseIterable  {
    case cashIn = "Einzahlung"
    case cashOut = "Auszahlung"
}

extension CashFlow: Identifiable {
    public var id: Self { self }
}
let defaultSFSymbol: Icon = "questionmark.square.fill"
let defaultHexColor: HexColor = "#34C759".hexColor!
let errorColor: HexColor = "#00000000".hexColor! // clear color alpha = 0
