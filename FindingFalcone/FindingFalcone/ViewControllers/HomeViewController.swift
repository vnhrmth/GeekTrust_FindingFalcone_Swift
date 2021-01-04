//
//  HomeViewController.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 04/01/21.
//

import UIKit

class HomeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,VehicleSelectionDelegate,UIAdaptivePresentationControllerDelegate,StartAgainDelegate  {
    
    @IBOutlet weak var rocketIcon: UIImageView!
    var planetArray = [Planet]()
    var vehicleArray = [Vehicle]()
        
    @IBOutlet weak var findFalconeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var selectedPlanetRowIndex = [IndexPath]()
    var planetVehicleDictionary = [Planet:Vehicle]()

    @IBOutlet weak var timeTakenStatusLabel: UILabel!
    var selectedCount : Int=0
    var selectedPlanet : Planet?
    var button : UIButton?
    var status : FindFalconeStatus?
    var timeTaken:Int=0
    var activtyIndicator = UIActivityIndicatorView(style: .medium)
    let extractor = DataExtractor()
    let api = Api()
    let kMaxThresholdForPlanetSelection = 4
    let timeCalculator = TimeCalculator()
    let dataService = DataService(session: URLSession.shared)
    
    
    // MARK: - Business Logic
    fileprivate func getVehicles() {
        activtyIndicator.startAnimating()

        self.dataService.getVehicles { (isSuccessful,error) in
            DispatchQueue.main.async {
                if(isSuccessful){
                    self.vehicleArray.removeAll()
                    self.vehicleArray = self.dataService.vehicleArray
                    self.tableView.reloadData()
                    self.activtyIndicator.stopAnimating()
                }
                else{
                    self.activtyIndicator.stopAnimating()
                    self.showAlert(title: "Error Occured", message: error)
                }
            }
        }
    }
    
    
    fileprivate func getPlanets() {
        activtyIndicator.startAnimating()
        self.dataService.getPlanets{(isSuccessful,error) in
            DispatchQueue.main.async {
                if(isSuccessful){
                    self.planetArray = self.dataService.planetArray
                    self.tableView.reloadData()
                    self.activtyIndicator.stopAnimating()
                }
                else{
                    
                    self.activtyIndicator.stopAnimating()
                    self.showAlert(title: "Error Occured", message: error)
                }
            }
        }
    }
    
    
    func findFalcone(body:FindFalconeMessageBody) {
        self.dataService.findFalconeWithBody(body: body, completion: {(isSuccessful,error) in
            DispatchQueue.main.async {
                if(isSuccessful){
                    self.status = self.dataService.status
                    self.performSegue(withIdentifier: "ShowStatusSegue", sender: self)
                    self.activtyIndicator.stopAnimating()
                }
                else{
                    self.activtyIndicator.stopAnimating()
                    self.showAlert(title: "Error Occured", message: error)
                }
            }
        })
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
        activtyIndicator.color = UIColor.white
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
        
        configureBackground()
        addActivityIndicator()
        configureNavigationBar()
        DispatchQueue.global().sync {
            getVehicles()
            getPlanets()
        }
//        self.tableView.backgroundColor = UIColor.blue

        self.findFalconeButton.setTitle("Find Falcone!", for: .normal)
        updateTimeTakenLabelText(time: 0)
        rocketIcon.isHidden = true
    }
    
    func configureBackground(){
        let topColor = UIColor(red: 75/255, green: 121/255, blue: 161/255, alpha: 1)
        let bottomColor = UIColor(red: 40/255, green: 62/255, blue: 81/255, alpha: 1)
        
        let gradientBackgroundColors = [topColor.cgColor, bottomColor.cgColor]

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientBackgroundColors
        gradientLayer.locations = [0,1]

        gradientLayer.frame = self.tableView.bounds
        let backgroundView = UIView(frame: self.tableView.bounds)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        self.tableView.backgroundView = backgroundView
        
//
//        self.view.layer.insertSublayer(gradientLayer, at: 0)
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
        
        let time = timeCalculator.calculateTime(dict: planetVehicleDictionary)
        updateTimeTakenLabelText(time: time)
        handleResetButtonVisibility()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return .none
    }
    
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planetArray.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
    UITableViewCell{
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckedTableViewCellId",
                                                 for: indexPath) as? CheckedTableViewCell
        
        cell?.textLabel?.text = planetArray[indexPath.row].name
//        cell?.textLabel?.text?.append(planetVehicleDictionary[planetArray[indexPath.row]]?.name ?? "")
        
