//
//  ViewController.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 29/12/20.
//

import UIKit

class ViewController: UIViewController{
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var destination1TextField: UITextField!
    @IBOutlet weak var timeTakenLabel: UILabel!
    @IBOutlet weak var destination2TextField: UITextField!
    @IBOutlet weak var destination3TextField: UITextField!
    @IBOutlet weak var destination4TextField: UITextField!
    @IBOutlet weak var timeTakeLabel: UILabel!
    @IBOutlet var destinationTextFieldCollection: [UITextField]!
    @IBOutlet weak var vehicle1TextField: UITextField!
    @IBOutlet weak var vehicle2TextField: UITextField!
    @IBOutlet weak var vehicle3TextField: UITextField!
    @IBOutlet weak var vehicle4TextField: UITextField!
    var planetPickerData = [Planet]()
    var vehiclePickerData = [Vehicle]()
    var activeTextField = UITextField()
    var activePickerView = UIPickerView()
    var planets = [Planets]()
    let thePicker = UIPickerView()
    let vehiclePicker = UIPickerView()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        timeTakeLabel.text = ""
        thePicker.dataSource = self
        thePicker.delegate = self
        thePicker.tag = 99
        
        vehiclePicker.dataSource = self
        vehiclePicker.delegate = self
        vehiclePicker.tag = 100
        
        destination1TextField.inputView = thePicker
        destination1TextField.delegate = self
        destination2TextField.inputView = thePicker
        destination2TextField.delegate = self
        destination3TextField.inputView = thePicker
        destination3TextField.delegate = self
        destination4TextField.inputView = thePicker
        destination4TextField.delegate = self
        
        vehicle1TextField.inputView = vehiclePicker
        vehicle1TextField.delegate = self
        vehicle2TextField.inputView = vehiclePicker
        vehicle2TextField.delegate = self
        vehicle3TextField.inputView = vehiclePicker
        vehicle3TextField.delegate = self
        vehicle4TextField.inputView = vehiclePicker
        vehicle4TextField.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelPicker))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.title = "Finding Falcone!"
        self.headingLabel.text = "Select planets you want to search in"
        
        destination1TextField.inputAccessoryView = toolBar
        destination2TextField.inputAccessoryView = toolBar
        destination3TextField.inputAccessoryView = toolBar
        destination4TextField.inputAccessoryView = toolBar
        
        vehicle1TextField.inputAccessoryView = toolBar
        vehicle2TextField.inputAccessoryView = toolBar
        vehicle3TextField.inputAccessoryView = toolBar
        vehicle4TextField.inputAccessoryView = toolBar
        
        let extractor = DataExtractor()
        var token : String = ""
        let urls = Urls()
        extractor.getVehicles(url: urls.vehiclesUrlString) { (vehicle:Vehicles?) in
            if let aVehicle = vehicle{
                aVehicle.forEach({ (vehicleElement) in
                    self.vehiclePickerData.append(vehicleElement)

//                    self.vehiclePicker.reloadAllComponents()
                })
            }
        }
//
        extractor.getPlanets(url: urls.planetUrlString) { (planet: Planets?) in
            if let aPlanet = planet{
                aPlanet.forEach({ (planetElement) in
                    self.planetPickerData.append(planetElement)
//                    self.thePicker.reloadAllComponents()
                })
            }
        }
        
//        extractor.getGetToken(url: urls.getTokenUrl) { (tokenModel:TokenModel?) in
//            guard let aToken = tokenModel else{
//                print("Retrieving Token Failed")
//                return
//            }
//            token = aToken.token
//
//            if !token.isEmpty{
//                extractor.findFalcone(url: urls.findUrlString, body: PathFinder(token: token, planetNames: [
//                    "Donlon",
//                    "Enchai",
//                    "Pingasor",
//                    "Sapir"
//                    ], vehicleNames: [
//                        "Space pod",
//                        "Space rocket",
//                        "Space rocket",
//                        "Space rocket"])) { (status:FindFalconeStatus?) in
//
//                    if let aStatus = status{
//                        print("\(aStatus)")
//                    }
//                }
//            }
//        }
    }
    
    @objc func donePicker() {
        switch activePickerView.tag {
        case 99:
            let selectedRow = thePicker.selectedRow(inComponent: 0)
            activeTextField.text = planetPickerData[selectedRow].name
        case 100:
            let selectedRow = vehiclePicker.selectedRow(inComponent: 0)
            if(vehiclePickerData[selectedRow].totalNo == 0){
                return
            }
            vehiclePickerData[selectedRow].totalNo -= 1
            
            activeTextField.text = vehiclePickerData[selectedRow].name
        default:
            let selectedRow = vehiclePicker.selectedRow(inComponent: 0)
            activeTextField.text = planetPickerData[selectedRow].name
        }
        activeTextField.resignFirstResponder()
    }

    @objc func cancelPicker() {
        if !activeTextField.text!.isEmpty{
//            destination1TextField.text = myPickerData[selectedRow].name
            activeTextField.resignFirstResponder()
        }
        activeTextField.resignFirstResponder()

    }
    
//    func calculateTime() {
//        timeTakeLabel.text =
//    }
}
extension ViewController:  UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag{
            case 99:
                return planetPickerData.count
            case 100:
                return vehiclePickerData.count
            default:
                return planetPickerData.count
        }
//        return planetPickerData.count
    }

    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        activePickerView = pickerView

        switch pickerView.tag{
            case 99:
                return planetPickerData[row].name
            case 100:
                let str = "\(vehiclePickerData[row].name)(\(vehiclePickerData[row].totalNo))"
                return str
            default:
                return planetPickerData[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        activePickerView = pickerView
        switch pickerView.tag{
            case 99:
                return nil
            case 100:
                let str = "\(vehiclePickerData[row].name)+\(vehiclePickerData[row].totalNo)"

                if vehiclePickerData[row].totalNo == 0{
                    let attributesUnavailable = [NSAttributedString.Key.foregroundColor: UIColor.gray]
                    let attributedTitle = NSAttributedString(string:str, attributes: attributesUnavailable)
                    return attributedTitle
                }else{
                    let attributesAvailable = [NSAttributedString.Key.foregroundColor: UIColor.black]
                    let attributedTitle = NSAttributedString(string:str, attributes: attributesAvailable)
                    return attributedTitle
                }
            default:
                let str = "\(vehiclePickerData[row].name)+\(vehiclePickerData[row].totalNo)"
                let attributesAvailable = [NSAttributedString.Key.foregroundColor: UIColor.black]
                let attributedTitle = NSAttributedString(string:str, attributes: attributesAvailable)
                return attributedTitle
        }
        
    }

    private func pickerView( pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        theTextField.text = myPickerData[row]
        if let activeTextFieldText = self.activeTextField.text {
              print("Active text field's text: \(activeTextFieldText)")
            switch pickerView.tag{
                case 99:
                    activeTextField.text = planetPickerData[row].name
                case 100:
                    
                    let str = "\(vehiclePickerData[row].name)+\(vehiclePickerData[row].totalNo)"
                    activeTextField.text = str//vehiclePickerData[row].name
                default:
                    activeTextField.text = planetPickerData[row].name
            }
        }
        activePickerView = pickerView
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
         self.activeTextField = textField
    }
}

