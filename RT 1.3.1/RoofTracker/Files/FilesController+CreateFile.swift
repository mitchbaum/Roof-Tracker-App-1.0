//
//  FilesController+CreateFile.swift
//  TrainingCourse
//
//  Created by Mitch Baumgartner on 3/2/21.
//

import UIKit

extension FilesController: CreateFileControllerDelegate {
    // specify your extensions here
    
    func didEditFile(file: File) {
        
        // update my tableView somehow
        //find index of cell we are editing
        if(searchController.isActive) {
            print("Active")
            let row = filteredFiles.firstIndex(of: file)
            // this will update row automatically when you press save
            let reloadIndexPath = IndexPath(row: row!, section: 0)
            // cell will be reloaded and animated with .middle animation
            tableView.reloadRows(at: [reloadIndexPath], with: .middle)
        } else {
            let row = files.firstIndex(of: file)
            // this will update row automatically when you press save
            let reloadIndexPath = IndexPath(row: row!, section: 0)
            // cell will be reloaded and animated with .middle animation
            tableView.reloadRows(at: [reloadIndexPath], with: .middle)
        }
    }
    
    func didAddFile(file: File) {
        // modify array
        files.insert(file, at: 0)
        // insert a new indexpath into tableView
//        let newIndexPath = IndexPath(row: files.count - 1, section: 0)
//        tableView.insertRows(at: [newIndexPath], with: .automatic)
        tableView.reloadData()
    }
    
}
