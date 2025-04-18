import SwiftUI
import TPPDF

struct ExternalPDF: PDFReporting {
    
    public var paperSize: PDFPageFormat = .a4
    public var landscape: Bool = false
    
    // No document header or footer
    func addReport(to document: PDFDocument) {
        let bundle = Bundle.module
        guard let pdfURL = bundle.url(forResource: "roche", withExtension: "pdf")
        else {
            print("roche.pdf not found")
            return }
        let pdf = PDFExternalDocument(url: pdfURL)
        document.add(externalDocument: pdf)
    }
}
