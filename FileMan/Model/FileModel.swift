//
//  FileModel.swift
//  FileMan
//
//  Created by Mahdi on 8/22/18.
//  Copyright © 2018 Mahdi Makhdumi. All rights reserved.
//

import UIKit

struct FileModel {
    
    let type: UIImage
    let name: String
    let url: URL
    let index: Int
    let size: Int64?
    var downloaded = false
}
