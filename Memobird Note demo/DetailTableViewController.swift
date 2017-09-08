//
//  DetailTableViewController.swift
//  edit data demo
//
//  Created by Oottru on 04/09/17.
//  Copyright © 2017 Oottru technologies. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

let textFieldDefaultTag = 10
let imageViewDefaultTag = 20

class DetailTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

   
    var index:Int?
    var subModelArray:[Any]!
    let imagePicker = UIImagePickerController()
    var editedModel:String?
    var selectedRowIndex = 0
    var viewHasMoved = false
    var movingCellIndexPath : NSIndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
//Drag and drop long press gesture on tableview cell
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(DetailTableViewController.longPressGestureRecognized(_:)))
        tableView.addGestureRecognizer(longpress)
        tableView.rowHeight = UITableViewAutomaticDimension
        print("subModelArrayCount : \(subModelArray.count)")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setInitialFocus()
    }

    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: tableView)
        var indexPath = tableView.indexPathForRow(at: locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshotOfCell(cell!)
                cell?.isHidden = true
                var center = cell?.center
                My.cellSnapshot?.frame = CGRect(x:(My.cellSnapshot?.frame.origin.x)!, y:(My.cellSnapshot?.frame.origin.y)!,width:(My.cellSnapshot?.frame.size.width)!, height : 40)
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                tableView.addSubview(My.cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        My.cellIsAnimating = false
                        if My.cellNeedToShow {
                            My.cellNeedToShow = false
                            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                                cell?.alpha = 1
                            })
                        } else {
                            cell?.isHidden = true
                        }
                    }
                })
            }
            
        case UIGestureRecognizerState.changed:
            if(indexPath != nil){
            viewHasMoved = true
            movingCellIndexPath = indexPath as NSIndexPath?
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot?.frame = CGRect(x:(My.cellSnapshot?.frame.origin.x)!, y:(My.cellSnapshot?.frame.origin.y)!,width:(My.cellSnapshot?.frame.size.width)!, height : 40)
                My.cellSnapshot!.center = center
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                    subModelArray.insert(subModelArray.remove(at: Path.initialIndexPath!.row), at: indexPath!.row)
                    tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                    Path.initialIndexPath = indexPath
                }
            }
            }
        default:
            viewHasMoved = false

            if Path.initialIndexPath != nil {
                let cell = tableView.cellForRow(at: Path.initialIndexPath!) as UITableViewCell!
                if(cell != nil){
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell?.isHidden = false
                    cell?.alpha = 0.0
                }
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = (cell?.center)!
                    My.cellSnapshot!.transform = CGAffineTransform.identity
                    My.cellSnapshot!.alpha = 0.0
                    cell?.alpha = 1.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
            }
                tableView.reloadData()
            }
        }
        
    }
    
    func snapshotOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - TABLEVIEW DELEGATE methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if ((subModelArray[indexPath.row] as? UIImage) != nil)
        {
            if(viewHasMoved == true)
            {
                return 40
            }
            else
            {
                return 240
            }
        }
        
        return 40
        //Not expanded
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

     override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return subModelArray.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        
          if subModelArray[indexPath.row] is String
        {

            let myTextField : UITextField! = cell.contentView.viewWithTag(textFieldDefaultTag) as! UITextField!
            let myImageView : UIImageView! = cell.contentView.viewWithTag(imageViewDefaultTag) as! UIImageView!
            myImageView.image = nil
            myTextField.delegate = self
            myTextField.font = .systemFont(ofSize: 18)
            myTextField.text = subModelArray[indexPath.row] as? String
            myTextField.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width-30, height:cell.contentView.frame.size.height)
            myTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            myTextField.autocorrectionType = .no
        }
        else
        {
            if(viewHasMoved == true)
            {
                let myMovingCell = tableView.cellForRow(at: movingCellIndexPath! as IndexPath)
                if movingCellIndexPath != nil
                {
                    myMovingCell?.isHidden = true
                }
                else
                {
                    myMovingCell?.isHidden = false
                }
            }
            let myTextField : UITextField! = cell.contentView.viewWithTag(textFieldDefaultTag) as! UITextField!
            myTextField.text = ""
            let myImageView : UIImageView! = cell.contentView.viewWithTag(imageViewDefaultTag) as! UIImageView!
            myImageView.frame = CGRect(x : 30, y: 5, width : tableView.frame.size.width-60, height:300)
            myImageView.contentMode = UIViewContentMode.scaleAspectFit
            myImageView.image = subModelArray[indexPath.row] as? UIImage
        }
        cell.selectionStyle = .none
        // Configure the cell...
        return cell
    }
    
    // MARK: - IMAGEPICKER METHODS
    @IBAction func loadImageButtonTapped(sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Image", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openCamera()
        })
        let gallaryAction = UIAlertAction(title: "Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openGallary()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(gallaryAction)
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(optionMenu, animated: true) { 
            print("option menu presented")
        }
    }
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            subModelArray.insert(image, at: selectedRowIndex+1)
            tableView.reloadData()
        }
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "save" {
            let indexPaths  = indexPathsForRowsInSection(0, numberOfRows: tableView.numberOfRows(inSection: 0))
            subModelArray.removeAll()
            for i in 0 ..< indexPaths.count
            {
                let cell = tableView.cellForRow(at: (indexPaths[i]) as IndexPath)
                let myTextField : UITextField? = cell?.contentView.viewWithTag(textFieldDefaultTag) as? UITextField
                let myImageView : UIImageView? = cell?.contentView.viewWithTag(imageViewDefaultTag) as? UIImageView
                if(myImageView?.image != nil)
                {
                    subModelArray.append(myImageView?.image! as Any)
                }
                else
                {
                    subModelArray.append(myTextField?.text ?? "")
                }
            }
 
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - TextField Methods
  
    func textFieldDidChange(textField: UITextField) {
        
        let currentCell : UITableViewCell! = textField.superview?.superview as! UITableViewCell
        let currentIndexpath : NSIndexPath! = tableView.indexPath(for: currentCell)! as NSIndexPath
        selectedRowIndex = currentIndexpath!.row
        subModelArray[currentIndexpath!.row] = textField.text!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        let currentCell : UITableViewCell! = textField.superview?.superview as! UITableViewCell
        let currentIndexpath : NSIndexPath! = tableView.indexPath(for: currentCell)! as NSIndexPath
        selectedRowIndex = currentIndexpath!.row

        createNewCell(tag: (currentIndexpath!.row))
        
        return true
    }
 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(string.isEmpty)
        {
            if let selectedRange = textField.selectedTextRange {
                
                let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
                
                if(cursorPosition==1)
                {
                    let currentCell : UITableViewCell! = textField.superview?.superview as! UITableViewCell
                    let currentIndexpath : NSIndexPath! = tableView.indexPath(for: currentCell)! as NSIndexPath
                    
                    textField.resignFirstResponder()
                    deleteCell(tag: currentIndexpath!.row)
                }
                
                print("\(cursorPosition)")
            }
            print("Backspace pressed")
        }
        return true
    }
    
    // MARK: - Custom methods
 //Deleting string backspace
    func deleteCell(tag : Int)
    {
        if(subModelArray.count>1){
            subModelArray.remove(at: tag)
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1,initialSpringVelocity: 1, options:[], animations: {
            self.tableView.reloadData()
                 }, completion: { (finished: Bool) in
                    print("deleteCell method : tag : \(tag)")
                    //let indexPaths = self.tableView.indexPathsForVisibleRows
                     let indexPaths  = self.indexPathsForRowsInSection(0, numberOfRows: self.tableView.numberOfRows(inSection: 0))
                    //var myIndexPath = IndexPath()
                    var cell : UITableViewCell!
                    if (indexPaths.count)>1 {
                        cell =  self.tableView.cellForRow(at: (indexPaths[tag-1]) as IndexPath)
                    }
                    else {
                        cell =  self.tableView.cellForRow(at: (indexPaths[0]) as IndexPath)
                    }
                    if(cell != nil)
                    {
                        cell?.setSelected(true, animated:true)
                        
                        let previousTextField : UITextField! = cell!.contentView.viewWithTag(textFieldDefaultTag) as! UITextField
                        if(previousTextField.canBecomeFirstResponder){
                            if(previousTextField.text?.characters.count==0){
                                previousTextField.text? = " "
                            }
                            previousTextField.becomeFirstResponder()
                        }
                    }
            })
          
        }
    }
    //Creating new cell
    func createNewCell(tag : Int)
    {
        let emptyRow : String = " "
        subModelArray.insert(emptyRow, at: tag+1)
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options:[], animations: {
             self.tableView.reloadData()
        }, completion: { (finished: Bool) in
            let indexPaths =  self.indexPathsForRowsInSection(0, numberOfRows: self.tableView.numberOfRows(inSection: 0))
            let cell =  self.tableView.cellForRow(at: (indexPaths[tag+1]) as IndexPath)
            if((cell?.contentView.viewWithTag(textFieldDefaultTag)) != nil)
            {
                cell?.setSelected(true, animated:true)
                let nextTextField : UITextField! = cell!.contentView.viewWithTag(textFieldDefaultTag) as! UITextField
                nextTextField.becomeFirstResponder()
            }
        })
    }
    //Initial Textfield focus point
    func setInitialFocus()
    {
        
        let indexPaths  = indexPathsForRowsInSection(0, numberOfRows: tableView.numberOfRows(inSection: 0))
        let cell =  self.tableView.cellForRow(at: (indexPaths[subModelArray.count-1]) as IndexPath)
        if((cell?.contentView.viewWithTag(textFieldDefaultTag)) != nil)
        {
            cell?.setSelected(true, animated:true)
            let currentTextField : UITextField! = cell!.contentView.viewWithTag(textFieldDefaultTag) as! UITextField
            currentTextField.delegate = self
            currentTextField.becomeFirstResponder()
        }

        
    }
    
    // Getting indexPaths for all rows
    func indexPathsForRowsInSection(_ section: Int, numberOfRows: Int) -> [NSIndexPath] {
        return (0..<numberOfRows).map{NSIndexPath(row: $0, section: section)}
    }

}



extension UITextField {
    func setCursor(position: Int) {
        let position = self.position(from: beginningOfDocument, offset: position)!
        selectedTextRange = textRange(from: position, to: position)
    }
}
