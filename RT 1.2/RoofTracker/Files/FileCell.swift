//
//  fileCell.swift
//  TrainingCourse
//
//  Created by Mitch Baumgartner on 3/2/21.
//
// this file customizes the cells in filesController
import UIKit
class FileCell: UITableViewCell {
    
    var file: File? { // start off file with nil with ?
        didSet {
            // extract file name out of file
            nameLabel.text = file?.name
            messageLabel.text = ""
            // place image in cell, each cell already has a image property for, once you call for it it will show up
//            cell.imageView?.image = #imageLiteral(resourceName: "select_photo_empty");
            if let imageData = file?.imageData {
                fileImageView.image = UIImage(data: imageData);
            }
            // make date show up pretty in cell by unwrapping name and founded property
            if let name = file?.name, let coc = Double(file?.coc ?? ""), let deductible = Double(file?.deductible ?? "") {
                let currencyFormatter = NumberFormatter()
                currencyFormatter.usesGroupingSeparator = true
                currencyFormatter.numberStyle = .currency
                currencyFormatter.locale = Locale.current
                
//                // MMM dd, yyyy
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "MMM dd, yyyy"
//                let foundedDateString = dateFormatter.string(from: founded)
                let checkACVTotal = Double(file?.insCheckACVTotal ?? "")
                if checkACVTotal == nil {
                    let insToHomeOwner = coc - deductible
                    let shortDeductible = currencyFormatter.string(from: NSNumber(value: insToHomeOwner))
                    let fileString = "\(name)"
                    let message = "Insurance still owes HO: \(shortDeductible ?? "$0.00")"
                    
                    nameLabel.text = fileString
                    messageLabel.text = message
                } else if checkACVTotal != nil {
                    let fileString = "\(name)"
                    let moneyToHO = coc + checkACVTotal! - deductible
                    let moneyToHOFormat = currencyFormatter.string(from: NSNumber(value: moneyToHO))
                    let message = "Insurance still owes HO: \(moneyToHOFormat ?? "$0.00")"
                    //nameLabel.text = file?.name
                    nameLabel.text = fileString
                    messageLabel.text = message
                }
    

                
            } else {
                nameLabel.text = file?.name
            }
            

        }
    }
    
    // ypu cannot declare another image view using "imageView"
    let fileImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "file_photo_empty"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // circular picture
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.darkBlue.cgColor
        imageView.layer.borderWidth = 0.8
        return imageView
    }()
    
    // create custom label for file name
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "FILE NAME"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create custom label for file message
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "MESSAGE"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.tealColor
        // placement of the image in cell
        addSubview(fileImageView)
        fileImageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        fileImageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        fileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        fileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        // placement of file name in cell
        addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: fileImageView.rightAnchor, constant: 24).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        //nameLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        // placement of file message in cell
        addSubview(messageLabel)
        messageLabel.leftAnchor.constraint(equalTo: fileImageView.rightAnchor, constant: 24).isActive = true
        messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

