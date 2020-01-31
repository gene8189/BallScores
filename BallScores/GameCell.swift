//
//  GameCell.swift
//  BallScores
//
//  Created by Tan Yee Gene on 31/01/2020.
//  Copyright © 2020 Tan Yee Gene. All rights reserved.
//

import UIKit

class GameCell: UITableViewCell {
    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var visitorImageView: UIImageView!
    @IBOutlet weak var homeAbbreviationLabel: UILabel!
    
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var visitorScoreLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var visitorAbbreviationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
