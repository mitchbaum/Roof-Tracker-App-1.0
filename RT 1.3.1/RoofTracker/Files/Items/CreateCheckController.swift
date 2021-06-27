//
//  CreateEmployeeController.swift
//  TrainingCourse
//
//  Created by Mitch Baumgartner on 3/2/21.
//

import UIKit

protocol createCheckControllerDelegate {
    func didAddItem(item: FileItem)
    func didEditItem(item: FileItem)
}

// this controller creates a view controller for creating an employee when user taps plus button 
class CreateCheckController: UIViewController {
    
     
    var file: File? // file? (optional) means it can start as nil
    
    // go into coredata and set a variable for FileItem that way i can access the variables
    var fileItem: FileItem? {
        // set the edit view to this value once user taps edit button
        didSet {
            numberTextField.text = fileItem?.name
            
            if fileItem?.type == "Insurance" {
                checkTypeSegmentedControl.selectedSegmentIndex = 0
            } else if fileItem?.type == "Personal" {
                checkTypeSegmentedControl.selectedSegmentIndex = 1
            } else {
                checkTypeSegmentedControl.selectedSegmentIndex = 2
            }
            
            
        }
    }
    var itemInformation: ItemInformation? {
        didSet {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = .decimal
            currencyFormatter.currencySymbol = ""
            
            amountTextField.text = itemInformation?.checkAmount
            if itemInformation?.checkAmount != "" {
                let amount = Double(itemInformation?.checkAmount ?? "")
                let amountFormat = currencyFormatter.string(from: NSNumber(value: amount ?? 0.0))
                amountTextField.text = amountFormat
            }
        
            // convert Date type to string
            // guard if date is empty return 2000-01-01 00:00:00 value
            guard let dateRaw = itemInformation?.checkDate else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyyyy"
            let dateLong = dateFormatter.string(from: dateRaw)
            if dateLong == "01012000" {
                dateTextField.attributedPlaceholder = NSAttributedString(string: "MMdd",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            } else {
                dateFormatter.dateFormat = "MMdd"
                let date = dateFormatter.string(from: dateRaw)
                dateTextField.text = date
            }
        
            
        }
    }
        

    
    // establish delegate
    var delegate: createCheckControllerDelegate?
    
    // create check number label
    let numberLabel: UILabel = {
        let label = UILabel()
        label.text = "Number"
        label.textColor = .black
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create text field for check number entry
    let numberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter check number"
        textField.attributedPlaceholder = NSAttributedString(string: "Enter check number",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        // enable autolayout, without this constraints wont load properly


        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create check amount label
    let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "Amount          $"
        label.textColor = .black
        // label.backgroundColor = .red
        // enable autolayout
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create text field for check amount entry
    let amountTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter check amount",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.keyboardType = UIKeyboardType.decimalPad
        textField.textColor = .black
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = UIKeyboardType.decimalPad
        return textField
    }()
    
    // create date label
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create text field for date entry
    let dateTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "MMdd",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.keyboardType = UIKeyboardType.numberPad
        textField.textColor = .black
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        navigationItem.title = "Add Check"
        
        // add cancel button to dismiss view
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        view.backgroundColor = .darkBlue
        
        setupUI()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        
        // dismiss keyboard when user taps outside of keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        let swipeDown = UIPanGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeDown)
    }
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    // distinguish between save and edit
    @objc private func handleSave() {
        // creating a new check
        if itemInformation == nil {
            createCheck()
        } else {
            saveCheckChanges()
        }
    }
    private func saveCheckChanges() {
        // persist the change in coredata
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        guard let number = numberTextField.text else { return }
        if number != "" {
            fileItem?.name = number
        } else {
            fileItem?.name = ""
        }
        
        guard let amount = amountTextField.text else { return }
        if amount != "" {
            let amountDouble = amount.toDoubleWithAutoLocale()
            // if user enters invalid entry for a amount value (commas and decimals) error message
            if amountDouble == nil {
                return showError(title: "Invalid Amount Entry", message: "Double check your amount entry.")
            }
            itemInformation?.checkAmount = "\(amountDouble ?? 0.0)"
        } else {
            itemInformation?.checkAmount = amount
        }
        
        guard let date = dateTextField.text else { return }
        if date.isEmpty {
            // date formatter for empty date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMdd"
            let checkDate = dateFormatter.date(from: date)
            itemInformation?.checkDate = checkDate
        } else {
        
            // date formatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyyyy"
            guard let checkDate = dateFormatter.date(from: date + "2021")
            else {
                let alertController = UIAlertController(title: "Invalid Date", message: "Double check the format. MMdd", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
                return
            }
            itemInformation?.checkDate = checkDate
        }
        
        // reset time stamp
        let timeStamp = Date()
        fileItem?.timeStamp = timeStamp
        

        

        
        
        
        if number.isEmpty && amount.isEmpty && date.isEmpty {
            return showError(title: "Invalid Check", message: "No check information added.")
        }
    
        
        fileItem?.type = checkTypeSegmentedControl.titleForSegment(at: checkTypeSegmentedControl.selectedSegmentIndex)
        
        do {
            try context.save()
            // save success
            dismiss(animated: true, completion: {
                self.delegate?.didEditItem(item: self.fileItem!)
            })
        } catch let saveErr {
            print("Failed to save check changes: ", saveErr)
        }
        
        
    }
    
    
    @objc private func createCheck() {
        print("saving check with a date..")
        
        // use nonoptional of name, unwraps the itemName
        guard let itemName = numberTextField.text else { return }
        
        // use nonoptional of file, unwraps the file
        guard let file = self.file else { return }
        
        guard let checkAmount = amountTextField.text else { return }
        
        // turn birthdayTextField.text into a date object
        guard let checkText = dateTextField.text else { return }
        if checkText.isEmpty && checkAmount.isEmpty && itemName.isEmpty {
            return showError(title: "Invalid Check", message: "No check information added.")
        }
        guard let insCheckCounter = Double(amountTextField.text!) else { return showError(title: "Invalid Check", message: "Invalid amount entry.") }

        let itemPrice = ""
        
        let lineNumber = ""
        
        let lineNote = ""
        

        
        if checkText.isEmpty {
            return handleSaveNoDate() //showError(title: "Missing date", message: "Please enter a valid date.")
        }
        print("itemName: ", itemName)
        print("checkAmount: ",checkAmount)
        print("checkText: ",checkText)
        
        // date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyyyy"
        // check to make sure user enters correct format of birthday or correct date
        guard let checkDate = dateFormatter.date(from: checkText + "2021")
        else {
            let alertController = UIAlertController(title: "Invalid Date", message: "Double check the format. MMdd", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        // how to make create employee know which filter to set the employee to
        guard let itemType = checkTypeSegmentedControl.titleForSegment(at: checkTypeSegmentedControl.selectedSegmentIndex) else { return }
        
        // reset time stamp
        let timeStamp = Date()
        fileItem?.timeStamp = timeStamp

        
        // employee tuple found in CoreDataManager.swift
        // where do we get file from?
        let tuple = CoreDataManager.shared.createFileItem(itemName: itemName, itemType: itemType, checkDate: checkDate, checkAmount: checkAmount, lineNumber: lineNumber, linePrice: itemPrice, lineNote: lineNote, insCheckCounter: insCheckCounter, file: file)
        
        if let error = tuple.1 { // tuple is a variable that contains .0 for the first variable (employee) and .1 for the second variable nil that youre passing back
            // this is where you present error modal of some kind
            // perhaps use a UIAlertController to show your error message
            print(error)
        } else {
            
            // dismiss the create employee modal afte success
            dismiss(animated: true) {
                // well call the delegate somehow
                // this employee is going to be the employee we created
                self.delegate?.didAddItem(item: tuple.0!)
            }

        }
        
    }
    @objc private func handleSaveNoDate() {
        print("saving check without a date..")
        
        // use nonoptional of name, unwraps the itemName
        guard let itemName = numberTextField.text else { return }
        // use nonoptional of file, unwraps the file
        guard let file = self.file else { return }

        guard let checkAmount = amountTextField.text else { return }
        
        // turn birthdayTextField.text into a date object
        guard let checkText = dateTextField.text else { return }
        
        guard let insCheckCounter = Double(amountTextField.text!) else { return }
        
        let itemPrice = ""
        
        let lineNumber = ""
        
        let lineNote = ""
        
        // date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMdd"
        // check to make sure user enters correct format of birthday or correct date
        let checkDate = dateFormatter.date(from: checkText)
        
        // how to make create employee know which filter to set the employee to
        guard let itemType = checkTypeSegmentedControl.titleForSegment(at: checkTypeSegmentedControl.selectedSegmentIndex) else { return }
        
        // employee tuple found in CoreDataManager.swift
        // where do we get file from?
        let tuple = CoreDataManager.shared.createFileItem(itemName: itemName, itemType: itemType, checkDate: checkDate, checkAmount: checkAmount, lineNumber: lineNumber, linePrice: itemPrice, lineNote: lineNote, insCheckCounter: insCheckCounter, file: file)
        
        // reset time stamp
        let timeStamp = Date()
        fileItem?.timeStamp = timeStamp
        
        if let error = tuple.1 { // tuple is a variable that contains .0 for the first variable (employee) and .1 for the second variable nil that youre passing back
            // this is where you present error modal of some kind
            // perhaps use a UIAlertController to show your error message
            print(error)
        } else {
            
            // dismiss the create employee modal afte success
            dismiss(animated: true) {
                // well call the delegate somehow
                // this employee is going to be the employee we created
                self.delegate?.didAddItem(item: tuple.0!)
            }

        }
        
        
    }
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    // check type segmented viewing filter
    let checkTypeSegmentedControl: UISegmentedControl = {

        let types = ["Insurance","Personal", "Insurance PAID"]
        let sc = UISegmentedControl(items: types)
        // default as first item
        sc.selectedSegmentIndex = 0
        sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        // highlighted filter color
        sc.tintColor = UIColor.darkBlue
        return sc
    }()
    
    // radio button for insurance check AND paid to viking
    
    private func setupUI() {
        // add and position background color in relationship to the view elements on the view controller
        let silverBackgroundView = UIView()
        silverBackgroundView.backgroundColor = UIColor.silver
        silverBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(silverBackgroundView)
        silverBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        silverBackgroundView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        silverBackgroundView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        silverBackgroundView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        // add and position check number label
        view.addSubview(numberLabel)
        numberLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        // move label to the right a bit
        numberLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        numberLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        numberLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the numberLabel
        view.addSubview(numberTextField)
        numberTextField.leftAnchor.constraint(equalTo: numberLabel.rightAnchor).isActive = true
        numberTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        numberTextField.bottomAnchor.constraint(equalTo: numberLabel.bottomAnchor).isActive = true
        numberTextField.topAnchor.constraint(equalTo: numberLabel.topAnchor).isActive = true
        
        // add and position check amount label
        view.addSubview(amountLabel)
        amountLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        amountLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        amountLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        amountLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the numberLabel
        view.addSubview(amountTextField)
        amountTextField.leftAnchor.constraint(equalTo: amountLabel.rightAnchor).isActive = true
        amountTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        amountTextField.bottomAnchor.constraint(equalTo: amountLabel.bottomAnchor).isActive = true
        amountTextField.topAnchor.constraint(equalTo: amountLabel.topAnchor).isActive = true
        
        // add and position date label
        view.addSubview(dateLabel)
        dateLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        dateLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        dateLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        //dateLabel.backgroundColor = .yellow
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // add and position date textfield element to the right of the dateLabel
        view.addSubview(dateTextField)
        dateTextField.leftAnchor.constraint(equalTo: dateLabel.rightAnchor).isActive = true
        dateTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        dateTextField.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
        dateTextField.topAnchor.constraint(equalTo: dateLabel.topAnchor).isActive = true
        
        // add segmented control view
        view.addSubview(checkTypeSegmentedControl)
        checkTypeSegmentedControl.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 0).isActive = true
        checkTypeSegmentedControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        checkTypeSegmentedControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        
        checkTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
}
