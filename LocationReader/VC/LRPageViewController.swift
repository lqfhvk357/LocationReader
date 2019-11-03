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
//    var backImage: UIImage? = UIImage(named: "Miso(1347)0032.jpg")
    var backColor: UIColor = .white
    
}


class LRPageViewController: UIPageViewController {
    
    var textArray = [String:[LRPageModel]]()
    var textConfig = LRTextConfig()

    let TextRangeKey = "TextRangeKey"
    let TitleKey = "TitleKey"
    var chapters = [[String:String]]()
    
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    
    var contentString: NSString = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        chapters = getChapters()
        popChapters(at: 0)
        
//        let workItem = DispatchWorkItem {
//            for i in 1..<self.chapters.count {
//                self.popChapters(at: i)
//            }
//        }
//        DispatchQueue.global().async(execute: workItem)
//        self.workItem = workItem
        
        let bookVC = setupBookVC(at: IndexPath(row: 0, section: 0))
        self.setViewControllers([bookVC], direction: .forward, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }
    
    deinit {
        
        print("\(self) doalloc")
    }
    
    // MARK: - DATA
    func getChapters() -> [[String:String]] {
        let bookName = "all"
        let filePath = Bundle.main.path(forResource: bookName, ofType: "txt")!
//        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        let encoding = String.Encoding.utf8.rawValue
        let content = try? String(contentsOfFile: filePath, encoding: String.Encoding(rawValue: encoding))
        if content == nil {
            return []
        }
        contentString = NSString(string: content!)

        let chaptersPath = "\(documentsPath)/\(bookName)_chapters.plist"
        let fm = FileManager.default
        if fm.fileExists(atPath: chaptersPath) {
            print(Date())
            let chaptersUrl = URL(fileURLWithPath: chaptersPath)
            let array = NSArray(contentsOf: chaptersUrl)
            print(Date())
            if let array = array, let dictArray = Array(array) as? [[String : String]] {
                return dictArray
            }
        }
        
        
        var datas = [[String:String]]()
        
        print(Date())
        let pattern = "\n[序第][\\d\\u4e00-\\u9fa5]{0,8}[章回]\\s+\\S+"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        let results = reg.matches(in: content!, options: [], range: NSRange(location: 0, length: contentString.length))
        
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
            let textRange = NSRange(location: location, length: length)
            var title = contentString.substring(with: result.range)

            title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            title = title.replacingOccurrences(of: "\n", with: " ")
            title = title.replacingOccurrences(of: "\r", with: " ")
            let dict = [TextRangeKey: NSStringFromRange(textRange), TitleKey: title]
            datas.append(dict)
            
            i = i + 1
        }
        
        print(Date())
        
        let nsArr = NSArray(array: datas)
        print(chaptersPath)
        nsArr.write(toFile: chaptersPath, atomically: true)
        
        return datas
    }
    
    func getPages(for textDict: [String:String]) -> [LRPageModel] {
        let rangeString = textDict[TextRangeKey]!
        let range = NSRangeFromString(rangeString)
        let text = contentString.substring(with: range)
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
    
    func popChapters(at index: Int) {
        if chapters.count <= index {
            return
        }
        if textArray["\(index)"] != nil {
            return
        }
        let fc = chapters[index]
        textArray["\(index)"] = getPages(for: fc)
    }
    
    // MARK: - View
    func setupBookVC(at indexPath: IndexPath) -> LRBooKViewController {
        let bookVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BooKVC") as! LRBooKViewController
        
        bookVC.pageModel = textArray["\(indexPath.section)"]![indexPath.row]
        bookVC.textConfig = textConfig
        bookVC.indexPath = indexPath
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
        
        let bookVC = viewController as! LRBooKViewController
        let currentIndex = bookVC.indexPath!
        
        
        if currentIndex.section == 0, currentIndex.row == 0 {
            return nil
        }else {
            var willIndex: IndexPath
            if currentIndex.row == 0 {
                popChapters(at: currentIndex.section-1)
                let count = textArray["\(currentIndex.section-1)"]!.count
                willIndex = IndexPath(row: count-1, section: currentIndex.section-1)
            }else {
                willIndex = IndexPath(row: currentIndex.row-1, section: currentIndex.section)
            }
            
            print("Before \(willIndex)")
            return setupBookVC(at: willIndex)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let bookVC = viewController as! LRBooKViewController
        let currentIndex = bookVC.indexPath!
        
        if currentIndex.section >= chapters.count-1, currentIndex.row >= textArray["\(currentIndex.section)"]!.count-1 {
            return nil
        }else {
            var willIndex: IndexPath
            if currentIndex.row == textArray["\(currentIndex.section)"]!.count-1 {
                popChapters(at: currentIndex.section+1)
                willIndex = IndexPath(row: 0, section: currentIndex.section+1)
            }else {
                willIndex = IndexPath(row: currentIndex.row+1, section: currentIndex.section)
            }
            
            print("After \(willIndex)")
            return setupBookVC(at: willIndex)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        self.view.isUserInteractionEnabled = false
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
//            self.view.isUserInteractionEnabled = true
        }
    }
}
