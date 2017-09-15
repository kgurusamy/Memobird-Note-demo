//
//  MainTableViewController.swift
//  edit data demo
//
//  Created by Oottru on 04/09/17.
//  Copyright © 2017 Oottru technologies. All rights reserved.
//

import UIKit
import Foundation
import CoreData

let dateLabelDefaultTag = 10
let noteLabelDefaultTag = 20

class MainTableViewController: UITableViewController {
    
    var notes = [Notes]()
  
//  MARK: - VIEWCONTROLLER DELEGATE methods
    override func viewDidLoad() {
        super.viewDidLoad()
    
        getSavedData()
        
        // Retrieving from local storage
//        if(UserDefaults.standard.object(forKey: "notes") != nil){
//            let decoded  = UserDefaults.standard.object(forKey: "notes") as! Data
//            notes = NSKeyedUnarchiver.unarchiveObject( with: decoded as Data!) as! [[Any]]
//        }
    }
       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   //  MARK: - TABLEVIEW DELEGATE methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        cell.clipsToBounds = true
        // Configure the cell...
        
        let myNoteNameLabel : UILabel! = cell.contentView.viewWithTag(noteLabelDefaultTag) as! UILabel!
        myNoteNameLabel.text = notes[indexPath.row].name
        
        let myDateLabel : UILabel! = cell.contentView.viewWithTag(dateLabelDefaultTag) as! UILabel!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let modifiedDateTime = notes[indexPath.row].modified_time
        
        myDateLabel.text = formatter.string(from: modifiedDateTime! as Date)
        
        return cell
    }
    
    //  MARK: - ADD & SAVE methods
    // Add newnote button click
    @IBAction func Addnotebtn(_ sender: Any)
    {
       
        InitialNoteSave()
        getSavedData()
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1,initialSpringVelocity: 1, options:[], animations: {
            
            self.tableView .reloadData()
            
        }, completion: { (finished: Bool) in
            
            let indexPath = IndexPath(row: self.notes.count-1, section: 0)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            self.performSegue(withIdentifier: "edit", sender: self)
        })
        
    }
    // Save button click
    @IBAction func saveToMainViewController (_ segue:UIStoryboardSegue) {
        
        let detailViewController = segue.source as! DetailTableViewController
        let index = detailViewController.index
        let subModel = detailViewController.subModelArray
        
        let fetchRequest: NSFetchRequest<Notes> = Notes.fetchRequest()
     
        do {
            let records = try CoreDataStack.managedObjectContext.fetch(fetchRequest)
            let saveNote : Notes  = records[index!]
        
        saveNote.subNote = subModel! as NSObject
            
        saveNote.modified_time = Date() as NSDate
    
        for i in 0..<subModel!.count {
            if subModel?[i] is String {
                let localString = subModel?[i] as? String
                if((localString?.characters.count)! > 0 && localString != " ")
                {
                    saveNote.name = subModel![i] as? String
                    break
                }
            }
        }

        } catch {
            print(error)
        }
        
        CoreDataStack.saveContext()
        
// Saving to local storage
//        let defaults = UserDefaults.standard
//        let encodedData = NSKeyedArchiver.archivedData(withRootObject: notes)
//        defaults.set(encodedData, forKey: "notes")
//        defaults.synchronize()
        tableView.reloadData()
    }

  
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let path = tableView.indexPathForSelectedRow
            let detailViewController = segue.destination as! DetailTableViewController
            detailViewController.index = path?.row
            
            detailViewController.subModelArray = notes[(path?.row)!].subNote as? [Any]
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    //  MARK: - CoreData ADD & SAVE methods
   
    func InitialNoteSave() {
        if #available(iOS 10.0, *) {
            let coreDataNote = Notes(context: CoreDataStack.managedObjectContext)
          
            coreDataNote.name = " "
            coreDataNote.modified_time = Date() as NSDate
            coreDataNote.subNote = nil
            
        } else {
            // Fallback on earlier versions
            
            let entityDesc = NSEntityDescription.entity(forEntityName: "Notes", in: CoreDataStack.managedObjectContext)
            let coreDataNote = Notes(entity: entityDesc!, insertInto: CoreDataStack.managedObjectContext)
            coreDataNote.name = " "
            coreDataNote.modified_time = Date() as NSDate
            coreDataNote.subNote = nil
        }
        CoreDataStack.saveContext()
    }

    func getSavedData()
    {
        
        let fetchRequest: NSFetchRequest<Notes> = Notes.fetchRequest()
        
        do {

            notes = try CoreDataStack.managedObjectContext.fetch(fetchRequest)
            
            for record in notes {
                
                print("Note name : \(record.name ?? " ")")
                print("Date created :\(String(describing: record.modified_time ?? nil))")
            }
            
        } catch {
            print(error)
        }
    }
}
