//
//  AppCategoriesViewController.swift
//  TopApps
//
//  Created by Sufyan on 15/03/17.
//  Copyright © 2017 Sufyan. All rights reserved.
//

import UIKit

protocol AppCategoriesViewControllerDelegate {
    func selectedCategory(category: String)
    func showAllCategory()
}


class AppCategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var categoryTableView: UITableView!
    var delegate: AppCategoriesViewControllerDelegate?
    var categoryNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryNames = categoryNames.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        self.categoryTableView.tableFooterView?.frame = CGRect.zero
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.categoryNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CategoryCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell")!as! CategoryCell
        cell.categoryName.text = categoryNames[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let appCell = cell as! CategoryCell
        let actualCenter : CGPoint = appCell.center
        appCell.center = CGPoint(x: tableView.frame.width * 1.5, y: actualCenter.y)
        UIView.animate(withDuration: 0.45, delay: 0.0, options: .curveEaseInOut, animations: {
            appCell.center = actualCenter
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.selectedCategory(category: self.categoryNames[indexPath.row])
        self.dismiss(animated: true)
    }
    
    @IBAction func dismissAppCategoryView(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func showAllApps(_ sender: Any) {
        self.delegate?.showAllCategory()
        self.dismiss(animated: true)
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
