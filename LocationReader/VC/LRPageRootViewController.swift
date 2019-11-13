
//
//  LRPageRootViewController.swift
//  LocationReader
//
//  Created by 罗超 on 2019/11/1.
//  Copyright © 2019 罗超. All rights reserved.
//

import UIKit

let DirectoryViewWidth: CGFloat = 268
let DirectoryTopHeight = CGFloat(ScreenHeight<810 ? 16 : 49)
let SettingViewHeight = CGFloat(ScreenHeight<810 ? 190 : 224)

class LRPageRootViewController: UIViewController {

    @IBOutlet weak var handleView: UIView!
    
    //topView
    @IBOutlet weak var topHandleView: UIView!
    @IBOutlet weak var topHeightConstraint: NSLayoutConstraint!
    
    //bottomView
    @IBOutlet weak var bottomHandleView: UIView!
    @IBOutlet weak var bottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nightButton: LRSettingButton!
    
    //directoryView
    @IBOutlet weak var directoryView: UIView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var directoryTableView: UITableView!
    @IBOutlet weak var directoryTitleTopConstraint: NSLayoutConstraint!
    
    //settingView
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var fontSizeView: UIView!

    @IBOutlet weak var lineSpacingLabel: UILabel!
    @IBOutlet weak var lineSpacingView: UIView!
    @IBOutlet weak var backColorCollectionView: UICollectionView!
    @IBOutlet weak var pageAnimationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var settingViewHeightConstraint: NSLayoutConstraint!
    
    
    var tap: UITapGestureRecognizer?
    
    let topBeginTransform = CGAffineTransform(translationX: 0, y: -NavBarHeight)
    let bottomBeginTransform = CGAffineTransform(translationX: 0, y: TabBarHeight)
    let directoryBeginTransform = CGAffineTransform(translationX: -DirectoryViewWidth, y: 0)
    let settingBeginTransform = CGAffineTransform(translationX: 0, y: SettingViewHeight)
    
    @UserDefault(key: "ModeNumKey", defaultValue: 0) var modeNum: Int
    @UserDefault(key: "FontSizeKey", defaultValue: 16) var fontSize: CGFloat
    @UserDefault(key: "LineSpacingKey", defaultValue: 2) var lineSpacing: CGFloat
    @UserDefault(key: "PageTransitionStyleRowValueKey", defaultValue: 0) var pageTransitionStyleRowValue: Int
    
    let modes: [Mode] = [.dayMode0, .dayMode1, .dayMode2, .dayMode3, .dayMode4, .dayMode5, .dayMode6, .dayMode7, .dayMode8]

