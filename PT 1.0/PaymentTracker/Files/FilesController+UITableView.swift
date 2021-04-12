//
//  filesController+UITableView.swift
//  TrainingCourse
//
//  Created by Mitch Baumgartner on 3/2/21.
//

import UIKit
// this file will hold all my tableView delegate functions
extension FilesController {
    // when user taps on row bring them into another view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // whenever user taps on a file cell, push over the information to the employee view controller
        let file = self.files[indexPath.row]
        
        let itemsController = ItemsController()
        itemsController.file = file
        
        
        // push into new viewcontroller
        navigationController?.pushViewController(itemsController, animated: true)
    }
    
    // delete file from tableView and coredata
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            // get file you are swiping on to get delete action
            let file = self.files[indexPath.row]
            
            print("attempting to delete file", file.name ?? "")
            
            // remove the file from the tableView
            self.files.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // delete the file from coreData
            let context = CoreDataManager.shared.persistentContainer.viewContext
       
            context.delete(file)
            // save() will persist the function of deleting in the database
            do {
                 try context.save()
            } catch _ {
                print("failed to delete file")
            }
        }
        // change color of delete button
        deleteAction.backgroundColor = UIColor.lightRed
        // perform edit action
        let editAction = UITableViewRowAction(style: .normal , title: "Edit", handler: editHandlerFunction)
        // change color of edit button
        editAction.backgroundColor = UIColor.darkBlue

        
        // this puts the action buttons in the row the user swipes so user can actually see the buttons to delete or edit
        return [deleteAction, editAction]
    }
    
    // edit cell function 
    private func editHandlerFunction(action: UITableViewRowAction, indexPath: IndexPath) {
        print("Editing file in seperate function")
        // pop up modal that displays information about the selected file
        let editFileController = CreateFileController()
        
        editFileController.delegate = self
        // find the file you are swiping and put the file in the text area to edit
        editFileController.file = files[indexPath.row]
        let navController = CustomNavigationController(rootViewController: editFileController)
        present(navController, animated: true, completion: nil)
    }
    
    // create footer that displays when there are no files in the table
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No files available.."
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }
    // create footer that is hidden when no rows are present
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return files.count == 0 ? 150 : 0
    }
    
    // create some cells for the rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // this will return a UITableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! FileCell
        
        //when you call the file on the cell, you trigger the didSet property in fileCell.swift file for var file: file?
        let file = files[indexPath.row]
        cell.file = file
        
        
//        // change cell background color
//
//        // the cell takes a color with variable from UIColor+theme.swift file, in this case the function UIColor with the variable "someColor" found in that file
//        //cell.backgroundColor = UIColor.tealColor
//        // add some text to each cell and text color
//        // access file for each row by using files model
//        let file = files[indexPath.row]
//        // make date show up pretty in cell by unwrapping name and founded property
//
//
//        cell.textLabel?.textColor = .white
//        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
//
        // place image in cell, each cell already has a image property for, once you call for it it will show up
//        cell.imageView?.image = #imageLiteral(resourceName: "select_photo_empty");
//        if let imageData = file.imageData {
//            cell.imageView?.image = UIImage(data: imageData);
//        }
        return cell
}
    // height of each cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    // add some rows to the tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // returns number of rows as number of files
        return files.count
    }
    
    
}
