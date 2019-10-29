//
//  LRPageViewController.swift
//  LocationReader
//
//  Created by 罗超 on 2019/10/28.
//  Copyright © 2019 罗超. All rights reserved.
//

import UIKit

struct LRTextConfig {
    var color: UIColor = .yellow
    var font: UIFont = UIFont(name: "PingFangTC-Regular", size: 16)!
    var backImage: UIImage? = UIImage(named: "Miso(1347)0032.jpg")
    var backColor: UIColor = .white
}


class LRPageViewController: UIPageViewController {
    
    var textArray = [[NSAttributedString]]()
    var currentIndex = IndexPath(row: 0, section: 0)
    var oldIndex = IndexPath(row: 0, section: 0)
    var textConfig = LRTextConfig()
    var chapters = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        chapters = getChapters()
        popChapters()

        let bookVC = setupBookVC(at: currentIndex)
        self.setViewControllers([bookVC], direction: .forward, animated: true, completion: nil)
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
    
    
    // MARK: - DATA
    func getChapters() -> [String] {
        let filePath = Bundle.main.path(forResource: "水浒传", ofType: "txt")!
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        
        var datas = [String]()
        
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
                
                datas.append(text)
                
                i = i + 1
            }
//
//            print(datas[0])
//            print("******************************")
//            print(datas[sum - 1])
        }
        
        return datas
        
    }
    
    func getPages(for text: String) -> [NSAttributedString] {
        let heigth = ScreenHeight - 20 - 34 - 32
        let width = ScreenWidth - 18 * 2
        
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
        
        let textString = NSString(string: text)
        var pages = [NSAttributedString]()
        
        while true {
            let textContainer = NSTextContainer(size: CGSize(width: width, height: heigth))
            layoutM.addTextContainer(textContainer)
            let range = layoutM.glyphRange(for: textContainer)
            if range.length <= 0 {
                break
            }
            let pageText = textString.substring(with: range)
            let attrString = NSAttributedString(string: pageText, attributes: attributes)
            pages.append(attrString)
        }
        return pages
        
    }
    
    func popChapters() {
        if chapters.count == 0 {
            return
        }
        let fc = chapters.remove(at: 0)
        textArray.append(getPages(for: fc))
    }
    
    // MARK: - View
    func setupBookVC(at indexPath: IndexPath) -> BooKViewController {
        let bookVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BooKVC") as! BooKViewController
        bookVC.text = textArray[indexPath.section][indexPath.row]
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
                currentIndex = IndexPath(row: count-1, section: currentIndex.section-1)
            }else {
                currentIndex = IndexPath(row: currentIndex.row-1, section: currentIndex.section)
            }
            
            print("Before \(currentIndex)")
            return setupBookVC(at: currentIndex)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentIndex.section >= textArray.count-1, currentIndex.row >= textArray[currentIndex.section].count-1 {
            return nil
        }else {
            oldIndex = currentIndex
            
            if currentIndex.row == textArray[currentIndex.section].count-1 {
                currentIndex = IndexPath(row: 0, section: currentIndex.section+1)
            }else {
                currentIndex = IndexPath(row: currentIndex.row+1, section: currentIndex.section)
            }
            
            print("After \(currentIndex)")
            return setupBookVC(at: currentIndex)
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
            DispatchQueue.global().async {
                if self.currentIndex.section == self.textArray.count-1 {
                    self.popChapters()
                }
            }
        }
    }
}
