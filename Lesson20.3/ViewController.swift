//
//  ViewController.swift
//  Lesson20.3
//
//  Created by Владислав Пуцыкович on 3.01.22.
//

import UIKit

struct FileFolder {
    var name: String
    var size: Int
    var type: String
}

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {

    var tableView = UITableView()
    
    var files: [FileFolder] = []
    
    var buttonAdd = UIButton()
    var buttonFile = UIButton()
    var buttonFolder = UIButton()
    
    var textField = UITextField()
    
    let identificator = "MyView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTable()
        
        createAddButton()
        
        getFiles()
    }
    
    func createTable() {
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
    
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identificator)
        
        self.view.addSubview(tableView)
    }

    // MARK: DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: identificator)
        if files[indexPath.row].type == "NSFileTypeRegular" {
            cell.imageView?.image = UIImage(named: "file")
        }
        if files[indexPath.row].type == "NSFileTypeDirectory" {
            cell.imageView?.image = UIImage(named: "folder")
        }
        cell.textLabel?.text = files[indexPath.row].name
        cell.detailTextLabel?.text = "\(files[indexPath.row].size) KB"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        
        textField = UITextField(frame: CGRect(x: 0, y: self.view.bounds.height - 60, width: self.view.bounds.width, height: 30))
        textField.placeholder = "Введите название"
        textField.isHidden = true
        
        buttonFile = UIButton()
        buttonFile.frame = CGRect(x: 0, y: self.view.bounds.height - 30, width: self.view.bounds.width / 2, height: 30)
        buttonFile.setTitle("Создать файл", for: .normal)
        buttonFile.setTitleColor( .black, for: .normal)
        buttonFile.backgroundColor = .gray
        buttonFile.addAction(UIAction(handler: {_ in self.addFile()}), for: .touchUpInside)
        buttonFile.isHidden = true
        
        buttonFolder = UIButton()
        buttonFolder.frame = CGRect(x: self.view.bounds.width / 2, y: self.view.bounds.height - 30, width: self.view.bounds.width / 2, height: 30)
        buttonFolder.setTitle("Создать папку", for: .normal)
        buttonFolder.setTitleColor( .black, for: .normal)
        buttonFolder.backgroundColor = .gray
        buttonFolder.addAction(UIAction(handler: {_ in self.addFolder()}), for: .touchUpInside)
        buttonFolder.isHidden = true
        
        self.view.addSubview(buttonFile)
        self.view.addSubview(buttonFolder)
        self.view.addSubview(textField)
        
        return footerView
    }
    
    func createAddButton() {
        buttonAdd = UIButton()
        buttonAdd.frame = CGRect(x: 0, y: self.view.bounds.height - 30, width: self.view.bounds.width , height: 30)
        buttonAdd.setTitle("Создать", for: .normal)
        buttonAdd.setTitleColor( .black, for: .normal)
        buttonAdd.backgroundColor = .gray
        buttonAdd.addAction(UIAction(handler: {_ in self.add()}), for: .touchUpInside)
        
        self.view.addSubview(buttonAdd)
    }
    
    func add() {
        tableView.frame.origin.y -= 30
        buttonAdd.isHidden = true
        buttonFolder.isHidden = false
        buttonFile.isHidden = false
        textField.isHidden = false
    }
    
    func addFile() {
        createFile()
        buttonAdd.isHidden = false
        buttonFile.isHidden = true
        buttonFolder.isHidden = true
        textField.isHidden = true
        tableView.frame.origin.y += 30
    }
    
    func addFolder() {
        createFolder()
        buttonAdd.isHidden = false
        buttonFolder.isHidden = true
        buttonFile.isHidden = true
        textField.isHidden = true
        tableView.frame.origin.y += 30
    }
    
    // MARK: FileManager
    
    func getFiles() {
        let tempDir = NSTemporaryDirectory()
        let url = URL(fileURLWithPath: tempDir)
        let contents = try! FileManager.default.contentsOfDirectory(at: url,
                                                        includingPropertiesForKeys: nil,
                                                        options: [.skipsHiddenFiles])
        contents.forEach { link in
            let name = link.lastPathComponent
            let typeFile = try! FileManager.default.attributesOfItem(atPath: link.path)[.type] as! String
            let size = try! FileManager.default.attributesOfItem(atPath: link.path)[.size] as? Int
            let file = FileFolder(name: name, size: size ?? 0, type: typeFile)
            files.append(file)
        }
    }
    
    func createFile() {
        
        let tempDir = NSTemporaryDirectory()
        guard let fileName = textField.text else { return }
        
        let path = (tempDir as NSString).appendingPathComponent(fileName)
        let contentsOfFile = "Some Text Here"
        
        do {
            try contentsOfFile.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            print("File text.txt created at temp directory")
        } catch let error as NSError {
            print("could't create file text.txt because of error: \(error)")
        }
        let size = try! FileManager.default.attributesOfItem(atPath: path)[.size] as? Int
        files.append(FileFolder(name: fileName, size: size ?? 0, type: "NSFileTypeRegular"))
        tableView.reloadData()
    }
    
    func createFolder() {
        let tempDir = NSTemporaryDirectory()
        guard let fileName = textField.text else { return }
        do {
            try FileManager.default.createDirectory(atPath: tempDir + fileName, withIntermediateDirectories: true, attributes: nil)
            print("Directory create \(tempDir + fileName)")
        } catch {
            print(error)
        }
        let size = try! FileManager.default.attributesOfItem(atPath: tempDir + fileName)[.size] as? Int
        files.append(FileFolder(name: fileName, size: size ?? 0, type: "NSFileTypeDirectory"))
        tableView.reloadData()
    }
    
    // MARK: Drag and Drop

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let mover = files.remove(at: sourceIndexPath.row)
        files.insert(mover, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = files[indexPath.row]
        return [dragItem]
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            files.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }

}

