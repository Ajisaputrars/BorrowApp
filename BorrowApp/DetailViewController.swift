//
//  DetailViewController.swift
//  BorrowApp
//
//  Created by Aji Saputra Raka Siwi on 8/7/17.
//  Copyright © 2017 Aji Saputra Raka Siwi. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var borrowedAtLabel: UILabel!
    @IBOutlet weak var returnAtLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personTextField: UITextField!
    
    var personImageAdded = false
    var itemImageAdded = false
    
    enum PicturePurpose{
        case item
        case person
    }
    
    var PicturePurposeSelector: PicturePurpose = .item
    
    var moc:NSManagedObjectContext!
    
    var detailItem: BorrowItem? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    @IBAction func saveItems(_ sender: Any) {
        if detailItem == nil {
            let borrowItem = BorrowItem(context: moc)
            borrowItem.title = itemTitleTextField.text
            
            if let itemImage = itemImageView.image {
                borrowItem.image = NSData(data: UIImageJPEGRepresentation(itemImage, 0.3)!)
            }
            
        }
        
        do {
            try moc.save()
        } catch let err as NSError{
            print ("Errornya adalah \(err) dengan detail \(err.localizedDescription)")
        }

    }
    
    func addPictureForItem(){
        PicturePurposeSelector = .item
        addImageWithPurpose()
    }
    
    func addPictureForPerson(){
        PicturePurposeSelector = .person
        addImageWithPurpose()
    }
    
    func addImageWithPurpose(){
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        
        imagePickerVC.sourceType = .photoLibrary
        
        self.present(imagePickerVC, animated: true, completion: nil)
        
    }
    
    func configureView() {
        if let titleTextField = itemTitleTextField {
            if let borrowItem = detailItem {
                titleTextField.text = borrowItem.title
                if let availableImage = borrowItem.image as Data? {
                    itemImageView.image = UIImage(data: availableImage)
                }
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let itemGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.addPictureForItem))
        itemImageView.addGestureRecognizer(itemGestureRecognizer)
        
        let personGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.addPictureForPerson))
        personImageView.addGestureRecognizer(personGestureRecognizer)
        
        configureView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let scaledImage = UIImage.scaleImage(image: image, toWidth: 120, andHeight: 120)
            
            if PicturePurposeSelector == .item {
                itemImageView.image = scaledImage
                itemImageAdded = true
            } else {
                personImageView.image = scaledImage
                personImageAdded = true
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

//    var detailItem: Event? {
//        didSet {
//            // Update the view.
//            configureView()
//        }
//    }


}

