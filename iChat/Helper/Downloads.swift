//
//  Downloads.swift
//  iChat
//
//  Created by zeyad on 10/25/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import MBProgressHUD
import AVFoundation

let storage = Storage.storage()

//upload image

func uploadImage(image: UIImage , chatRoomID: String , view: UIView , completion: @escaping (_ imageLink: String?)-> Void ) {
    
    let progressHud = MBProgressHUD.showAdded(to: view, animated: true)
    progressHud.mode = .determinateHorizontalBar
    let stringDate = dateFormatter().string(from: Date())
    let photoFileName = "PictureMessages/" + FUser.currentId() + "/" + chatRoomID + "/" + stringDate + ".jpg"
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)
    let imageData = image.jpegData(compressionQuality: 0.7)
    var uploadtask: StorageUploadTask!
    uploadtask = storageRef.putData(imageData!, metadata: nil) { (metaData, error) in
        if error != nil {
            print("there is error uploading \(error!.localizedDescription )")
            return
        }
        uploadtask.removeAllObservers()
        progressHud.hide(animated: true)
        storageRef.downloadURL { (url, error) in
            guard let imageURL = url else {
                
                completion(nil)
                return
                
            }
            completion(imageURL.absoluteString)
        }
        
    }
    uploadtask.observe(StorageTaskStatus.progress) { (snapshot) in
        progressHud.progress = Float((snapshot.progress?.completedUnitCount)!) /
                               Float((snapshot.progress?.totalUnitCount)!)
    }

}

func downloadImage(imageUrl: String , completion: @escaping(_ image: UIImage?) -> Void){
    let imageURL = NSURL(string: imageUrl)
    //print(imageURL!)
    let imageFileName = (imageUrl.components(separatedBy: "%").last)!.components(separatedBy: "?").first!
    //print(imageFileName!)
    
    if fileExsistsAtPath(path: imageFileName) {
        if let contentOfFile = UIImage(contentsOfFile: fileInDocumentDirectory(fileName: imageFileName)){
            print("fuchk")
            completion(contentOfFile)
        }else {
            print("couldnot complete generation")
            completion(nil)
        }
        
    }else{
        let downloadQueue = DispatchQueue(label: "Downloading image")
        
        downloadQueue.async {
            print(imageURL!)
            print("downloadQueue")
            if let data = NSData(contentsOf: imageURL! as URL){
                var docURL = getDocumentsURL()
                              docURL = docURL.appendingPathComponent(imageFileName, isDirectory: false)
                data.write(to: docURL, atomically: true)
                let imageToReturn = UIImage(data: data as Data)
                              DispatchQueue.main.async {
                                  print("this is the imageToReturn \(imageToReturn)")
                                  completion(imageToReturn)
                              }
            }else {
                DispatchQueue.main.async {
                    print("there is no image in the database")
                    completion(nil)
                }
            }
            //let data = NSData(contentsOf: imageURL! as URL)
            
           
//            if data != nil {
//                var docURL = getDocumentsURL()
//                docURL = docURL.appendingPathComponent(imageFileName, isDirectory: false)
//                data?.write(to: docURL, atomically: true)
//                let imageToReturn = UIImage(data: data! as Data)
//                DispatchQueue.main.async {
//                    print("this is the imageToReturn \(imageToReturn)")
//                    completion(imageToReturn)
//                }
//
//            }else {
//                DispatchQueue.main.async {
//                    print("there is no image in the database")
//                    completion(nil)
//                }
//            }
        }
    }
}

//HELPERS

func fileInDocumentDirectory(fileName: String) -> String {
    let fileURL = getDocumentsURL().appendingPathComponent(fileName)
    return fileURL.path
}

func getDocumentsURL() -> URL {
    let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    return documentUrl
}
func fileExsistsAtPath(path: String) -> Bool {
    var doesExsist = false
    let filePath = fileInDocumentDirectory(fileName: path)
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: filePath) {
        doesExsist = true
        return doesExsist
    }else {
        return doesExsist
    }
    
}
