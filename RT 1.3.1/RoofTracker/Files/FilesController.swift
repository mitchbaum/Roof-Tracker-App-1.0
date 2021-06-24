//
//  ViewController.swift
//  TrainingCourse
//
//  Created by Mitch Baumgartner on 2/27/21.
//

import UIKit
import CoreData

// controller name should reflect what it is presenting
class FilesController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    // let: constant
    // var: variable that can be modified
    // initilalize array with list of things
    var files = [File]() // empty array
    var filteredFiles = [File]()
    var file: File?

    let searchController = UISearchController()
    

    
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
        filterFiles()
        setupUI()
        
        // this modifies the property on table view (accesses the white list of cells)
        // changes color of list to dark blue
        tableView.backgroundColor = UIColor.darkBlue
        // removes lines of tableView
        //tableView.separatorStyle = .none
        // change color of seperator lines
        tableView.separatorColor = .gray
        
        // removes lines below cells
        tableView.tableFooterView = UIView() // blank UIView
        // this method takes in a cell class of type "any class" and takes in a string of "cellId" the class type is found by using .self
        // call the fileCell in fileCell.swift file for the type of cell we are returning, this gives us custom cell abilities
        // register fileCell wiht cellId
        tableView.register(FileCell.self, forCellReuseIdentifier: "cellId")
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddFile))
        // plus sign image for bar button item: UIBarButtonItem(image: #imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddFile))
        
        //setupUI()
        setTypeToOpen()
        initSearchController()
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
    
    func setTypeToOpen() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        for  i in files {
            if i.type == nil {
                i.type = "Open"
                //print(i.type)
            }
        }
        do {
            try context.save()
        } catch let saveErr {
            print("Failed to save file changes:", saveErr)
        }
        
        
        
        
        
    }
    func initSearchController() {

        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = true
        //searchController.searchBar.placeholder = "Search for files"
        // change color and text of placeholder
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString.init(string: "Search for files", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        // makes text and buttons in searchbar white
        searchController.searchBar.barStyle = .black

        searchController.searchBar.returnKeyType = UIReturnKeyType.search
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        //navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.scopeButtonTitles = ["Open", "Closed", "All"]
        //searchController.searchBar.showsScopeBar = true
        searchController.searchBar.delegate = self
        searchController.searchBar.becomeFirstResponder()
    }
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!
        filterForSearchAndScopeButton(searchText: searchText, scopeButton: scopeButton)

    }
    func filterForSearchAndScopeButton(searchText: String, scopeButton : String = "Open") { // default to open
        // this will give all the files in the coreDatabase layer
        files = CoreDataManager.shared.fetchFiles()

        filteredFiles = files.filter {
            file in
            // this sets the filter by type
            let scopeMatch = (scopeButton == "All" || file.type!.lowercased().contains(scopeButton.lowercased()))
            if (searchController.searchBar.text != "") {
                let searchTextMatch = file.name!.lowercased().contains(searchText.lowercased())
                return scopeMatch && searchTextMatch
            } else {
                return scopeMatch
            }
        }
        tableView.reloadData()
    }
    
    func filterFiles() {
        files = CoreDataManager.shared.fetchFiles()
        let fileType = openClosedSegmentedControl.titleForSegment(at: openClosedSegmentedControl.selectedSegmentIndex)
        filteredFiles = files.filter {
            file in
            let match = (fileType == "Open" || file.type!.lowercased().contains((fileType?.lowercased())!))
            if fileType == "Open" {
                return match
            } else {
                return match
            }
        }
        tableView.reloadData()
        
    }
    
    
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
    
    
    // segmented control for open or close files
    let openClosedSegmentedControl: UISegmentedControl = {
        let types = ["Open", "Closed"]
        let sc = UISegmentedControl(items: types)
        // default as first item
        sc.selectedSegmentIndex = 0
        //sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        // highlighted filter color
        sc.selectedSegmentTintColor = UIColor.white
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        return sc
    }()
    
    func setupUI() {
//        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35))
//        tableView.addSubview(header)
        tableView.addSubview(openClosedSegmentedControl)
        openClosedSegmentedControl.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        openClosedSegmentedControl.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        //openClosedSegmentedControl.rightAnchor.constraint(equalTo: tableView.rightAnchor, constant: -6).isActive = true
        openClosedSegmentedControl.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        //openClosedSegmentedControl.leftAnchor.constraint(equalTo: tableView.leftAnchor, constant: 6).isActive = true
        
        //openClosedSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        //openClosedSegmentedControl.widthAnchor.constraint(equalToConstant: 300).isActive = true
        tableView.tableHeaderView = openClosedSegmentedControl
    }
    
}









