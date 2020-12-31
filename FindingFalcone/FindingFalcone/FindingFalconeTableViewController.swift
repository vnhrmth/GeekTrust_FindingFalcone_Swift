//
//  FindingFalconeTableViewController.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 30/12/20.
//

import UIKit
struct DefaultVehicle {
    let name: String
    var totalNo : Int
    let maxDistance, speed: Int
}
typealias DefaultVehicles = [DefaultVehicle]

class FindingFalconeTableViewController: UITableViewController,VehicleSelectionDelegate,UIPopoverPresentationControllerDelegate,UIAdaptivePresentationControllerDelegate,StartAgainDelegate {
    var planetArray = [Planet]()
    var vehicleArray = [Vehicle]()
    var selectedPlanetRowIndex = [IndexPath]()
    var dict = [Planet:Vehicle]()
    var defaultVehicles = [DefaultVehicle]()
    var selectedCount : Int=0
    var selectedPlanet : Planet?
    var button : UIButton?
    var timeTakenStatusLabel:UILabel?
    var status : FindFalconeStatus?
    var timeTaken:Int=0
    var activtyIndicator = UIActivityIndicatorView(style: .medium)
    var originalVehicleArray = [Vehicle]()
    let extractor = DataExtractor()
    let urls = Urls()

    override func viewDidLoad() {
        super.viewDidLoad()
        activtyIndicator.center = self.view.center
        activtyIndicator.style = .medium
        activtyIndicator.startAnimating()
        self.view.addSubview(activtyIndicator)
        self.title = "Finding Falcone!"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(reset))
        self.navigationItem.rightBarButtonItem!.isEnabled = false;


