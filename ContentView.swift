import SwiftUI
import PDFKit
import OSLog
import Extensions


struct ContentView: View {
    // pdfData is now a @State variable
    @State private var pdfData: Data = Data() // Initialize with an empty Data object
    @State private var reportType: ReportType = .TableReport
    @State private var debugFrame = false
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
            VStack {
                Picker("Report Type", selection: $reportType) {
                    Text("SingleBookingReport").tag(ReportType.SingleBookingReport)
                    Text("TableReport").tag(ReportType.TableReport)
                    Text("FullReport").tag(ReportType.FullReport)
                    Text("PlaygroundReport").tag(ReportType.PlaygroundReport)
                    Text("ExternalPDF").tag(ReportType.ExternalPDF)
                }
                HStack {
                    Text("Show Debug Frame")
                    Toggle("Show Debug Frame", isOn: $debugFrame)
                        .labelsHidden()
                }
                .frame(maxWidth: .infinity, alignment: .center) // Ensures centering
                .padding(.bottom, 5)
            }
            .frame(maxWidth: .infinity) // Ensures VStack takes full width
        }
        .onChange(of: reportType) { loadSamplePDF(reportType: reportType) }
        .onChange(of: debugFrame) { loadSamplePDF(reportType: reportType) }
        .onAppear { loadSamplePDF(reportType: reportType) }
    }
    
    // Example function to load PDF data
    private func loadSamplePDF(reportType: ReportType) {
        pdfData = Data()
        var report: Report?
        switch reportType {
        case .SingleBookingReport:
            report =  SingleBookingReport(reportRecord: ReportRecord.mock(scanCount: 4))
        case .PlaygroundReport:
            report = PlaygroundReport()
        case .FullReport:
            report = FullReport()
        case .TableReport:
            report = TableReport(reportRecords: ReportRecords.mocks() )
        case .ExternalPDF:
            report = ExternalPDF()
        }
        guard let data = report?.data(debugFrame: debugFrame)
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
        
        return  // no saving to disk
//        enum saveError: Error {
//           case cannotWrite
//        }
//        do {
//            let directory = try PlatformImage.tempDirectory()
//            let file = directory.appending(path: "report.pdf")
//            let sucess = pdfDocument.write(to: file)
//            if !sucess { throw saveError.cannotWrite}
//            print(file.absoluteString)
//        }
//            catch {
//                print("Cannot save PDFDocument \(error.localizedDescription)")
//            }
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
    case ExternalPDF
}
