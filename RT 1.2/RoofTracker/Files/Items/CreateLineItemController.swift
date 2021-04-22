//
//  CreateLineItemController.swift
//  PaymentTracker
//
//  Created by Mitch Baumgartner on 3/7/21.
//

import UIKit

// this adds +/- to the keyboard so user can enter a negative number while only viewing the number pad keyboard type
extension UITextField {
    func addNumericAccessory(addPlusMinus: Bool) {
        let numberToolbar = UIToolbar()
        numberToolbar.barStyle = UIBarStyle.default
        var accessories : [UIBarButtonItem] = []
        if addPlusMinus {
            accessories.append(UIBarButtonItem(title: "+/-", style: UIBarButtonItem.Style.plain, target: self, action: #selector(plusMinusPressed)))
            accessories.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))   //add padding after
        }
        accessories.append(UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: #selector(numberPadClear)))
        accessories.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))   //add padding space
        accessories.append(UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(numberPadDone)))

        numberToolbar.items = accessories
        numberToolbar.sizeToFit()

        inputAccessoryView = numberToolbar
    }

    @objc func numberPadDone() {
        self.resignFirstResponder()
    }
    @objc func numberPadClear() {
        self.text = ""
    }
    @objc func plusMinusPressed() {
        guard let currentText = self.text else {
            return
        }
        if currentText.hasPrefix("-") {
            let offsetIndex = currentText.index(currentText.startIndex, offsetBy: 1)
            let substring = currentText[offsetIndex...]  //remove first character
            self.text = String(substring)
        }
        else {
            self.text = "-" + currentText
        }
    }

}
protocol createLineItemControllerDelegate {
    func didAddItem(item: FileItem)
}

// this controller creates a view controller for creating an employee when user taps plus button
class CreateLineItemController: UIViewController {
    
    var file: File? // File? (optional) means it can start as nil
    
    // establish delegate
    var delegate: createCheckControllerDelegate?
    
    // create work item name label
    let lineItemLabel: UILabel = {
        let label = UILabel()
        label.text = "Item"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create text field for item entry
    let lineItemTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Line item description"
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create work item price label
    let itemPriceLabel: UILabel = {
        let label = UILabel()
        label.text = "Price               $"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create text field for price entry
    let itemPriceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Line item price"
        textField.keyboardType = UIKeyboardType.decimalPad
        textField.addNumericAccessory(addPlusMinus: true)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        
        return textField
    }()
    
    // create work item line number label
    let itemLineNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "Line Number"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create text field for price entry
    let itemLineNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Insurance line item number"
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        //textField.keyboardType = UIKeyboardType.numberPad
        return textField
    }()
    
