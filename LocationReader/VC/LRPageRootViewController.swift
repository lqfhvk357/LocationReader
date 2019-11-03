
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

class LRPageRootViewController: UIViewController {

    @IBOutlet weak var handleView: UIView!
    @IBOutlet weak var topHandleView: UIView!
    @IBOutlet weak var topHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomHandleView: UIView!
    @IBOutlet weak var bottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var directoryView: UIView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var directoryTableView: UITableView!
    @IBOutlet weak var directoryTitleTopConstraint: NSLayoutConstraint!
    
    var tap: UITapGestureRecognizer?
    
    
    let topBeginTransform = CGAffineTransform(translationX: 0, y: -NavBarHeight)
    let bottomBeginTransform = CGAffineTransform(translationX: 0, y: TabBarHeight)
    let directoryBeginTransform = CGAffineTransform(translationX: -DirectoryViewWidth, y: 0)
    
    var ishiddenHandleView = true {
        didSet {
            updateHandleHidden(isHedden: ishiddenHandleView)
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return ishiddenHandleView
    }
    
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Private
    func setup() {
        let pageVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "pageVC") as! LRPageViewController
        self.addChild(pageVC)
        self.view.insertSubview(pageVC.view, at: 0)
        pageVC.view.frame = self.view.bounds
        
        handleView.isHidden = ishiddenHandleView
        self.topHeightConstraint.constant = NavBarHeight
        self.topHandleView.transform = topBeginTransform
        self.bottomHeightConstraint.constant = TabBarHeight
        self.bottomHandleView.transform = bottomBeginTransform
        self.directoryView.isHidden = true
        self.directoryView.transform = directoryBeginTransform
        self.directoryTitleTopConstraint.constant = DirectoryTopHeight
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapView))
        self.view.addGestureRecognizer(tap)
        self.tap = tap
        
        let maskTap = UITapGestureRecognizer(target: self, action: #selector(tapMask))
        self.maskView.addGestureRecognizer(maskTap)
        
        self.directoryTableView.delegate = self
        self.directoryTableView.dataSource = self
        self.directoryTableView.lc_registerNibCell(cellClass: LRDirectoryCell.self)
        self.directoryTableView.estimatedRowHeight = 0
        self.directoryTableView.rowHeight = 44
    }

    // MARK: - Event
    
    //base
    @objc func tapView() {
        self.ishiddenHandleView.toggle()
    }
    
    func updateHandleHidden(isHedden: Bool) {
        self.setNeedsStatusBarAppearanceUpdate()
        self.tap?.isEnabled = false
        
        if !isHedden {
            self.handleView.isHidden = isHedden
            UIView.animate(withDuration: 0.25, animations: {
                self.topHandleView.transform = .identity
                self.bottomHandleView.transform = .identity
            }, completion: { (_) in
                self.tap?.isEnabled = true
            })
        }else {
            UIView.animate(withDuration: 0.25, animations: {
                self.topHandleView.transform = self.topBeginTransform
                self.bottomHandleView.transform = self.bottomBeginTransform
            }, completion: { (_) in
                self.handleView.isHidden = isHedden
                if self.directoryView.isHidden {
                    self.tap?.isEnabled = true
                }
            })
        }
    }
    
    // top
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //bottom
    @IBAction func directory(_ sender: Any) {
        self.directoryView.isHidden = false
        self.ishiddenHandleView = true
        UIView.animate(withDuration: 0.3, animations: {
            self.maskView.alpha = 0.3
            self.directoryView.transform = .identity
        }, completion: { (_) in
            self.tap?.isEnabled = false
        })
    }
    
    @IBAction func night(_ sender: LRSettingButton) {
        
    }
    @IBAction func setting(_ sender: Any) {
        
    }
    
    //left
    @objc func tapMask() {
        close()
    }

    @IBAction func close() {
        self.tap?.isEnabled = true
        UIView.animate(withDuration: 0.25, animations: {
            self.directoryView.transform = self.directoryBeginTransform
            self.maskView.alpha = 0
        }, completion: { (_) in
            self.directoryView.isHidden = true
        })
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
        close()
        tableView.reloadData()
    }
}
