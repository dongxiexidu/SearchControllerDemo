//
//  SearchController.swift
//  SearchControllerDemo
//
//  Created by fashion on 2018/3/10.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

/// 搜索控制器类型
enum SearchControllerType {
    case partOne
    case partTwo
    case partThree
}
/// 搜索控制器跳转方式
enum SearchJumpType {
    case push
    case present
}
/// 点击事件类型
enum SearchFunctionType {
    /// 点击了"清除搜索历史"按钮
    case clear
    /// 点击了"搜索"按钮
    case search
    /// 点选了搜索结果列表
    case searchArray
    /// 点选了热门搜索列表
    case hotArray
    /// 点选了历史搜索列表
    case historyArray
    /// 点选了创建标签
    case creatTagForDiscover
}

/// 点击回调 参数一：点击事件类型 参数二：选中行号 参数三：选中文字
typealias SearchCallBack = (SearchFunctionType,Int,String)->()
/// 通过此block传递搜索结果字符串数组
typealias SearchSetNewArrayHandle = ([String])->()

typealias HeightCallBack = (CGFloat)->Void


let kNavigationHeihgt : CGFloat = 64
let kScreenWidth : CGFloat = UIScreen.main.bounds.size.width
let kScreenHeight : CGFloat = UIScreen.main.bounds.size.height

class SearchController: UIViewController {
    
    /// 控制器样式
    var type = SearchControllerType.partOne
    /** 是否点击了搜索 */
    var searching : Bool = false
    
    var callBack : SearchCallBack?
    
    var jumpType = SearchJumpType.push
    
    //// 热门搜索String
    var hotKeywordsArray = [String]()
    /// 历史搜索String
    var historyKeywordsArray = [String]()
    
    
    /// 热门搜索Btns
    var hotKeywordsBtnArray = [UIButton]()
    /// 历史搜索Btns
    var historyKeywordsBtnArray = [UIButton]()
    
    var result : Bool = false
    
    /// 搜索结果String
    var resultArray : [String] = [String]() {
       
        didSet{
            if resultArray.count > 0 {
                result = true
            }else{
                result = false
            }
            tableView.reloadData()
        }
    }
    
    
    lazy var setNewArrayHandle: SearchSetNewArrayHandle = {
        let handle = { [unowned self] newArray in
            self.resultArray = newArray
        }
        return handle
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // resultArray = []
        view.addSubview(tableView)
        setupNav()
    }
    
    
    static func showSearchControllerFromController(fromController: UIViewController, hotKeywordsArray hotArray: [String], historyKeywordsArray hisArray: [String], type: SearchControllerType, jumpType: SearchJumpType, callBack: @escaping SearchCallBack) -> SearchSetNewArrayHandle {
        
        let controller = SearchController()
        controller.callBack = callBack
        controller.type = type
        controller.jumpType = jumpType
        controller.hotKeywordsArray = hotArray
        controller.historyKeywordsArray = hisArray
        if jumpType == .push {
            fromController.navigationController?.pushViewController(controller, animated: true)
        } else {
            let nav : UINavigationController = UINavigationController.init(rootViewController: controller)
            fromController.present(nav, animated: true, completion: nil)
        }
        
        return controller.setNewArrayHandle
    }
    
    
    
    lazy var searchBar: UISearchBar = {
        let searchB = UISearchBar.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth-90, height: 30))
        searchB.delegate = self
        searchB.placeholder = self.placeholder
        return searchB
    }()
    
    lazy var placeholder: String = {
        var placeStr = "输入感兴趣的目的地"
        switch type {
        case .partOne:
            placeStr = "搜索话题"
        case .partTwo:
            placeStr = "输入感兴趣的目的地"
        default:
            placeStr = "请输入感兴趣的景点"
        }
        return placeStr
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView.init()
        table.tableFooterView = UIView()
        table.separatorStyle = .none
        table.frame = CGRect.init(x: 0, y: kNavigationHeihgt, width: kScreenWidth, height: kScreenHeight-kNavigationHeihgt)
        table.dataSource = self
        table.delegate = self
        table.keyboardDismissMode = .onDrag
        if #available(iOS 11.0,*) {
           table.contentInsetAdjustmentBehavior = .never
        }else{
            self.automaticallyAdjustsScrollViewInsets = false
        }
        return table
    }()

    let cellIdentifier = "keywordCubCell"
}


