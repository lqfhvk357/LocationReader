//
//  LRPageViewController.swift
//  LocationReader
//
//  Created by 罗超 on 2019/10/28.
//  Copyright © 2019 罗超. All rights reserved.
//

import UIKit

struct LRTextConfig {
    var color: UIColor = .black
    var font: UIFont = UIFont(name: "PingFangTC-Regular", size: 16)!
//    var font: UIFont = .systemFont(ofSize: 16)!
    var backImage: UIImage? = nil
//        UIImage(named: "Miso(1347)0032.jpg")
    var backColor: UIColor = .white
}


class LRPageViewController: UIPageViewController {

    var textArray = [[LRPageModel]]()
    var currentIndex = IndexPath(row: 0, section: 0)
    var oldIndex = IndexPath(row: 0, section: 0)
    var willIndex = IndexPath(row: 0, section: 0)
    
    var textConfig = LRTextConfig()
    
    let TextKey = "TextKey"
    let TitleKey = "TitleKey"
    var chapters = [[String:String]]()
    
    let topMargin = CGFloat(ScreenHeight<810 ? 32 : 77)
    let bottomMargin = CGFloat(ScreenHeight<810 ? 32 : 66)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        chapters = getChapters()
        popChapters()

        let bookVC = setupBookVC(at: currentIndex)
        self.setViewControllers([bookVC], direction: .forward, animated: true, completion: nil)
        
        addTap()
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
    
    // MARK: - Event
    func addTap() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapView))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func tapView() {
        print("tap")
    }
    
    
    
    // MARK: - DATA
    func getChapters() -> [[String:String]] {
        let filePath = Bundle.main.path(forResource: "水浒传", ofType: "txt")!
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        
        var datas = [[String:String]]()
        
        if let content = try? String(contentsOfFile: filePath, encoding: String.Encoding(rawValue: encoding)) {
            
            let contentString = NSString(string: content)
            
            let pattern = "\n[序第][\\d\\u4e00-\\u9fa5]{0,8}[章回]\\s+\\S+"
            let reg = try! NSRegularExpression(pattern: pattern, options: [])
            let results = reg.matches(in: content, options: [], range: NSRange(location: 0, length: contentString.length))
            
            let sum = results.count
            var i = 0
            for result in results {
                let location = result.range.location
                var length = 0
                if i + 1 < sum {
                    length = results[i+1].range.location - location
                }else {
                    length = contentString.length - location
                }
                let text = contentString.substring(with: NSRange(location: location, length: length))
                var title = contentString.substring(with: result.range)
                print(title)
                title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                title = title.replacingOccurrences(of: "\n", with: " ")
                title = title.replacingOccurrences(of: "\r", with: " ")
                let dict = [TextKey: text, TitleKey: title]
                datas.append(dict)
                
                i = i + 1
            }
        }
        return datas
    }
    
    func getPages(for textDict: [String:String]) -> [LRPageModel] {
        let text = textDict[TextKey]!
        let textStorage = NSTextStorage(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        let attributes:[NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: textConfig.font,
            .foregroundColor: textConfig.color
        ]
        textStorage.setAttributes(attributes, range: NSRange(location: 0, length: text.count))
        let layoutM = NSLayoutManager()
        textStorage.addLayoutManager(layoutM)
        
        let lineH = getOneLineHeight(with: "超哥", attributes: attributes)
        print(lineH)
        let heigth = ScreenHeight - topMargin - bottomMargin - lineH
        let width = ScreenWidth - 18 * 2
        
        var pages = [LRPageModel]()
        
        while true {
            let textContainer = NSTextContainer(size: CGSize(width: width, height: heigth))
            layoutM.addTextContainer(textContainer)
            let range = layoutM.glyphRange(for: textContainer)
            if range.length <= 0 {
                for i in 0..<pages.count {
                    let page = "\(i+1)/\(pages.count)页"
                    pages[i].page = page
                }
                break
            }
//            let pageText = textStorage.attributedSubstring(from: range)
            let textString = NSString(string: text)
            let pageString = textString.substring(with: range)
            let pageText = NSAttributedString(string: pageString, attributes: attributes)
            let chapter = textDict[TitleKey]!
            
            let pageModel = LRPageModel(text: pageText, page: "", chapter: chapter)
            pages.append(pageModel)
        }
        return pages
        
    }
    
    
    func getOneLineHeight(with text: String, attributes: [NSAttributedString.Key : Any]) -> CGFloat {
        
        let textStorage = NSTextStorage(string: text, attributes: attributes)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: CGSize(width: 1000, height: 100))
        layoutManager.addTextContainer(textContainer)
        let height = layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: text.count), in: textContainer).size.height
        return height
    }
    
    func popChapters() {
        if chapters.count == 0 {
            return
        }
        let fc = chapters.remove(at: 0)
        textArray.append(getPages(for: fc))
    }
    
    // MARK: - View
    func setupBookVC(at indexPath: IndexPath) -> LRBooKViewController {
        let bookVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BooKVC") as! LRBooKViewController
        
        bookVC.pageModel = textArray[indexPath.section][indexPath.row]
        bookVC.textConfig = textConfig
        return bookVC
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UIPageViewControllerDataSource
extension LRPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if currentIndex.section == 0, currentIndex.row == 0 {
            return nil
        }else {
            oldIndex = currentIndex
            if currentIndex.row == 0 {
                let count = textArray[currentIndex.section-1].count
                willIndex = IndexPath(row: count-1, section: currentIndex.section-1)
            }else {
                willIndex = IndexPath(row: currentIndex.row-1, section: currentIndex.section)
            }
            
            print("Before \(willIndex)")
            return setupBookVC(at: willIndex)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentIndex.section >= textArray.count-1, currentIndex.row >= textArray[currentIndex.section].count-1 {
            return nil
        }else {
            oldIndex = currentIndex
            
            if currentIndex.row == textArray[currentIndex.section].count-1 {
                willIndex = IndexPath(row: 0, section: currentIndex.section+1)
            }else {
                willIndex = IndexPath(row: currentIndex.row+1, section: currentIndex.section)
            }
            
            print("After \(willIndex)")
            return setupBookVC(at: willIndex)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.view.isUserInteractionEnabled = false
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            self.view.isUserInteractionEnabled = true
        }
        
        if !completed {
            currentIndex = oldIndex
        }else {
            currentIndex = willIndex
            DispatchQueue.global().async {
                if self.currentIndex.section == self.textArray.count-1 {
                    self.popChapters()
                }
            }
        }
    }
}
