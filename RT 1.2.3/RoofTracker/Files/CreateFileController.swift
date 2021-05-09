//
//  CreatefileController.swift
//  TrainingCourse
//
//  Created by Mitch Baumgartner on 2/27/21.
//

// this file will create a clustom viewController that allows user to add a file to the tableView with a nice display
import UIKit
import CoreData
extension String {
    func toDecimalWithAutoLocale() -> Decimal? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        //** US,CAD,GBP formatted
        formatter.locale = Locale(identifier: "en_US")

        if let number = formatter.number(from: self) {
            return number.decimalValue
        }
        
        return nil
    }
    func toDoubleWithAutoLocale() -> Double? {
        guard let decimal = self.toDecimalWithAutoLocale() else {
            return nil
        }

        return NSDecimalNumber(decimal:decimal).doubleValue
    }
}

//custom delegation
protocol CreateFileControllerDelegate {
    func didAddFile(file: File)
    func didEditFile(file: File)
}

class CreateFileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // variable keeps track of which file you are trying to edit. variable comapny with type file
    var file: File? {
        // this will prefill the form with whatever i need when tapping the edit button
        didSet {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = .decimal
            currencyFormatter.currencySymbol = ""
            
            nameTextField.text = file?.name
            
            cocTextField.text = file?.coc
            if file?.coc != "" {
                let coc = Double(file?.coc ?? "")
                let cocFormat = currencyFormatter.string(from: NSNumber(value: coc ?? 0.0))
                cocTextField.text = cocFormat
            }
            
            invoiceTextField.text = file?.invoice
            if file?.invoice != "" {
                let invoice = Double(file?.invoice ?? "")
                let invoiceFormat = currencyFormatter.string(from: NSNumber(value: invoice ?? 0.0))
                invoiceTextField.text = invoiceFormat
            }
            
            deductibleTextField.text = file?.deductible
            if file?.deductible != "" {
                let deductible = Double(file?.deductible ?? "")
                let deductibleFormat = currencyFormatter.string(from: NSNumber(value: deductible ?? 0.0))
                deductibleTextField.text = deductibleFormat
            }
            // set image whenever editing file, optional (?) because it might be an empty image
            if let imageData = file?.imageData {
                fileImageView.image = UIImage(data: imageData)
                // call function that styles the image
                setupCircularStyle()

            }
//            // this fixes the crash if you tap edit on a cell without a date
//            guard let founded = file?.founded else { return }
//            datePicker.date = (file?.founded)!
        }
    }
    // this function styles the images, a shortcut to avoid redundancy and copying and pasting code
    private func setupCircularStyle() {
        // make image circular
        fileImageView.layer.cornerRadius = fileImageView.frame.width / 3
        // this makes it so that image actually gets clipped off outside of the circle
        fileImageView.clipsToBounds = true
        // add circular border outline around image
        //fileImageView.layer.borderColor = UIColor.darkBlue.cgColor //border color expects a cgcolor (coregraphics color)
        fileImageView.layer.borderWidth = 1
    }
    
    var delegate: CreateFileControllerDelegate?
    
    // establishes link to filesController
    //var filesController: filesController?
    
    // create image picker option profile picture
    // lazy var enables self to be something other than nil, so that handleSelectPhoto actually works
    lazy var fileImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "file_photo_empty"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // alters the squashed look to make the image appear normal in the view, fixes aspect ratio
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.width / 3
        imageView.layer.borderWidth = 1
        // to make user image interactive so user can choose a photo
        imageView.isUserInteractionEnabled = true
        // similar to button handler, need user to be able to gesture to open up images
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto)))
        return imageView
        
    }()
    @objc private func handleSelectPhoto() {
        print("trying to select photo...")
        
        // pop up for user to choose photo from their campera roll
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        // allow editing of photo
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    // when user selects photo have a cancel option
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    // get image user selects
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info) // info contains image we are selecting
        // to get image out of info dictionary
        // if the image is edited, then use the edited image, otherwise use the original image
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            fileImageView.image = editedImage
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // set image if it has not been edited
            fileImageView.image = originalImage
        }
        // call function that styles the image
        setupCircularStyle()
        // dismiss entire view image controller
        dismiss(animated: true, completion: nil)
        
    }
    // create file name label
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for name entry
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter name",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    // create COC total label
    let cocLabel: UILabel = {
        let label = UILabel()
        label.text = "COC Total:            $"
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // create text field for coc entry
    let cocTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter coc total",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = UIKeyboardType.decimalPad
        return textField
    }()
    // create invoice total label
    let invoiceLabel: UILabel = {
        let label = UILabel()
        label.text = "Invoice Total:        $"
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for coc entry
    let invoiceTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter invoice total",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = UIKeyboardType.decimalPad
        return textField
    }()
    // create deductible total label
    let deductibleLabel: UILabel = {
        let label = UILabel()
        label.text = "Deductible Total: $"
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // create text field for coc entry
    let deductibleTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter deductible total",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = UIKeyboardType.decimalPad
        return textField
    }()
    
