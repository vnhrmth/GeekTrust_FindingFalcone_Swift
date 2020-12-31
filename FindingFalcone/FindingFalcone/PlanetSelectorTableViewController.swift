//
//  PlanetSelectorTableViewController.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 29/12/20.
//

import UIKit

class PlanetSelectorTableViewController: UITableViewController {
    var planetArray = [Planet]()
    var vehicleArray = [Vehicle]()
    var selectedVehicleRowIndex = [Int]()
    var selectedPlanetRowIndex = [Int]()
    
    var isPlanetSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        self.navigationItem.rightBarButtonItem!.isEnabled = false;

        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        let extractor = DataExtractor()
        var token : String = ""
    
        
        let urls = Urls()
        extractor.getVehicles(url: urls.vehiclesUrlString) { (vehicle:Vehicles?) in
            if let aVehicle = vehicle{
                aVehicle.forEach({ (vehicleElement) in
                    self.vehicleArray.append(vehicleElement)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                })
            }
        }

        extractor.getPlanets(url: urls.planetUrlString) { (planet: Planets?) in
            if let aPlanet = planet{
                aPlanet.forEach({ (planetElement) in
                    self.planetArray.append(planetElement)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                })
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func nextTapped(){
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Planets"
        case 1:
            if isPlanetSelected{
                return "Vehicles"
            }
            return ""
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section == 0){
            return planetArray.count
        }
        else{
            if isPlanetSelected{
                return vehicleArray.count
            }
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 0.01
        default:
            return UITableView.automaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 0.1
        default:
            return UITableView.automaticDimension
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
    CheckedTableViewCell
    {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckedTableViewCellId",
            for: indexPath) as? CheckedTableViewCell
        if indexPath.section == 0{
            cell?.textLabel?.text = planetArray[indexPath.row].name
            
            cell?.callback = { [self](selected) in
                if selectedPlanetRowIndex.count >= 4{
                    cell?.accessoryType = .none
                    return
                }

                if(selected){
                    self.selectedPlanetRowIndex.append(indexPath.row)
                }
                else{
                    if self.selectedPlanetRowIndex.count > 0{
                        self.selectedPlanetRowIndex.removeAll{$0 == indexPath.row}
                    }
                }
            }
        }
        else{
            cell?.textLabel?.text = vehicleArray[indexPath.row].name
            
//            if(indexPath.row == self.selectedVehicleRowIndex)
//            {
//               cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            }
//            else
//            {
//               cell.accessoryType = UITableViewCellAccessoryNone;
//            }

            
            cell?.callback = { [self](selected) in
//                if selectedVehicleRowIndex.count >= 4{
//                    cell?.accessoryType = .none
//                    return
//                }

//                if(selected){
//                    if self.selectedVehicleRowIndex.count > 0{
//
//                        let previousIndexPath = NSIndexPath(row: self.selectedVehicleRowIndex.first ?? 0, section: 1)
//                        let previousCell = tableView.cellForRow(at: previousIndexPath as IndexPath)
//                        previousCell?.accessoryType = .none
//                        self.selectedVehicleRowIndex.removeAll{$0 == previousIndexPath.row}
//                        let currentCell = tableView.cellForRow(at: indexPath)
//                        currentCell?.accessoryType = .checkmark
//                    }
//                    self.selectedVehicleRowIndex.append(indexPath.row)
//                }
//                else{
//                    if self.selectedVehicleRowIndex.count > 0{
//                        self.selectedVehicleRowIndex.removeAll{$0 == indexPath.row}
//                    }
//                }
            }
        }
        
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.section == 0{
            isPlanetSelected = true
            self.tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: .automatic)
            isPlanetSelected = false
        }
        
        if selectedPlanetRowIndex.count >= 4 && selectedVehicleRowIndex.count >= 4{
            self.navigationItem.rightBarButtonItem!.isEnabled = true
        }
        else{
            self.navigationItem.rightBarButtonItem!.isEnabled = false
        }
//        UserDefaults.standard.set(selectedVehicleRowIndex, forKey: "selectedVehicleRows")
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
