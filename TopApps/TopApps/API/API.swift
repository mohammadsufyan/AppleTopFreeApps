//
//  API.swift
//  TopApps
//
//  Created by Sufyan on 08/03/17.
//  Copyright © 2017 Sufyan. All rights reserved.
//

import UIKit


protocol APIProtocol {
    var isInternetConnected: Bool {get set}
    func recievedData(data: Any, fromLocal isLocal:Bool)
}

class API: NSObject  {
    var delegate : APIProtocol?
    var urlString : String = "https://itunes.apple.com/us/rss/topfreeapplications/limit=200/json"
    
    init(withDelegate delegate: APIProtocol) {
        self.delegate = delegate
    }
    
    override init() {
        super.init()
    }
    
    func fetchJSONData() {
        
        let url = URL(string: self.urlString)
        let request = URLRequest( url: url!)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in

            if error != nil {
                self.sendDataToDelegate(data: Data(), fromLocal: false)
            }
            else {
                do {
                    if let json: Dictionary = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                    {
                        self.sendDataToDelegate(data: json, fromLocal: false)
                        DispatchQueue.global().async {
                            self.saveJSONToDocumentDirectory(jsonObject: json)
                        }
                    }
                } catch {
                    print("error in JSONSerialization")
                }
                
            }
        }
        task.resume()
    }
    
//    MARK: Recived JSON Delegate
    
    func sendDataToDelegate(data: Any, fromLocal isLocal:Bool)  {
        self.delegate?.recievedData(data: data, fromLocal: isLocal)
    }
    
//    MARK: Cache Handling Methods
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func createFolders() {
        
        let dataPath = (self.getDirectoryPath() as NSString).appendingPathComponent("Data") as String
        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent("Images") as String
        do {
            try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
            try FileManager.default.createDirectory(atPath: imagePath, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
    }
    
    func saveJSONToDocumentDirectory(jsonObject: [String: Any]){
        do{
            self.createFolders()
            let jsonData: Data = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
//            let jsonString = String(data: jsonData, encoding: .utf8)
            let filePath = (self.getDirectoryPath() as NSString).appendingPathComponent("Data/AppList.json") as String
            let fileManager = FileManager.default
            
            if fileManager.createFile(atPath: filePath as String, contents: jsonData, attributes: nil){
                print("file saved")
            }
            else {
                print("file not saved")
            }
            
        }
        catch {
            print("Problem in saving file")
        }
    }
    
    func checkImageAvailability(name: String) -> Bool {
        let fileManager = FileManager.default
        let path = (self.getDirectoryPath() as NSString).appendingPathComponent("Images/"+name+".png")
        return fileManager.fileExists(atPath: path)
    }
    
    
    func saveImages(imageDic: [String: UIImage]) {
        for (imageName, image) in imageDic {
            self.saveImageToDocumentDirectory(image: image, withName: imageName)
        }
    }
    
    func saveImageToDocumentDirectory(image:UIImage, withName name: String){
        let fileManager = FileManager.default
        let path = (self.getDirectoryPath() as NSString).appendingPathComponent("Images/"+name+".png")
        let imageData = UIImagePNGRepresentation(image)
        if fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil){
            print("Image saved")
        }
        else {
            print("Image already exist")
        }
    }
    
    func getImageFromDocumentDirectory(name: String) -> UIImage {
        let fileManager = FileManager.default
        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent("Images/"+name+".png")
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)!
        }else{
            return UIImage(named: "defaultImage")!
        }
    }
    
    func getJSONFromDocumentDirectory()  {
        
        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent("Data/AppList.json") as String
        do {
            
            let jsonData: Data = try Data(contentsOf: URL(fileURLWithPath: imagePath) , options: .alwaysMapped)
            do {
                if let json: Dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
                {
                    self.sendDataToDelegate(data: json as Any, fromLocal: true)
                }
            } catch {
                self.sendDataToDelegate(data: Data() as Any, fromLocal: true)
                print("error in JSONSerialization")
            }
        }
        catch let error as NSError {
            self.sendDataToDelegate(data: Data() as Any, fromLocal: true)
            print(error.localizedDescription)
        }
    }
    
}
