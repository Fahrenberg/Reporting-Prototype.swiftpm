#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import TPPDF
import ImageCompressionKit
import Extensions
import CoreGraphics

struct SingleBookingReport: Report {
    let reportRecord: ReportRecord
    
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
       
        // not really a header is in the content area....
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
        document.add(.contentCenter, text: "Single Booking Report")
        document.add(space: 10.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: style)
        document.add(space: 10.0)
        
        document.add(.contentLeft, text: reportRecord.text)
        let amountFormatted = reportRecord.amount.formatted(
            .number
                .grouping(.automatic)
                .precision(.fractionLength(2...2))
        )
        document.add(.contentCenter, text: amountFormatted)
        
        return [document]
    }
}
