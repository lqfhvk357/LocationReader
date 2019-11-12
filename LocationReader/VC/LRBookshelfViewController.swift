//
//  LRBookshelfViewController.swift
//  LocationReader
//
//  Created by 罗超 on 2019/10/28.
//  Copyright © 2019 罗超. All rights reserved.
//

import UIKit

class LRBookshelfViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.lc_registerClassCell(cellClass: UITableViewCell.self)
        // Do any additional setup after loading the view.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushToPageRoot" {
            let pageRootVC = segue.destination as! LRPageRootViewController
            pageRootVC.bookName = "jpm"
        }
    }

}


extension LRBookshelfViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.lc_dequeueReusableCell(indexPath: indexPath)
        cell.textLabel?.text = "\(indexPath.row) 楼"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "PushToPageRoot", sender: nil)
    }
}
