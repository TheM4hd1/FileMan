//
//  FileManagerController.swift
//  FileMan
//
//  Created by Mahdi Makhdumi on 8/19/18.
//  Copyright © 2018 Mahdi Makhdumi. All rights reserved.
//

import UIKit
import QuickLook

class FileManagerController: UITableViewController {
    
    let cellId = "FMCell"
    var tableViewData: [(String, Int64, URL)] = []
    let fileManager = FileManager.default
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var currentPath: URL?
    let quickLookPreview = QLPreviewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewsAndConfigs()
    }
    
    fileprivate func setupViewsAndConfigs() {
        navigationItem.title = "File Manager"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        quickLookPreview.dataSource = self
        currentPath = documentsPath
        NotificationCenter.default.addObserver(self, selector: #selector(currentPathChanged), name: Configs.shared.CURRENT_PATH_CHANGED_NOTIF, object: nil)
        NotificationCenter.default.post(name: Configs.shared.CURRENT_PATH_CHANGED_NOTIF, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshFileManager(at: currentPath!)
    }
    
    fileprivate func refreshFileManager(at path: URL) {
        // TODO: Refresh tableView and FileManager
        do {
            tableViewData.removeAll()
            let fileURLs = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            for url in fileURLs {
                let fileName = url.lastPathComponent
                let fileInfo = try fileManager.attributesOfItem(atPath: url.path)
                let fileSize = fileInfo[FileAttributeKey.size]
                if fileName != ".DS_Store" {
                    // In the Apple macOS operating system, .DS_Store is a file that stores custom attributes of its containing folder
                    tableViewData.append((fileName, fileSize as! Int64, url))
                }
            }
            tableView.reloadData()
            quickLookPreview.reloadData()
        } catch {
            print("Error while enumerating files \(currentPath!.path): \(error.localizedDescription)")
        }
    }
    
    fileprivate func removeItem(at url: URL, indexPath: IndexPath) {
        // TODO: - Remove File/Directory at url
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("Error in removing")
        }
        tableViewData.remove(at: indexPath.item)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        quickLookPreview.reloadData()
    }
    
    @objc fileprivate func backButtonPressed(_ sender: UIBarButtonItem) {
        currentPath = currentPath?.deletingLastPathComponent()
        NotificationCenter.default.post(name: Configs.shared.CURRENT_PATH_CHANGED_NOTIF, object: nil)
        refreshFileManager(at: currentPath!)
    }
    
    @objc fileprivate func currentPathChanged() {
        // FIXME: - Handle leftBarButtonItem
        if currentPath == documentsPath {
            navigationItem.leftBarButtonItem = nil
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Icon_NavigationBack"), style: .done, target: self, action: #selector(backButtonPressed(_:)))
        }
    }
}

// MARK: - tableView DataSource and Delegate
extension FileManagerController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let item = tableViewData[indexPath.item]
        cell.textLabel?.text = item.0
        cell.imageView?.image = Helper.shared.getImage(for: item.2).withRenderingMode(.alwaysTemplate)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = tableViewData[indexPath.item].2
        if url.hasDirectoryPath {
            // Open Directory
            currentPath = url
            NotificationCenter.default.post(name: Configs.shared.CURRENT_PATH_CHANGED_NOTIF, object: nil)
            refreshFileManager(at: url)
        } else {
            // Directory Files
            let nsurl = NSURL(fileURLWithPath: url.absoluteString)
            if QLPreviewController.canPreview(nsurl) {
                quickLookPreview.currentPreviewItemIndex = indexPath.row
                navigationController?.pushViewController(quickLookPreview, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let url = tableViewData[indexPath.item].2
            if url.hasDirectoryPath {
                let alert = UIAlertController(title: "Warning", message: "All contents and files will remove, are you sure?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    self.removeItem(at: url, indexPath: indexPath)
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (action) in
                    return
                }))
                
                self.present(alert, animated: true, completion: nil)
            } else {
                removeItem(at: url, indexPath: indexPath)
            }
        }
    }
}

// MARK: - QLPreviewController DataSource
extension FileManagerController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return tableViewData.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let url = tableViewData[index].2
        return NSURL(string: url.absoluteString)!
    }
}
