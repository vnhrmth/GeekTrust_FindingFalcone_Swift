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
    var testArray = [Vehicle]()
    
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
    let api = Api()
    let kMaxThresholdForPlanetSelection = 4
    let timeCalculator = TimeCalculator()

    // MARK: - Business Logic
    fileprivate func getVehicles() {
        activtyIndicator.startAnimating()
        extractor.getData(url: api.getVehiclesUrl) { (vehicle:Vehicles?, error:JSONError?) in
            
            if let error = error{
                let description = "\(error)"
                self.showAlert(title: "Error Occured", message: description)
                DispatchQueue.main.async {
                    self.activtyIndicator.stopAnimating()
                }
                return
            }
            
            if let aVehicle = vehicle{
                aVehicle.forEach({ (vehicleElement) in
                    self.vehicleArray.append(vehicleElement)
                    let defaultVehicle = DefaultVehicle(name: vehicleElement.name, totalNo: vehicleElement.totalNo, maxDistance: vehicleElement.maxDistance, speed: vehicleElement.speed)
                    self.defaultVehicles.append(defaultVehicle)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.activtyIndicator.stopAnimating()
                    }
                })
            }
        }
    }
    
    fileprivate func getPlanets() {
        activtyIndicator.startAnimating()
        extractor.getData(url: api.getPlanetsUrl) { (planet: Planets?,error:JSONError?) in
            
            if let error = error{
                let description = "\(error)"
                self.showAlert(title: "Error Occured", message: description)
                DispatchQueue.main.async {
                    self.activtyIndicator.stopAnimating()
                }
                return
            }
            
            if let aPlanet = planet{
                aPlanet.forEach({ (planetElement) in
                    self.planetArray.append(planetElement)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.activtyIndicator.stopAnimating()
                    }
                })
            }
            print(planet!)
            DispatchQueue.main.async {
                self.activtyIndicator.stopAnimating()
            }
        }
    }
    
    
    fileprivate func findFalcone(_ planetNames: [String], _ vehicleNames: [String]) {
        var token = ""
        extractor.postData(url: api.getTokenUrl) { (tokenModel:TokenModel?) in
            guard let aToken = tokenModel else{
                print("Retrieving Token Failed")
                DispatchQueue.main.async {
                    self.activtyIndicator.stopAnimating()
                }
                return
            }
            token = aToken.token
            
            if !token.isEmpty{
                self.extractor.findFalcone(url: self.api.findFalconeUrl, body: PathFinder(token: token, planetNames: planetNames, vehicleNames:vehicleNames)) { (status:FindFalconeStatus?) in
                    
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
    
    // MARK: - View Methods
    func showAlert(title:String,message:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    fileprivate func addActivityIndicator() {
        activtyIndicator.center = self.view.center
        activtyIndicator.style = .medium
        self.view.addSubview(activtyIndicator)
    }
    
    private func configureNavigationBar(){
        self.title = "Finding Falcone!"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(reset))
        self.navigationItem.rightBarButtonItem!.isEnabled = false;
    }
    
    fileprivate func handleResetButtonVisibility() {
        if selectedCount > 0 {
            self.navigationItem.rightBarButtonItem!.isEnabled = true;
        }
        else{
            self.navigationItem.rightBarButtonItem!.isEnabled = false;
        }
    }
    
    fileprivate func handleFindingFalconeButtonVisibility() {
        if selectedCount < 4 {
            button?.isHidden = true
        }
        else {
            button?.isHidden = false
        }
    }
        
    // MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addActivityIndicator()
        configureNavigationBar()
        DispatchQueue.global().sync {
            getVehicles()
            getPlanets()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VehiclePopOverId"{
            configureVehicleControllerNavigation(segue)
        }
        else if segue.identifier == "ShowStatusSegue"{
            configureStatusControllerNavigation(segue)
        }
    }
    
    fileprivate func configureVehicleControllerNavigation(_ segue: UIStoryboardSegue) {
        let vc = segue.destination as! VehiclesTableViewController
        vc.vehicleArray = vehicleArray
        vc.selectedPlanet = selectedPlanet
        segue.destination.presentationController?.delegate = self;
        vc.delegate = self
    }
    
    fileprivate func configureStatusControllerNavigation(_ segue: UIStoryboardSegue) {
        let vc = segue.destination as! StatusViewController
        vc.findFalconeStatus = status
        vc.delegate = self
        vc.calculatedTime = timeTaken
    }
    
    public func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController)
    {
        selectedPlanetRowIndex.removeLast()
        selectedCount -= 1
        tableView.reloadData()
        
        let time = timeCalculator.calculateTime(dict: dict)
        updateTimeTakenLabelText(time: time)
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
        
    private func handlePlanetSelection(cell:CheckedTableViewCell?,indexPath:IndexPath){
        cell?.accessoryType = .checkmark;
        selectedPlanetRowIndex.append(indexPath)
        selectedCount += 1
        selectedPlanet = planetArray[indexPath.row]
        self.performSegue(withIdentifier: "VehiclePopOverId", sender:self)
    }
    
    fileprivate func handlePlanetDeselection(_ indexPath: IndexPath, _ cell: UITableViewCell?) {
        let planet = planetArray[indexPath.row]
        let vehicle = dict[planet]
        let extractedVehicle = self.vehicleArray.filter{$0.name == vehicle?.name}.first
        extractedVehicle?.totalNo += 1
        dict[planet] = nil
        cell?.accessoryType = .none;
        selectedPlanetRowIndex.removeAll{$0==indexPath}
        selectedCount -= 1
        
        let time = timeCalculator.calculateTime(dict: dict)
        updateTimeTakenLabelText(time: time)
    }
    
    fileprivate func handleCellSelection(_ cell: UITableViewCell?, _ indexPath: IndexPath) {
        if (cell?.accessoryType == UITableViewCell.AccessoryType.none) {
            handlePlanetSelection(cell: cell as? CheckedTableViewCell, indexPath: indexPath)
        }
        else {
            handlePlanetDeselection(indexPath, cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if (cell?.accessoryType == UITableViewCell.AccessoryType.none) {
            if(isMaxThresholdReached(cell: cell as? CheckedTableViewCell, indexPath: indexPath)){
                return
            }
        }
        handleCellSelection(cell, indexPath)
        handleFindingFalconeButtonVisibility()
        handleResetButtonVisibility()
    }
    
    private func isMaxThresholdReached(cell:CheckedTableViewCell?,indexPath:IndexPath)->Bool{
        if selectedCount >= kMaxThresholdForPlanetSelection{
            cell?.accessoryType = .none;
            selectedPlanetRowIndex.removeAll{$0==indexPath}
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height:
                                    100)
        button = UIButton()
        button?.isHidden = true
        button?.addTarget(self, action:#selector(self.findFalconeTapped(sender:)), for: .touchUpInside)
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
    
    
    @objc func findFalconeTapped(sender: UIButton!) {
        activtyIndicator.startAnimating()
        
        var planetNames = [String]()
        var vehicleNames = [String]()
        for element in dict{
            planetNames.append(element.key.name)
            vehicleNames.append(element.value.name)
        }
        
        findFalcone(planetNames, vehicleNames)
    }
    
    func selectVehicle(vehicl: Vehicle) {
        let planet = planetArray[selectedPlanetRowIndex.last!.row]
        print(selectedPlanetRowIndex)
        dict[planet] = vehicl
        let time = timeCalculator.calculateTime(dict: dict)
        updateTimeTakenLabelText(time:time)
    }
    
    func updateTimeTakenLabelText(time:Int){
        timeTaken = time
        timeTakenStatusLabel?.text = "Time Taken : \(timeTaken)"
    }
    
    @objc func reset() {
        selectedCount = 0
        dict.removeAll()
        selectedPlanetRowIndex.removeAll()
        timeTaken = 0
        self.vehicleArray.removeAll()        
        getVehicles()
        self.tableView.reloadData()
        self.navigationItem.rightBarButtonItem!.isEnabled = false;
    }
}
