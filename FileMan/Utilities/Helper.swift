//
//  Helper.swift
//  FileMan
//
//  Created by Mahdi on 8/29/18.
//  Copyright © 2018 Mahdi Makhdumi. All rights reserved.
//

import UIKit

class Helper {
    
    static let shared = Helper()
    
     func getImage(for url: URL) -> UIImage {
        if url.hasDirectoryPath {
            return #imageLiteral(resourceName: "baseline_folder_black_36pt_")
        }
        
        switch url.pathExtension.lowercased() {
        case "mp3", "m4a", "wav":
            return #imageLiteral(resourceName: "baseline_library_music_black_36pt_")
        case "mov", "mp4", "avi":
            return #imageLiteral(resourceName: "baseline_movie_black_36pt_")
        default:
            return #imageLiteral(resourceName: "baseline_file_copy_black_36pt_")
        }
    }
}
