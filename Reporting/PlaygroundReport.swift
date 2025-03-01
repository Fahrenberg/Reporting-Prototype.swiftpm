#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import TPPDF
import ImageCompressionKit
import Extensions
import CoreGraphics

struct PlaygroundReport: Report {
    
    private let style = PDFLineStyle(type: .full, color: .darkGray, width: 0.5)
    private let logoSize = CGSize(width: 200, height: 70)
    
    
    private var logo: PDFImage {
        guard let resizedImage = logoImage.resized(to: logoSize)
        else { fatalError() }
        let finalImage = resizedImage.fillFrame(frameColor: .white)
        return PDFImage(image: finalImage)
    }
    
    
    func generateDocument() -> [PDFDocument] {
        let document = PDFDocument(format: .a4)
        
        
        let headerGroup = PDFGroup(allowsBreaks: false,
                                   backgroundColor: .green,
                                   padding: EdgeInsets(top: 2, left: 2, bottom: 2, right: 2 )
        )
        headerGroup.add(.right, image: logo)
        document.add(group: headerGroup)
        
        document.add(space: 20.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: style)
        document.add(space: 10.0)
        document.add(.contentCenter, text: "Playground Report")
        document.add(space: 10.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: style)
        document.add(space: 10.0)
        
        // Test
        //
        return [document]
    }
}
