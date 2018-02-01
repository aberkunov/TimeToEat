//
//  CenteredTableViewCell.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 04.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

class CenteredTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var centeredImageView: UIImageView!
    
    override var textLabel: UILabel? {
        return titleLabel
    }
    
    override var detailTextLabel: UILabel? {
        return subtitleLabel
    }
    
    override var imageView: UIImageView? {
        return centeredImageView
    }
}
