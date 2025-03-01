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
    
    private let style = PDFLineStyle(type: .full, color: .darkGray, width: 0.5)
    private let logoSize = CGSize(width: 200, height: 70)
    
    
    private var logo: PDFImage {
        guard let resizedImage = logoImage.resized(to: logoSize)
        else { fatalError() }
        let finalImage = resizedImage.fillFrame(frameColor: .white)
        return PDFImage(image: finalImage, options: [.none])
    }
    
    
    func generateDocument() -> [PDFDocument] {
        let document = PDFDocument(format: .a4)
        
        
        let headerGroup = PDFGroup(allowsBreaks: false,
                                   backgroundColor: .green,
                                   padding: EdgeInsets(top: 2, left: 2, bottom: 2, right: 2 )
        )
        headerGroup.add(.right, image: logo)
        document.add(group: headerGroup)
        
        document.add(space: 20.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: style)
        document.add(space: 10.0)
        document.add(.contentCenter, text: "Playground Report")
        document.add(space: 10.0)
        document.addLineSeparator(PDFContainer.contentLeft, style: style)
        document.add(space: 10.0)
        
        // Test
        let imageNames = ["0B1AAB7D-93F9-4B4A-A5ED-247AA02137BD",
                          "0A0BFAFA-90DD-40D4-97A3-E6FDA59128C2",
                          "00EAA8D5-B01E-47E8-A4C9-6FF9C48B7C3C",
                          "2DF0E853-55DD-4969-B360-D034DE087740"]

        let scanSize = CGSize(width: document.layout.width / 2 - 10,
                          height:document.layout.height / 2 - 80 )
        
        let imageGroup = PDFGroup(allowsBreaks: false, backgroundColor: .white)
        var pdfImagesRow: [PDFImage] = []

        for imageName in imageNames {
            // Retrieve the image data using the image name.
            guard let reportImage = PlatformImage(data: imageData(filename: imageName)),
                  let resizedImage: PlatformImage = reportImage.resized(to: scanSize) else { continue }
            let pdfImage = PDFImage(image: resizedImage.addFrame(), options: [.none])
            pdfImagesRow.append(pdfImage)
            
            // When two images have been collected, add them as a row and reset the temporary array.
            if pdfImagesRow.count == 2 {
                imageGroup.add(.left, imagesInRow: pdfImagesRow)
                imageGroup.add(space: 5)
                pdfImagesRow.removeAll()
            }
        }

        // If there's one image left after the loop, add it as a single-image row.
        if !pdfImagesRow.isEmpty {
            imageGroup.add(.left, imagesInRow: pdfImagesRow)
        }
        
        document.add(.contentLeft, group: imageGroup)
        
        //
        return [document]
    }
}
