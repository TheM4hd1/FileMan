//
//  DownloadManagerController.swift
//  FileMan
//
//  Created by Mahdi Makhdumi on 8/19/18.
//  Copyright © 2018 Mahdi Makhdumi. All rights reserved.
//

import UIKit

class DownloadManagerController: UITableViewController {

    let cellId = "DMCell"
    var activeDownloads: [FileModel] = []
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier:
            "bgSessionConfiguration")//URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Services.download.downloadSession = downloadsSession
        setupViews()
    }
    
    fileprivate func setupViews() {
        
        // ======================//
        // FIXME: Customize NavBar
        navigationItem.title = "Downloads"
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(btnAddPressed))
        navigationItem.rightBarButtonItem = rightBarButton
        
        tableView.register(DownloadManagerCell.self, forCellReuseIdentifier: cellId)
    }
    
    @objc fileprivate func btnAddPressed() {
        
        // ======================//
        // TODO: Alert with textField
        let alert = UIAlertController(title: "", message: "Download File", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter URL Address"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            guard let userInput = textField?.text, !(textField?.text?.isEmpty)! else { return }
            guard let url = URL(string: userInput) else { self.showAlert(message: "Invalid URL Address")
                return }
            
            // ======================//
            // TODO: Verify URL Address
            if self.verifyUrl(urlString: userInput) {
                let filename = url.lastPathComponent
                let fileImage = self.getImageForExtension(filename: filename)
                let file = FileModel(type: fileImage, name: filename, url: url, index: self.activeDownloads.count, size: nil, downloaded: false)
                self.activeDownloads.append(file)
                Services.download.start(file)
                self.tableView.insertRows(at: [IndexPath(row: file.index, section: 0)], with: .none)
            } else {
                self.showAlert(message: "Invalid URL Address")
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    fileprivate func getImageForExtension(filename: String) -> UIImage {
        return UIImage()
    }
    
    fileprivate func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    fileprivate func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    fileprivate func reload(_ row: Int) {
        //tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
}

extension DownloadManagerController: DownloadManagerCellDelegate {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeDownloads.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DownloadManagerCell
        cell.delegate = self
        let file =  activeDownloads[indexPath.item]
        if let downloadItem = Services.download.activeDownloads[file.url] {
            cell.setupCell(file: file, downloaded: downloadItem.file.downloaded, download: downloadItem)
        } else {
            cell.setupCell(file: file, downloaded: file.downloaded, download: Services.download.activeDownloads[file.url])
        }
        
        return cell
    }
    
    func didTappedPause(_ cell: DownloadManagerCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let file = activeDownloads[indexPath.row]
            Services.download.pause(file)
            reload(indexPath.row)
        }
    }
    
    func didTappedResume(_ cell: DownloadManagerCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let file = activeDownloads[indexPath.row]
            Services.download.resume(file)
            reload(indexPath.row)
        }
    }
    
    func didTappedCancel(_ cell: DownloadManagerCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let file = activeDownloads[indexPath.row]
            Services.download.cancel(file)
            reload(indexPath.row)
        }
    }
}

extension DownloadManagerController: URLSessionDownloadDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("didFinished")
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        var download = Services.download.activeDownloads[sourceURL]
        Services.download.activeDownloads[sourceURL] = nil
        
        let destinationURL = localFilePath(for: sourceURL)
        //print(destinationURL)
        
        let filemanager = FileManager.default
        try? filemanager.removeItem(at: destinationURL)
        do {
            try filemanager.copyItem(at: location, to: destinationURL)
        } catch let error {
            print(error.localizedDescription)
        }
        
        download?.file.downloaded = true
        activeDownloads[(download?.file.index)!].downloaded = true
        
        if let index = download?.file.index {
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
        print("Finished downloading to \(location).")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.originalRequest?.url,
            var download = Services.download.activeDownloads[url] else { return }
        
        Configs.shared.totalDownloadedBytes += totalBytesWritten
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        
        DispatchQueue.main.async {
            if let downloadCell = self.tableView.cellForRow(at: IndexPath(row: download.file.index,
                                                                       section: 0)) as? DownloadManagerCell {
                downloadCell.updateDisplay(progress: download.progress, totalSize: totalSize)
            }
        }
    }
}
