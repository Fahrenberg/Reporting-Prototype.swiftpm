import SwiftUI
import PDFKit
import OSLog
import Extensions


struct ContentView: View {
    @State private var pdfData: Data = Data()
    @State private var reportType: ReportType = .PlaygroundReport
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
                    ForEach(ReportType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Toggle("Show Debug Frame", isOn: $debugFrame)
                    .padding(.bottom, 5)
            }
            .frame(maxWidth: .infinity)
        }
        .onChange(of: reportType) { newValue in
            Task {
                await loadSamplePDF(reportType: newValue)
            }
        }
        .onChange(of: debugFrame) { newValue in
            Task {
                await loadSamplePDF(reportType: reportType)
            }
        }
        .task {
            await loadSamplePDF(reportType: reportType)
        }
    }

    // Example function to load PDF data
    private func loadSamplePDF(reportType: ReportType) async {
        pdfData = Data()
        let trafinaLogo = PlatformImage.image(named: "TrafinaLogo.jpeg")!
        var report: PDFReporting?
        switch reportType {
        case .SingleBookingReport:
            report =  PDFBooking(
                reportRecord: ReportRecord.mock(scanCount: 6) // using default header
            )
        case .PlaygroundReport:
            report = PlaygroundReport() // using no header
        case .FullReport:
            report = PDFFullReport(
                reportRecords: ReportRecords.mocks(),
                pdfHeader: PDFLogoImageHeader(logoImage: trafinaLogo) // overwriting header for PDFFullReport
            )
        case .TableReport:
            report = PDFRecordTable(
                reportRecords: ReportRecords.mocks()
            )
        case .ExternalPDF:
            report = ExternalPDF()
        }
        guard let data = await report?.data(debugFrame: debugFrame)
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
enum ReportType: String, CaseIterable {
    case SingleBookingReport
    case PlaygroundReport
    case FullReport
    case TableReport
    case ExternalPDF
}
