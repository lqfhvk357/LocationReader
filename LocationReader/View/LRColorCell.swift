//
//  LRColorCell.swift
//  LocationReader
//
//  Created by 罗超 on 2019/11/12.
//  Copyright © 2019 罗超. All rights reserved.
//

import UIKit

class LRColorCell: UICollectionViewCell {
    
    var mode: Mode? {
        didSet {
            if let mode = mode {
                self.colorView.backgroundColor = mode.backColor
            }
        }
    }

    @IBOutlet weak var colorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.colorView.layer.cornerRadius = 20
        self.colorView.clipsToBounds = true
        
        // Initialization code
    }

}
