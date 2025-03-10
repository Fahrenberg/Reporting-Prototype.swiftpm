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
    
    
    func generateDocument() -> [PDFDocument] {
        
        
        let size = CGSize(width: 100, height: 100)
        let path = PDFBezierPath(ref: CGRect(origin: .zero, size: size))
        path.move(to: PDFBezierPathVertex(position: CGPoint(x: size.width / 2, y: 0),
                                          anchor: .topCenter))
        path.addLine(to: PDFBezierPathVertex(position: CGPoint(x: size.width, y: size.height / 2),
                                             anchor: .middleRight))
        path.addLine(to: PDFBezierPathVertex(position: CGPoint(x: size.width / 2, y: size.height),
                                             anchor: .bottomCenter))
        path.addLine(to: PDFBezierPathVertex(position: CGPoint(x: 0, y: size.height / 2),
                                             anchor: .middleLeft))
        path.close()
        
        let shape = PDFDynamicGeometryShape(path: path, fillColor: .white, stroke: .init(type: .full, color: .red, width: 5.0, radius: 0))

        // Create the group object and set the background color and shape
        let group = PDFGroup(allowsBreaks: false,
                             backgroundColor: .lightGray,
                             backgroundShape: shape,
                             padding: EdgeInsets(top: 200, left: 200, bottom: 200, right: 200)
                            )
        
        
        group.add(text: " ddddd ")
        document.add(group: group)
        
        
        
        return [document]
    }
}
