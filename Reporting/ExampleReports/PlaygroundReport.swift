#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import TPPDF
import ImageCompressionKit
import Extensions
import CoreGraphics

struct PlaygroundReport: PDFReporting {
    public var paperSize: PDFPageFormat = .a4
    public var landscape: Bool = true
    
    let pdfFooter: PDFReportingFooter = PlaygroundFooter()
    let logoSize = CGSize(width: 250, height: 70)
    private var logo: PDFImage {
        let logoImage = logoImage
        guard let resizedImage = logoImage.resized(to: logoSize, alignment: .left)
        else { fatalError() }
        let finalImage = resizedImage.fillFrame(frameColor: .white).addFrame(frameColor: .lightGray)
        return PDFImage(image: finalImage, options: [.none])
    }
    
    private let lineStyle = PDFLineStyle(type: .full, color: .purple, width: 1.0)
   
    private var attributedString: NSAttributedString {
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.red
        ]
        
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.blue
        ]
        
        let firstPart = NSMutableAttributedString(
            string: "Hello",
            attributes: regularAttributes
        )
        
        let secondPart = NSMutableAttributedString(
            string: " World",
            attributes: boldAttributes
        )
        
        let thirdPart = NSMutableAttributedString(
            string: ", again",
            attributes: regularAttributes
        )
        thirdPart.addAttribute(
            .foregroundColor,
            value: UIColor.orange,
            range: NSRange(location: 0, length: thirdPart.length)
        )
        firstPart.append(secondPart)
        firstPart.append(thirdPart)
        return  firstPart
    }
    
    func addReport(to document: PDFDocument) async {
        
        // PDFTable with attributed string
        document.add(text: "--- first start ---- ")
        
        let table = PDFTable(rows: 5, columns: 2)
        table.style = PDFTableStyle()
        table.padding = 2.0
        
        
        
        for row in 0..<5 {
            let currentRow = table[row: row]
            currentRow.content = [attributedString, ""]
        }
        document.add(.contentLeft, table: table)
        document.add(text: "--- first end ---- ")
        
        // Attributed string to PDFDocument
        document.createNewPage()
        document.add(text: "--- second start ---- ")
        for _ in 0..<5 {
            document.add(attributedText: attributedString)
        }
        document.add(text: "--- second finished ---- ")
        
        
        document.createNewPage()
        document.add(text: "--- thrid start ---- ")

        let maxLogoImages = 5
        let groupImageSize = CGSize(
            width:  document.layout.width 
                    - document.layout.margin.left
                    - document.layout.margin.right,
            height: (logoSize.height + 10) * CGFloat(maxLogoImages)
        )
        let group = PDFGroup(
            allowsBreaks: true,
            backgroundColor: .clear,
            outline: lineStyle,
            padding: EdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        )
            .addBorderShapeRectangle(size: groupImageSize, color: .blue)
        
        for _ in 0..<maxLogoImages {
            group.add(image: logo)
        }
        document.add(group: group)
        document.add(space: 10)
        document.add(text: "--- thrid finished ---- ")
        
        let externalPDF = ExternalPDF()
        externalPDF.addReport(to: document)        
    }
}

fileprivate struct PlaygroundFooter: PDFReportingFooter {
    func add(to document: PDFDocument) async {
        // Footer text right
        
        document.set(.footerRight, font: PDFReportingStyle.title)
        
        let footerRightText = "PlaygroundReport"
        document.add(.footerRight, text: footerRightText)
        document.set(.footerCenter, font: PDFReportingStyle.title)
        // Pagination
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        
        let pagination = PDFPagination(
            container: .footerCenter,
            style: PDFPaginationStyle.customNumberFormat(template: "%@/%@",
                                                         formatter: numberFormatter),
            textAttributes: [
                .font: PDFReportingStyle.title,
                .foregroundColor: Color.red,
                    ]
        )
        
        
        document.pagination = pagination
        
    }
     public let height: CGFloat = 0
}
