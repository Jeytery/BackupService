import Foundation

public class BackupService {
    public init(for codable: Codable) {
        self.codable = codable
        self.filePath = NSHomeDirectory() + "/Documents/" + "\(UUID().uuidString).txt"
        self.documentsUrl = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileUrl = documentsUrl.appendingPathComponent("\(UUID().uuidString).txt")
    }

    public enum BackupServiceError: Error {
        case cantCreateFile
    }
    
    private let codable: Codable
    private let filePath: String
    
    private let documentsUrl: URL
    private let fileUrl: URL
}

private extension BackupService {
    func toJSON(codable: Codable, encoder: JSONEncoder = JSONEncoder()) throws -> String {
       let data = try encoder.encode(codable)
       return String(decoding: data, as: UTF8.self)
   }
    
    func createPackageFile(filePath: String) -> BackupServiceError? {
        guard FileManager
            .default
            .createFile(
                atPath: filePath,
                contents: nil,
                attributes: nil
            )
        else {
            return .cantCreateFile
        }
        return nil
    }
    
    func savePackageToFile(
        _ codable: Codable,
        filePath: String
    ) throws {
        do {
            try toJSON(codable: codable)
                .write(
                    to: fileUrl,
                    atomically: true,
                    encoding: .utf8
                )
        }
        catch(let error) {
            throw error
        }
    }
}

public extension BackupService {
    func backup() -> Result<URL, Error> {
        if let error = self.createPackageFile(filePath: self.filePath) {
            return .failure(error)
        }
        
        do {
            try self.savePackageToFile(
                self.codable,
                filePath: self.filePath
            )
        }
        catch(let error) {
            return .failure(error)
        }
        
        return .success(fileUrl)
    }
    
    func removeFile() -> Error? {
        do {
            try FileManager.default.removeItem(atPath: filePath)
        }
        catch(let error) {
            return error
        }
        return nil
    }
}
