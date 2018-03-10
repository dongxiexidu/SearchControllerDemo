//
//  ViewController.swift
//  SearchControllerDemo
//
//  Created by fashion on 2018/3/10.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var handle : SearchSetNewArrayHandle!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
       self.handle = SearchController.showSearchControllerFromController(fromController: self, hotKeywordsArray: ["帅锅","美眉"], historyKeywordsArray: ["TFBoys","TFS"], type: .partThree, jumpType: .push) { [unowned self] (selectedType, selectedRowIndex, resultString) in
            print("\(selectedType),\(selectedRowIndex),\(resultString)")
            
            if selectedType == .search {
                let time : TimeInterval = 0.25
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+time, execute: {
                    self.handle(["搜索结果一","搜索结果二"])
                })
            }
        }
    }


}

