#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import TPPDF
import ImageCompressionKit
import Extensions


struct SingleBookingReport: Report {
    let reportRecord: ReportRecord
    
    private let style = PDFLineStyle(type: .full, color: .darkGray, width: 0.5)
    private var logo: PDFImage {
        let size = CGSize(width: 70,
                          height: 70
        )
        guard let resizedImage = logoImage.resized(to: size),
              let finalImage = resizedImage.replacingTransparentPixels(with: .white)
        else { fatalError() }
        return PDFImage(image: finalImage)
    }
    func generateDocument() -> [PDFDocument] {
        let document = PDFDocument(format: .a4)
        
        
        document.add(.headerRight, image: logo)
        
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
