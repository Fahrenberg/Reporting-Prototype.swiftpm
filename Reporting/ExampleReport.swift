//
//  ExampleReport.swift
//  TPPDF_Example
//
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import TPPDF
import ImageCompressionKit
import Extensions
import OSLog

struct ExampleReport: Report {
    func generateDocument() -> PDFDocument {
        let document = PDFDocument(format: .a4)
        document.background.color = .systemBrown
        
        document.set(.contentCenter, textColor: .white)
        document.set(.contentCenter, font: .systemFont(ofSize: 30, weight: .bold))
        document.add(.contentCenter, text: "ExampleReport")
        document.add(.contentCenter, space: 20)
        document.add(.contentCenter, text: "Create PDF documents easily.")
        
        document.createNewPage()

        let targetSize = CGSize(width: document.layout.width - 50,
                                height: document.layout.width - 50)
        
        guard let image = PlatformImage(data: imageData(filename: "1556181D-AF21-468E-9B17-72FA7469D469")),
              let resizedImage = image.resized(to: targetSize * 2),
              let finalImage = resizedImage.replacingTransparentPixels(with: .brown )
        else {
            Logger.source.critical("image is nil")
            print("image is nil")
            return document 
        }
        
        
        let pdfImage = PDFImage(image: finalImage ,
                                size: targetSize * 2,
                                quality: 1.0,
                                options: [.rounded],
                                cornerRadius: 25)
        document.set(.contentCenter, textColor: .blue)
        for i in (0..<5) {
            document.add(.contentCenter, text: "Resized Image \(i)")
            document.add(.contentCenter, space: 20)
            document.add(.contentCenter, image: pdfImage)
            if i < 4 { document.createNewPage() }
        }
        
        return document
    }
}

