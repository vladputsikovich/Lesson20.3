//
//  ViewController.swift
//  Lesson20.3
//
//  Created by Владислав Пуцыкович on 3.01.22.
//

import UIKit

struct Constants {
    static let identificator = "MyView"
    static let titleAddButton = "Создать"
    static let sizeButton: CGFloat = 30
    static let NSFileTypeRegularString = "NSFileTypeRegular"
    static let NSFileTypeDirectoryString = "NSFileTypeDirectory"
    static let stringFileImage = "file"
    static let stringFolderImage = "folder"
    static let heightRow: CGFloat = 50
    static let half: CGFloat = 2
    static let placeholderName = "Введите название"
    static let stringCreateFile = "Создать файл"
    static let stringCreateFolder = "Создать папку"
}

class ViewController: UIViewController , UITableViewDelegate {

    private var tableView = UITableView()
    
    private var files = [FileFolder]() {
        willSet {
            tableView.reloadData()
        }
    }
    
    private var buttonAdd = UIButton()
    private var buttonFile = UIButton()
    private var buttonFolder = UIButton()
    private var textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTable()
        createAddButton()
        files = FM().getFiles()
    }
    
    func createTable() {
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
    
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.identificator)
        
        self.view.addSubview(tableView)
    }

    func createAddButton() {
        buttonAdd = UIButton()
        buttonAdd.frame = CGRect(
            x: .zero,
            y: self.view.bounds.height - Constants.sizeButton,
            width: self.view.bounds.width,
            height: Constants.sizeButton
        )
        buttonAdd.setTitle(Constants.titleAddButton, for: .normal)
        buttonAdd.setTitleColor( .black, for: .normal)
        buttonAdd.backgroundColor = .gray
        buttonAdd.addAction(UIAction(handler: {_ in self.add()}), for: .touchUpInside)
        
        self.view.addSubview(buttonAdd)
    }
    
    func add() {
        tableView.frame.origin.y -= Constants.sizeButton
        buttonAdd.isHidden = true
        buttonFolder.isHidden = false
        buttonFile.isHidden = false
        textField.isHidden = false
    }
    
    func addFile() {
        files.append(contentsOf: FM().createFile(fileName: textField.text ?? "null"))
        buttonAdd.isHidden = false
        buttonFile.isHidden = true
        buttonFolder.isHidden = true
        textField.isHidden = true
        tableView.frame.origin.y += Constants.sizeButton
        tableView.reloadData()
    }
    
    func addFolder() {
        files.append(contentsOf: FM().createFolder(fileName: textField.text ?? "null"))
        buttonAdd.isHidden = false
        buttonFolder.isHidden = true
        buttonFile.isHidden = true
        textField.isHidden = true
        tableView.frame.origin.y += Constants.sizeButton
    }
}

// MARK: UITableViewDragDelegate

extension ViewController: UITableViewDragDelegate {
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

// MARK: UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: Constants.identificator)
        if files[indexPath.row].type == Constants.NSFileTypeRegularString {
            cell.imageView?.image = UIImage(named: Constants.stringFileImage)
        }
        if files[indexPath.row].type == Constants.NSFileTypeDirectoryString {
            cell.imageView?.image = UIImage(named: Constants.stringFolderImage)
        }
        cell.textLabel?.text = files[indexPath.row].name
        cell.detailTextLabel?.text = "\(files[indexPath.row].size) KB"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.heightRow
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        
        textField = UITextField(
            frame: CGRect(
                x: .zero,
                y: self.view.bounds.height - Constants.sizeButton * Constants.half,
                width: self.view.bounds.width,
                height: Constants.sizeButton
            )
        )
        textField.placeholder = Constants.placeholderName
        textField.isHidden = true
        
        buttonFile = UIButton()
        buttonFile.frame = CGRect(
            x: .zero,
            y: self.view.bounds.height - Constants.sizeButton,
            width: self.view.bounds.width / Constants.half,
            height: Constants.sizeButton
        )
        buttonFile.setTitle(Constants.stringCreateFile, for: .normal)
        buttonFile.setTitleColor( .black, for: .normal)
        buttonFile.backgroundColor = .gray
        buttonFile.addAction(UIAction(handler: {_ in self.addFile()}), for: .touchUpInside)
        buttonFile.isHidden = true
        
        buttonFolder = UIButton()
        buttonFolder.frame = CGRect(
            x: self.view.bounds.width / Constants.half,
            y: self.view.bounds.height - Constants.sizeButton,
            width: self.view.bounds.width / Constants.half,
            height: Constants.sizeButton
        )
        buttonFolder.setTitle(Constants.stringCreateFolder, for: .normal)
        buttonFolder.setTitleColor( .black, for: .normal)
        buttonFolder.backgroundColor = .gray
        buttonFolder.addAction(UIAction(handler: {_ in self.addFolder()}), for: .touchUpInside)
        buttonFolder.isHidden = true
        
        self.view.addSubview(buttonFile)
        self.view.addSubview(buttonFolder)
        self.view.addSubview(textField)
        
        return footerView
    }
}

