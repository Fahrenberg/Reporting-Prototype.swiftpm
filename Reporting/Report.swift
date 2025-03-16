//
//  Report.swift
//  PDF-Reporting
//
//  Created by Jean-Nicolas on 31.01.2025.
//
import Foundation
import TPPDF
import OSLog

public protocol Report {
    /// PDF Paper Size
    ///
    var paperSize: PDFPageFormat { get set}
    
    /// PDF Paper Orientation
    var landscape: Bool {get set }
    /// Adds report layout to PDFDocument
    ///
    /// Can be used to add mulitple reports into one PDFDocument
    /// and ensure correct pagination
    func addReport(to document: PDFDocument)
}
extension Report {
    /// Create Data from PDF Document
    public func data(debugFrame: Bool = false) -> Data? {
        let pdfDocuments = generateDocument()
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
    
    /// Write PDF Document with default filename to module temporary  directory
    public func write() -> URL? {
        guard let data = data() else {
            return nil
        }
        return data.write(ext: "pdf")
    }
    
    /// Generates a instance of PDFDocument with basic layout definition
    func generateDocument() -> [PDFDocument] {
        let document = PDFDocument(format: paperSize)
        if landscape {
            document.layout.size = PDFPageFormat.a4.landscapeSize
        }
        document.background.color = .white
        addReport(to: document)
        return [document]
    }
}

// Internal Extensions

fileprivate extension Data {
    /// Write ````Data```` to temp file.
    ///
    /// - returns: URL to temp file.
    func write(ext: String) -> URL? {
        do {
            let fileURL = fileURL(ext: ext)
            try self.write(to: fileURL, options: .atomic)
            return fileURL
        }
        catch {
            return nil
        }
    }
    private func fileURL(ext: String) -> URL {
        let subDirectory = FileManager().temporaryDirectory.appendingPathComponent(Logger.subsystem)
        try? FileManager.createDirectory(at: subDirectory)
        let filename = "PDF-Reporting.\(ext)"
        let cleanFilename = filename.replacingOccurrences(of: ":", with: "-")   // .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? filename
        return subDirectory.appending(path: cleanFilename)
        
        
    }
}
