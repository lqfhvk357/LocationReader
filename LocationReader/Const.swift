//
//  Const.swift
//  LCTodayNews
//
//  Created by 罗超 on 2018/9/22.
//  Copyright © 2018年 罗超. All rights reserved.
//

import Foundation
import UIKit


/// device
let Device_id: Int64 = 21482297196
let Iid: Int64 = 45275915249
let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
let NavBarHeight = CGFloat(ScreenHeight<810 ? 64 : 88)
let TabBarHeight = CGFloat(ScreenHeight<810 ? 49 : 83)
let topMargin = CGFloat(ScreenHeight<810 ? 32 : 77)
let bottomMargin = CGFloat(ScreenHeight<810 ? 32 : 66)

/// keys of userDefaults
let KHomeTitlesKey = "KHomeTitlesKey"
let KHomeOtherTitlesKey = "KHomeOtherTitlesKey"
let KVideoTitlesKey = "KVideoTitlesKey"

/// keys of cell or header
let KMainTitle = "KMainTitle"
let KSubTitle = "KSubTitle"
let KActive = "KActive"

//
//var partUrlString = "v88"


///UserDefault
@propertyWrapper public struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    public var wrappedValue: T {
        get {
            UserDefaults.standard.value(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    init(key: String, defaultValue: T) {
        self.defaultValue = defaultValue
        self.key = key
    }
}
