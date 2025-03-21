//
//  --------------------------------------------------------------------------------------------------
//  ---------------                                                                     --------------
//  ---------------                         FileManager+Extension                       --------------
//  ---------------                                                                     --------------
//  --------------------------------------------------------------------------------------------------
//
//
//  *  Writing Data to a (newly created) local app bundle temporary directory
//  *  Local 'FileManager.default.temporaryDirectory' handled by os
//
//  --------------------------------------------------------------------------------------------------

import Foundation
import OSLog

extension Data {
    /// Write ````Data```` to Reporting+DataString.ext in temporary bundle folder.
    ///
    /// - returns: URL to file
    func write(ext: String) -> URL? {
        do {
            let uniqueFileURL = uniqueFileURL(ext: ext)
            try self.write(to: uniqueFileURL, options: .atomic)
            return uniqueFileURL
        }
        catch {
            return nil
        }
    }
    
    /// Write ````Data```` to filename in temporary bundle folder.
    ///
    /// - returns: URL to file
    func write(filename: String) -> URL? {
        do {
            let cleanBaseFilename = filename.replacingOccurrences(of: ":", with: "-")
            let fileURL = FileManager.reportingTemporaryDirectory.appendingPathComponent(cleanBaseFilename)
            try self.write(to: fileURL, options: .atomic)
            return fileURL
        }
        catch {
            return nil
        }
    }
    
       
    private func uniqueFileURL(ext: String) -> URL {
        
        let baseFilename = "Reporting-\(Date().ISO8601Format()).\(ext)"
        let cleanBaseFilename = baseFilename.replacingOccurrences(of: ":", with: "-")
        
        var uniqueFilename = cleanBaseFilename
        var counter = 1
        
        var fileURL = FileManager.reportingTemporaryDirectory.appendingPathComponent(uniqueFilename)
        
        // Ensure the filename is unique by checking if it already exists
        while FileManager.default.fileExists(atPath: fileURL.path) {
            let filenameWithoutExtension = (cleanBaseFilename as NSString).deletingPathExtension
            let newFilename = "\(filenameWithoutExtension)-\(counter).\(ext)"
            uniqueFilename = newFilename
            fileURL = FileManager.reportingTemporaryDirectory.appendingPathComponent(uniqueFilename)
            counter += 1
        }
        
        return fileURL
    }

}

extension FileManager {
    static var reportingTemporaryDirectory: URL {
        let reportingTemporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(Logger.subsystem)
        try! FileManager.default.createDirectory(at: reportingTemporaryDirectory, withIntermediateDirectories: true)
        return reportingTemporaryDirectory
    }
}

