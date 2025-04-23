//
//  -------------------------------------------------------------------
//  ---------------     Closing Model                    --------------
//  ---------------                                         --------------
//  -------                    RuKa                                -------
//  -------------------------------------------------------------------


import Foundation
import OSLog


public struct Closing: Hashable, Identifiable {
    public init(id: UUID = UUID(), text: String = "", closing_date: Date = Date()) {
        self.id = id
        self.text = text
        self.closing_date = closing_date
    }
    
    public var id: UUID
    public var text: String
    public var closing_date: Date
    
    func convertToClosing() -> Closing { return self }
}
