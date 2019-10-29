//
//  LRTimeLabel.swift
//  LocationReader
//
//  Created by 罗超 on 2019/10/28.
//  Copyright © 2019 罗超. All rights reserved.
//

import UIKit

class LRTimeLabel: UILabel {

    var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    deinit {
//        print("\(Self.self) deinit...")
    }
    
    func setup() {
        self.text = self.getNowTimeString()
        addTimer()
        
    }
    
    //MARK: - timer
    func addTimer() {
        timer = Timer(timeInterval: 1, repeats: true, block: {[weak self] _ in
            if self!.text != self!.getNowTimeString() {
                self!.text = self!.getNowTimeString()                
            }
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func getNowTimeString() -> String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let time = df.string(from: Date())
        return time
    }

}