        DispatchQueue.global().sync {
            extractor.getVehicles(url: urls.vehiclesUrlString) { (vehicle:Vehicles?) in
                if let aVehicle = vehicle{
                    aVehicle.forEach({ (vehicleElement) in
                        self.vehicleArray.append(vehicleElement)
                        let defaultVehicle = DefaultVehicle(name: vehicleElement.name, totalNo: vehicleElement.totalNo, maxDistance: vehicleElement.maxDistance, speed: vehicleElement.speed)
                        self.defaultVehicles.append(defaultVehicle)
                    })
                }
            }

            extractor.getPlanets(url: urls.planetUrlString) { (planet: Planets?) in
                if let aPlanet = planet{
                    aPlanet.forEach({ (planetElement) in
                        self.planetArray.append(planetElement)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.activtyIndicator.stopAnimating()
                            }
                    })
                }
            }
        }
      

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VehiclePopOverId"
        {
            let vc = segue.destination as! VehiclesTableViewController
            vc.vehicleArray = vehicleArray
            vc.selectedPlanet = selectedPlanet
            segue.destination.presentationController?.delegate = self;
            vc.delegate = self
        }
        else if segue.identifier == "ShowStatusSegue"{
            let vc = segue.destination as! StatusViewController
            vc.findFalconeStatus = status
            vc.delegate = self
            vc.calculatedTime = timeTaken
        }
    }
    
    public func presentationControllerDidDismiss(
      _ presentationController: UIPresentationController)
    {
        selectedPlanetRowIndex.removeLast()
        selectedCount -= 1
        tableView.reloadData()
        calculateTime()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return .none
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
   
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
            return planetArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
    CheckedTableViewCell{
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckedTableViewCellId",
            for: indexPath) as? CheckedTableViewCell
        cell?.textLabel?.text = planetArray[indexPath.row].name
        if selectedPlanetRowIndex.contains(indexPath){
            cell?.accessoryType = .checkmark
        }
        else{
            cell?.accessoryType = .none
        }
        

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let cell = tableView.cellForRow(at: indexPath)
        
        
            if (cell?.accessoryType == UITableViewCell.AccessoryType.none) {
                if selectedCount >= 4{
                    cell?.accessoryType = .none;
                    selectedPlanetRowIndex.removeAll{$0==indexPath}
                    return
            }
            
        }
        
        if (cell?.accessoryType == UITableViewCell.AccessoryType.none) {
            cell?.accessoryType = .checkmark;
            selectedPlanetRowIndex.append(indexPath)
            selectedCount += 1
            selectedPlanet = planetArray[indexPath.row]
            self.performSegue(withIdentifier: "VehiclePopOverId", sender:self)
        } else {
            let planet = planetArray[indexPath.row]
            let vehicle = dict[planet]
            let extractedVehicle = self.vehicleArray.filter{$0.name == vehicle?.name}.first
            
//            let extractedVehicle = defaultVehicles.filter{$0.name == vehicle?.name}.first
//            print(extractedVehicle!.totalNo)
            extractedVehicle?.totalNo += 1
//            print(extractedVehicle?.name)
            dict[planet] = nil
            cell?.accessoryType = .none;
            selectedPlanetRowIndex.removeAll{$0==indexPath}
            selectedCount -= 1
            calculateTime()
        }
        if selectedCount < 4{
            button?.isHidden = true
            
        }
        else{
            button?.isHidden = false
        }
        
        if selectedCount > 0 {
            self.navigationItem.rightBarButtonItem!.isEnabled = true;
        }
        else{
            self.navigationItem.rightBarButtonItem!.isEnabled = false;
        }
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200
//    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       return 100
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height:
        100)
        button = UIButton()
        button?.isHidden = true
        button?.addTarget(self, action:#selector(self.pressed(sender:)), for: .touchUpInside)
        button?.frame = CGRect(x: 0, y: 30, width: 300, height: 50)
        button?.setTitle("Find Falcone!", for: .normal)
        button?.setTitleColor( UIColor(red: 0, green: 0, blue: 1, alpha: 1), for: .normal)
        
        timeTakenStatusLabel = UILabel()
        timeTakenStatusLabel?.text = "Time Taken : \(timeTaken)"
        timeTakenStatusLabel?.frame = CGRect(x: 20, y: 0, width: 300, height: 50)
        button?.setTitleColor( UIColor(red: 0, green: 0, blue: 1, alpha: 1), for: .normal)
        
        footerView.addSubview(button!)
        footerView.addSubview(timeTakenStatusLabel!)
        return footerView
    }
    
    @objc func pressed(sender: UIButton!) {
        
        activtyIndicator.startAnimating()

        var planetNames = [String]()
        var vehicleNames = [String]()
        for element in dict{
            planetNames.append(element.key.name)
            vehicleNames.append(element.value.name)
        }
        
        var token = ""
        let urls = Urls()
        let extractor = DataExtractor()
        extractor.getGetToken(url: urls.getTokenUrl) { (tokenModel:TokenModel?) in
            guard let aToken = tokenModel else{
                print("Retrieving Token Failed")
                return
            }
            token = aToken.token

            if !token.isEmpty{
                extractor.findFalcone(url: urls.findUrlString, body: PathFinder(token: token, planetNames: planetNames, vehicleNames:vehicleNames)) { (status:FindFalconeStatus?) in

                    if let aStatus = status{
                        print("status\(aStatus)")
                        self.status = aStatus
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "ShowStatusSegue", sender: self)
                            self.activtyIndicator.stopAnimating()
                        }
                        
                    }
                }
            }
        }
    }

    func selectVehicle(vehicl: Vehicle) {
//        let cell = tableView.cellForRow(at: selectedPlanetRowIndex.last!)
        let planet = planetArray[selectedPlanetRowIndex.last!.row]
        print(selectedPlanetRowIndex)
        dict[planet] = vehicl
        calculateTime()
    }
    
    func calculateTime(){
        var time:Int = 0
        for val in dict{
            let planet = val.key
            let vehicle = val.value
            
            let distance = planet.distance
            let speed = vehicle.speed
            time += distance/speed
        }
        timeTaken = time
        timeTakenStatusLabel?.text = "Time Taken : \(timeTaken)"
    }
    
    @objc func reset() {
//        self.vehicleArray.removeAll()
        selectedCount = 0
        dict.removeAll()
        selectedPlanetRowIndex.removeAll()
        timeTaken = 0
        self.vehicleArray.removeAll()
        
        extractor.getVehicles(url: urls.vehiclesUrlString) { (vehicle:Vehicles?) in
            if let aVehicle = vehicle{
                aVehicle.forEach({ (vehicleElement) in
                    self.vehicleArray.append(vehicleElement)
                    let defaultVehicle = DefaultVehicle(name: vehicleElement.name, totalNo: vehicleElement.totalNo, maxDistance: vehicleElement.maxDistance, speed: vehicleElement.speed)
                    self.defaultVehicles.append(defaultVehicle)
                })
            }
        }
        self.tableView.reloadData()
    }
}
