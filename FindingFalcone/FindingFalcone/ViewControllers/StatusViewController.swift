//
//  StatusViewController.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 31/12/20.
//

import UIKit
protocol StartAgainDelegate {
    func reset()
}

class StatusViewController: UIViewController {

    var findFalconeStatus : FindFalconeStatus?
    var calculatedTime:Int=0
    var delegate : StartAgainDelegate?
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeTakenLabel: UILabel!
    @IBOutlet weak var planetFoundLabel: UILabel!
    
    @IBOutlet weak var startAgainButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Finding Falcone!"
        configureStatuses()
        configureBackground()
    }
    
    func configureStatuses(){
        statusLabel.textColor = UIColor.white
        timeTakenLabel.textColor = UIColor.white
        planetFoundLabel.textColor = UIColor.white
        
        startAgainButton.setTitleColor(UIColor.white, for: .normal)
        statusLabel.text = findFalconeStatus?.status
        timeTakenLabel.text = "Time Taken: \(calculatedTime)"
        planetFoundLabel.text = "Planet Found: \(findFalconeStatus?.planetName ?? "")"
        startAgainButton.setTitle("Start Again", for: .normal)
        
        startAgainButton.titleLabel?.font =  UIFont(name: "System", size: 26)
    }
    
    func configureBackground(){
        let topColor = UIColor(red: 75/255, green: 121/255, blue: 161/255, alpha: 1)
        let bottomColor = UIColor(red: 40/255, green: 62/255, blue: 81/255, alpha: 1)
        
        let gradientBackgroundColors = [topColor.cgColor, bottomColor.cgColor]

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientBackgroundColors
        gradientLayer.locations = [0,1]

        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    
    @IBAction func StartAgainTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        delegate?.reset()
    }
    
}
