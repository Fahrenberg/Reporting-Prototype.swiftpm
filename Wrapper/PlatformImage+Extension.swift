//
//  PlatformImage+Extension.swift
//  Reporting
//
//  Created by Jean-Nicolas on 25.03.2025.
//
import Extensions
import Foundation
// PlatformImage for macOS and iOS
#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

extension PlatformImage {
    static func image(named: String) -> PlatformImage? {
        let bundle = Bundle.module
        guard let imageURL = bundle.url(forResource: named, withExtension: nil) else {
            return nil
        }
        
        #if canImport(UIKit)
        return UIImage(contentsOfFile: imageURL.path)
        #elseif canImport(AppKit)
        return NSImage(contentsOf: imageURL)
        #endif
    }
}
