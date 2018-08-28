//
//  DownloadManagerCell.swift
//  FileMan
//
//  Created by Mahdi on 8/22/18.
//  Copyright © 2018 Mahdi Makhdumi. All rights reserved.
//

import UIKit

protocol DownloadManagerCellDelegate {
    func didTappedPause(_ cell: DownloadManagerCell)
    func didTappedResume(_ cell: DownloadManagerCell)
    func didTappedCancel(_ cell: DownloadManagerCell)
}

class DownloadManagerCell: UITableViewCell {
    var delegate: DownloadManagerCellDelegate?
    
    private lazy var imageFile: UIImageView = {
        let imageview = UIImageView()
        return imageview
    }()
    
    private lazy var labelFilename: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var buttonPause: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_pause_black_24pt_").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tag = 1 // [1: Pause] [2: Resume]
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonCancel: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_stop_black_24pt_").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackButtons: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [buttonPause, buttonCancel])
        stackview.axis = .horizontal
        stackview.distribution = .fillEqually
        stackview.spacing = 1
        return stackview
    }()
    
    private lazy var labelFileUrl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var progressDownload: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        return progress
    }()
    
    private lazy var labelProgress: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        return label
    }()
    
    func setupCell(file: FileModel, downloaded: Bool, download: DownloadModel?) {
        addSubviews()
        setupConstraints()
        imageFile.image = Helper.shared.getImage(for: file.url).withRenderingMode(.alwaysTemplate)
        labelFilename.text = file.name
        labelFileUrl.text = file.url.absoluteString
        
        if downloaded {
            stackButtons.isHidden = true
            labelProgress.text = "Completed"
            labelProgress.textColor = .lightGray
            labelProgress.font = UIFont.systemFont(ofSize: 10)
            progressDownload.isHidden = true
        }
    }
    
    fileprivate func addSubviews() {
        addSubview(imageFile)
        addSubview(labelFilename)
        addSubview(stackButtons)
        addSubview(labelFileUrl)
        addSubview(progressDownload)
        addSubview(labelProgress)
    }
    
    fileprivate func setupConstraints() {
        imageFile.anchorManual(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 30, height: 40)
        stackButtons.anchorManual(top: topAnchor, left: labelFilename.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 50, height: 24)
        labelFilename.anchorManual(top: topAnchor, left: imageFile.rightAnchor, bottom: nil, right: stackButtons.leftAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        labelFileUrl.anchorManual(top: labelFilename.bottomAnchor, left: imageFile.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)
        labelProgress.anchorManual(top: labelFileUrl.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 100, height: 20)
        progressDownload.anchorManual(top: labelFileUrl.bottomAnchor, left: imageFile.rightAnchor, bottom: nil, right: labelProgress.leftAnchor, paddingTop: 18, paddingLeft: 16, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    func updateDisplay(progress: Float, totalSize : String) {
        progressDownload.progress = progress
        labelProgress.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
    
    @objc fileprivate func handlePause() {
        switch buttonPause.tag {
        case 1: // Pause requested
            buttonPause.tag = 2
            buttonPause.setImage(#imageLiteral(resourceName: "baseline_play_arrow_black_24pt_"), for: .normal)
            delegate?.didTappedPause(self)
        case 2:
            buttonPause.tag = 1
            buttonPause.setImage(#imageLiteral(resourceName: "baseline_pause_black_24pt_"), for: .normal)
            delegate?.didTappedResume(self)
        default:
            print("Unhandled case")
        }
    }
    
    @objc fileprivate func handleCancel() {
        delegate?.didTappedCancel(self)
        labelProgress.text = "Canceled."
        stackButtons.isHidden = true
    }
}
