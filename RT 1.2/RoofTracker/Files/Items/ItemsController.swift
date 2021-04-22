//
//  EmployeesController.swift
//  TrainingCourse
//
//  Created by Mitch Baumgartner on 3/2/21.
//

import UIKit
import CoreData

// create UILabel subclass for custom text drawing - usually for my headers
class IndentedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let customRect = rect.inset(by: insets)
        super.drawText(in: customRect)
    }
}

class ItemsController: UITableViewController, createCheckControllerDelegate, createLineItemControllerDelegate {

    
    // append each employee we recieve from this method call (didAddEmployee) to the file associated with the employee
    // this is called when we dismiss empoyee creation
    func didAddItem(item: FileItem) {
        print("did add item")
        //employees.append(employee)
        allItems.append([item])
        fetchItems()
        fetchInsToHOTotal()
        tableView.reloadData()
        // refresh the balance remaining label
        viewWillAppear(true)
        
    }
    
    
    var file: File?
    
    // create employees array for employees in each file
   // var employees = [Employee]()
    
    public func saveTime() {
        // persist the change in coredata
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let timeStamp = "\(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .long))"
        file?.timeStamp = timeStamp
        
        do {
            try context.save()
        } catch let saveErr {
            print("Failed to save file changes:", saveErr)
        }
        
    }
//    public func saveInsStillOwesHO() {
//        // persist the change in coredata
//        let context = CoreDataManager.shared.persistentContainer.viewContext
//        file?.insCheckACVTotal =
//    }
    // this function controls what the employee view controller looks like when user taps on it
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        saveTime()
        navigationItem.title = file?.name

        
        // make date show up pretty in cell by unwrapping name and founded property
        if let coc = Double(file?.coc ?? ""), let invoice = Double(file?.invoice ?? ""), let deductible = Double(file?.deductible ?? "") {
            let cocMessage = currencyFormatter.string(from: NSNumber(value: coc))
            cocTotalLabelInfo.text = cocMessage
            let invoiceMessage = currencyFormatter.string(from: NSNumber(value: invoice))
            invoiceTotalLabelInfo.text = invoiceMessage
            let deductibleMessage = currencyFormatter.string(from: NSNumber(value: deductible))
            deductibleTotalLabelInfo.text = deductibleMessage
            let cashTotal = Double(file?.cashItemTotal ?? "")
            let pymtsMade = Double(file?.pymtCheckTotal ?? "")
            let invoiceBalance = coc + (cashTotal ?? 0.00) - (pymtsMade ?? 0.00)
            let invoiceBalanceMessage = currencyFormatter.string(from: NSNumber(value: invoiceBalance))
            invoiceBalanceTotalLabelInfo.text = invoiceBalanceMessage
            

            
            
        } else if Double(file?.deductible ?? "") != nil  {
            cocTotalLabelInfo.text = ""
            if file?.coc != "" {
                let coc = Double(file?.coc ?? "")
                let cocMessage = currencyFormatter.string(from: NSNumber(value: coc ?? 0.00))
                cocTotalLabelInfo.text = cocMessage
            }
            
            invoiceTotalLabelInfo.text = ""
            if file?.invoice != "" {
                let invoice = Double(file?.invoice ?? "")
                let invoiceMessage = currencyFormatter.string(from: NSNumber(value: invoice ?? 0.00))
                invoiceTotalLabelInfo.text = invoiceMessage
            }
            
            deductibleTotalLabelInfo.text = ""
            if file?.deductible != "" {
                let deductible = Double(file?.deductible ?? "")
                let deductibleMessage = currencyFormatter.string(from: NSNumber(value: deductible ?? 0.00))
                deductibleTotalLabelInfo.text = deductibleMessage
            }
            
        } else if Double(file?.invoice ?? "") != nil {
            cocTotalLabelInfo.text = file?.coc
            let invoice = Double(file?.invoice ?? "")
            let invoiceMessage = currencyFormatter.string(from: NSNumber(value: invoice ?? 0.00))
            invoiceTotalLabelInfo.text = invoiceMessage
            
            deductibleTotalLabelInfo.text = file?.deductible
            
        } else if Double(file?.coc ?? "") != nil {
            let coc = Double(file?.coc ?? "")
            let cocMessage = currencyFormatter.string(from: NSNumber(value: coc ?? 0.00))
            cocTotalLabelInfo.text = cocMessage
            invoiceTotalLabelInfo.text = file?.invoice
            deductibleTotalLabelInfo.text = file?.deductible
        }
        else {
            cocTotalLabelInfo.text = ""
            invoiceTotalLabelInfo.text = ""
            deductibleTotalLabelInfo.text = ""
        }
        
