//
//  CreateEmployeeController.swift
//  TrainingCourse
//
//  Created by Mitch Baumgartner on 3/2/21.
//

import UIKit

protocol createCheckControllerDelegate {
    func didAddItem(item: FileItem)
}

// this controller creates a view controller for creating an employee when user taps plus button 
class CreateCheckController: UIViewController {
    
    var file: File? // file? (optional) means it can start as nil
    
    // establish delegate
    var delegate: createCheckControllerDelegate?
    
    // create check number label
    let numberLabel: UILabel = {
        let label = UILabel()
        label.text = "Number"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create text field for check number entry
    let numberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter check number"
        // enable autolayout, without this constraints wont load properly


        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create check amount label
    let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "Amount          $"
        // label.backgroundColor = .red
        // enable autolayout
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create text field for check amount entry
    let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter check amount"
        textField.keyboardType = UIKeyboardType.decimalPad
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = UIKeyboardType.decimalPad
        return textField
    }()
    
    // create date label
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create text field for date entry
    let dateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "MMdd"
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
    }
    @objc private func handleSave() {
        print("saving check with a date..")
        
        // use nonoptional of name, unwraps the itemName
        guard let itemName = numberTextField.text else { return }
        
        // use nonoptional of file, unwraps the file
        guard let file = self.file else { return }
        
        guard let checkAmount = amountTextField.text else { return }
        
        // turn birthdayTextField.text into a date object
        guard let checkText = dateTextField.text else { return }
        if checkText.isEmpty && checkAmount.isEmpty && itemName.isEmpty {
            return showError(title: "Invalid Check", message: "No Check Information Added.")
        }
        guard let insCheckCounter = Double(amountTextField.text!) else { return showError(title: "Invalid Check", message: "No Check Amount Added.") }

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
