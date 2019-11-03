//
//  LRSettingButton.swift
//  LocationReader
//
//  Created by 罗超 on 2019/11/1.
//  Copyright © 2019 罗超. All rights reserved.
//

import UIKit

class LRSettingButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel?.textAlignment = .center
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let width: CGFloat = 24
        let height: CGFloat = 24
        let x = (contentRect.width - width) * 0.5
        let y:CGFloat = 5
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        
        let width: CGFloat = contentRect.width
        let y:CGFloat = 5 + 24 + 5
        let height: CGFloat = contentRect.height - y
        let x:CGFloat = 0
        return CGRect(x: x, y: y, width: width, height: height)
    }

}
