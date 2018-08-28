//
//  SettingsController.swift
//  FileMan
//
//  Created by Mahdi Makhdumi on 8/19/18.
//  Copyright © 2018 Mahdi Makhdumi. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {
    
    private let sections: [[(String, String, String)]] = [[("Proxy", Configs.shared.proxyStatus, "Icon_SettingsProxy")],
                                        [("Data and Storage", "", "Icon_SettingsStorage")],
                                        [("Ask a Question", "", "Icon_SettingsAskQuestion"), ("FileMan FAQ", "", "Icon_SettingsFaq")]]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    fileprivate func setupViews() {
        
        navigationItem.title = "Settings"
        self.tableView = UITableView(frame: tableView.frame, style: .grouped)
    }
}

extension SettingsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "settingsCell")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = sections[indexPath.section][indexPath.row].0
        cell.detailTextLabel?.text = sections[indexPath.section][indexPath.row].1
        cell.imageView?.image = UIImage(named: sections[indexPath.section][indexPath.row].2)?.withRenderingMode(.alwaysOriginal)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(ByteCountFormatter.string(fromByteCount: Configs.shared.totalDownloadedBytes, countStyle: .file))
    }
}