    var ishiddenHandleView = true {
        didSet {
            updateHandleHidden(isHedden: ishiddenHandleView)
        }
    }
    var bookName: String? = nil
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return ishiddenHandleView
    }
    
    //MARK: - Life
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    deinit {
        print("\(self) doalloc")
    }

    
    // MARK: - View
    func setup() {
        nightButton.isSelected = modeNum < 0
        let mode = modeNum < 0 ? Mode.darkMode : modes[modeNum]
        let textConfig = LRTextConfig(mode: mode)
        
        let pageTransitionStyle = UIPageViewController.TransitionStyle(rawValue: pageTransitionStyleRowValue)!
        self.pageAnimationSegmentedControl.selectedSegmentIndex =
            pageTransitionStyle == UIPageViewController.TransitionStyle.pageCurl ? 0 : 1
        
        addPageVC(with: pageTransitionStyle, textConfig: textConfig)
        
        handleView.isHidden = ishiddenHandleView
        self.topHeightConstraint.constant = NavBarHeight
        self.topHandleView.transform = topBeginTransform
        self.bottomHeightConstraint.constant = TabBarHeight
        self.bottomHandleView.transform = bottomBeginTransform
        self.directoryView.isHidden = true
        self.directoryView.transform = directoryBeginTransform
        self.directoryTitleTopConstraint.constant = DirectoryTopHeight
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapViewHandle))
        self.view.addGestureRecognizer(tap)
        self.tap = tap
        self.tap!.delegate = self
        
        let maskTap = UITapGestureRecognizer(target: self, action: #selector(tapMask))
        self.maskView.addGestureRecognizer(maskTap)
        
        self.directoryTableView.delegate = self
        self.directoryTableView.dataSource = self
        self.directoryTableView.lc_registerNibCell(cellClass: LRDirectoryCell.self)
        self.directoryTableView.estimatedRowHeight = 0
        self.directoryTableView.rowHeight = 44
        
        
        self.settingViewHeightConstraint.constant = SettingViewHeight
        self.settingView.transform = settingBeginTransform
        self.settingView.isHidden = true
        self.fontSizeView.layer.cornerRadius = 5
        self.fontSizeView.clipsToBounds = true
        self.fontSizeView.layer.borderWidth = 1
        self.fontSizeView.layer.borderColor = UIColor.systemBackground.cgColor
        
        self.lineSpacingView.layer.cornerRadius = 5
        self.lineSpacingView.clipsToBounds = true
        self.lineSpacingView.layer.borderWidth = 1
        self.lineSpacingView.layer.borderColor = UIColor.systemBackground.cgColor
        
        self.backColorCollectionView.lc_registerNibCell(cellClass: LRColorCell.self)
        self.flowLayout.estimatedItemSize = .zero
        self.flowLayout.itemSize = CGSize(width: 40, height: 40)
        self.backColorCollectionView.dataSource = self
        self.backColorCollectionView.delegate = self
        
    }
    
    func addPageVC(with transitionStyle: UIPageViewController.TransitionStyle, textConfig: LRTextConfig? = nil) {
        let newPageVC = LRPageViewController(transitionStyle: transitionStyle, navigationOrientation: .horizontal, options: nil)
        if let textConfig = textConfig {
            newPageVC.textConfig = textConfig
        }
        newPageVC.bookName = bookName
        self.addChild(newPageVC)
        self.view.insertSubview(newPageVC.view, at: 0)
        newPageVC.view.frame = self.view.bounds
    }
    
    func removePageVC() -> LRTextConfig {
        let pageVC = self.children.first as! LRPageViewController
        let textConfig = pageVC.textConfig
        
        pageVC.view.removeFromSuperview()
        pageVC.removeFromParent()
        
        return textConfig
    }
    
    // MARK: - Data
    func IndexPathKey(for bookName: String?) -> String? {
        guard let bookName = bookName else {
            return nil
        }
        return "\(bookName)_currentPage"
    }
    
    func dictionaryFrom(indexPath: IndexPath) -> Dictionary<String,Int> {
        let dict = ["section":indexPath.section, "row":indexPath.row]
        return dict
    }
    
    func readTextConfig() -> LRTextConfig {
        let mode = modeNum < 0 ? Mode.darkMode : modes[modeNum]
        
//        let pageTransitionStyle = readPageTransitionStyle()
        return LRTextConfig(mode: mode)
    }
    
    func saveIndex() {
        guard let currentIndexKey = IndexPathKey(for: bookName) else {
            return
        }
        
        let pageVC = self.children.first as! LRPageViewController
        guard pageVC.children.count > 0 else { return }
        let bookVC = (pageVC.children.count == 3 ? pageVC.children[1]
            : pageVC.children[0]) as! LRBooKViewController
        
        let dict = dictionaryFrom(indexPath: bookVC.indexPath!)
        UserDefaults.standard.set(dict, forKey: currentIndexKey)
    }
    
    // MARK: - Private
    func updateSetting(isHedden: Bool) {
        if !isHedden {
            self.settingView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.settingView.transform = .identity
            }, completion: { (_) in
                
            })
        }else {
            UIView.animate(withDuration: 0.25, animations: {
                self.settingView.transform = self.settingBeginTransform
            }, completion: { (_) in
                self.settingView.isHidden = true
                self.handleView.isHidden = self.settingView.isHidden
            })
        }
        
    }
    
    func updateDirectoryView(isHedden: Bool) {
        if !isHedden {
            self.directoryView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.maskView.alpha = 0.3
                self.directoryView.transform = .identity
            }, completion: { (_) in
                
            })
        }else {
            UIView.animate(withDuration: 0.25, animations: {
                self.directoryView.transform = self.directoryBeginTransform
                self.maskView.alpha = 0
            }, completion: { (_) in
                self.directoryView.isHidden = true
            })
        }
        
    }
    
    func updateHandleHidden(isHedden: Bool) {
        self.setNeedsStatusBarAppearanceUpdate()
        if !isHedden {
            self.handleView.isHidden = isHedden
            UIView.animate(withDuration: 0.25, animations: {
                self.topHandleView.transform = .identity
                self.bottomHandleView.transform = .identity
            }, completion: { (_) in
                
            })
        }else {
            UIView.animate(withDuration: 0.25, animations: {
                self.topHandleView.transform = self.topBeginTransform
                self.bottomHandleView.transform = self.bottomBeginTransform
            }, completion: { (_) in
                self.handleView.isHidden = self.settingView.isHidden
            })
        }
    }


    
    func pageUpdate(mode: Mode) {
        let pageVc = self.children.first as! LRPageViewController
        var textConfig = pageVc.textConfig
        textConfig.mode = mode
        pageVc.textConfig = textConfig
        
        let bookVC = pageVc.viewControllers!.first as! LRBooKViewController
        let newBookVC = pageVc.setupBookVC(at: bookVC.indexPath!)
        pageVc.setViewControllers([newBookVC], direction: .forward, animated: false, completion: nil)
    }
    
    // MARK: - Event
    //base
    @objc func tapViewHandle(tap: UITapGestureRecognizer) {
        if !settingView.isHidden {
            updateSetting(isHedden: true)
        }else {
            self.ishiddenHandleView.toggle()
        }
    }
    
    // top
    @IBAction func back(_ sender: Any) {
        saveIndex()
        self.navigationController?.popViewController(animated: true)
    }
    
    //bottom
    @IBAction func directory(_ sender: Any) {
        self.ishiddenHandleView = true
        updateDirectoryView(isHedden: false)
    }
    
    @IBAction func night(_ sender: LRSettingButton) {
        let newModeNum = -(modeNum+1)
        
        sender.isSelected = newModeNum < 0
        let mode = newModeNum < 0 ? .darkMode : modes[newModeNum]
        
        modeNum = newModeNum
        pageUpdate(mode: mode)
    }
    
    //Setting
    @IBAction func setting(_ sender: Any) {
        self.ishiddenHandleView = true
        updateSetting(isHedden: false)
    }
    @IBAction func selectPageAnimation(_ sender: UISegmentedControl) {
        saveIndex()
        
        let textConfig = removePageVC()
        let pageTransitionStyle: UIPageViewController.TransitionStyle =
            sender.selectedSegmentIndex == 0 ? .pageCurl : .scroll
        pageTransitionStyleRowValue = pageTransitionStyle.rawValue
        addPageVC(with: pageTransitionStyle, textConfig: textConfig)
    }
    
    //Directory
    @objc func tapMask() {
        updateDirectoryView(isHedden: true)
    }

    @IBAction func close() {
        updateDirectoryView(isHedden: true)
    }
    
    @IBAction func selectTo(_ sender: UISegmentedControl) {
        
    }
    
}



