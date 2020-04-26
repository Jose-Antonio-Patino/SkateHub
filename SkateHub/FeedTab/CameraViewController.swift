//
//  CameraViewController.swift
//  SkateHub
//
//  Copyright © 2020 Jose Patino/Aldo Almeida/Paola Camacho All rights reserved.
//

import UIKit
import Parse
class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var captionField: UITextView!
    @IBOutlet weak var postBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onPostButton(_ sender: Any) {
        self.postBtn.isEnabled=false
        let post = PFObject(className: "Posts")
        
        post["caption"] = captionField.text!
        post["author"] = PFUser.current()!
        
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        post["image"] = file
        
        post.saveInBackground(block: { (success, error) in
            if success{
                self.postBtn.isEnabled=true
                print("Saved!")
                self.dismiss(animated: true, completion: nil)
            }else{
                self.postBtn.isEnabled=true
                print("Error!")
            }

            
        })
        
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        //let size = CGSize(width: 300, height: 300)
        //let scaledImage = image.af_imageAspectScaled(toFill: size)
        
        imageView.image = image
        
        dismiss(animated: true, completion: nil)
        
        
        
        
        
    }


}
