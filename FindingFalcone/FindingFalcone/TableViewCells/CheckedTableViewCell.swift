//
//  CheckedTableViewCell.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 29/12/20.
//

import UIKit

class CheckedTableViewCell: UITableViewCell {
    var callback : ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.selectionStyle = .none
            
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
//            super.setSelected(selected, animated: animated)
//            self.accessoryType = selected ? .checkmark : .none
//            callback?(selected)
        }
}