extension SearchController {
    
    
    private func setupNav() {
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: searchBar)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBtnDidClick))
    }
    
    @objc private func rightBtnDidClick(item: UIBarButtonItem) {
        if item.title == "搜索" {
            item.title = "取消"
            searching = true
            callBack?(.search,0,searchBar.text!)
        } else {
            searchBar.resignFirstResponder()
            dismissController()
        }
    }
    
    private func dismissController() {
        if jumpType == .push {
            navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc private func hotArrayBtnClick(btn: UIButton) {
        //  返回索引号
        callBack!(.hotArray,btn.tag,searchBar.text!)
        dismissController()
    }
    @objc private func historyArrayBtnClick(btn: UIButton) {
        //  返回索引号
        callBack!(.historyArray,btn.tag,searchBar.text!)
        dismissController()
    }
    
    private func showNoneInCell(cell: UITableViewCell) {
        if type == .partThree {
            let attrStrPartOne = NSAttributedString.init(string: "没有搜索到", attributes: [NSAttributedStringKey.foregroundColor : UIColor.black,NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12)])
            
            let attrStrPartTwo = NSAttributedString.init(string: "\(searchBar.text!)", attributes: [NSAttributedStringKey.foregroundColor : UIColor.orange,NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12)])
            
            let attrStrPartThree = NSAttributedString.init(string: "相关的内容，换个关键字搜搜看", attributes: [NSAttributedStringKey.foregroundColor : UIColor.black,NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12)])
            
            let realAttrs = NSMutableAttributedString.init()
            realAttrs.append(attrStrPartOne)
            realAttrs.append(attrStrPartTwo)
            realAttrs.append(attrStrPartThree)
            
            cell.textLabel?.attributedText = realAttrs
        }else{
            cell.textLabel?.text = "没有找到相关话题"
        }
    }
    
    
    func creatKeywordCubCellWithArray(keywordArray: [String],toArray mutableArray: inout [UIButton], inTableView tableView : UITableView,heightCallBack callBack: HeightCallBack? ) -> UITableViewCell {
        mutableArray.removeAll()
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
            cell?.selectionStyle = .none
        }
        
        let cub = UIView()
        cub.frame = CGRect.init(x: 0, y: 0, width: tableView.bounds.size.width, height: 250)
        
        for i in 0..<keywordArray.count {
            let kKeywordMargin : CGFloat = 10
            let kBtnLeftMarginToCub : CGFloat = 15
            let kBtnRightMarginToCub : CGFloat = 15
            let btn = UIButton.init(type: UIButtonType.custom)
            btn.tag = i
            let attr = NSAttributedString.init(string: keywordArray[i], attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray,NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12)])
            btn.setAttributedTitle(attr, for: .normal)
            
            if mutableArray == hotKeywordsBtnArray {
                btn.addTarget(self, action: #selector(hotArrayBtnClick(btn:)), for: .touchUpInside)
            }else if mutableArray == historyKeywordsBtnArray {
                btn.addTarget(self, action: #selector(historyArrayBtnClick(btn:)), for: .touchUpInside)
            }
            //  设置btn宽度和高度
            btn.sizeToFit()
            btn.m_width += 20
            btn.m_height = 27
            
            //  边框
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.init(red: 221.0/255, green:221.0/255, blue:221.0/255, alpha:1).cgColor
            btn.layer.cornerRadius = 3
            btn.layer.masksToBounds = true
            btn.backgroundColor = UIColor.white
            
            // 设置Btn最大宽度
            if btn.m_width > cub.m_width - 2 * kKeywordMargin{
                btn.m_width = cub.m_width - 2 * kKeywordMargin
            }
            //  计算Btn的frame
            let lastBtn = mutableArray.last
            //  第一个Btn位置
            if (lastBtn == nil){
                btn.m_left = kBtnLeftMarginToCub
                btn.m_top = 0
            }else{
                let widthPart = (lastBtn?.frame.maxX)! + kKeywordMargin
                btn.m_left = cub.m_width - widthPart - kBtnRightMarginToCub > btn.m_width ? widthPart : kBtnLeftMarginToCub
                btn.m_top = cub.m_width - widthPart - kBtnRightMarginToCub > btn.m_width ? (lastBtn?.frame.origin.y)! : (lastBtn?.frame.maxY)! + kKeywordMargin
            }
             //  添加Btn
            mutableArray.append(btn)
            cub.addSubview(btn)
                
        }
        let btn = mutableArray.last
        cub.m_height = (btn?.frame.maxY)!
        if callBack != nil {
            callBack!(cub.m_height)
        }
        //  添加到cell
        cell?.addSubview(cub)
        cell?.bounds = cub.frame
        return cell!
    }
    
    
    
}

