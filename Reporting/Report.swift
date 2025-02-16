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
    func generateDocument() -> PDFDocument
}

extension Report {
    /// Create Data from PDF Document 
    func data() -> Data? {
        let pdfDocument = generateDocument()
        let generator = PDFGenerator(document: pdfDocument)
        guard let data = try? generator.generateData() else {
            return nil
        }
        return data
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
