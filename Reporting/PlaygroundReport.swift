#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import TPPDF
import ImageCompressionKit
import Extensions
import CoreGraphics

struct PlaygroundReport: Report {
    
    func generateDocument() -> [PDFDocument] {
        let document = PDFDocument(format: .a4)
        
        document.add(.contentLeft, text: "PlaygroundReport")
        
        return [document]
    }
}