        // this handles the RCV total section
        // print empty label to summary section
        rcvTotalLabelInfo.text = ""
        // if there has been an entered item, but deleted this will handle the making the label empty
        if file?.rcvItemTotal == "0.0" {
            rcvTotalLabelInfo.text = ""
        } else if file?.rcvItemTotal != "" { // else there is a number entered 
            let rcv = Double(file?.rcvItemTotal ?? "")
            let rcvMessage = currencyFormatter.string(from: NSNumber(value: rcv ?? 0.0))
            rcvTotalLabelInfo.text = rcvMessage
        }


    }

    // creates style of header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        // make headers refelct what goes information goes into the sections

        if section == 0 {
            label.text = "Insurance Checks Recieved"
        } else if section == 1 {
            label.text = "Insurance Checks Recieved AND Paid"
        } else if section == 2 {
            label.text = "Personal Checks Paid"
        } else if section == 3 {
            label.text = "ACV Owed to HO"
        } else if section == 4 {
            label.text = "RCV Work to do"
        } else {
            label.text = "Cash Work to do"
        }

        label.backgroundColor = UIColor.lightBlue
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)



        return label
    }
    
    // creates height of header
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    // an array of arrays of employees
    var allItems = [[FileItem]]()

    
    
    func fetchInsToHOTotal() {
        tableView.reloadData()
        guard let fileItems = file?.fileItems?.allObjects as? [FileItem] else { return }
        var insCheckTotal = 0.0
        var ACVItemTotal = 0.0
        var cashItemTotal = 0.0
        var pymtCheckTotal = 0.0
        var RCVItemTotal = 0.0
        for item in fileItems {
            if item.type! == "Insurance" || item.type! == "Insurance PAID" {
                let checkAmount = Double(item.itemInformation?.checkAmount ?? "")
                insCheckTotal += checkAmount ?? 0.0
                
            }
            else if item.type! == "ACV owed to HO" {
                let itemAmount = Double(item.itemInformation?.linePrice ?? "")
                ACVItemTotal += itemAmount ?? 0.0
                
            }
            else if item.type! == "Cash work to do" {
                let itemAmount = Double(item.itemInformation?.linePrice ?? "")
                cashItemTotal += itemAmount ?? 0.0
            }
            else if item.type! == "RCV work to do" {
                let itemAmount = Double(item.itemInformation?.linePrice ?? "")
                RCVItemTotal += itemAmount ?? 0.0
                
            }
            if item.type! == "Personal" || item.type! == "Insurance PAID"{
                let checkAmount = Double(item.itemInformation?.checkAmount ?? "")
                pymtCheckTotal += checkAmount ?? 0.0
            }
        }

        file?.insCheckTotal = String(insCheckTotal)
        file?.acvItemTotal = String(ACVItemTotal)
        file?.insCheckACVTotal = String(ACVItemTotal - insCheckTotal)
        //print("Insurance checks + ACV = $", file?.insCheckACVTotal ?? 0.0)
        file?.cashItemTotal = String(cashItemTotal)
        //print(cashItemTotal)
        file?.pymtCheckTotal = String(pymtCheckTotal)
        //print(pymtCheckTotal)
        file?.rcvItemTotal = String(RCVItemTotal)
        // persist the change in coredata
        let context = CoreDataManager.shared.persistentContainer.viewContext
        do {
            try context.save()
            // save succeeded

        } catch let saveErr {
            print("Failed to save file changes:", saveErr)
        }
        
    }


    
    // fetch employees for each file when user taps on file
    private func fetchItems() {
        // this will prevent a crash if it is not able to cast all objects into employees properly
        guard let fileItems = file?.fileItems?.allObjects as? [FileItem] else { return }
        // filter senior management for "Executives"
        let insChecksRecieved = fileItems.filter { (item) -> Bool in
            return item.type == "Insurance"
        }
        // filter staff for "Executives"
        let insChecksRecievedAndPaid = fileItems.filter { (item) -> Bool in
            return item.type == "Insurance PAID"
        }
        // filter staff for "Executives"
        let personalPaymentMade = fileItems.filter { (item) -> Bool in
            return item.type == "Personal"
        }
        // filter for insurance and paid
        // filter senior management for "Executives"
        let RCVworkToDo = fileItems.filter { (item) -> Bool in
            return item.type == "ACV owed to HO"
        }
        // filter staff for "Executives"
        let ACVtoHO = fileItems.filter { (item) -> Bool in
            return item.type == "RCV work to do"
        }
        // filter staff for "Executives"
        let cashToDo = fileItems.filter { (item) -> Bool in
            return item.type == "Cash work to do"
        }
        
        
        
        allItems = [
            insChecksRecieved,
            insChecksRecievedAndPaid,
            personalPaymentMade,
            RCVworkToDo,
            ACVtoHO,
            cashToDo
        ]
        
    }
    
    
    // creates header
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allItems.count
    }
    
    // get employees to show up in tableView for the file selected
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems[section].count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCellId, for: indexPath)
        // check employee based on which section they are in
        // print names in cell
        // if we are section 0 we will use all employees at 0 (shortnameEmployees) and we will select correct indexPath row
        let item = allItems[indexPath.section][indexPath.row]
