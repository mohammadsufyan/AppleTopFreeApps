//
//  AppDetailViewController.swift
//  TopApps
//
//  Created by Sufyan on 10/03/17.
//  Copyright © 2017 Sufyan. All rights reserved.
//

import UIKit

class AppDetailViewController: UIViewController {

    var appInformation: AppInformation = AppInformation()
    
    @IBOutlet weak var appImageView: UIImageView!
    
    @IBOutlet weak var appNameLabel: UILabel!
    
    @IBOutlet weak var appCopyrightLabel: UILabel!
    
    @IBOutlet weak var appDescriptionTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "App Details"
        self.appDescriptionTextView.isScrollEnabled = false
        self.loadAppDataInView()
    }

    // MARK: - Load App Details 
    
    func loadAppDataInView() {
        self.appImageView.image = self.appInformation.appImage
        self.appNameLabel.text = self.appInformation.appName
        self.appCopyrightLabel.text = self.appInformation.copyright
        self.appDescriptionTextView.text = self.appInformation.description
        self.appDescriptionTextView.isScrollEnabled = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
