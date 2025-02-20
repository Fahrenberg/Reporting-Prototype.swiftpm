import SwiftUI
import PDFKit
import OSLog
struct ContentView: View {
    // pdfData is now a @State variable
    @State private var pdfData: Data = Data() // Initialize with an empty Data object
    @State private var reportType: ReportType = .RecordReport
    var body: some View {
        VStack {
            if let pdfDocument = PDFDocument(data: pdfData), !pdfData.isEmpty {
                PDFKitView(pdfDocument: pdfDocument)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("No PDF to display")
                    .padding()
            }
            Spacer()
            Picker("Report Type", selection: $reportType) {
                Text("ReportRecord").tag(ReportType.RecordReport)
                Text("MultipleLargeImageReport").tag(ReportType.MultipleLargeImageReport)
                Text("TableReport").tag(ReportType.TableReport)
                Text("ExternalPDF").tag(ReportType.PDFFile)
            }.padding()
        }
        .onChange(of: reportType) { loadSamplePDF(reportType: reportType) }
        .onAppear { loadSamplePDF(reportType: reportType) }
    }
    
    // Example function to load PDF data
    private func loadSamplePDF(reportType: ReportType) {
        pdfData = Data()
        var report: Report = SingleBookingReport(reportRecord: ReportRecord.mockReportRecord)
        switch reportType {
        case .RecordReport:
            report =  SingleBookingReport(reportRecord: ReportRecord.mockReportRecord)
        case .MultipleLargeImageReport:
            report = MultipleLargeImageReport(imagesData: allImageData())
        case .TableReport:
            report = TableReport(reportRecords: TableReport.mockReportRecords)
        case .PDFFile:
            report = ExternalPDF()
        }
        guard let data = report.data() 
        else { 
            Logger.source.error("Cannot create report!")
            print("Cannot create report!")
            pdfData = Data() 
            return
        }
        pdfData = data
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
    case RecordReport
    case MultipleLargeImageReport
    case TableReport
    case PDFFile
}