    // create label for notes
    let notesLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        // label.backgroundColor = .red
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // create text field for notes
    let notesTextField: UITextView = {
        let textField = UITextView()
        textField.font = .systemFont(ofSize: 16)
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.cornerRadius = 7;
        textField.backgroundColor = UIColor.silver
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        //textField.keyboardType = UIKeyboardType.numberPad
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        navigationItem.title = "Add Line Item"
        
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
    
    @objc private func handleSave() {
        print("saving line item..")
        
        // use nonoptional of name, unwraps the employeeName
        guard let itemName = lineItemTextField.text else { return }
        // use nonoptional of company, unwraps the company
        guard let file = self.file else { return }
        
        


        
        guard let itemPrice = itemPriceTextField.text else { return showError(title: "Invalid Price", message: "Invalid price entry.") }
        
        guard let lineNumber = itemLineNumberTextField.text else { return }
        
        guard let lineNote = notesTextField.text else { return }
        
        // this date resolves error, doesnt actually do anything
        let checkText = "08/23/2000"
        // date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        // check to make sure user enters correct format of birthday or correct date
        guard let checkDate = dateFormatter.date(from: checkText) else { return }
        
        let checkAmount = ""
        
        let insCheckCounter = 0.0
        
        if itemName.isEmpty && itemPrice.isEmpty {
            return showError(title: "Invalid Entry", message: "You have not entered an item or price.")
        } else if itemName.isEmpty {
            return showError(title: "Invalid Entry", message: "You have not entered an item.")
        } else if itemPrice.isEmpty {
            return showError(title: "Invalid Entry", message: "You have not entered a price.")
        }
        // this guard verifies that the user enterd a valid number in the line item text field
        guard Double(itemPriceTextField.text!) != nil else { return showError(title: "Invalid Price", message: "Invalid price entry.")}
        
    
        
        // how to make create employee know which filter to set the employee to
        guard let itemType = lineItemTypeSegmentedControl.titleForSegment(at: lineItemTypeSegmentedControl.selectedSegmentIndex) else { return }
        

        
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
    // employee type segmented viewing filter
    let lineItemTypeSegmentedControl: UISegmentedControl = {
        let types = ["ACV owed to HO","RCV work to do", "Cash work to do"]
        let sc = UISegmentedControl(items: types)
        // default as first item
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        // highlighted filter color
        sc.tintColor = UIColor.darkBlue
        return sc
    }()
    private func setupUI() {
        // add and position background color in relationship to the view elements on the view controller
        let silverBackgroundView = UIView()
        silverBackgroundView.backgroundColor = UIColor.silver
        silverBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(silverBackgroundView)
        silverBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        silverBackgroundView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        silverBackgroundView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        silverBackgroundView.heightAnchor.constraint(equalToConstant: 290).isActive = true
        
        // add and position item name label
        view.addSubview(lineItemLabel)
        lineItemLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        // move label to the right a bit
        lineItemLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        lineItemLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        lineItemLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position item name textfield element to the right of the nameLabel
        view.addSubview(lineItemTextField)
        lineItemTextField.leftAnchor.constraint(equalTo: lineItemLabel.rightAnchor).isActive = true
        lineItemTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        lineItemTextField.bottomAnchor.constraint(equalTo: lineItemLabel.bottomAnchor).isActive = true
        lineItemTextField.topAnchor.constraint(equalTo: lineItemLabel.topAnchor).isActive = true
        
        // add and position item price label
        view.addSubview(itemPriceLabel)
        itemPriceLabel.topAnchor.constraint(equalTo: lineItemLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        itemPriceLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        itemPriceLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        itemPriceLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // add and position item price textfield element to the right of the itemPriceLabel
        view.addSubview(itemPriceTextField)
        itemPriceTextField.leftAnchor.constraint(equalTo: itemPriceLabel.rightAnchor).isActive = true
        itemPriceTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        itemPriceTextField.bottomAnchor.constraint(equalTo: itemPriceLabel.bottomAnchor).isActive = true
        itemPriceTextField.topAnchor.constraint(equalTo: itemPriceLabel.topAnchor).isActive = true
        
        // add and position item line number label
        view.addSubview(itemLineNumberLabel)
        itemLineNumberLabel.topAnchor.constraint(equalTo: itemPriceLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        itemLineNumberLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        itemLineNumberLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        itemLineNumberLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // add and position item price textfield element to the right of the itemPriceLabel
        view.addSubview(itemLineNumberTextField)
        itemLineNumberTextField.leftAnchor.constraint(equalTo: itemLineNumberLabel.rightAnchor).isActive = true
        itemLineNumberTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        itemLineNumberTextField.bottomAnchor.constraint(equalTo: itemLineNumberLabel.bottomAnchor).isActive = true
        itemLineNumberTextField.topAnchor.constraint(equalTo: itemLineNumberLabel.topAnchor).isActive = true
        
        
        // add and position item line number label
        view.addSubview(notesLabel)
        notesLabel.topAnchor.constraint(equalTo: itemLineNumberLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        notesLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        notesLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        notesLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // add and position item price textfield element to the right of the itemPriceLabel
        view.addSubview(notesTextField)
        notesTextField.leftAnchor.constraint(equalTo: notesLabel.rightAnchor).isActive = true
        notesTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        //notesTextField.bottomAnchor.constraint(equalTo: notesLabel.bottomAnchor).isActive = true
        notesTextField.topAnchor.constraint(equalTo: notesLabel.topAnchor, constant: 6).isActive = true
        notesTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        // add segmented control view
        view.addSubview(lineItemTypeSegmentedControl)
        lineItemTypeSegmentedControl.topAnchor.constraint(equalTo: notesTextField.bottomAnchor, constant: 10).isActive = true
        lineItemTypeSegmentedControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        lineItemTypeSegmentedControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        
        lineItemTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
}
