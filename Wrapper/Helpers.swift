//
//  ------------------------------------------------------------
//  ---------------            Helpers            --------------
//  ---------------                               --------------
//  ------------------------------------------------------------

import Foundation
import OSLog
import Extensions
import ImageCompressionKit

public var exampleImageData: Data {
    let bundle = Bundle.module
    let imageURL = bundle.url(forResource: "large", withExtension: "png")
    return try! Data(contentsOf: imageURL!)
}

public func imageData(filename: String = "0A0BFAFA-90DD-40D4-97A3-E6FDA59128C2") -> Data {
    let bundle = Bundle.module
    guard let imageURL = bundle.url(forResource: filename, withExtension: "png") 
            else { 
        print("image not found: \(filename)")
        return Data() }
    return try! Data(contentsOf: imageURL)
}

public func allImageFilenames() -> [String] {
    let bundle = Bundle.module
    guard let allImagesURL = bundle.urls(forResourcesWithExtension: "png", subdirectory: nil) else { return [] }
    return allImagesURL.map { imageURL in
        imageURL.deletingPathExtension().lastPathComponent
    }
}

public func allImageData() -> [Data] {
    return allImageFilenames().map { filenme in
        return imageData(filename: filenme)
    }
}

public var logoImage: PlatformImage {
    let bundle = Bundle.module
    let imageURL = bundle.url(forResource: "Reporting-Prototype-Icon", withExtension: "jpeg")!
    let data =  try! Data(contentsOf: imageURL)
    return PlatformImage(data: data)!
}

extension Logger {
    public static let subsystem = "\(Bundle.module.bundleIdentifier!)"
    public static let source = Logger(subsystem: subsystem, category: "PDF_Reporting (main)")
}
