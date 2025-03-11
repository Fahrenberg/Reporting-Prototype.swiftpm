//
//  PDFRectangleGroup.swift
//  Extenstion
//  Reporting-Prototype
//
//  Created by Jean-Nicolas on 11.03.2025.
//

import TPPDF
import UIKit




extension PDFGroup {
    static func withRectangleBorder(size: CGSize, color: UIColor) -> PDFGroup {
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
            stroke: .init(type: .full, color: .brown, width: 5.0, radius: 0)
        )
        
        // Create the group object and set default values
        let group = PDFGroup(allowsBreaks: true,
                             backgroundColor: .none,
                             backgroundShape: shape,
                             padding: EdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        )
        return group
    }
}
