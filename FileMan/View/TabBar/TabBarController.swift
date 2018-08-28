//
//  TabBarontroller.swift
//  FileMan
//
//  Created by Mahdi Makhdumi on 8/19/18.
//  Copyright © 2018 Mahdi Makhdumi. All rights reserved.
//

import UIKit

class TabBarontroller: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    fileprivate func setupViews() {
        
        // ======================//
        // FIXME: Customize Tab/Nav Bar Properties
        view.backgroundColor = .orange
        
        // ======================//
        // TODO: Creating tabBar items
        let fileManagerItem = createViewControllerWithNavigationBar(view: FileManagerController(), icon: #imageLiteral(resourceName: "baseline_folder_black_36pt_"), icon: #imageLiteral(resourceName: "baseline_folder_black_36pt_"), title: "Files")
        let downloadManagerItem = createViewControllerWithNavigationBar(view: DownloadManagerController(), icon: #imageLiteral(resourceName: "baseline_get_app_black_36pt_"), icon: #imageLiteral(resourceName: "baseline_get_app_black_36pt_"), title: "Queue")
        let settingsItem = createViewControllerWithNavigationBar(view: SettingsController(), icon: #imageLiteral(resourceName: "baseline_settings_black_36pt_"), icon: #imageLiteral(resourceName: "baseline_settings_black_36pt_"), title: "Settings")
        
        // ======================//
        // FIXME: Adding items to tabBar
        viewControllers = [downloadManagerItem, fileManagerItem, settingsItem]
        
    }
    
    fileprivate func createViewControllerWithNavigationBar(view controller: UIViewController, icon selected: UIImage, icon unselected: UIImage, title: String) -> UINavigationController {
        
        let navController = UINavigationController(rootViewController: controller)
        navController.tabBarItem.selectedImage = selected
        navController.tabBarItem.image = unselected
        navController.tabBarItem.title = title
        navController.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: ( UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16) )]
        
        return navController
    }
}
