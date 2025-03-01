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
   
    
    func generateDocument() -> [PDFDocument] {
       return []
    }
}

