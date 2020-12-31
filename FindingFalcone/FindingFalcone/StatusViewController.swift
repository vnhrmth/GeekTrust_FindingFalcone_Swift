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
        statusLabel.text = findFalconeStatus?.status
        timeTakenLabel.text = "Time Taken:\(calculatedTime)"
        planetFoundLabel.text = "Planet Found:\(findFalconeStatus?.planetName ?? "")"
        startAgainButton.setTitle("Start Again", for: .normal)
    }
    
    @IBAction func StartAgainTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        delegate?.reset()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
