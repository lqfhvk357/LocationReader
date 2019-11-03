//
//  LRDirectoryCell.swift
//  LocationReader
//
//  Created by 罗超 on 2019/11/1.
//  Copyright © 2019 罗超. All rights reserved.
//

import UIKit

struct LRTitleModel {
    let title: String
    let selelct: Bool
}

class LRDirectoryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var titleModel: LRTitleModel? = nil {
        didSet {
            if let titleModel = titleModel{
                self.titleLabel.text = titleModel.title
                self.titleLabel.textColor = titleModel.selelct ? UIColor.orange: UIColor.black
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
