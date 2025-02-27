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
    private var cashFlowFormatted: PDFSimpleText {
        PDFSimpleText(text: reportRecord.cashFlow)
  }
    
    private var amountFormatted: String { 
        let amountValue = Decimal(reportRecord.amount) // Ensure Decimal type
        return "CHF " + amountValue.formatted(
            .number
            .precision(.fractionLength(2...2))
            .sign(strategy: .always()) // Ensures + or - sign
        )
    }
    private var dateFormatted: String {
        return reportRecord.date.formatted(
            date: .long, 
            time: .omitted)
    }
    
    private var iconImage: PDFImage {
        let symbolSize = CGSize(width: 20, height: 20)
       let symbolImage = UIImage(systemName: reportRecord.icon) ?? UIImage(systemName: "questionmark")!
        guard let resizedImage = symbolImage.resized(to: symbolSize, alignment: .left)
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
        document.set(font: SingleBookingFonts.bold)
        document.add(.contentLeft, textObject: cashFlowFormatted)
        document.set(font: SingleBookingFonts.regular)
        document.add(.contentRight, text: dateFormatted) 
        document.add(.contentRight, text: amountFormatted)
        document.add(.contentLeft, image: iconImage)
        document.add(.contentLeft, text: reportRecord.text)
        document.add(space: 10.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: style)
        document.add(space: 10.0)
        

        
       
        
        return [document]
    }
}


fileprivate struct SingleBookingFonts {
    static let title = Font.systemFont(ofSize: 30, weight: .bold)
    static let regular = Font.systemFont(ofSize: 15, weight: .regular)
    static  let bold = Font.systemFont(ofSize: 15, weight: .bold)
#if canImport(UIKit)
    static  let digit = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
    static  let digitBold = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .bold)
#elseif canImport(AppKit)
    static  let digit = NSFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
    static  let digitBold = NSFont.monospacedDigitSystemFont(ofSize: 15, weight: .bold)
#endif
}
