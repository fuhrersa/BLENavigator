//
//  ServicesTableViewCell.swift
//  BLENavigator
//
//  Created by Samuel Fuhrer on 8/14/17.
//  Copyright © 2017 Samuel Fuhrer. All rights reserved.
//

import UIKit

class ServicesTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
