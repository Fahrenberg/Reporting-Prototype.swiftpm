import SwiftUI
import TPPDF

struct RecordReport: Report {
    let reportRecord: ReportRecord
    
     func generateDocument() -> [PDFDocument] {
         let document = PDFDocument(format: .a4)
         document.add(.contentCenter, text: "RecordReport")
         document.add(space: 10.0)
         let style = PDFLineStyle(type: .full, color: .darkGray, width: 0.5)
         document.addLineSeparator(PDFContainer.contentLeft, style: style)

         document.add(space: 10.0)
         document.add(.contentLeft, text: reportRecord.text)
         let amountFormatted = reportRecord.amount.formatted(
            .number
                .grouping(.automatic)
                .precision(.fractionLength(2...2))
         )
         document.add(.contentCenter, text: amountFormatted)
         
         return [document]
     }
}
