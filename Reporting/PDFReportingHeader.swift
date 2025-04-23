//
//  PDFReportingHeader.swift
//  Reporting-Prototype
//
//  Created by Jean-Nicolas on 02.04.2025.
//
import Foundation
import Extensions
import TPPDF

public protocol PDFReportingHeader {
    ///  Customised Report Header layout
    func add(to document: PDFDocument) async
    /// Height of header in pixel
    var height: CGFloat { get }
}

public struct PDFEmptyHeader: PDFReportingHeader {
    public func add(to document: PDFDocument) async {}
    public let height: CGFloat = 0
}

/// Default implementation of PDF header
///
/// - Parameters:
///     -  logoImage: logo to show in the right corner (300px x 70px)
public struct PDFLogoImageHeader: PDFReportingHeader {
    ///  Report Logo shown in  header
    public let logoImage: PlatformImage
    /// Logo Header Implementation
    public func add(to document: PDFDocument) async {
        let logoSize = CGSize(width: 300, height: height)
        var logo: PDFImage {
            guard let resizedImage = logoImage.resized(to: logoSize, alignment: .right)
            else { fatalError() }
            let finalImage = resizedImage.fillFrame(frameColor: .white).addFrame(frameColor: .lightGray)
            return PDFImage(image: finalImage, options: [.none])
        }
        // Logo Header
        document.add(.headerRight, image: logo)
    }
    public let height: CGFloat = 70
}
