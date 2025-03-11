//
//  PDFGroup Extensions
//  Reporting-Prototype
//

import TPPDF
import UIKit

extension PDFGroup {
    /// Adding a rectangle stroke to PDFGroup, anchor is topLeft
    func addBorderShapeRectangle(size: CGSize, color: UIColor) -> PDFGroup {
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
            stroke: .init(type: .full, color: color, width: 2.0, radius: 0)
        )
        
        // Create the group object and set default values
        let group = PDFGroup(allowsBreaks: self.allowsBreaks,
                             backgroundColor: self.backgroundColor,
                             backgroundShape: shape,
                             outline: self.outline,
                             padding: self.padding
        )
        return group
    }
}
