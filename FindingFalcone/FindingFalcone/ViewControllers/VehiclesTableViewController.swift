//
//  VehiclesTableViewController.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 30/12/20.
//

import UIKit
protocol VehicleSelectionDelegate{
    func selectVehicle(vehicle:Vehicle)
}

class VehiclesTableViewController: UITableViewController {
    var vehicleArray = [Vehicle]()
    var selectedVehicleRowIndex = [IndexPath]()
    var delegate:VehicleSelectionDelegate?
    var selectedPlanet : Planet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
    }
    
    func configureBackground(){
        let topColor = UIColor(red: 75/255, green: 121/255, blue: 161/255, alpha: 0.8)
        let bottomColor = UIColor(red: 40/255, green: 62/255, blue: 81/255, alpha: 0.8)
        
        let gradientBackgroundColors = [topColor.cgColor, bottomColor.cgColor]

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientBackgroundColors
        gradientLayer.locations = [0,1]

        gradientLayer.frame = self.tableView.bounds
        let backgroundView = UIView(frame: self.tableView.bounds)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        self.tableView.backgroundView = backgroundView
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
        
//        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        if (cell?.accessoryType == UITableViewCell.AccessoryType.none) {
            cell?.accessoryType = .checkmark;
            selectedVehicleRowIndex.append(indexPath)
        } else {
            cell?.accessoryType = .none;
            selectedVehicleRowIndex.removeAll{$0==indexPath}
        }
        
        dismiss(animated: true) {
            if let delegate = self.delegate {
                var vehicle = self.vehicleArray[self.selectedVehicleRowIndex.first!.row]
                vehicle.totalNo -= 1
                delegate.selectVehicle(vehicle:vehicle)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear

        if(vehicleArray[indexPath.row].totalNo == 0 || (selectedPlanet?.distance)! > vehicleArray[indexPath.row].maxDistance){
            cell.backgroundColor = UIColor.darkGray
        }
        else{
            cell.backgroundColor = UIColor.clear
        }
    }

}
