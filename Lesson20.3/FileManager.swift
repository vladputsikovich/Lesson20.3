//
//  FileManager.swift
//  Lesson20.3
//
//  Created by Владислав Пуцыкович on 6.01.22.
//

import Foundation

struct FM {
    func getFiles() -> [FileFolder] {
        var files = [FileFolder]()
        let tempDir = NSTemporaryDirectory()
        let url = URL(fileURLWithPath: tempDir)
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return [] }
        contents.forEach { link in
            let name = link.lastPathComponent
            guard
                let typeFile = try? FileManager.default.attributesOfItem(atPath: link.path)[.type] as? String,
                let size = try? FileManager.default.attributesOfItem(atPath: link.path)[.size] as? Int
            else { return }
            
            let file = FileFolder(name: name, size: size, type: typeFile)
            files.append(file)
        }
        return files
    }
    
    func createFile(fileName: String) -> [FileFolder] {
        var files = [FileFolder]()
        let tempDir = NSTemporaryDirectory()
        let path = (tempDir as NSString).appendingPathComponent(fileName)
        let contentsOfFile = "Some Text Here"
        
        do {
            try contentsOfFile.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            print("File text.txt created at temp directory")
        } catch let error as NSError {
            print("could't create file text.txt because of error: \(error)")
        }
        guard let size = try? FileManager.default.attributesOfItem(atPath: path)[.size] as? Int else { return [] }
        files.append(FileFolder(name: fileName, size: size, type: Constants.NSFileTypeRegularString))
        return files
    }
    
    func createFolder(fileName: String) -> [FileFolder] {
        var files = [FileFolder]()
        let tempDir = NSTemporaryDirectory()
        do {
            try FileManager.default.createDirectory(
                atPath: tempDir + fileName,
                withIntermediateDirectories: true,
                attributes: nil
            )
            print("Directory create \(tempDir + fileName)")
        } catch {
            print(error)
        }
        guard
            let size = try? FileManager.default.attributesOfItem(atPath: tempDir + fileName)[.size] as? Int
        else { return [] }
        files.append(FileFolder(name: fileName, size: size, type: Constants.NSFileTypeDirectoryString))
        return files
    }
}
