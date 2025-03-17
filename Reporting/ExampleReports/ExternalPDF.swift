import SwiftUI
import TPPDF

struct ExternalPDF: Report {
    public var paperSize: PDFPageFormat = .a4
    public var landscape: Bool = false
    
    public let showHeaderFooter: Bool = false
    
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
