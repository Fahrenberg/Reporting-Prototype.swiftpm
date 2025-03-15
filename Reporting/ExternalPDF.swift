import SwiftUI
import TPPDF

struct ExternalPDF: Report {
    func addReport(to document: PDFDocument) {
        
    }
        
    func generateDocument() -> [PDFDocument] {
         let document = PDFDocument(format: .a4)
         let bundle = Bundle.module
         guard let pdfURL = bundle.url(forResource: "roche", withExtension: "pdf") 
         else { 
             print("roche.pdf not found")
             return [document] }
         let pdf = PDFExternalDocument(url: pdfURL)
         document.add(externalDocument: pdf)
         return [document]
     }
}
