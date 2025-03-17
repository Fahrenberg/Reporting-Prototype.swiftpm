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
    
    /// Document Header layout
    ///
    /// Default header layout available
    /// can be overwritten by Report implementation
    ///
    func addHeader(to document: PDFDocument)
    
    /// Document Footer layout
    ///
    /// Default footer layout available
    /// can be overwritten by Report implementation
    ///
    func addFooter(to document: PDFDocument)
    
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
        document.set(textColor: .black)
        addHeader(to: document)
        addFooter(to: document)
        addReport(to: document)
        return [document]
    }
}

extension Report {
    public func addHeader(to document: PDFDocument) {
        let logoSize = CGSize(width: 300, height: 70)
        var logo: PDFImage {
            guard let resizedImage = logoImage.resized(to: logoSize, alignment: .right)
            else { fatalError() }
            let finalImage = resizedImage.fillFrame(frameColor: .white).addFrame(frameColor: .lightGray)
            return PDFImage(image: finalImage, options: [.none])
        }
        // Logo Header
        document.add(.headerRight, image: logo)
    }
    
    public func addFooter(to document: PDFDocument) {
        document.set(textColor: .black)
        // Footer text right
        document.addLineSeparator(.footerCenter, style: ReportStyle.dividerLine)
        document.set(.footerRight, font: ReportStyle.footerRegular)
        let date = Date()
        // Use the .dateTime format and localize to German
        let formattedDate = date.formatted(
            .dateTime
                .day(.twoDigits)
                .month(.twoDigits)
                .year(.defaultDigits)
                .hour(.defaultDigits(amPM: .abbreviated))
                .minute(.defaultDigits)
        )
        
        let footerRightText = "Druckdatum: \(formattedDate)"
        document.add(.footerRight, text: footerRightText)
        
        // Pagination
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        
        let pagination = PDFPagination(
            container: .footerCenter,
            style: PDFPaginationStyle.customNumberFormat(template: "%@/%@",
                                                         formatter: numberFormatter),
            textAttributes: [.font: ReportStyle.footerRegular,
                             .foregroundColor: Color.black]
        )
        document.pagination = pagination
        
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
