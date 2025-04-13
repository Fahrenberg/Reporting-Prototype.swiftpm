import SwiftUI
import TPPDF

struct ExternalPDF: PDFReporting {
    public let pdfHeader: PDFReportingHeader = PDFEmptyHeader()
    public let pdfFooter: PDFReportingFooter = PDFEmptyFooter()
    
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
    
    public func addDocument(to document: PDFDocument) async {
        pdfHeader.add(to: document)
        addReport(to: document)
        pdfFooter.add(to: document)
    }
}
