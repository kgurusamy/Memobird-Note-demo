//
//  MainTableViewController.swift
//  edit data demo
//
//  Created by Oottru on 04/09/17.
//  Copyright © 2017 Oottru technologies. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    var notes = [[Any]]()
  
//  MARK: - VIEWCONTROLLER DELEGATE methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieving from local storage
        if(UserDefaults.standard.object(forKey: "notes") != nil){
            let decoded  = UserDefaults.standard.object(forKey: "notes") as! Data
            notes = NSKeyedUnarchiver.unarchiveObject( with: decoded as Data!) as! [[Any]]
        }
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
        // Configure the cell...
        var submodel = notes[indexPath.row]
        // Setting a first string as a title for the Row
        for i in 0 ..< submodel.count {
            if submodel[i] is String {
                let localString = submodel[i] as? String
                if((localString?.characters.count)! > 0 && localString != " ")
                {
                    cell.textLabel?.text = submodel[i] as? String
                    break
                }
            }
        }
        return cell
    }
    
    //  MARK: - ADD & SAVE methods
    // Add newnote button click
    @IBAction func Addnotebtn(_ sender: Any)
    {
        let subModel1 = [" "]
        notes.append(subModel1)
        tableView .reloadData()
        let indexPath = IndexPath(row: notes.count-1, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        self.performSegue(withIdentifier: "edit", sender: self)
        
    }
    // Save button click
    @IBAction func saveToMainViewController (_ segue:UIStoryboardSegue) {
        
        let detailViewController = segue.source as! DetailTableViewController
        let index = detailViewController.index
        let subModel = detailViewController.subModelArray
        notes[index!] = subModel!
        // Saving to local storage
        let defaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: notes)
        defaults.set(encodedData, forKey: "notes")
        defaults.synchronize()
        tableView.reloadData()
    }

  
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let path = tableView.indexPathForSelectedRow
            let detailViewController = segue.destination as! DetailTableViewController
            detailViewController.index = path?.row
            detailViewController.subModelArray = notes[(path?.row)!]
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

}
