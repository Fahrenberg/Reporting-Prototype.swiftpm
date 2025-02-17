//
//  MultipleLargeImageReport.swift
//  PDF-Reporting
//
//  Created by Jean-Nicolas on 31.01.2025.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import TPPDF
import ImageCompressionKit
import Extensions

struct MultipleLargeImageReport: Report {
    let imagesData: [Data]
    
    func generateDocument() -> [PDFDocument] {
        let pdfDoc = PDFDocument(format: .a4)
        pdfDoc.background.color = .lightGray
        
        
        let pdfImages: [PDFImage] = imagesData.enumerated().compactMap { (index, data) in
            let size = CGSize(width: pdfDoc.layout.width / 2 - 10,
                              height:pdfDoc.layout.height / 2 - 100 )
           
            guard let image = PlatformImage(data: data),
                  let resizedImage = image.resized(to: size),
                  let finalImage = resizedImage.replacingTransparentPixels(with: .lightGray)
            else { return nil }
            let pdfImage = PDFImage(image: finalImage)
            let finalDataSize = finalImage.jpgDataCompression()?.count ?? 0
            
            let caption =  PDFSimpleText(text: "\(index + 1) - \(data.count.outputMBytes) - \(finalDataSize.outputMBytes)") // Index as caption (1-based)
            pdfImage.caption = caption
            pdfImage.quality = 1.0
            return pdfImage
        }
        pdfDoc.set(textColor: .white)
        pdfDoc.set(font: .systemFont(ofSize: 30, weight: .bold))
        pdfDoc.add(text: "MultipleLargeImageReport")
        pdfDoc.set(font: .systemFont(ofSize: 14, weight: .regular))
        let imagesSize = imagesData.reduce(0) { $0 + $1.count}
        pdfDoc.add(text: "\(imagesData.count) images with total size of \(imagesSize.outputMBytes)")
        pdfDoc.add(space: 20)
        
        
        let fourPDFImages = pdfImages.chunked(into: 4)
        for pdfImages in fourPDFImages {
            let group = PDFGroup(allowsBreaks: false)
            let twoPDFImages = pdfImages.chunked(into: 2)
            for imgRow in twoPDFImages {
                group.add(imagesInRow:  imgRow, spacing: 10)
                group.add(space: 10)
            }
            pdfDoc.add(group: group)
            pdfDoc.createNewPage()
            pdfDoc.add(space: 50)
        }
        return [pdfDoc]
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, self.count)])
        }
    }
}
