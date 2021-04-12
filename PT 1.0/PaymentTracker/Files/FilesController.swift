//
//  ViewController.swift
//  TrainingCourse
//
//  Created by Mitch Baumgartner on 2/27/21.
//

import UIKit
import CoreData

// controller name should reflect what it is presenting
class FilesController: UITableViewController {
    // let: constant
    // var: variable that can be modified
    // initilalize array with list of things
    var files = [File]() // empty array

    
    // this function will refresh the viewController when user goes back from the file summary controller, refreshing the cell to reflect the most accurate ins still owes HO
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view did appear reload files")
//        // this will give all the files in the coreDatabase layer
        self.files = CoreDataManager.shared.fetchFiles()
        tableView.reloadData()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem.leftBarButtonItem = UIBarButtonItem(title: "TEST ADD", style: .plain, target: self, action: #selector(addfile))
        // this will give all the files in the coreDatabase layer
        self.files = CoreDataManager.shared.fetchFiles()
        
        
        // nav item for Reset all button in top left corner
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset))
        
        // creates title of files
        navigationItem.title = "Files"
        
        
        // this modifies the property on table view (accesses the white list of cells)
        // changes color of list to dark blue
        tableView.backgroundColor = UIColor.darkBlue
        // removes lines of tableView
        //tableView.separatorStyle = .none
        // change color of seperator lines
        tableView.separatorColor = .white
        
        // removes lines below cells
        tableView.tableFooterView = UIView() // blank UIView
        // this method takes in a cell class of type "any class" and takes in a string of "cellId" the class type is found by using .self
        // call the fileCell in fileCell.swift file for the type of cell we are returning, this gives us custom cell abilities
        // register fileCell wiht cellId
        tableView.register(FileCell.self, forCellReuseIdentifier: "cellId")
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddFile))
        print("reloaded files")
    }
//    // function that handles reset button
//    @objc private func handleReset(){
//        print("Attempting to delete all core data objects...")
//        // context configures and modifies objects inside of core data, always needed
//        let context = CoreDataManager.shared.persistentContainer.viewContext
//
//        // this batch request removes all the files objects from core data
//        let batchDeleteRequest = NSBatchDeleteRequest (fetchRequest: File.fetchRequest())
//        do {
//            try context.execute(batchDeleteRequest)
//
//            var indexPathsToRemove = [IndexPath]()
//            for (index, file) in files.enumerated() {
//                let indexPath = IndexPath(row: index, section:0)
//                indexPathsToRemove.append(indexPath)
//            }
//            // this will remove all files from my files array
//            files.removeAll()
//            // create animation (.left) that upon deletion from coredata succeeded
//            tableView.deleteRows(at: indexPathsToRemove, with: .left)
//
//        } catch let delErr {
//            print("failed to delete objects from coredata")
//        }
//
//    }
    
    // function that handles the plus button in top right corner
    @objc func handleAddFile() {
        print("Adding file..")
        
        // present modal presentation style (window will pop up from bottom)
        // this will access the CreatefileController.swift file and use the variables/functions defined in there
        let createFileController = CreateFileController()

        // customNavigationController is found in the appDelegate.swift file to use light content
        let navController = CustomNavigationController(rootViewController: createFileController)
        // fullscreen modal view
        //navController.modalPresentationStyle = .fullScreen
        // create link between createfileController and filesController
        createFileController.delegate = self
        present(navController, animated: true, completion: nil)
    }
    
    
}









