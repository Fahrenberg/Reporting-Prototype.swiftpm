#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import TPPDF
import ImageCompressionKit
import Extensions
import CoreGraphics

struct BoxLogoReport: Report {
    
    private let style = PDFLineStyle(type: .full, color: .darkGray, width: 0.5)
    private let logoSize = CGSize(width: 200, height: 70)
    
    
    private var logo: PDFImage {
        guard let resizedImage = logoImage.resized(to: logoSize),
              let finalImage = resizedImage.replacingTransparentPixels(with: .white)
        else { fatalError() }
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
//        document.add(.headerRight, image: PDFImage(image: logoImage, size: logoSize, options: .rounded))
        
        document.addLineSeparator(PDFContainer.contentLeft, style: style)
        document.add(space: 10.0)
        document.add(.contentCenter, text: "Box and Logo Report")
        document.add(space: 10.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: style)
        document.add(space: 10.0)
        
      
        let size = CGSize(width: 500, height: 300)
        let path = PDFBezierPath(ref: CGRect(origin: .zero, size: size))
        path.move(to: PDFBezierPathVertex(position: CGPoint(x: 0, y: 0),
                                          anchor: .topCenter))
        path.addLine(to: PDFBezierPathVertex(position: CGPoint(x: size.width, y: 0),
                                             anchor: .topCenter))
        path.addLine(to: PDFBezierPathVertex(position: CGPoint(x: size.width , y: size.height),
                                             anchor: .topCenter))
        path.addLine(to: PDFBezierPathVertex(position: CGPoint(x: 0, y: size.height),
                                             anchor: .bottomCenter))
        path.close()
        
        let shape = PDFDynamicGeometryShape(path: path, fillColor: .yellow, stroke: style)

        let boxGroup = PDFGroup(allowsBreaks: false,
                                backgroundColor: .yellow,
                                backgroundShape: shape
        )
        boxGroup.add(.center, text: "anchor .topCenter to keep size in points, to flex .bottomCenter ")
       
        
        document.add(.contentLeft, group: boxGroup)
        document.add(.contentLeft, text: " not after group ")
        
//        document.add(.contentLeft, text: "DREI")
        return [document]
    }
}