        if selectedPlanetRowIndex.contains(indexPath){
            cell?.accessoryType = .checkmark
        }
        else{
            cell?.accessoryType = .none
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
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
        let vehicle = planetVehicleDictionary[planet]
        
        let updatedVehicleArray = self.vehicleArray.map({ (aVehicle) -> Vehicle in
            // You can check anything like:
            if aVehicle.name == vehicle?.name {
                var modified = aVehicle
                modified.totalNo += 1
                return modified
            } else {
                return aVehicle
            }
        })
        
        self.vehicleArray.removeAll()
        self.vehicleArray.append(contentsOf: updatedVehicleArray)

//        var extractedVehicle = self.vehicleArray.filter{$0.name == vehicle?.name}.first
//        extractedVehicle?.totalNo += 1
        planetVehicleDictionary[planet] = nil
        cell?.accessoryType = .none;
        selectedPlanetRowIndex.removeAll{$0==indexPath}
        selectedCount -= 1
        
        let time = timeCalculator.calculateTime(dict: planetVehicleDictionary)
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
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if (cell?.accessoryType == UITableViewCell.AccessoryType.none) {
            if(isMaxThresholdReached(cell: cell as? CheckedTableViewCell, indexPath: indexPath)){
                showAlert(title: "Tap on finding falcone", message: "You already selected 4 planets")
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
//     func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView = UIView()
//        footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height:
//                                    100)
//        button = UIButton()
//        button?.isHidden = true
//        button?.addTarget(self, action:#selector(self.findFalconeTapped(sender:)), for: .touchUpInside)
//        button?.frame = CGRect(x: 0, y: 30, width: 300, height: 50)
//        button?.setTitle("Find Falcone!", for: .normal)
//        button?.setTitleColor( UIColor(red: 0, green: 0, blue: 1, alpha: 1), for: .normal)
//
//        timeTakenStatusLabel = UILabel()
//        timeTakenStatusLabel?.text = "Time Taken : \(timeTaken)"
//        timeTakenStatusLabel?.frame = CGRect(x: 20, y: 0, width: 300, height: 50)
//        button?.setTitleColor( UIColor(red: 0, green: 0, blue: 1, alpha: 1), for: .normal)
//
//        footerView.addSubview(button!)
//        footerView.addSubview(timeTakenStatusLabel!)
//        return footerView
//    }
    
    @IBAction func findFalconeTapped(_ sender: Any) {
        activtyIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        var planetNames = [String]()
        var vehicleNames = [String]()
        for element in planetVehicleDictionary{
            planetNames.append(element.key.name)
            vehicleNames.append(element.value.name)
        }
        
        self.rocketIcon.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(
           withDuration: 1.2,
           delay: 0.0,
           usingSpringWithDamping: 0.2,
           initialSpringVelocity: 0.2,
           options: .curveEaseOut,
           animations: {
                self.rocketIcon.isHidden = false
               self.rocketIcon.transform = CGAffineTransform(scaleX: 1, y: 1)
           },
           completion: nil)


        

        dataService.getToken { (isSuccess, token) in
            if(isSuccess){
                let body = FindFalconeMessageBody(token: token, planetNames: planetNames, vehicleNames: vehicleNames)
                self.findFalcone(body: body)
                DispatchQueue.main.async {
                    self.activtyIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.rocketIcon.layer.removeAllAnimations()
                    self.rocketIcon.isHidden = true
                }
            }
            else{
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "No token generated")
                    self.activtyIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.rocketIcon.layer.removeAllAnimations()
                    self.rocketIcon.isHidden = true
                }
            }
        }
    }
    
    func selectVehicle(vehicle: Vehicle) {
        let planet = planetArray[selectedPlanetRowIndex.last!.row]
        print(selectedPlanetRowIndex)
        planetVehicleDictionary[planet] = vehicle
        let time = timeCalculator.calculateTime(dict: planetVehicleDictionary)
        updateTimeTakenLabelText(time:time)
        
        let selectedVehicles = self.vehicleArray.filter{$0.name == vehicle.name}
        var selectedVehicle = selectedVehicles.last
        selectedVehicle?.totalNo = vehicle.totalNo
        
        if let index = self.vehicleArray.firstIndex(where: {$0.name == vehicle.name}) {
            self.vehicleArray[index].totalNo = vehicle.totalNo
        }

    }
    
    func updateTimeTakenLabelText(time:Int){
        timeTaken = time
        timeTakenStatusLabel?.text = "Time Taken : \(timeTaken)"
    }
    
    @objc func reset() {
        selectedCount = 0
        planetVehicleDictionary.removeAll()
        selectedPlanetRowIndex.removeAll()
        timeTaken = 0
        self.vehicleArray.removeAll()
        self.vehicleArray.append(contentsOf: self.dataService.originalVehicleArray)
        self.tableView.reloadData()
        self.navigationItem.rightBarButtonItem!.isEnabled = false;
        self.updateTimeTakenLabelText(time: timeTaken)
    }

}
