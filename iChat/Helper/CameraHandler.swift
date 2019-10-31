//
//  CamerHandler.swift
//  iChat
//
//  Created by zeyad on 10/23/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
class CameraHandler {
    
    var delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    init(delegate_:UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        delegate  = delegate_
    }
    //static let shared = CameraHandler()
        
   // fileprivate var currentVC: UIViewController!
        
    //MARK: Internal Properties
    //var imagePickedBlock: ((UIImage) -> Void)?
    
    
//    var pickedImage: UIImage?
//    var PickedVideo: NSURL?
//
    
    
    func camera(vc: UIViewController){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = delegate
            myPickerController.sourceType = .camera
            vc.modalPresentationStyle = .fullScreen
            vc.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    func photoLibrary(vc: UIViewController){
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = delegate
            myPickerController.sourceType = .photoLibrary
            vc.present(myPickerController, animated: true, completion: nil)
            vc.modalPresentationStyle = .fullScreen
            
        }
    }

}
//extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        pickedImage = info[.originalImage] as? UIImage
//        PickedVideo = info[.mediaURL] as? NSURL
//        ChattingVC.shared.sendMessage(text: nil, date: Date(), picture: pickedImage, location: nil, video: nil, audio: nil)
//        self.dismiss(animated: true, completion: nil)
//    }
//
//}


