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
    private let logoSize = CGSize(width: 100, height: 50)
    
    
    private var logo: PDFImage {
        guard let resizedImage = logoImage.resized(to: logoSize, alignment: .right)
        else { fatalError() }
        let finalImage = resizedImage.fillFrame(frameColor: .white).addFrame(frameColor: .lightGray)
        return PDFImage(image: finalImage)
    }

    
    func generateDocument() -> [PDFDocument] {
        let document = PDFDocument(format: .a4)
       
        // Logo Header
        document.add(.contentRight, image: logo)
        document.add(space: 20.0)
        
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
