//
//  ViewController.swift
//  LocationReader
//
//  Created by 罗超 on 2019/10/28.
//  Copyright © 2019 罗超. All rights reserved.
//

import UIKit
import CoreFoundation



class LRBooKViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var chaptersLabel: UILabel!
    @IBOutlet weak var timeLabel: LRTimeLabel!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    
    
    var textConfig: LRTextConfig? = nil
    var pageModel: LRPageModel?
    var indexPath: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
//
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        
        // Do any additional setup after loading the view.
    }

    func setup() {
        if let pageModel = pageModel {
            textView.attributedText = pageModel.text
            pageLabel.text = pageModel.page
            chaptersLabel.text = pageModel.chapter
        }
        
        if let textConfig = textConfig {
            textView.textColor = textConfig.color
//            textView.font = textConfig.font
            backImageView.image = textConfig.backImage
            backImageView.backgroundColor = textConfig.backColor
        }
    }

    deinit {
        if timeLabel != nil {
            timeLabel.removeTimer()
        }
    }
}

extension LRBooKViewController: UIGestureRecognizerDelegate {}