//        cell.textLabel?.text = item.name
//        cell.textLabel?.text = "\(item.name ?? "") - Check Amount:  \(item.itemInformation?.checkDate ?? nil)"
        
//        let lineItem = allLineItems[indexPath.section][indexPath.row]
//        cell.textLabel?.text = lineItem.name
        // print check date in cell
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current

        if let date = item.itemInformation?.checkDate, let amount = Double(item.itemInformation?.checkAmount ?? "") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let checkCell = tableView.dequeueReusableCell(withIdentifier: "CheckTableViewCell", for: indexPath) as! CheckTableViewCell
            let shortAmount = currencyFormatter.string(from: NSNumber(value: amount))
            if item.name == "" {
                checkCell.myCheckNumberLabel?.text = " "
            } else {
                checkCell.myCheckNumberLabel?.text = "\(item.name ?? "")"
            }
            checkCell.myCheckAmountLabel?.text = shortAmount
            let checkDateString = "\(dateFormatter.string(from: date))"
            if checkDateString == "Jan 01, 2000" {
                checkCell.myCheckDateLabel?.text = " "
            } else {
                checkCell.myCheckDateLabel?.text = "\(dateFormatter.string(from: date))"
            }

            checkCell.selectionStyle = UITableViewCell.SelectionStyle.none
            return checkCell
                
            
        } else if let lineNumber = item.itemInformation?.lineNumber, let amount = Double(item.itemInformation?.linePrice ?? "") {
            // this is for all work to do
            let lineItemCell = tableView.dequeueReusableCell(withIdentifier: "LineItemTableViewCell", for: indexPath) as! LineItemTableViewCell
            let shortAmount = currencyFormatter.string(from: NSNumber(value: amount))
            lineItemCell.myLineItemLabel?.text = "\(item.name ?? " ")"
            lineItemCell.myPriceLabel?.text = shortAmount
            if lineNumber == "" {
                lineItemCell.myLineNumberLabel?.text = " "
            }
            lineItemCell.myLineNumberLabel?.text = "\(lineNumber)"
            lineItemCell.myNotesTextView?.text = "\(item.itemInformation?.lineNote ?? "None")"
            lineItemCell.selectionStyle = UITableViewCell.SelectionStyle.none
            return lineItemCell
        }
        
        
        // check for employeeInformation
        // if i have taxId information for user selected employee, display the tax informatin in the cell for the employee, if no taxId is found, dont include it.