//    // create date picker property
//    let datePicker: UIDatePicker = {
//        let dp = UIDatePicker()
//        // change style of date picerk UI
//        dp.datePickerMode = .date
//        dp.translatesAutoresizingMaskIntoConstraints = false
//
//        return dp
//    }()
//
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ternary syntax. Basically a shortened if else statement that checks to see if file is nil or if it is already avalible which would determine the title
        navigationItem.title = file == nil ? "Create File" : "Edit File"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up label position in view controller
        setupUI()
        // create title for this view controller
        navigationItem.title = "Create File"
        
        // add cancel button to dismiss view
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        // add save button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        
        view.backgroundColor = UIColor.darkBlue
        
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
    // save function
    @objc private func handleSave() {
        // this means im creating a file
        if file == nil {
            createFile()
        } else {
            saveFileChanges()
        }
    }
    // save file edits when i tap the "save" button on edit file modal
        
    private func saveFileChanges() {
        // persist the change in coredata
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let coc = cocTextField.text
        // if user enters something in the coc textfield, start this if statement block
        if coc != "" {
            let cocDouble = coc?.toDoubleWithAutoLocale()
            // if user enters invalid entry for a coc value (commas and decimals) error message
            if cocDouble == nil {
                return showError(title: "Invalid COC Entry", message: "Double check your COC entry.")
            }
            file?.coc = "\(cocDouble ?? 0.00)"
            
        } else { // if user decides to remove a coc entry, the save will clear the textfield to empty
            file?.coc = coc
        }
        
        let invoice = invoiceTextField.text
        // if user enters something in the invoice textfield, start this if statement block
        if invoice != "" {
            let invoiceDouble = invoice?.toDoubleWithAutoLocale()
            // if user enters invalid entry for a invoice value (commas and decimals) error message
            if invoiceDouble == nil {
                return showError(title: "Invalid Invoice Entry", message: "Double check your Invoice entry.")
            }
            file?.invoice = "\(invoiceDouble ?? 0.0)"
        } else { // if user decides to remove a invoice entry, the save will clear the textfield to empty
            file?.invoice = invoice
        }
        
        let deductible = deductibleTextField.text
        // if user enters something in the deductible textfield, start this if statement block
        if deductible != "" {
            let deductibleDouble = deductible?.toDoubleWithAutoLocale()
            // if user enters invalid entry for a deductible value (commas and decimals) error message
            if deductibleDouble == nil {
                return showError(title: "Invalid Deductible Entry", message: "Double check your Deductible entry.")
            }
            file?.deductible = "\(deductibleDouble ?? 0.0)"
        } else {
            file?.deductible = deductible
        }
        
        file?.name = nameTextField.text
        file?.insCheckACVTotal = file?.insCheckACVTotal
        
        // reset time stamp
        let timeStamp = "\(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .long))"
        file?.timeStamp = timeStamp
//        file?.founded = datePicker.date
        
        
        
        // properly save data even when you are editing the row
        if let fileImage = fileImageView.image {
            let imageData = fileImage.jpegData(compressionQuality: 0.8)
            file?.imageData = imageData
        }
        
        do {
            try context.save()
            // save succeeded
            dismiss(animated: true, completion: {
                self.delegate?.didEditFile(file: self.file!)
            })
        } catch let saveErr {
            print("Failed to save file changes:", saveErr)
        }
        
        
    }
    
    
    private func createFile() {
        print("trying to save file")

        // this comes from CoreDataManger.swift
       // CoreDataManager.shared.persistentContainer.viewContext
        
        // initalization of our core data stack
//        let persistentContainer = NSPersistentContainer(name: "TrainingModels")
//        persistentContainer.loadPersistentStores { (storeDescription, err) in
//            if let err = err {
//                fatalError("loading of store failed: \(err)")
//            }
//        }
        // put data in context so it can be saved later on
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let file = NSEntityDescription.insertNewObject(forEntityName: "File", into: context)
        let timeStamp = "\(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .long))"
        // set the value of what the user enters in name of file
        file.setValue(nameTextField.text, forKey: "name")
        file.setValue(cocTextField.text, forKey: "coc")
        file.setValue(invoiceTextField.text, forKey: "invoice")
        file.setValue(deductibleTextField.text, forKey: "deductible")
        file.setValue(timeStamp, forKey: "timeStamp")
        // set founded date
//        file.setValue(datePicker.date, forKey: "founded")
        // set new image value in core data
        if let fileImage = fileImageView.image {
            let imageData = fileImage.jpegData(compressionQuality: 0.8)
            file.setValue(imageData, forKey: "imageData")
        }
        
       
        // perform the save
        do {
            try context.save()
            
            // success
            dismiss(animated: true, completion: {
                self.delegate?.didAddFile(file: file as! File)
            })
 
        } catch let saveErr {
            print("Failed to save file:", saveErr)
        }

        // dismiss modal with animation to insert the row
//        dismiss(animated: true) {
//            // use the name text field property to save it as the file name
//            // get text out of textfield, any code that is right after guard statement, use this name variable instead
//            // we need a self because we have closure {} to avoid retain cycle
//            guard let name = self.nameTextField.text else { return }
//            let file = file(name: name, founded: Date())
//            // send new file to the filesController
//            self.filesController?.addfile(file: file)
//        }
        
        
    }
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    
    // all code to add any layout UI elements
    private func setupUI() {
        // add and position background color in relationship to the view elements on the view controller
        let silverBackgroundView = UIView()
        silverBackgroundView.backgroundColor = UIColor.silver
        silverBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(silverBackgroundView)
        silverBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        silverBackgroundView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        silverBackgroundView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        silverBackgroundView.heightAnchor.constraint(equalToConstant: 320).isActive = true
        
        //add image picker view
        view.addSubview(fileImageView)
        // gives padding of image from top
        fileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        fileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        fileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        fileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        // add and position name label
        view.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: fileImageView.bottomAnchor).isActive = true
        // move label to the right a bit
        nameLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        nameLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(nameTextField)
        nameTextField.leftAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        nameTextField.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        nameTextField.topAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // add and position coc label
        view.addSubview(cocLabel)
        cocLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        cocLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        cocLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        cocLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // add and position coc textfield element to the right of the nameLabel
        view.addSubview(cocTextField)
        cocTextField.leftAnchor.constraint(equalTo: cocLabel.rightAnchor).isActive = true
        cocTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        cocTextField.bottomAnchor.constraint(equalTo: cocLabel.bottomAnchor).isActive = true
        cocTextField.topAnchor.constraint(equalTo: cocLabel.topAnchor).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // add and position invoice label
        view.addSubview(invoiceLabel)
        invoiceLabel.topAnchor.constraint(equalTo: cocLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        invoiceLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        invoiceLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        invoiceLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // add and position invoice textfield element to the right of the nameLabel
        view.addSubview(invoiceTextField)
        invoiceTextField.leftAnchor.constraint(equalTo: invoiceLabel.rightAnchor).isActive = true
        invoiceTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        invoiceTextField.bottomAnchor.constraint(equalTo: invoiceLabel.bottomAnchor).isActive = true
        invoiceTextField.topAnchor.constraint(equalTo: invoiceLabel.topAnchor).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // add and position deductible label
        view.addSubview(deductibleLabel)
        deductibleLabel.topAnchor.constraint(equalTo: invoiceLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        deductibleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        deductibleLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        deductibleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(deductibleTextField)
        deductibleTextField.leftAnchor.constraint(equalTo: deductibleLabel.rightAnchor).isActive = true
        deductibleTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        deductibleTextField.bottomAnchor.constraint(equalTo: deductibleLabel.bottomAnchor).isActive = true
        deductibleTextField.topAnchor.constraint(equalTo: deductibleLabel.topAnchor).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
//        // add and position datepicker element
//        view.addSubview(datePicker)
//        datePicker.topAnchor.constraint(equalTo: deductibleLabel.bottomAnchor).isActive = true
//        datePicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        datePicker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        datePicker.bottomAnchor.constraint(equalTo: lightBlueBackgroundView.bottomAnchor).isActive = true
        
    }
    
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}

