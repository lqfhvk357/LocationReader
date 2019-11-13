//
//  ViewController.swift
//  LocationReader
//
//  Created by 罗超 on 2019/10/28.
//  Copyright © 2019 罗超. All rights reserved.
//

import UIKit
import CoreFoundation
import SnapKit



class LRBooKViewController: UIViewController {
    
    weak var textView: UITextView!
    @IBOutlet weak var spaceView: UIView!
    @IBOutlet weak var chaptersLabel: UILabel!
    @IBOutlet weak var timeLabel: LRTimeLabel!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var topHeightConstraint: NSLayoutConstraint!
    
    
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
        topHeightConstraint.constant = topMargin
        
        let textView = UITextView()
        textView.backgroundColor = .clear
        self.view.addSubview(textView)
        textView.snp_makeConstraints { make in
            make.edges.equalTo(spaceView)
        }
        self.textView = textView
        self.textView.isUserInteractionEnabled = false
        
        if let pageModel = pageModel {
            textView.attributedText = pageModel.text
            pageLabel.text = pageModel.page
            chaptersLabel.text = pageModel.chapter
        }
        
        if let textConfig = textConfig {
            textView.textColor = textConfig.mode.color
//            textView.font = textConfig.font
            backImageView.image = textConfig.mode.backImage
            backImageView.backgroundColor = textConfig.mode.backColor
            pageLabel.textColor = textConfig.mode.color
            timeLabel.textColor = textConfig.mode.color
            chaptersLabel.textColor = textConfig.mode.color
        }
    }

    deinit {
        if timeLabel != nil {
            timeLabel.removeTimer()
        }
    }
}

extension LRBooKViewController: UIGestureRecognizerDelegate {}

