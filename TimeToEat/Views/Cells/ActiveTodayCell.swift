//
//  ActiveTodayCell.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 19.12.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol ActiveTodayCellDelegate: class {
    func didTouchDone(_ cell: ActiveTodayCell)
}

class ActiveTodayCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    weak var delegate: ActiveTodayCellDelegate?
    
    override var textLabel: UILabel? {
        return titleLabel
    }
    
    override var detailTextLabel: UILabel? {
        return subtitleLabel
    }
    
    override var imageView: UIImageView? {
        return backgroundImageView
    }
    
    @IBAction func onDoneTouch(button: UIButton) {
        delegate?.didTouchDone(self)
    }
}
