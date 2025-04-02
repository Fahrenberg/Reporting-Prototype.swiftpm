//
//  ------------------------------------------------------------
//  ---------------         PDFReporting          --------------
//  ---------------                               --------------
//  ------------------------------------------------------------
import Foundation
import Extensions
import TPPDF
import OSLog


public protocol PDFReporting {
    /// PDF Paper Size
    ///
    var paperSize: PDFPageFormat { get }
    
    /// PDF Paper Orientation
    var landscape: Bool {get }
    
    /// Adds report layout to PDFDocument
    ///
    /// Add one or mulitple report layouts into one PDFDocument
    /// to ensure continous pagination.
    ///
    /// - SeeAlso: [TPPDF Documentation](https://github.com/techprimate/TPPDF/blob/269dd6627b5ade0f9de600723a001bd419f6ebf5/Documentation/Usage.md)
    ///
    func addReport(to document: PDFDocument) async
    
    /// Complete document with optional document header and footer
    /// Content added with addReport
    func addDocument(to document: PDFDocument) async
    
}
extension PDFReporting {
    /// Create Data from PDFDocument
    ///
    /// - Parameters:
    ///     -  debugFrame: shows dotted lines around PDF elements.
    ///                    default == `false`
    ///
    public func data(debugFrame: Bool = false) async -> Data? {
        let pdfDocuments = await generateDocument()
        let generator: PDFGeneratorProtocol?  // Define generator variable outside switch
        
        switch pdfDocuments.count {
        case 0:
            return nil
        case 1:
            generator = PDFGenerator(document: pdfDocuments.first!)
        case let count where count > 1:
            generator = PDFMultiDocumentGenerator(documents: pdfDocuments)
        default:
            return nil
        }
        
        guard let generator = generator else { // Use the generator safely
            return nil
        }
        generator.debug = debugFrame
        do {
            let data = try generator.generateData()
            return data
        } catch {
            return nil
        }
    }
    
    /// Write PDFDocument with default filename to module temporary directory
    public func write() async -> URL? {
        guard let data = await data() else {
            return nil
        }
        return data.write(ext: "pdf")
    }
    
    /// Generates a instance of PDFDocument with basic layout definition
    ///
    /// Papersize from Report `papersize`
    /// Print orientation from Repor `landscape`.
    /// White paper background and black printing.
    ///
    func generateDocument() async -> [PDFDocument] {
        let document = PDFDocument(format: paperSize)
        if landscape {
            document.layout.size = PDFPageFormat.a4.landscapeSize
        }
        document.background.color = .white
        await addDocument(to: document)
        return [document]
    }
}


