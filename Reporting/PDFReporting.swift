//
//  ------------------------------------------------------------
//  ---------------         PDFReporting          --------------
//  ---------------                               --------------
//  ------------------------------------------------------------
import Foundation
import Extensions
import TPPDF
import OSLog


public protocol PDFReporting {
    /// PDF Paper Size
    ///
    var paperSize: PDFPageFormat { get }
    
    /// PDF Paper Orientation
    var landscape: Bool {get }
    
    /// Customised Document Header layout
    ///
    /// - If ommited, uses default header layout
    ///
    /// - Can be overwritten by concrete Report implementation
    ///
    func addHeader(to document: PDFDocument)
    
    /// Customised Document Footer layout
    ///
    /// - If ommited, uses default footer layout.
    ///
    /// - Can be overwritten by concrete Report implementation.
    ///
    func addFooter(to document: PDFDocument)
    
    /// Adds report layout to PDFDocument
    ///
    /// Add one or mulitple report layouts into one PDFDocument
    /// to ensure continous pagination.
    ///
    /// - SeeAlso: [TPPDF Documentation](https://github.com/techprimate/TPPDF/blob/269dd6627b5ade0f9de600723a001bd419f6ebf5/Documentation/Usage.md)
    ///
    func addReport(to document: PDFDocument) async
    
    /// Shows document Header and Footer (default)
    ///
    /// Set to false when adding external pdf to avoid empty blank page.
    var showHeaderFooter: Bool { get }
}
extension PDFReporting {
    /// Create Data from PDFDocument
    ///
    /// - Parameters:
    ///     -  debugFrame: shows dotted lines around PDF elements.
    ///                    default == `false`
    ///
    public func data(debugFrame: Bool = false) async -> Data? {
        let pdfDocuments = await generateDocument()
        let generator: PDFGeneratorProtocol?  // Define generator variable outside switch
        
        switch pdfDocuments.count {
        case 0:
            return nil
        case 1:
            generator = PDFGenerator(document: pdfDocuments.first!)
        case let count where count > 1:
            generator = PDFMultiDocumentGenerator(documents: pdfDocuments)
        default:
            return nil
        }
        
        guard let generator = generator else { // Use the generator safely
            return nil
        }
        generator.debug = debugFrame
        do {
            let data = try generator.generateData()
            return data
        } catch {
            return nil
        }
    }
    
    /// Write PDFDocument with default filename to module temporary directory
    public func write() async -> URL? {
        guard let data = await data() else {
            return nil
        }
        return data.write(ext: "pdf")
    }
    
    /// Generates a instance of PDFDocument with basic layout definition
    ///
    /// Papersize from Report `papersize`
    /// Print orientation from Repor `landscape`.
    /// White paper background and black printing.
    ///
    func generateDocument() async -> [PDFDocument] {
        let document = PDFDocument(format: paperSize)
        if landscape {
            document.layout.size = PDFPageFormat.a4.landscapeSize
        }
        document.background.color = .white
        if showHeaderFooter {
            document.set(textColor: .black) // for external documents no textcolor must be set
            addHeader(to: document)
            addFooter(to: document)
        }
        await addReport(to: document)
        return [document]
    }
}

extension PDFReporting {
    /// Default Document Header layout
    public func addHeader(to document: PDFDocument) {
        // keep empty, add PDFReportingHeader or concrete addHeaderImplementation
    }
    /// Default Document Footer layout
    public func addFooter(to document: PDFDocument) {
        document.set(textColor: .black)
        // Footer text right
        document.addLineSeparator(.footerCenter, style: PDFReportingStyle.dividerLine)
        document.set(.footerRight, font: PDFReportingStyle.footerRegular)
        let date = Date()
        // Use the .dateTime format and localize to German
        let formattedDate = date.formatted(
            .dateTime
                .day(.twoDigits)
                .month(.twoDigits)
                .year(.defaultDigits)
                .hour(.defaultDigits(amPM: .abbreviated))
                .minute(.defaultDigits)
        )
        
        let footerRightText = "Druckdatum: \(formattedDate)"
        document.add(.footerRight, text: footerRightText)
        
        // Pagination
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        
        let pagination = PDFPagination(
            container: .footerCenter,
            style: PDFPaginationStyle.customNumberFormat(template: "%@/%@",
                                                         formatter: numberFormatter),
            textAttributes: [.font: PDFReportingStyle.footerRegular,
                             .foregroundColor: Color.black]
        )
        document.pagination = pagination
        
    }
    /// Show Header and Footer (default)
    ///
    /// Can be overwritten by concrete Report implementation.
    ///
    public var showHeaderFooter: Bool { true }
}


protocol PDFReportingHeader {
    /// Optional Report Logo shown in default header
    var logoImage: PlatformImage? { get }
}


extension PDFReportingHeader {
    /// Default Document Header layout
    public func addHeader(to document: PDFDocument) {
        let logoSize = CGSize(width: 300, height: 70)
        let logoImage = logoImage ?? PlatformImage.image(named: "ReportingDefaultLogo.png")!
        var logo: PDFImage {
            guard let resizedImage = logoImage.resized(to: logoSize, alignment: .right)
            else { fatalError() }
            let finalImage = resizedImage.fillFrame(frameColor: .white).addFrame(frameColor: .lightGray)
            return PDFImage(image: finalImage, options: [.none])
        }
        // Logo Header
        document.add(.headerRight, image: logo)
    }
}
