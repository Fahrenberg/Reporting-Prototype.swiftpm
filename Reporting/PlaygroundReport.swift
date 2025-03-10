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
        CGSize(width: document.layout.width
               - document.layout.margin.left
               - document.layout.margin.right,
               height: document.layout.height
               - document.layout.margin.top
               - document.layout.margin.bottom
               -  10 // Spacer before scans
               - 200 // Report info & header
        )
    }
    
    private var logo: PDFImage {
        let logoSize = CGSize(width: 150, height: 47)
        guard let resizedImage = logoImage.resized(to: logoSize, alignment: .right)
        else { fatalError() }
        let finalImage = resizedImage.fillFrame(frameColor: .white).addFrame(frameColor: .lightGray)
        return PDFImage(image: finalImage, options: [.none])
    }
    
    private func redRectangle(size: CGSize) -> PDFGroup {
        let path = PDFBezierPath(ref: CGRect(origin: .zero, size: size))
        path.move(to: PDFBezierPathVertex(
            position: CGPoint.zero,
            anchor: .topLeft)
        )
        path.addLine(to: PDFBezierPathVertex(
            position: CGPoint(x: size.width, y: 0), 
            anchor: .topLeft)
        )
        path.addLine(to: PDFBezierPathVertex(
            position: CGPoint(x: size.width, y: size.height),
            anchor: .topLeft)
        )
        path.addLine(to: PDFBezierPathVertex(
            position: CGPoint(x: 0, y: size.height),
            anchor: .topLeft)
        )
        path.addLine(to: PDFBezierPathVertex(
            position: CGPoint(x: 0, y: 0), 
            anchor: .topLeft)
        )
        
        path.close()
        
        let shape = PDFDynamicGeometryShape(
            path: path, 
            fillColor: .clear,
            stroke: .init(type: .full, color: .green, width: 2.0, radius: 0)
        )
        
        // Create the group object and set the background color and shape
        let group = PDFGroup(allowsBreaks: false,
                             backgroundColor: .none,
                             backgroundShape: shape
        ) 
        return group
    }
    
    func generateDocument() -> [PDFDocument] {
        let group = redRectangle(size: CGSize(width: 200, height: 300))
        group.add(space: 50)
        group.set(indentation: 30, left: true)
        group.add(image: logo)
        document.add(group: group)
        
        return [document]
    }
}
