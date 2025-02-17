import SwiftUI
import TPPDF

struct RecordReport: Report {
     func generateDocument() -> PDFDocument {
         let document = PDFDocument(format: .a4)
         document.add(.contentCenter, text: "Stub RecordReport")
         document.add(space: 10.0)
         let style = PDFLineStyle(type: .full, color: .darkGray, width: 0.5)
         document.addLineSeparator(PDFContainer.contentLeft, style: style)
         return document
     }
}
