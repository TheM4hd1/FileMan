//
//  DownloadModel.swift
//  FileMan
//
//  Created by Mahdi on 8/22/18.
//  Copyright © 2018 Mahdi Makhdumi. All rights reserved.
//

import Foundation

struct DownloadModel {
    
    var file: FileModel
    init(file: FileModel) {
        self.file = file
    }
    
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    var progress: Float = 0
}
