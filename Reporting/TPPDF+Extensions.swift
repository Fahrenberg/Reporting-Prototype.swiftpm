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
extension PDFDocument {
    /// Calculates the height of the given text when displayed within a specified width, using a given font.
    ///
    /// This function uses `boundingRect(with:options:attributes:context:)` to determine the required height for rendering
    /// the text within the provided width, accounting for the specified font attributes. It returns the height in pixels,
    /// rounding up to the nearest whole number.
    ///
    /// - Parameters:
    ///   - text: The string of text whose height is to be calculated.
    ///   - width: The fixed width (in pixels) within which the text will be displayed.
    ///   - font: The font used to render the text. This defines the text's size and style.
    /// 
    /// - Returns: The height in pixels required to display the text within the given width, rounded up to the nearest whole number.
    ///
    func calculateTextHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let boundingRect = NSString(string: text).boundingRect(
            with: constraintSize,
            options: options,
            attributes: attributes,
            context: nil
        )
        
        return ceil(boundingRect.height)
    }
}
