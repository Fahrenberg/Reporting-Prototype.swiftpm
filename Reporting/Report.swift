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
        return nil
        // return data.write(ext: "pdf")
    }
}
