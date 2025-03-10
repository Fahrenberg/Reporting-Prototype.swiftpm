import SwiftUI
import PDFKit
import OSLog
import Extensions

struct ContentView: View {
    // pdfData is now a @State variable
    @State private var pdfData: Data = Data() // Initialize with an empty Data object
    @State private var reportType: ReportType = .PlaygroundReport
    var body: some View {
        VStack {
            if let pdfDocument = PDFDocument(data: pdfData), !pdfData.isEmpty {
                PDFKitView(pdfDocument: pdfDocument)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Spacer()
                Text("No PDF to display")
                Spacer()
            }
            Spacer()
            Picker("Report Type", selection: $reportType) {
                Text("SingleBookingReport").tag(ReportType.SingleBookingReport)
                Text("TableReport").tag(ReportType.TableReport)
                Text("FullReport").tag(ReportType.FullReport)
                Text("PlaygroundReport").tag(ReportType.PlaygroundReport)
            }
            .padding(.top, 5)
        }
        .onChange(of: reportType) { loadSamplePDF(reportType: reportType) }
        .onAppear { loadSamplePDF(reportType: reportType) }
    }
    
    // Example function to load PDF data
    private func loadSamplePDF(reportType: ReportType) {
        pdfData = Data()
        var report: Report?
        switch reportType {
        case .SingleBookingReport:
            report =  SingleBookingReport(reportRecord: ReportRecord.mock(scanCount: 0))
        case .PlaygroundReport:
            report = PlaygroundReport()
        case .FullReport:
            report = FullReport()
        case .TableReport:
            report = TableReport(reportRecords: ReportRecords.mocks() )
        case .PDFFile:
            report = ExternalPDF()
        }
        guard let data = report?.data() 
        else { 
            Logger.source.error("Cannot create report!")
            print("Cannot create report!")
            pdfData = Data()
            return
        }
        pdfData = data
        let pdfDoc = PDFDocument(data: data)!
        save(pdfDocument: pdfDoc)
    }
    
    private func save(pdfDocument: PDFDocument) {
        enum saveError: Error {
           case cannotWrite
        }
        do {
            return
            let directory = try PlatformImage.tempDirectory()
            let file = directory.appending(path: "report.pdf")
            let sucess = pdfDocument.write(to: file)
            if !sucess { throw saveError.cannotWrite}
            print(file.absoluteString)
        }
            catch {
                print("Cannot save PDFDocument \(error.localizedDescription)")
            }
    }
}

struct PDFKitView: UIViewRepresentable {
    var pdfDocument: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = pdfDocument
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
enum ReportType {
    case SingleBookingReport
    case PlaygroundReport
    case FullReport
    case TableReport
    case PDFFile
}
