//
//  DetailViewController.swift
//  BorrowApp
//
//  Created by Aji Saputra Raka Siwi on 8/7/17.
//  Copyright © 2017 Aji Saputra Raka Siwi. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UITableViewController {

    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var borrowedAtLabel: UILabel!
    @IBOutlet weak var returnAtLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personTextField: UITextField!
    
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
            
            
            //TODO: Not yet done
        }
        
        do {
            try moc.save()
        } catch let err as NSError{
            print ("Errornya adalah \(err) dengan detail \(err.localizedDescription)")
        }

    }
    
    func configureView() {
        // Update the user interface for the detail item.
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        
        configureView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    var detailItem: Event? {
//        didSet {
//            // Update the view.
//            configureView()
//        }
//    }


}

