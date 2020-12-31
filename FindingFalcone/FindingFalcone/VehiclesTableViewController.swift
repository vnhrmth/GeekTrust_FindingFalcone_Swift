//
//  VehiclesTableViewController.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 30/12/20.
//

import UIKit
protocol VehicleSelectionDelegate{
    func selectVehicle(vehicl:Vehicle)
}

class VehiclesTableViewController: UITableViewController {
    var vehicleArray = [Vehicle]()
    var selectedVehicleRowIndex = [IndexPath]()
    var delegate:VehicleSelectionDelegate?
    var selectedPlanet : Planet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return vehicleArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
    CheckedTableViewCell
    {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckedTableViewCellId",
            for: indexPath) as? CheckedTableViewCell
        let str = "\(vehicleArray[indexPath.row].name)(\(vehicleArray[indexPath.row].totalNo))"
        
        if(vehicleArray[indexPath.row].totalNo == 0 || (selectedPlanet?.distance)! > vehicleArray[indexPath.row].maxDistance){
            cell?.selectionStyle = UITableViewCell.SelectionStyle.gray;
            cell?.isUserInteractionEnabled = false
        }
        else{
            cell?.selectionStyle = UITableViewCell.SelectionStyle.none;
            cell?.isUserInteractionEnabled = true
        }

        cell?.textLabel?.text = str
      
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        if (cell?.accessoryType == UITableViewCell.AccessoryType.none) {
            cell?.accessoryType = .checkmark;
            selectedVehicleRowIndex.append(indexPath)
        } else {
            cell?.accessoryType = .none;
            selectedVehicleRowIndex.removeAll{$0==indexPath}
        }
        
        dismiss(animated: true) {
            if let delegate = self.delegate {
                let vehicle = self.vehicleArray[self.selectedVehicleRowIndex.first!.row]
                vehicle.totalNo -= 1
                delegate.selectVehicle(vehicl:vehicle)
            }
        }
    }
}
