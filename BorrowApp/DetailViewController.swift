//
//  DetailViewController.swift
//  BorrowApp
//
//  Created by Aji Saputra Raka Siwi on 8/7/17.
//  Copyright © 2017 Aji Saputra Raka Siwi. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TimeFrameDelegate, MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource {

    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var borrowedAtLabel: UILabel!
    @IBOutlet weak var returnAtLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personTextField: MLPAutoCompleteTextField!
    
    
    var personImageAdded = false
    var itemImageAdded = false
    var startDate:NSDate?
    var endDate:NSDate?
    
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
            
            let request:NSFetchRequest<Person> = Person.fetchRequest()
            
            if let name = personTextField.text {
                request.predicate = NSPredicate(format: "name == %@", name)
            }
            
            request.fetchLimit = 1
            
            
            let numberOfResults = try! moc.count(for: request)
            
            if numberOfResults == 0 { // create a new person
                let newPerson = Person(context: moc)
                
                newPerson.name = personTextField.text
                
                if let personImageToSave = personImageView.image {
                    newPerson.image = NSData(data:UIImageJPEGRepresentation(personImageToSave, 0.3)!)
                }
                
                newPerson.addToBorrowItem(borrowItem)
                
            }else{
                var items = [Person]()
                
                do {
                    try items = moc.fetch(request)
                }catch{
                    print(error)
                }
                
                if let foundPerson = items.first {
                    foundPerson.addToBorrowItem(borrowItem)
                }
                
            }
            
            if let availableStartDate = startDate {
                borrowItem.startDate = availableStartDate
            }
            
            if let availableEndDate = endDate {
                borrowItem.endDate = availableEndDate
            }
            
        } else {
            if let availableStartDate = startDate {
                detailItem?.startDate = availableStartDate
            }
            
            if let availableEndDate = endDate {
                detailItem?.endDate = availableEndDate
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
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                
                if let startDateToDisplay = borrowItem.startDate as Date? {
                    borrowedAtLabel.text = "Borrowed at: \(dateFormatter.string(from: startDateToDisplay))"
                }
                
                if let endDateToDisplay = borrowItem.endDate as Date?{
                    returnAtLabel.text = "Return at: \(dateFormatter.string(from: endDateToDisplay))"
                }
                
                if let assosiatedPerson = borrowItem.person{
                    personTextField.text = assosiatedPerson.name
                    
                    if let personImageData = assosiatedPerson.image as Data? {
                        personImageView.image = UIImage(data: personImageData)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        personTextField.autoCompleteDelegate = self
        personTextField.autoCompleteDataSource = self
        personTextField.autoCompleteTableAppearsAsKeyboardAccessory = true
        personTextField.autoCompleteTableBackgroundColor = UIColor.white

        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTimeFrameVC" {
            let timeFrameVC = segue.destination as! TimeframeViewController
            timeFrameVC.timeFrameDelegate = self
        }
    }
    
    func didSelectTimeRange(range: GLCalendarDateRange) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        borrowedAtLabel.text = "Borrowed At \(dateFormatter.string(from: range.beginDate))"
        returnAtLabel.text = "Return At \(dateFormatter.string(from: range.endDate))"
        
        startDate = range.beginDate as NSDate
        endDate = range.endDate as NSDate

    }
    
    func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!, possibleCompletionsFor string: String!) -> [Any]! {
        let fetchRequest:NSFetchRequest<Person> = Person.fetchRequest()
        
        var personObjects = [Person]()
        
        do {
            personObjects = try moc.fetch(fetchRequest)
        }catch{
            print(error)
        }
        
        var nameArray = [String]()
        
        for person in personObjects {
            if let name = person.name {
                nameArray.append(name)
            }
        }
        
        return nameArray
    }
    
    func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!, didSelectAutoComplete selectedString: String!, withAutoComplete selectedObject: MLPAutoCompletionObject!, forRowAt indexPath: IndexPath!) {
        let predicate = NSPredicate(format: "name == %@", selectedString)
        
        let fetchRequest:NSFetchRequest<Person> = Person.fetchRequest()
        fetchRequest.predicate = predicate
        
        var selectedPerson:Person?
        
        do {
            selectedPerson = try moc.fetch(fetchRequest).first
        }catch{
            print(error)
        }
        
        if let imageData = selectedPerson?.image as Data? {
            personImageView.image = UIImage(data: imageData)
        }

    }

//    var detailItem: Event? {
//        didSet {
//            // Update the view.
//            configureView()
//        }
//    }


}