//        if let taxId = employee.employeeInformation?.taxId {
//            cell.textLabel?.text = "\(employee.name ?? "")  \(taxId)"
//        }
//

        return cell
    }
    
    // delete file from tableView and coredata
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            
            // get file you are swiping on to get delete action
            let item = self.allItems[indexPath.section][indexPath.row]
            
            // this removes a check or line item attached to a specific section in the tableview
            self.allItems[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            let context = CoreDataManager.shared.persistentContainer.viewContext
            context.delete(item)
            do {
                try context.save()
                print("data saved successfully")
                } catch {
                print("error saving context, \(error.localizedDescription)")
            }
            self.fetchInsToHOTotal()
            // refresh the balance remaining label
            self.viewWillAppear(true)


           
        }
        
        // change color of delete button
        deleteAction.backgroundColor = UIColor.lightRed

        // this puts the action buttons in the row the user swipes so user can actually see the buttons to delete or edit
        return [deleteAction]
    }
    
    
    
    let itemCellId = "itemCellId"

    
    // this function controls how the controller is styled
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchItems()
        fetchInsToHOTotal()
        tableView.backgroundColor = UIColor.darkBlue
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: itemCellId)
        // "add check" and "add line item" buttons
        let addCheck = UIBarButtonItem(title: "Add Check", style: .plain, target: self, action: #selector(handleAddCheck))
        let addLineItem = UIBarButtonItem(title: "Add Line Item", style: .plain, target: self, action: #selector(handleAddLineItem))
        
        
        navigationItem.rightBarButtonItems = [addCheck, addLineItem]
        
        setupUI()
        
        // create new custom cell for insurance check table view
        let nib_insCheck = UINib(nibName: "CheckTableViewCell", bundle: nil)
        tableView.register(nib_insCheck, forCellReuseIdentifier: "CheckTableViewCell")
        // create new custom cell for line item table view
        let nib_lineItem = UINib(nibName: "LineItemTableViewCell", bundle: nil)
        tableView.register(nib_lineItem, forCellReuseIdentifier: "LineItemTableViewCell")
        // refresh the balance remaining label
        viewWillAppear(true)
        
    
        
        

    }
    
//    // create file overview label
//    let overviewLabel: UILabel = {
//        let label = UILabel()
//        label.text = "File Summary"
//        label.textColor = .white
//        // enable autolayout
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.boldSystemFont(ofSize: 24)
//
//        return label
//    }()
    
    // create button to send summary to office
    let summaryButton: UIButton = {
        let button = UIButton()

        button.backgroundColor = .systemBlue
        button.setTitle("Show Summary", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleSummaryPopUp(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    
    // create file coc total label
    let cocTotalLabel: UILabel = {
        let label = UILabel()
        label.text = "COC Total"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    // create file coc total entry
    let cocTotalLabelInfo: UILabel = {
        let label = UILabel()
        
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 16)
        label.textColor = .white
        return label
    }()
    
    // create file invoice total label
    let invoiceTotalLabel: UILabel = {
        let label = UILabel()
        label.text = "Invoice Total"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    // create file invoice total entry
    let invoiceTotalLabelInfo: UILabel = {
        let label = UILabel()
        label.text = "THIS IS THE Invoice TOTAL"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 16)
        label.textColor = .white
        return label
    }()
    
    // create file deductible total label
    let deductibleTotalLabel: UILabel = {
        let label = UILabel()
        label.text = "Deductible Total"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    // create file deductible total entry
    let deductibleTotalLabelInfo: UILabel = {
        let label = UILabel()
        label.text = "THIS IS THE deductible TOTAL"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 16)
        label.textColor = .white
        return label
    }()
    
    // create invoice balance total label
    let invoiceBalanceTotalLabel: UILabel = {
        let label = UILabel()
        label.text = "Remaining Invoice - What's Due"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    // create file deductible total entry
    let invoiceBalanceTotalLabelInfo: UILabel = {
        let label = UILabel()
        label.text = ""
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 16)
        label.textColor = .white
        return label
    }()
    
    // create RCV total label
    let rcvTotalLabel: UILabel = {
        let label = UILabel()
        label.text = "RCV Total"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    // create file deductible total entry
    let rcvTotalLabelInfo: UILabel = {
        let label = UILabel()
        label.text = ""
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 16)
        label.textColor = .white
        return label
    }()
    
    
    private func setupUI() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 215))

        let headerView = UILabel(frame: header.bounds)
        header.addSubview(headerView)
        
//        header.addSubview(overviewLabel)
//        overviewLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
//        overviewLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
//        overviewLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        header.addSubview(summaryButton)
        summaryButton.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -6).isActive = true
        summaryButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 6).isActive = true
        summaryButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        summaryButton.widthAnchor.constraint(equalToConstant: 155).isActive = true
        
        header.addSubview(cocTotalLabel)
        cocTotalLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
        cocTotalLabel.topAnchor.constraint(equalTo: summaryButton.bottomAnchor).isActive = true
        cocTotalLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        header.addSubview(cocTotalLabelInfo)
        cocTotalLabelInfo.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        cocTotalLabelInfo.bottomAnchor.constraint(equalTo: cocTotalLabel.bottomAnchor).isActive = true
        cocTotalLabelInfo.topAnchor.constraint(equalTo: cocTotalLabel.topAnchor).isActive = true
        
        header.addSubview(invoiceTotalLabel)
        invoiceTotalLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
        invoiceTotalLabel.topAnchor.constraint(equalTo: cocTotalLabel.bottomAnchor).isActive = true
        invoiceTotalLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        header.addSubview(invoiceTotalLabelInfo)
        invoiceTotalLabelInfo.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        invoiceTotalLabelInfo.bottomAnchor.constraint(equalTo: invoiceTotalLabel.bottomAnchor).isActive = true
        invoiceTotalLabelInfo.topAnchor.constraint(equalTo: invoiceTotalLabel.topAnchor).isActive = true
        
        header.addSubview(deductibleTotalLabel)
        deductibleTotalLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
        deductibleTotalLabel.topAnchor.constraint(equalTo: invoiceTotalLabel.bottomAnchor).isActive = true
        deductibleTotalLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        header.addSubview(deductibleTotalLabelInfo)
        deductibleTotalLabelInfo.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        deductibleTotalLabelInfo.bottomAnchor.constraint(equalTo: deductibleTotalLabel.bottomAnchor).isActive = true
        deductibleTotalLabelInfo.topAnchor.constraint(equalTo: deductibleTotalLabel.topAnchor).isActive = true
        
        header.addSubview(invoiceBalanceTotalLabel)
        invoiceBalanceTotalLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
        invoiceBalanceTotalLabel.topAnchor.constraint(equalTo: deductibleTotalLabel.bottomAnchor).isActive = true
        invoiceBalanceTotalLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        header.addSubview(invoiceBalanceTotalLabelInfo)
        invoiceBalanceTotalLabelInfo.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        invoiceBalanceTotalLabelInfo.bottomAnchor.constraint(equalTo: invoiceBalanceTotalLabel.bottomAnchor).isActive = true
        invoiceBalanceTotalLabelInfo.topAnchor.constraint(equalTo: invoiceBalanceTotalLabel.topAnchor).isActive = true
        
        header.addSubview(rcvTotalLabel)
        rcvTotalLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
        rcvTotalLabel.topAnchor.constraint(equalTo: invoiceBalanceTotalLabel.bottomAnchor).isActive = true
        rcvTotalLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        header.addSubview(rcvTotalLabelInfo)
        rcvTotalLabelInfo.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        rcvTotalLabelInfo.bottomAnchor.constraint(equalTo: rcvTotalLabel.bottomAnchor).isActive = true
        rcvTotalLabelInfo.topAnchor.constraint(equalTo: rcvTotalLabel.topAnchor).isActive = true


        
        
        tableView.tableHeaderView = header
        print("label should appear...")

        
        
    }
    
    // add new check button handler
    @objc private func handleAddCheck() {
        print("trying to add new check")
        // show CreatEemployeeController
        let createCheckController = CreateCheckController()
        createCheckController.delegate = self
        createCheckController.file = file
        // this creates the red top nav portion that holds the create file name, cancel button, save button
        let navController = UINavigationController(rootViewController: createCheckController)
        present(navController, animated: true, completion: nil)
    }
    
    // add new line item button handler
    @objc private func handleAddLineItem() {
        print("trying to add new line item")
        // show CreatEemployeeController
        let createLineItemController = CreateLineItemController()
        createLineItemController.delegate = self
        createLineItemController.file = file
        // this creates the red top nav portion that holds the create file name, cancel button, save button
        let navController = UINavigationController(rootViewController: createLineItemController)
        present(navController, animated: true, completion: nil)
    }
    
    // send to office controller
    @objc private func handleSummaryPopUp(sender:UIButton) {
        print("File summary")
        // show summaryController
        let summaryController = SummaryController()
        summaryController.file = file
        // this creates the red top nav portion that holds the file name, done button
        let navController = UINavigationController(rootViewController: summaryController)
        // add animation to the button
        self.animateView(sender)
        present(navController, animated: true, completion: nil)
        
    }
    
    // animation for the "Show Summary" button
    fileprivate func animateView(_ viewToAnimate: UIView) {
        UIView.animate(withDuration: 0.30, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.6, options: .curveEaseIn, animations: {
            viewToAnimate.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { (_) in
            UIView.animate(withDuration: 0.30, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
    
}
