//
//  ViewController.swift
//  TopApps
//
//  Created by Sufyan on 08/03/17.
//  Copyright © 2017 Sufyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, APIProtocol, AppCategoriesViewControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var appCollectionView: UICollectionView!
    
    var appListArray: Array = [[String: Any]]()
    var showDataArray: Array = [[String: Any]]()
    var allCategoryList: Dictionary<String, [Dictionary<String, Any>]> = [String: [Dictionary]]()
    var categorisedAppsList: [Dictionary<String, Any>] = [[String: Any]]()
    var categoryName: String = ""
    var imageCache: Dictionary = [String: UIImage]()
    internal var isInternetConnected: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "All Apps"
        self.isInternetConnected = Reachability.connectedToNetwork()
        self.callAPIForData()
    }
    
    func callAPIForData()  {
        API(withDelegate: self).fetchJSONData()
    }
    
    func callAPIForLocalFile() {
        API(withDelegate: self).getJSONFromDocumentDirectory()
    }
    
    // MARK:    CollectionView Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.showDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : AppCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppCell", for: indexPath) as! AppCell
        let appInfo : Dictionary = self.showDataArray[indexPath.row]
        let appName: String = (appInfo["im:name"] as! [String: Any])["label"] as! String
        let copyright: String = (appInfo["im:artist"] as! [String: Any])["label"] as! String
        cell.appName.text = appName
        cell.copyright.text = copyright
        if self.imageCache[appName] == nil && self.isInternetConnected {
            DispatchQueue.global().async {
                let imageURLString: String = ((appInfo["im:image"] as! [[String: Any]])[2])["label"] as! String
                let url = URL(string: imageURLString)
                do{
                    let data = try Data(contentsOf: url!)
                    self.imageCache[appName] = UIImage(data: data)!
                }
                catch {
                    print("No image found at URL")
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        let appCell = cell as! AppCell
        let appInfo : Dictionary = self.showDataArray[indexPath.row]
        let appName: String = (appInfo["im:name"] as! [String: Any])["label"] as! String
        if self.imageCache[appName] != nil {
            appCell.appImage.image = self.imageCache[appName]
        } else{
            appCell.appImage.image = API().getImageFromDocumentDirectory(name: appName)
        }
        let previousFrame: CGRect = appCell.appImage.frame
        appCell.appImage.frame = CGRect(x: appCell.appImage.center.x, y: appCell.appImage.center.y, width: 0, height: 0)
        UIView.animate(withDuration: 0.65, delay: 0.0, options: .curveEaseInOut, animations: {
            appCell.appImage.frame = previousFrame
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if UIScreen.main.bounds.width > 375 {
            return UIEdgeInsetsMake(10, 0, 10, 0)
        } else if UIScreen.main.bounds.width <= 320 {
            return UIEdgeInsetsMake(10, 0, 10, 0)
        }
        else {
            return UIEdgeInsetsMake(10, 20, 10, 20)
        }
    }
    
    // MARK:    Segue Method
    
    func getSelectedApplicationInfoObject() -> AppInformation {
        let appInfo : Dictionary<String, Any>
        let indexPaths: [IndexPath] = self.appCollectionView.indexPathsForSelectedItems!
        appInfo = self.showDataArray[indexPaths[0].row]
        let appName: String = (appInfo["im:name"] as! [String: Any])["label"] as! String
        let copyright: String = (appInfo["rights"] as! [String: Any])["label"] as! String
        let description: String = (appInfo["summary"] as! [String: Any])["label"] as! String
        var appImage: UIImage
        if self.imageCache[appName] != nil {
            appImage = self.imageCache[appName]!
        }
        else{
            appImage = API().getImageFromDocumentDirectory(name: appName)
        }
        var appInformation: AppInformation = AppInformation.init()
        appInformation.appImage = appImage
        appInformation.appName = appName
        appInformation.copyright = copyright
        appInformation.description = description
        return appInformation
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAppDetail" {
            let appInformation: AppInformation = self.getSelectedApplicationInfoObject()
            let detailViewController: AppDetailViewController = segue.destination as! AppDetailViewController
            detailViewController.appInformation = appInformation
        }
        if segue.identifier == "showAllCategories" {
            if self.allCategoryList.count > 0 {
                let allCategories: [String] = self.getAllCategoriesName()
                let appCategoryView: AppCategoriesViewController = segue.destination as! AppCategoriesViewController
                appCategoryView.categoryNames = allCategories
                appCategoryView.delegate = self
                
            } else {
                let showAlert = UIAlertController.init(title: "Message", message: "No Categories to show", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Ok", style: .default) { (action) in
                }
                showAlert.addAction(cancel)
                present(showAlert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK:    Get All Categories Names
    
    func getAllCategoriesName() -> [String] {
        var categoryNames = [String]()
        for key in self.allCategoryList.keys {
            categoryNames.append(key)
        }
        return categoryNames
    }
    
    @IBAction func showWishList(_ sender: Any) {
        self.appCollectionView.reloadData()
    }
    
    // MARK:    APIProtocol Delegate Method
    
     func recievedData(data: Any, fromLocal isLocal:Bool) {
        if (data as? [String: Any]) != nil {
            let JSONData: Dictionary = data as! [String: Any]
            let dataArray: Array = (JSONData["feed"] as! [String: Any])["entry"] as! [[String: Any]]
            updateViewWithRecievedData(dataArray: dataArray)
        } else {
            if !isLocal {
                self.callAPIForLocalFile()
            } else {
                let showAlert = UIAlertController.init(title: "Error", message: "No Preview Available make sure you are connected to internet.", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Ok", style: .default) { (action) in
                }
                showAlert.addAction(cancel)
                present(showAlert, animated: true, completion: nil)
            }
        }
    }

    // MARK:    Update View Method
    func updateViewWithRecievedData(dataArray: [[String: Any]])  {
        self.appListArray = dataArray
        self.showDataArray = dataArray
        self.findAllCategories()
        if self.isInternetConnected {
            DispatchQueue.global().async {
                self.makeImageCache()
            }
        }
        DispatchQueue.main.async {
            self.appCollectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    // MARK:    Find all categories
    
    func findAllCategories() {
        for appInfo: Dictionary in self.appListArray {
            let appCategory: String = ((appInfo["category"] as! [String: Any])["attributes"] as! [String: Any])["term"] as! String
            if self.allCategoryList[appCategory] != nil {
                var array: [Dictionary] = self.allCategoryList[appCategory]! as [Dictionary]
                array.append(appInfo)
                self.allCategoryList[appCategory] = array
            } else {
                var newArray = [Dictionary<String, Any>]()
                newArray.append(appInfo)
               self.allCategoryList[appCategory] = newArray
            }
        }
    }
    
    func makeImageCache() {
        for (index,item) in self.appListArray.enumerated() {
            let appInfo : Dictionary = item
            let appName: String = (appInfo["im:name"] as! [String: Any])["label"] as! String
            if self.imageCache[appName] == nil {
                let imageURLString: String = ((appInfo["im:image"] as! [[String: Any]])[2])["label"] as! String
                let url = URL(string: imageURLString)
                do{
                    let data = try Data(contentsOf: url!)
                    self.imageCache[appName] = UIImage(data: data)!
                    DispatchQueue.main.async {
                        if self.showDataArray.count > index {
                            self.appCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                        }
                    }
                }
                catch {
                    print("No image found at URL")
                }
            }
        }
        API().saveImages(imageDic: self.imageCache)
    }
    
    // MARK:    Category Delegate Method
    
    func selectedCategory(category: String){
        let categoryApps : [Dictionary<String, Any>] = self.allCategoryList[category]!
        self.showDataArray = categoryApps
        self.categoryName = category
        self.appCollectionView.reloadData()
        self.title = category
    }
    
    func showAllCategory(){
        self.title = "All Apps"
        self.showDataArray = self.appListArray
        self.categoryName = ""
        self.appCollectionView.reloadData()
    }
}

