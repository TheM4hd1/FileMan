//
//  Services.swift
//  FileMan
//
//  Created by Mahdi on 8/22/18.
//  Copyright © 2018 Mahdi Makhdumi. All rights reserved.
//

import Foundation

class Services {
    
    static let download = Services()
    var activeDownloads: [URL: DownloadModel] = [:]
    var downloadSession: URLSession!
    
    func start(_ file: FileModel) {
        
        var download = DownloadModel(file: file)
        download.task = downloadSession.downloadTask(with: file.url)
        download.task!.resume()
        download.isDownloading = true
        activeDownloads[download.file.url] = download
    }
    
    func pause(_ file: FileModel) {
        guard var download = activeDownloads[file.url] else { return }
        if download.isDownloading {
            download.task?.cancel(byProducingResumeData: { (data) in
                download.resumeData = data
            })
            download.isDownloading = false
        }
        
        activeDownloads[file.url] = download
    }
    
    func cancel(_ file: FileModel) {
        if let download = activeDownloads[file.url] {
            download.task?.cancel()
            activeDownloads[file.url] = nil
        }
    }
    
    func resume(_ file: FileModel) {
        guard var download = activeDownloads[file.url] else { return }
        if let resumeData = download.resumeData {
            print("resuming")
            download.task = downloadSession.downloadTask(withResumeData: resumeData)
        } else {
            print("starting again")
            download.task = downloadSession.downloadTask(with: download.file.url)
        }
    
        download.isDownloading = true
        activeDownloads[download.file.url] = download
        download.task!.resume()
    }
    
//    func calculateSize(_ file: FileModel) {
//        var headrequest = URLRequest(url: file.url)
//        headrequest.httpMethod = "HEAD"
//        downloadSession.dataTask(with: headrequest) { (data, res, err) in
//            guard let size = res?.expectedContentLength else { return }
//            print(size)
//            let numberOfRequests = 4
//            for i in 0..<numberOfRequests {
//                let start = Int64(ceil(CGFloat(Int64(i) * size) / CGFloat(numberOfRequests)))
//                let end = Int64(ceil(CGFloat(Int64(i + 1) * size) / CGFloat(numberOfRequests)))
//                print(start, "+", end)
//            }
//            }.resume()
//    }
}
