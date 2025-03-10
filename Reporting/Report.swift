//
//  Report.swift
//  PDF-Reporting
//
//  Created by Jean-Nicolas on 31.01.2025.
//
import Foundation
import TPPDF
import OSLog

protocol Report {
    func generateDocument() -> [PDFDocument]
}

extension Report {
    /// Create Data from PDF Document 
    func data() -> Data? {
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
        generator.debug = true
        do {
            let data = try generator.generateData()
            return data
        } catch {
            return nil
        }
    }


    
    /// Write PDF Document with default filename to module temporary  directory
    func write() -> URL? {
        guard let data = data() else {
            return nil
        }
        return data.write(ext: "pdf")
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
