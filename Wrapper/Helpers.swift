//
//  ------------------------------------------------------------
//  ---------------            Helpers            --------------
//  ---------------                               --------------
//  ------------------------------------------------------------

import Foundation
import OSLog
import Extensions
import ImageCompressionKit
import TPPDF

public var exampleImageData: Data {
    let bundle = Bundle.main
    let imageURL = bundle.url(forResource: "large", withExtension: "png")
    return try! Data(contentsOf: imageURL!)
}

public func imageData(filename: String = "0A0BFAFA-90DD-40D4-97A3-E6FDA59128C2") -> Data {
    let bundle = Bundle.main
    guard let imageURL = bundle.url(forResource: filename, withExtension: "png")
            else { 
        return Data() }
    return try! Data(contentsOf: imageURL)
}
public func allImageFilenames() -> [String] {
    let bundle = Bundle.main
    guard let allImagesURL = bundle.urls(forResourcesWithExtension: "png", subdirectory: nil) else { return [] }
    return allImagesURL
        .map { $0.deletingPathExtension().lastPathComponent }
        .filter { !$0.contains("AppIcon") } // Exclude AppIcon, Swift Playground flattens Resources files
}


public func allImageData() -> [Data] {
    return allImageFilenames().map { filename in
        return imageData(filename: filename)
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

extension PDFDocument: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        return "size \(self.layout.height) h x \(self.layout.width) w, margin \(self.layout.margin)"
    }
}

public extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, self.count)])
        }
    }
}

extension Data {
    /// Write ````Data```` to temp file.
    ///
    /// - returns: URL to temp file.
    func write(ext: String) -> URL? {
        do {
            let fileURL = fileURL(ext: ext)
            try self.write(to: fileURL, options: .atomic)
            return fileURL
        }
        catch {
            return nil
        }
    }
    private func fileURL(ext: String) -> URL {
        let subDirectory = FileManager().temporaryDirectory.appendingPathComponent(Logger.subsystem)
        try? FileManager.createDirectory(at: subDirectory)
        let filename = "PDF-Reporting.\(ext)"
        let cleanFilename = filename.replacingOccurrences(of: ":", with: "-")   // .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? filename
        return subDirectory.appending(path: cleanFilename)
        
        
    }
}