// MARK: - UITableViewDataSource & UITableViewDelegate
extension LRPageRootViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let pageVc = self.children.first as! LRPageViewController
        return pageVc.chapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.lc_dequeueReusableCell(indexPath: indexPath) as LRDirectoryCell
        let pageVC = self.children.first as! LRPageViewController
        let bookVC = pageVC.children.first as! LRBooKViewController
        let index = bookVC.indexPath!.section
        
        let titleModel = LRTitleModel(title: pageVC.chapters[indexPath.row][pageVC.TitleKey]!, selelct: index == indexPath.row)
        cell.titleModel = titleModel
        cell.selectionStyle = .none
        return cell        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pageVc = self.children.first as! LRPageViewController
        pageVc.popChapters(at: indexPath.row)
        let bookVC = pageVc.setupBookVC(at: IndexPath(row: 0, section: indexPath.row))
        pageVc.setViewControllers([bookVC], direction: .forward, animated: false, completion: nil)
        updateDirectoryView(isHedden: true)
        tableView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension LRPageRootViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.modes.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.lc_dequeueReusableCell(indexPath: indexPath) as LRColorCell
        cell.mode = self.modes[indexPath.item]
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        nightButton.isSelected = false
        modeNum = indexPath.item
        pageUpdate(mode: modes[indexPath.item])
    }
}

// MARK: - UIGestureRecognizerDelegate
extension LRPageRootViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.tap {
            let location = gestureRecognizer.location(in: self.view)
//            print(location)
            
            if !self.directoryView.isHidden {
                return false
            }
            
            if !self.handleView.isHidden, location.y < NavBarHeight || location.y > ScreenHeight - TabBarHeight{
                return false
            }
            
            if !self.settingView.isHidden, location.y > ScreenHeight - SettingViewHeight {
                return false
            }
        }
        
        return true
    }

}
