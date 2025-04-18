import Foundation
import TPPDF
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Preset Styles and Fonts for all reports
enum PDFReportingStyle {
    static let dividerLine: PDFLineStyle = PDFLineStyle(type: .full, color: .darkGray, width: 0.5)
    static let title = Font.systemFont(ofSize: 20, weight: .bold)
    static let regular = Font.systemFont(ofSize: 10, weight: .regular)
    static let bold = Font.systemFont(ofSize: 10, weight: .bold)
    static let footerRegular = Font.systemFont(ofSize: 10, weight: .regular)
    static let footerBold = Font.systemFont(ofSize: 10, weight: .bold)
#if canImport(UIKit)
    static  let digit = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
    static  let digitBold = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
#elseif canImport(AppKit)
    static  let digit = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
    static  let digitBold = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
#endif
}

