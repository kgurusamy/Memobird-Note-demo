//
//  DetailTableViewController.swift
//  edit data demo
//
//  Created by Oottru on 04/09/17.
//  Copyright © 2017 Oottru technologies. All rights reserved.
//

import UIKit
import PhotoCropEditor
import Photos
import AssetsLibrary
let textFieldDefaultTag = 10
let imageViewDefaultTag = 20
let imageBGViewDefaultTag = 80
let imageOptionsViewDefaultTag = 30
let longPressButtonDefaultTag = 40
let imageDescriptionDefaultTag = 50
// For checking content type
enum contentType: Int {
    case text = 0
    case image = 1
}

class DetailTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
   
    var index:Int?
    var subNoteArray:[subNote]?
    let imagePicker = UIImagePickerController()
    var selectedRowIndex = 0
    var viewHasMoved = false
    var movingCellIndexPath : NSIndexPath? = nil
    
    var imagesDirectoryPath:String!
    var dragselectedRowIndex = 0
    var dragimageselected = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createImagesFolder()
        
        imagePicker.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(subNoteArray == nil){
            subNoteArray = []
            //let emptyImage:UIImage? = nil
            let emptyNote = subNote(type : contentType.text.rawValue, imageName: "some image name",text: " ")
            
            //let emptyString :String = " "
            subNoteArray?.insert(emptyNote,at: 0)
        }
        
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
        
        if(indexPath?.row != nil){
        dragselectedRowIndex = (indexPath!.row)
        }
        
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
                tableView.beginUpdates()
                tableView.endUpdates()
                tableView.reloadData()
                tableView.rowHeight = UITableViewAutomaticDimension
                dragimageselected = true
                Path.initialIndexPath = indexPath
                let cell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshotOfCell(cell!)
                cell?.isHidden = true
                var center = cell?.center

                My.cellSnapshot?.frame = CGRect(x:(My.cellSnapshot?.frame.origin.x)!, y:(My.cellSnapshot?.frame.origin.y)!,width:(My.cellSnapshot?.frame.size.width)!, height : 48)
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
                tableView.beginUpdates()
                tableView.endUpdates()
            viewHasMoved = true
            movingCellIndexPath = indexPath as NSIndexPath?
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot?.frame = CGRect(x:(My.cellSnapshot?.frame.origin.x)!, y:(My.cellSnapshot?.frame.origin.y)!,width:(My.cellSnapshot?.frame.size.width)!, height : 48)
                My.cellSnapshot!.center = center
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                    subNoteArray?.insert((subNoteArray?.remove(at: Path.initialIndexPath!.row))!, at: indexPath!.row)
                    tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                    Path.initialIndexPath = indexPath
                }
            }
            }
        default:
            tableView.beginUpdates()
            tableView.endUpdates()
            viewHasMoved = false
            dragimageselected = false
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
    
    @IBAction func deletebtn(_ sender: Any)
    {
        self.performSegue(withIdentifier: "deletee", sender: self)

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
    
   @IBAction func tapGestureForImageView(_ gestureRecognizer: UITapGestureRecognizer)
    {
        let currentCell : UITableViewCell! = gestureRecognizer.view?.superview?.superview as! UITableViewCell
        let currentIndexpath : NSIndexPath! = tableView.indexPath(for: currentCell)! as NSIndexPath
        
        let myImageOptionsView : UIView! = currentCell.contentView.viewWithTag(imageOptionsViewDefaultTag) as UIView!
        
        if(myImageOptionsView.isHidden == false){
            myImageOptionsView.isHidden = true
        }
        else{
            myImageOptionsView.isHidden = false
        }
        print("Imageview tapped on \(currentIndexpath!.row)")
                
    }

    // MARK: - TABLEVIEW DELEGATE methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = CGFloat()
        
        let mySubNoteData = subNoteArray?[indexPath.row]
        if (mySubNoteData?.type == contentType.image.rawValue)
        {
            if(viewHasMoved == true)
            {
                if( dragselectedRowIndex == indexPath.row)
                {
                    height = 48
                }
                else
                {
                    height = 280
                }
            }
            else
            {
                if( dragselectedRowIndex == indexPath.row)
                {
                    if (dragimageselected == true)
                    {
                        height = 48
                    }
                    else
                    {
                        height = 280
                    }
                }
                else
                {
                    height = 280
                }
            }
            //return 240
        }else{
            height = 48
        }
        return height
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
     
        tableView.beginUpdates()
        tableView.endUpdates()
    }

     override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (subNoteArray?.count != nil) {
            return (subNoteArray?.count)!
        }
        else{
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        
          if subNoteArray?[indexPath.row].type == contentType.text.rawValue {
            let ImageBGView : UIView! = cell.contentView.viewWithTag(imageBGViewDefaultTag)

            let myTextField : UITextField! = cell.contentView.viewWithTag(textFieldDefaultTag) as! UITextField!
            let myImageView : UIImageView! = cell.contentView.viewWithTag(imageViewDefaultTag) as! UIImageView!
            
            myImageView.image = nil
            myTextField.delegate = self
            myTextField.font = .systemFont(ofSize: 18)
            myTextField.text = subNoteArray?[indexPath.row].text
            myTextField.frame = CGRect(x: 5, y: 0, width: tableView.frame.size.width-12, height:cell.contentView.frame.size.height)
            myTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            myTextField.autocorrectionType = .no
            if #available(iOS 10.0, *) {
                myTextField.adjustsFontForContentSizeCategory = false
                myTextField.adjustsFontSizeToFitWidth = false
            } else {
                // Fallback on earlier versions
            }
            myTextField.isHidden = false
            ImageBGView.isHidden = true
            self.setInitialFocus()

            let longPressButton : UIButton! = cell.contentView.viewWithTag(longPressButtonDefaultTag) as! UIButton!
            longPressButton.isHidden = true
            
            let myImageOptionsView : UIView! = cell.contentView.viewWithTag(imageOptionsViewDefaultTag) as UIView!
            myImageOptionsView.isHidden = true
            
            let myphotoedittextfiled : UITextField! = cell.contentView.viewWithTag(imageDescriptionDefaultTag) as! UITextField!
            myphotoedittextfiled.isHidden = true

        }
        else
        {
            
            
            let ImageBGView : UIView! = cell.contentView.viewWithTag(imageBGViewDefaultTag)
            ImageBGView?.frame = CGRect(x : 24, y: 0, width : tableView.frame.size.width-48, height:278)
            ImageBGView.layer.borderWidth = 2
            ImageBGView.layer.borderColor = UIColor.white.cgColor
            ImageBGView.layer.shadowColor = UIColor.red.cgColor
            ImageBGView.isHidden = false

            if(viewHasMoved == true){
                let myMovingCell = tableView.cellForRow(at: movingCellIndexPath! as IndexPath)
                if movingCellIndexPath != nil{
                    myMovingCell?.isHidden = true
                }
                else{
                    myMovingCell?.isHidden = false
                }
            }
            let myTextField : UITextField! = cell.contentView.viewWithTag(textFieldDefaultTag) as! UITextField!
            myTextField.isHidden = true
            
            let myImageView : UIImageView! = cell.contentView.viewWithTag(imageViewDefaultTag) as! UIImageView!
            myImageView.frame = CGRect(x : 30, y: 5, width : tableView.frame.size.width-60, height:242)
            myImageView.contentMode = UIViewContentMode.scaleToFill
    
            let longPressButton : UIButton! = cell.contentView.viewWithTag(longPressButtonDefaultTag) as! UIButton!
            longPressButton.frame = CGRect(x: myImageView.frame.origin.x+myImageView.frame.size.width-10,y: myImageView.frame.origin.y+10,width:28,height:28)
            longPressButton.isHidden = false
            
            // Assign long press event for the Image for drag and drop
            let longpress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGestureRecognized(_:)))
            longPressButton.addGestureRecognizer(longpress)
            
            // Image tap event
            let tapImageView = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureForImageView(_:)))
            myImageView.addGestureRecognizer(tapImageView)
            
            let customImageObj = subNoteArray?[indexPath.row]
           
            let data = FileManager.default.contents(atPath: imagesDirectoryPath + "/\(customImageObj?.imageName ?? "")")
           
            myImageView.accessibilityIdentifier = customImageObj?.imageName
            if(data != nil){
                myImageView.image = UIImage(data: data!)
            }
            
            let imageDescription : UITextField! = cell.contentView.viewWithTag(imageDescriptionDefaultTag) as? UITextField
            imageDescription?.frame = CGRect(x : 30, y: 246, width : tableView.frame.size.width-60, height:30)
            imageDescription.delegate = self
            imageDescription.font = .systemFont(ofSize: 12)
            imageDescription.placeholder = "Picture Description"
            imageDescription.autocorrectionType = .no
            
            let imgDescCharactersCount = (customImageObj?.text.characters.count)
            
            if(imgDescCharactersCount != nil && imgDescCharactersCount! > 0){
                imageDescription.text = customImageObj?.text
                imageDescription.isHidden = false
            }else{
                imageDescription.isHidden = true
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
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
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
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
        
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil {
            
             if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                // Save image to Document directory
                var imageName = Date().description
                imageName = imageName.replacingOccurrences(of: " ", with: "") + ".png"
                let fullImagePath = imagesDirectoryPath + "/\(imageName)"
                let myImage = self.fixOrientation(image: image)
                let data = UIImagePNGRepresentation(myImage)
                let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
                if(success){
                    let customImageObj = subNote(type : contentType.image.rawValue, imageName:imageName , text:"")
                    subNoteArray?.insert(customImageObj, at: selectedRowIndex+1)
                }
            }
            tableView.reloadData()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "save" {
            let indexPaths  = indexPathsForRowsInSection(0, numberOfRows: tableView.numberOfRows(inSection: 0))
            subNoteArray?.removeAll()
            for i in 0 ..< indexPaths.count
            {
                let cell = tableView.cellForRow(at: (indexPaths[i]) as IndexPath)
                let myTextField : UITextField? = cell?.contentView.viewWithTag(textFieldDefaultTag) as? UITextField
                let myImageView : UIImageView? = cell?.contentView.viewWithTag(imageViewDefaultTag) as? UIImageView
            let imageDescription : UITextField? = cell?.contentView.viewWithTag(imageDescriptionDefaultTag) as? UITextField
               
                if(myImageView?.image != nil){
                    
                    let mysubNoteData = subNote(type : contentType.image.rawValue, imageName : (myImageView?.accessibilityIdentifier)!, text:(imageDescription?.text)!)
                    subNoteArray?.append(mysubNoteData)
                }
                else{
                    
                    let mysubNoteData = subNote(type : contentType.text.rawValue, imageName : "", text : myTextField?.text ?? " " )
                    subNoteArray?.append(mysubNoteData)
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        // Prepare for delete option
        if identifier == "deleteNote" {
            
            if((subNoteArray?.count)! > 0){
            
            let optionMenu = UIAlertController(title: nil, message: "Delete this Note?", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.deleteNote(sender: sender)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            self.present(optionMenu, animated: true) {
                    print("Delete option presented")
                }
                return false
            }
            else{
                return true
            }
        }
        else{
            return true
        }
    }

    // MARK: - TextField Methods

    func textFieldDidChange(textField: UITextField) {
        
        if(textField.tag != imageDescriptionDefaultTag)
        {
            let currentCell : UITableViewCell! = textField.superview?.superview as! UITableViewCell
            let currentIndexpath : NSIndexPath! = tableView.indexPath(for: currentCell)! as NSIndexPath
            selectedRowIndex = currentIndexpath!.row
            subNoteArray?[currentIndexpath!.row].text = textField.text!
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        if(textField.tag != imageDescriptionDefaultTag)
        {
        let currentCell : UITableViewCell! = textField.superview?.superview as! UITableViewCell
        let currentIndexpath : NSIndexPath! = tableView.indexPath(for: currentCell)! as NSIndexPath
        selectedRowIndex = currentIndexpath!.row

        createNewCell(atIndex: (currentIndexpath!.row))
        }
        return true
    }
 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let combinedString = textField.attributedText!.mutableCopy() as! NSMutableAttributedString
        combinedString.replaceCharacters(in: range, with: string)
        
        if(textField.tag != imageDescriptionDefaultTag)
        {
        if(string.isEmpty)
        {
            if let selectedRange = textField.selectedTextRange {
                
                let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
                
                if(cursorPosition==1)
                {
                    let currentCell : UITableViewCell! = textField.superview?.superview as! UITableViewCell
                    let currentIndexpath : NSIndexPath! = tableView.indexPath(for: currentCell)! as NSIndexPath
                    
                    textField.resignFirstResponder()
                    deleteCell(atIndex: currentIndexpath!.row)
                }
                
                print("\(cursorPosition)")
            }
            print("Backspace pressed")
        }
            if(combinedString.size().width < textField.bounds.size.width)
            {
                
            }else
            {
                let currentCell : UITableViewCell! = textField.superview?.superview as! UITableViewCell
                let currentIndexpath : NSIndexPath! = tableView.indexPath(for: currentCell)! as NSIndexPath
                selectedRowIndex = currentIndexpath!.row
                
                createNewCell(atIndex:  (currentIndexpath!.row))
                
            }
        }
        return combinedString.size().width < textField.bounds.size.width
    }

    @IBAction func photo_discription_btn(_ sender: UIButton)
    {
        let currentCell : UITableViewCell! = sender.superview?.superview?.superview as! UITableViewCell

        let myImageOptionsView : UIView! = currentCell.contentView.viewWithTag(imageOptionsViewDefaultTag) as UIView!
        
        let myphotoedittextfiled : UITextField! = currentCell.contentView.viewWithTag(imageDescriptionDefaultTag) as! UITextField!
        
        myphotoedittextfiled.isHidden = false
        myImageOptionsView.isHidden = true
        self.setInitialFocuspicturedescription()
    }
    // MARK: - Custom methods
    
    func createImagesFolder()
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        imagesDirectoryPath = documentDirectorPath + "/ImagePicker"
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a folder")
            }
        }
    }
    
    var cropimageindex = 0
    @IBAction func crop_btn(_ sender: UIButton)
    {
        let controller = CropViewController()
        controller.delegate = self
        let currentCell : UITableViewCell! = sender.superview?.superview?.superview as! UITableViewCell
        let currentIndexpath : NSIndexPath! = tableView.indexPath(for: currentCell)! as NSIndexPath
        cropimageindex = currentIndexpath.row
        let customImageObj = subNoteArray?[currentIndexpath.row]
        
        let data = FileManager.default.contents(atPath: imagesDirectoryPath + "/\(customImageObj?.imageName ?? "")")
        controller.image = UIImage(data :data!)
        
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
        
    }
    // Delete image action
    @IBAction func delete_image_clicked(_ sender : UIButton)
    {
        let currentCell : UITableViewCell! = sender.superview?.superview?.superview as! UITableViewCell
        let currentIndexpath : NSIndexPath! = tableView.indexPath(for: currentCell)! as NSIndexPath
        let myImageOptionsView : UIView! = currentCell.contentView.viewWithTag(imageOptionsViewDefaultTag) as UIView!
        myImageOptionsView.isHidden = true
        let mySubNoteObj = subNoteArray?[currentIndexpath.row]
        
        // Removing image from local folder
        self.deleteFileWithImageName(imageName: (mySubNoteObj?.imageName ?? ""))
        
        deleteCell(atIndex: currentIndexpath.row)
    }
    
    //Deleting string backspace
    func deleteCell(atIndex : Int)
    {
        if((subNoteArray?.count)!>1){
            subNoteArray?.remove(at: atIndex)
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1,initialSpringVelocity: 1, options:[], animations: {
                self.tableView.reloadData()
                
            }, completion: { (finished: Bool) in
                   
                let indexPaths  = self.indexPathsForRowsInSection(0, numberOfRows: self.tableView.numberOfRows(inSection: 0))
                var cell : UITableViewCell!
                if (indexPaths.count)>1 {
                    cell =  self.tableView.cellForRow(at: (indexPaths[atIndex-1]) as IndexPath)
                }
                else {
                
                    cell =  self.tableView.cellForRow(at: (indexPaths[0]) as IndexPath)
                }
                if(cell != nil){
                    
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
    
    // Delete note
    func deleteNote(sender : Any?)
    {
        for subNoteObj in subNoteArray!
        {
            if(subNoteObj.type == contentType.image.rawValue)
            {
                self.deleteFileWithImageName(imageName: subNoteObj.imageName)
            }
        }
        subNoteArray?.removeAll()
        performSegue(withIdentifier: "deleteNote", sender: sender)
    }
    
    //Creating new cell
    func createNewCell(atIndex : Int)
    {
        let emptyNote = subNote(type : contentType.text.rawValue, imageName : "some image name", text : " ")
        subNoteArray?.insert(emptyNote, at: atIndex+1)
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options:[], animations: {
             self.tableView.reloadData()
        }, completion: { (finished: Bool) in
            let indexPaths =  self.indexPathsForRowsInSection(0, numberOfRows: self.tableView.numberOfRows(inSection: 0))
            let cell =  self.tableView.cellForRow(at: (indexPaths[atIndex+1]) as IndexPath)
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
        if(subNoteArray?.count==0){
            createNewCell(atIndex: -1)
        }
        let indexPaths  = indexPathsForRowsInSection(0, numberOfRows: tableView.numberOfRows(inSection: 0))
        let cell =  self.tableView.cellForRow(at: (indexPaths[(subNoteArray?.count)!-1]) as IndexPath)
        if((cell?.contentView.viewWithTag(textFieldDefaultTag)) != nil)
        {
            cell?.setSelected(true, animated:true)
            let currentTextField : UITextField! = cell!.contentView.viewWithTag(textFieldDefaultTag) as! UITextField
            currentTextField.delegate = self
            currentTextField.becomeFirstResponder()
        }
    }
    
    func setInitialFocuspicturedescription()
    {
        let indexPaths  = indexPathsForRowsInSection(0, numberOfRows: tableView.numberOfRows(inSection: 0))
        let cell =  self.tableView.cellForRow(at: (indexPaths[(subNoteArray?.count)!-1]) as IndexPath)
        if((cell?.contentView.viewWithTag(imageDescriptionDefaultTag)) != nil)
        {
            cell?.setSelected(true, animated:true)
            let currentTextField : UITextField! = cell!.contentView.viewWithTag(imageDescriptionDefaultTag) as! UITextField
            currentTextField.delegate = self
            currentTextField.becomeFirstResponder()
        }
    }

    // Getting indexPaths for all rows
    func indexPathsForRowsInSection(_ section: Int, numberOfRows: Int) -> [NSIndexPath] {
        return (0..<numberOfRows).map{NSIndexPath(row: $0, section: section)}
    }
    // MARK: - CropView
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
    }

    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect){
    
        let customSubNoteObj = subNoteArray?[cropimageindex]
        let imageName = customSubNoteObj?.imageName
        deleteFileWithImageName(imageName: (customSubNoteObj?.imageName)!)
        
        let fullImagePath = imagesDirectoryPath + "/\(imageName ?? "")"
        let data = UIImagePNGRepresentation(image)
        let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
        if(success){
            let imageDesc = customSubNoteObj?.text
            customSubNoteObj?.text = imageDesc!
            subNoteArray?[cropimageindex] = customSubNoteObj!
        }

        controller.dismiss(animated: true, completion: nil)
        tableView .reloadData()
   }

    func cropViewControllerDidCancel(_ controller: CropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Helper methods
    
    func fixOrientation(image: UIImage) -> UIImage {
        // No-op if the orientation is already correct
        if (image.imageOrientation == UIImageOrientation.up) { return image; }
        
        print(image.imageOrientation)
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch (image.imageOrientation) {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: .pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: .pi/2)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -.pi/2)
            break
        case .up, .upMirrored:
            break
        }
        
        switch (image.imageOrientation) {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .up, .down, .left, .right:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        
        let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue)
        
        ctx!.concatenate(transform);
        
        switch (image.imageOrientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            ctx?.draw(image.cgImage!, in: CGRect(origin: .zero, size: CGSize(width: image.size.height, height: image.size.width)))
            
            break
            
        default:
            ctx?.draw(image.cgImage!, in: CGRect(origin: .zero, size: CGSize(width: image.size.width, height: image.size.height)))
            break
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = ctx!.makeImage()
        let img = UIImage(cgImage: cgimg!)
        
        return img
    }

    // Delete file with imageName
    func deleteFileWithImageName(imageName : String)
    {
        if(imageName != ""){
            
            let filePath = "\(imagesDirectoryPath!)/\(imageName)"
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }
    }

   
}

