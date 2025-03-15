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
    
    private let document = PDFDocument(format: .a4)
    // Scans
    var scansSize: CGSize {
        let documentContentWidth = document.layout.width
        - document.layout.margin.left
        - document.layout.margin.right
        
//        let documentContentHeight =  document.layout.height
//        - document.layout.margin.top
//        - document.layout.margin.bottom
        
        return CGSize(
            width: documentContentWidth,
            height: 275
        )
    }
    
    private var logo: PDFImage {
        let logoSize = CGSize(width: 250, height: 47)
        guard let resizedImage = logoImage.resized(to: logoSize, alignment: .right)
        else { fatalError() }
        let finalImage = resizedImage.fillFrame(frameColor: .white).addFrame(frameColor: .lightGray)
        return PDFImage(image: finalImage, options: [.none])
    }
    
    private let lineStyle = PDFLineStyle(type: .full, color: .purple, width: 1.0)
   
    func addReport(to document: PDFDocument) {
        
    } 
    
    func generateDocument() -> [PDFDocument] {
        // Pagination
        document.add(.footerRight, text: "Date")
        let pagination = PDFPagination(container: .footerCenter)
        document.pagination = pagination
        //
        
        
        let groupBorder = PDFGroup(
            allowsBreaks: true,
            backgroundColor: .clear, 
            outline: lineStyle, 
            padding: EdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        )
            .addBorderShapeRectangle(size: scansSize, color: .blue)
        
        for _ in 0..<5 { 
            groupBorder.add(image: logo)
        }
        document.add(text: "--- first start ---- ")
        document.add(group: groupBorder)
        document.add(space: 50)
                document.add(text: "--- first end ---- ")
        
        
        document.createNewPage()
        document.add(text: "--- second start ---- ")

        let groupOutline = PDFGroup(
            allowsBreaks: true,
            backgroundColor: .clear, 
            outline: lineStyle,
            padding: EdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        )
            .addBorderShapeRectangle(size: scansSize, color: .blue)
        
        for _ in 0..<5 { 
            groupOutline.add(image: logo)
        }
        document.add(group: groupOutline)
        document.add(space: 10)
        document.add(text: "--- second finished ---- ")
        
        
        document.createNewPage()
        document.add(text: "--- thrid start ---- ")
        
        let group = PDFGroup(
            allowsBreaks: true,
            backgroundColor: .clear, 
            outline: lineStyle,
            padding: EdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        )
            .addBorderShapeRectangle(size: scansSize, color: .blue)
        
        for _ in 0..<5 { 
            group.add(image: logo)
        }
        document.add(group: group)
        document.add(space: 10)
        document.add(text: "--- thrid finished ---- ")
        
        return [document]
    }
}