// MARK: -UISearchBarDelegate
extension SearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.navigationItem.rightBarButtonItem?.title = "取消"
        } else {
            self.navigationItem.rightBarButtonItem?.title = "搜索"
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searching = true
        callBack!(.search,0,searchBar.text!)
    }
    
}
// MARK: -UITableViewDataSource
extension SearchController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sectionNum = 0
        if searching == true {
            sectionNum = 1
        } else {
            if type == .partThree {
                sectionNum = 0
            }else{
                sectionNum = 2
            }
        }
        return sectionNum
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if type == .partTwo {
            if searching == true{
                if result == true {
                    // 返回数组长度 + 1（提示添加标签）
                    return self.resultArray.count + 1
                }else{
                    // 没结果展示两行 - 第一行提示没结果，第二行提示添加标签
                    return 2
                }
            }else{
                return 1
            }
        } else if type == .partOne {
            if searching == true{
                if result == true {
                    return self.resultArray.count
                }else{
                    return 1
                }
            }else{
                return 1
            }
        }else { // 默认 - 不展示推荐标签
            if searching == true{
                if result == true {
                    return self.resultArray.count
                }else{
                    return 1
                }
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searching { //  点击了搜索
            let cell = UITableViewCell.init()
            if result == false {
                if indexPath.row == 0 {
                    showNoneInCell(cell: cell)
                }
                if indexPath.row == 1 {
                    showNoneInCell(cell: cell)
                }
            }else{// 有结果，展示结果
                cell.textLabel?.text = resultArray[indexPath.row]
            }
            
            return cell
        }
        //  没点搜索，展示默认推荐界面
        //  热门搜索
        if indexPath.section == 0 {
            let cell = creatKeywordCubCellWithArray(keywordArray: hotKeywordsArray, toArray: &hotKeywordsBtnArray, inTableView: tableView, heightCallBack: nil)
            
            return cell
        }
        //  历史搜索
        let cell = creatKeywordCubCellWithArray(keywordArray: historyKeywordsArray, toArray: &historyKeywordsBtnArray, inTableView: tableView, heightCallBack: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searching {
            return 44
        }
        var cellHeight : CGFloat = 0
        // 热门搜索
        if indexPath.row == 0 {
            let _ = creatKeywordCubCellWithArray(keywordArray: hotKeywordsArray, toArray: &hotKeywordsBtnArray, inTableView: tableView, heightCallBack: { (height) in
                cellHeight = height
            })
            return cellHeight + 20
        }
        
        // 历史搜索计算高度
        let _ = creatKeywordCubCellWithArray(keywordArray: historyKeywordsArray, toArray: &historyKeywordsBtnArray, inTableView: tableView, heightCallBack: { (height) in
            cellHeight = height
        })
        return cellHeight + 20
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searching {
            return 0
        }
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searching {
            return nil
        }
        //根据type 创建 @"热门话题" 或 @"热门目的地";
        if section == 0 {
            let header = UIView()
            header.backgroundColor = UIColor.red
            return header
        }
        //根据type 创建 @"添加过的话题" 或 @"历史搜索"
        if section == 1 {
            let header = UIView()
            header.backgroundColor = UIColor.blue
            return header
        }
        return nil
    }
    
}

// MARK: -UITableViewDelegate
extension SearchController:UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching {
            // 没结果点击不处理
            if result == false{
                if type == .partTwo && indexPath.row == 1 {
                    callBack!(.creatTagForDiscover,indexPath.row,searchBar.text!)
                }
                
            }else{// 有结果点击结果退出当前页并回调Block
                callBack!(.creatTagForDiscover,indexPath.row,resultArray[indexPath.row])
            }
            dismissController()
            
            
        }
    }
}


extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
