//
//  SummaryController.swift
//  PaymentTracker
//
//  Created by Mitch Baumgartner on 4/1/21.
//

import UIKit


// create UILabel subclass for custom text drawing - usually for my headers
class IndentedLabelSummary: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        let customRect = rect.inset(by: insets)
        super.drawText(in: customRect)
    }
}
// this controller creates a view controller for creating an employee when user taps plus button
class SummaryController: UITableViewController {
    
    var file: File? // File? (optional) means it can start as nil
    
    // creates style of header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabelSummary()
        // make headers refelct what goes information goes into the sections

        if section == 0 {
            label.text = "Insurance Checks Recieved"
        } else  {
            label.text = "ACV owed to Homeowner"
        }

        label.backgroundColor = UIColor.lightBlue
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)



        return label
    }
    
    // creates height of header
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    // an array of arrays of employees
    var allItems = [[FileItem]]()
    
    // fetch employees for each file when user taps on file
    private func fetchItems() {
        // this will prevent a crash if it is not able to cast all objects into employees properly
        guard let fileItems = file?.fileItems?.allObjects as? [FileItem] else { return }
        // filter senior management for "Executives"
        let insChecksRecieved = fileItems.filter { (item) -> Bool in
            return item.type == "Insurance" || item.type == "Insurance PAID"
        }
        // filter senior management for "Executives"
        let RCVworkToDo = fileItems.filter { (item) -> Bool in
            return item.type == "ACV owed to HO"
        }
        
        allItems = [
            insChecksRecieved,
            RCVworkToDo,
        ]
        
    }
    // creates header
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allItems.count
    }
    
    // get items to show up in tableView for the file selected
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

        if let date = item.itemInformation?.checkDate, let amount = Double(item.itemInformation?.checkAmount ?? " ") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let checkCell = tableView.dequeueReusableCell(withIdentifier: "InsuranceCheckCell", for: indexPath) as! InsuranceCheckCell
            checkCell.myCheckNumberLabel?.text = "\(item.name ?? "")"
            let shortAmount = currencyFormatter.string(from: NSNumber(value: amount))
            checkCell.myCheckAmountLabel?.text = shortAmount
            let checkDateString = "\(dateFormatter.string(from: date))"
            if checkDateString == "Jan 01, 2000" {
                checkCell.myCheckDateLabel?.text = " "
            } else {
                checkCell.myCheckDateLabel?.text = "\(dateFormatter.string(from: date))"
            }
            checkCell.selectionStyle = UITableViewCell.SelectionStyle.none
            return checkCell
                
            
        } else if let lineNumber = item.itemInformation?.lineNumber, let amount = Double(item.itemInformation?.linePrice ?? " ") {
            // this is for all work to do
            let lineItemCell = tableView.dequeueReusableCell(withIdentifier: "ACVItemCell", for: indexPath) as! ACVItemCell
            let shortAmount = currencyFormatter.string(from: NSNumber(value: amount))
            lineItemCell.myLineItemLabel?.text = "\(item.name ?? " ")"
            lineItemCell.myPriceLabel?.text = shortAmount
            lineItemCell.myLineNumberLabel?.text = "\(lineNumber)"
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
    
    let itemCellId = "itemCellId"
    
    
    
    // create work item name label
    let insStillOwesHOLabel: UILabel = {
        let label = UILabel()
        label.text = "Insurance Still Owes Homeowner:"
        label.textColor = .white
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create info for amount owed to HO
    let insStillOwesHOLabelInfo: UILabel = {
        let label = UILabel()
        label.text = "Not available"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        label.textColor = .white
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create work item name label
    let insChecksShouldEqualLabel: UILabel = {
        let label = UILabel()
        label.text = "Insurance Checks Issued SHOULD equal:"
        label.textColor = .white
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create info for amount owed to HO
    let insChecksShouldEqualLabelInfo: UILabel = {
        let label = UILabel()
        label.text = "Not available"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        label.textColor = .white
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // because label
    let becauseLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Because..."
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // coc label
    let cocLabel: UILabel = {
        let label = UILabel()
        label.text = "COC"
        label.textColor = .white
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // coc info label
    let cocLabelInfo: UILabel = {
        let label = UILabel()
        label.text = "No entry"
        label.textColor = .white
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // acv label
    let acvLabel: UILabel = {
        let label = UILabel()
        label.text = "ACV"
        label.textColor = .white
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // acv info label
    let acvLabelInfo: UILabel = {
        let label = UILabel()
        label.text = "No entry"
        label.textColor = .white
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // deductible label
    let deductibleLabel: UILabel = {
        let label = UILabel()
        label.text = "Deductible"
        label.textColor = .white
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // deductinble info label
    let deductibleLabelInfo: UILabel = {
        let label = UILabel()
        label.text = "No entry"
        label.textColor = .white
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    // all insurance checks label
//    let insChecksLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Insurance Checks Recieved"
//        label.textColor = .white
//        // label.backgroundColor = .red
//        // enable autolayout
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    // all insurance checks info label
//    let insChecksLabelInfo: UILabel = {
//        let label = UILabel()
//        label.text = "$0.00"
//        label.textColor = .white
//        // label.backgroundColor = .red
//        // enable autolayout
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    
    // equation line
    let line: UILabel = {
        let line = UILabel()
        line.backgroundColor = UIColor.white
        // enable autolayout
        line.translatesAutoresizingMaskIntoConstraints = false
    
        return line
    }()
    
    // Total label
    let totalLabel: UILabel = {
        let label = UILabel()
        label.text = "Total"
        label.textColor = .white
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // total info label
    let totalLabelInfo: UILabel = {
        let label = UILabel()
        label.text = "Not Available"
        label.textColor = .white
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchItems()
        tableView.backgroundColor = UIColor.darkBlue
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: itemCellId)
        // title
        navigationItem.title = file?.name
        
        
        view.backgroundColor = .darkBlue
        
        setupUI()
        getSummaryValues()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        // create new custom cell for insurance check table view
        let nib_insCheck = UINib(nibName: "InsuranceCheckCell", bundle: nil)
        tableView.register(nib_insCheck, forCellReuseIdentifier: "InsuranceCheckCell")
        // create new custom cell for line item table view
        let nib_lineItem = UINib(nibName: "ACVItemCell", bundle: nil)
        tableView.register(nib_lineItem, forCellReuseIdentifier: "ACVItemCell")
        
    
        
    }
    
    private func getSummaryValues() {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        // make date show up pretty in cell by unwrapping name and founded property
        if let insCheckACVTotal = Double(file?.insCheckACVTotal ?? ""), let coc = Double(file?.coc ?? ""), let deductible = Double(file?.deductible ?? ""), let insChecksTotal = Double(file?.insCheckTotal ?? ""), let acvItemTotal = Double(file?.acvItemTotal ?? "") {
            let moneyOwedToHO = coc + insCheckACVTotal - deductible
            let amountOwed = currencyFormatter.string(from: NSNumber(value: moneyOwedToHO))
            insStillOwesHOLabelInfo.text = amountOwed

            
            let totalInsChecks = currencyFormatter.string(from: NSNumber(value: insChecksTotal + moneyOwedToHO))
            insChecksShouldEqualLabelInfo.text = totalInsChecks
            totalLabelInfo.text = totalInsChecks
            
            let cocTotal = currencyFormatter.string(from: NSNumber(value: coc))
            cocLabelInfo.text = cocTotal
            
            let acvTotal = currencyFormatter.string(from: NSNumber(value: acvItemTotal))
            acvLabelInfo.text = acvTotal
            
            let deductibleTotal = currencyFormatter.string(from: NSNumber(value: deductible))
            deductibleLabelInfo.text = "-\(deductibleTotal ?? "")"
            
//            let insTotal = currencyFormatter.string(from: NSNumber(value: insChecksTotal))
//            insChecksLabelInfo.text = insTotal
        } else if let deductible = Double(file?.deductible ?? "") {
            let deductibleTotal = currencyFormatter.string(from: NSNumber(value: deductible))
            deductibleLabelInfo.text = "-\(deductibleTotal ?? "")"
            totalLabelInfo.text = "-\(deductibleTotal ?? "")"
        } else if let coc = Double(file?.coc ?? "") {
            let cocTotal = currencyFormatter.string(from: NSNumber(value: coc))
            cocLabelInfo.text = cocTotal
            totalLabelInfo.text = "-\(cocTotal ?? "")"
        }
        else {
            insStillOwesHOLabelInfo.text = "Not available"
            insChecksShouldEqualLabelInfo.text = "Not available"
        }
        
        if file?.acvItemTotal == "0.0"{
            acvLabelInfo.text = "No entry"
        } else if file?.acvItemTotal != "" && file?.deductible != "" && file?.coc != "" {
            let acvItemTotal = Double(file?.acvItemTotal ?? "")
            let acvTotal = currencyFormatter.string(from: NSNumber(value: acvItemTotal ?? 0.0))
            acvLabelInfo.text = acvTotal
            
            let deductible = Double(file?.deductible ?? "")
            let deductibleTotal = currencyFormatter.string(from: NSNumber(value: deductible ?? 0.0))
            deductibleLabelInfo.text = "-\(deductibleTotal ?? "")"
            
            let coc = Double(file?.coc ?? "")
            let cocTotal = currencyFormatter.string(from: NSNumber(value: coc ?? 0.0))
            cocLabelInfo.text = cocTotal
            
            let total = (coc ?? 0.0) + (acvItemTotal ?? 0.0) - (deductible ?? 0.0)
            let totalFormatted = currencyFormatter.string(from: NSNumber(value: total))
            totalLabelInfo.text = totalFormatted
            
        }else if file?.acvItemTotal != "" && file?.deductible != "" {
            let acvItemTotal = Double(file?.acvItemTotal ?? "")
            let acvTotal = currencyFormatter.string(from: NSNumber(value: acvItemTotal ?? 0.0))
            acvLabelInfo.text = acvTotal
            
            let deductible = Double(file?.deductible ?? "")
            let deductibleTotal = currencyFormatter.string(from: NSNumber(value: deductible ?? 0.0))
            deductibleLabelInfo.text = "-\(deductibleTotal ?? "")"
            let total = (acvItemTotal ?? 0.0) - (deductible ?? 0.0)
            let totalFormatted = currencyFormatter.string(from: NSNumber(value: total))
            totalLabelInfo.text = totalFormatted
        } else if file?.acvItemTotal != "" {
            let acvItemTotal = Double(file?.acvItemTotal ?? "")
            let acvTotal = currencyFormatter.string(from: NSNumber(value: acvItemTotal ?? 0.0))
            acvLabelInfo.text = acvTotal
        }
        
        
    }
    
    private func setupUI() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 230))
        

        let headerView = UILabel(frame: header.bounds)
        //headerView.backgroundColor = .lightBlue
        header.addSubview(headerView)
        
        // add and position item name label
        header.addSubview(insStillOwesHOLabel)
        insStillOwesHOLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        // move label to the right a bit
        insStillOwesHOLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
//        insStillOwesHOLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        insStillOwesHOLabel.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        insStillOwesHOLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true

        header.addSubview(insStillOwesHOLabelInfo)
        insStillOwesHOLabelInfo.topAnchor.constraint(equalTo: insStillOwesHOLabel.bottomAnchor).isActive = true
        insStillOwesHOLabelInfo.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
        insStillOwesHOLabelInfo.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true

        header.addSubview(insChecksShouldEqualLabel)
        insChecksShouldEqualLabel.topAnchor.constraint(equalTo: insStillOwesHOLabelInfo.bottomAnchor).isActive = true
        insChecksShouldEqualLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
        insChecksShouldEqualLabel.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        insChecksShouldEqualLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true

        header.addSubview(insChecksShouldEqualLabelInfo)
        insChecksShouldEqualLabelInfo.topAnchor.constraint(equalTo: insChecksShouldEqualLabel.bottomAnchor).isActive = true
        insChecksShouldEqualLabelInfo.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
        insChecksShouldEqualLabelInfo.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true

        header.addSubview(becauseLabel)
        becauseLabel.topAnchor.constraint(equalTo: insChecksShouldEqualLabelInfo.bottomAnchor, constant: 5).isActive = true
        becauseLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
        becauseLabel.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        becauseLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true

        header.addSubview(cocLabel)
        cocLabel.topAnchor.constraint(equalTo: becauseLabel.topAnchor).isActive = true
        cocLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 210).isActive = true
        cocLabel.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        cocLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true

        header.addSubview(cocLabelInfo)
        cocLabelInfo.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -24).isActive = true
        cocLabelInfo.topAnchor.constraint(equalTo: cocLabel.topAnchor).isActive = true
        cocLabelInfo.bottomAnchor.constraint(equalTo: cocLabel.bottomAnchor).isActive = true

        header.addSubview(acvLabel)
        acvLabel.topAnchor.constraint(equalTo: cocLabel.bottomAnchor).isActive = true
        acvLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 210).isActive = true
        acvLabel.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        acvLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true

        header.addSubview(acvLabelInfo)
        acvLabelInfo.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -24).isActive = true
        acvLabelInfo.topAnchor.constraint(equalTo: acvLabel.topAnchor).isActive = true
        acvLabelInfo.bottomAnchor.constraint(equalTo: acvLabel.bottomAnchor).isActive = true

        header.addSubview(deductibleLabel)
        deductibleLabel.topAnchor.constraint(equalTo: acvLabel.bottomAnchor).isActive = true
        deductibleLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 164).isActive = true
        deductibleLabel.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        deductibleLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true

        header.addSubview(deductibleLabelInfo)
        deductibleLabelInfo.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -24).isActive = true
        deductibleLabelInfo.topAnchor.constraint(equalTo: deductibleLabel.topAnchor).isActive = true
        deductibleLabelInfo.bottomAnchor.constraint(equalTo: deductibleLabel.bottomAnchor).isActive = true

//        header.addSubview(insChecksLabel)
//        insChecksLabel.topAnchor.constraint(equalTo: deductibleLabel.bottomAnchor).isActive = true
//        insChecksLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 38).isActive = true
//        insChecksLabel.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
//        insChecksLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
//
//        header.addSubview(insChecksLabelInfo)
//        insChecksLabelInfo.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -24).isActive = true
//        insChecksLabelInfo.topAnchor.constraint(equalTo: insChecksLabel.topAnchor).isActive = true
//        insChecksLabelInfo.bottomAnchor.constraint(equalTo: insChecksLabel.bottomAnchor).isActive = true

        header.addSubview(line)
        line.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -22).isActive = true
        line.topAnchor.constraint(equalTo: deductibleLabelInfo.bottomAnchor, constant: 5).isActive = true
        line.heightAnchor.constraint(equalToConstant: 2).isActive = true
        line.widthAnchor.constraint(equalToConstant: 100).isActive = true

        header.addSubview(totalLabel)
        totalLabel.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 5).isActive = true
        totalLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 210).isActive = true
        totalLabel.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        totalLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true

        header.addSubview(totalLabelInfo)
        totalLabelInfo.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -24).isActive = true
        totalLabelInfo.topAnchor.constraint(equalTo: totalLabel.topAnchor).isActive = true
        totalLabelInfo.bottomAnchor.constraint(equalTo: totalLabel.bottomAnchor).isActive = true

        
        tableView.tableHeaderView = header
        print("label should appear...")

    }
    
    @objc func handleDone() {
        dismiss(animated: true, completion: nil)
    }
    
}

