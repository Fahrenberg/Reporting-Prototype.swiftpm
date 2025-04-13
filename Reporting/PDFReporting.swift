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
    
    /// Set PDF document header
    var pdfHeader: PDFReportingHeader { get }
  
    /// Set PDF document footer
    var pdfFooter: PDFReportingFooter { get }
}
extension PDFReporting {
    /// Create PDF reporting data using the layout from addReport
    ///
    /// - Create an instance of PDFDocument with basic layout definition.
    /// - Define all pdf elements in addReport
    /// - `papersize` sets pdf paper size.
    /// - `landscape` sets print orientation.
    /// - White paper background and black printing.
    ///
    /// - Parameters:
    ///     -  debugFrame: shows dotted lines around PDF elements.
    ///                    default == `false`
    ///
    public func data(debugFrame: Bool = false) async -> Data? {
        let pdfDocument = PDFDocument(format: paperSize)
        if landscape {
            pdfDocument.layout.size = paperSize.landscapeSize
        }
        pdfDocument.background.color = .white
        await addDocument(to: pdfDocument)
        let generator: PDFGeneratorProtocol?  // Define generator variable outside switch
        generator = PDFGenerator(document: pdfDocument)
        
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
    
    /// Complete document with optional document header and footer
    /// Content added with addReport
    func addDocument(to document: PDFDocument) async {
        await pdfHeader.add(to: document)
        await addReport(to: document)
        await pdfFooter.add(to: document)
    }
    
    
}


