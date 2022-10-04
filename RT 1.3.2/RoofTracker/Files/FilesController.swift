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
    // this variable is for the search feature
    var filteredFiles = [File]()
    // this variable is for the open close segmented control feature
    var rowsToDisplay = [File]()
    var file: File?
    
//    var openFiles = [File]()
//    var closedFiles = [File]()
    // this variable is for the open close segmented control feature
    // the "lazy" means that this variable is created AFTER the files variable is created.

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
        //filterFiles()
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
        
        setTypeToOpen()
        filterFiles()
        initSearchController()
        newAppAlert()
        print("reloaded files")
        
    }
    
    // add alert that this app will be shutting down and to move to the new Roof Tracker
    func newAppAlert() {
        showError(title: "Attention!", message: "This version of the application will no longer be available in the next update version 2.0. All your data will be lost after that update. Please transition over to the new version called \"Roof Tracker\" in the App Store and add your files. Find the full transition notes in the What's New section of this update.")
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
        // makes text in search bar white
        searchController.searchBar.barStyle = .black
        // makes color of "Cancel" and cursor blinking white
        searchController.searchBar.tintColor = .white
        // Text field in search bar.
        let textField = searchController.searchBar.value(forKey: "searchField") as! UITextField
        let glassIconView = textField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        glassIconView.tintColor = UIColor.white
        // Scope: Normal text color
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        // Scope: Selected text color
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
    
        
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
        setupUI()
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
        rowsToDisplay = files.filter {
            file in
            let match = (file.type!.lowercased().contains((fileType?.lowercased())!))
            //print("returning file type is ", fileType, ": ", match)
            return match
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
        // this handles then segment changing action
        sc.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        
        sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        // highlighted filter color
        sc.selectedSegmentTintColor = UIColor.white
        // changes text color to black for selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        // changes text color to black for non selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        return sc
    }()
    
    @objc fileprivate func handleSegmentChange() {
        print(openClosedSegmentedControl.selectedSegmentIndex)
        // these lines are to handle the different segment indexes (0 = open, 1 = closed)
        switch openClosedSegmentedControl.selectedSegmentIndex {
        case 0:
            filterFiles()
            //print("OPEN rowsToDisplay: ", rowsToDisplay.count)
        case 1:
            filterFiles()
            //print("CLOSED rowsToDisplay: ", rowsToDisplay.count)
        default:
            filterFiles()
        }
        tableView.reloadData()
    }
    
    func setupUI() {
//        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35))
//        tableView.addSubview(header)
        let HEADER_HEIGHT = 34
        tableView.addSubview(openClosedSegmentedControl)
        openClosedSegmentedControl.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        openClosedSegmentedControl.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        //openClosedSegmentedControl.rightAnchor.constraint(equalTo: tableView.rightAnchor, constant: -6).isActive = true
        openClosedSegmentedControl.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        //openClosedSegmentedControl.leftAnchor.constraint(equalTo: tableView.leftAnchor, constant: 6).isActive = true
        
        openClosedSegmentedControl.heightAnchor.constraint(equalToConstant: 34).isActive = true
        //openClosedSegmentedControl.widthAnchor.constraint(equalToConstant: 300).isActive = true
        tableView.tableHeaderView = openClosedSegmentedControl
        tableView.tableHeaderView?.frame.size = CGSize(width: tableView.frame.width, height: CGFloat(HEADER_HEIGHT))
        // this hides the segmented control buttons when search is active
        if searchController.isActive {
            tableView.tableHeaderView = nil
            tableView.tableHeaderView?.isHidden = true
        }
    }
    
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "I understand", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    
}









