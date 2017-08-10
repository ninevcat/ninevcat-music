//
//  ChannelViewController.swift
//  doubandiantai
//
//  Created by 秦昊 on 2017/7/7.
//  Copyright © 2017年 秦昊. All rights reserved.
//

import UIKit
import Toucan
import SwiftyJSON
import Kingfisher

// 1.声明协议
@objc protocol  ChannelViewControllerDelegate {
    // 2.设置协议中的方法
    @objc optional func viewController(viewController:ChannelViewController,popWithValue:String)->Void
}

class ChannelViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    // 3.声明协议属性
    weak var delegate : ChannelViewControllerDelegate?
    
    // 用于存放网络请求的数据
    var items:[JSON] = []
    var listitems:[String] = []
    var songlist:[String] = []
    
    var imageVwbg: UIImageView!
    
    var goBackBtn: UIButton!
    
    var channelLabel: UILabel!
    
    var channelClect: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化Image View(background)
        imageVwbg = {
            let image = UIImageView(frame: self.view.frame)
            let bg = UIImage(named: "bg2")
            image.image = bg
            return image
        }()
        
        // 返回按钮
        goBackBtn = {
            let btn = UIButton(frame: CGRect(x:20, y:30, width:20, height:20))
            let icon = UIImage(named:"goBackIcon")?.withRenderingMode(.alwaysOriginal)
            btn.setImage(icon, for: .normal)
            btn.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
            return btn
        }()
        
        // 频道选择label
        channelLabel = {
            let label = UILabel(frame: CGRect(x:0, y:20, width:self.view.bounds.size.width, height:40))
            label.text = "热门歌单"
            label.textColor = .white
            label.textAlignment = NSTextAlignment.center
            label.font = UIFont.systemFont(ofSize: 22)
            return label
        }()
        
        // 各频道的collectionview
        channelClect = {
            let layout = UICollectionViewFlowLayout()
//             let layout = CustomLayout()
            // cell大小
            layout.itemSize = CGSize(width: 162, height: 222)
            // cell之间水平间隔
//            flow.minimumInteritemSpacing = 5.0
            // cell之间垂直行间距
//            layout.minimumLineSpacing = 60.0
            
            let frame = CGRect(x:0, y:60, width:self.view.bounds.size.width, height:self.view.bounds.size.height-60)
            let clect = UICollectionView(frame: frame, collectionViewLayout: layout)
            
            clect.delegate = self
            clect.dataSource = self
            // 注册单元格
            clect.register(UICollectionViewCell.self,forCellWithReuseIdentifier: "ChannelViewCell")
            // 更改背景色为透明
            clect.backgroundColor = .clear
            // 设置collectionView的内边距
            clect.contentInset = UIEdgeInsetsMake(15, 20, 0, 20)
            // 去除滚动条
            clect.showsVerticalScrollIndicator = false
            
            return clect
        }()
        
        self.view.addSubview(self.imageVwbg!)
        self.view.addSubview(self.goBackBtn!)
        self.view.addSubview(self.channelLabel!)
        self.view.addSubview(self.channelClect!)
        
        httpGet()
        
    }
    
    func goBack(_ button:UIButton){

        if let delegate = self.delegate {
            delegate.viewController?(viewController: self, popWithValue: "ninevcat🐱")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // 获取网络数据
    func httpGet(){
        Network.AnalyzeGet("http://localhost:4000/recommendLst", params: nil) { (Json, status) in
            if status == "0"{
                self.items = Json["data"].arrayValue
                self.songGet(Json["data"].arrayValue)
                self.listGet(Json["data"].arrayValue)
            }
        }
        
    }
    
    func songGet(_ data:[JSON]){
        var songarr: [String] = []
        for _ in data{
            songarr.append("")
        }
        for json in data {
            let href = json["songhref"].stringValue
            if let index = data.index(of: json){
                songarr[index] = href
//                print(songarr)
            }
        }
        self.songlist = songarr
    }
    
    func listGet(_ data: [JSON]){
        var ownerarr: [String] = []
        for _ in data{
            ownerarr.append("")
        }
        
        let allnum = data.count
        var isdownnum  = 0

        for json in data {
            let href = json["listhref"].stringValue
            Network.AnalyzeGet(href, params: nil) { (Json, status) in
                isdownnum += 1
                if status == "0"{
                    var str = Json["data"]["owner"].stringValue
                    let len = str.characters.count
                    var owner:String!
                    if len==0 {
                        owner = "电台节目"
                        
                    }else{
                        owner = (str as NSString).substring(with: NSMakeRange(1, len-2))
                    }
                    if let index = data.index(of: json){
                        ownerarr[index] = owner
                    }
                }
                
                if allnum == isdownnum{
                    self.listitems = ownerarr
                    self.channelClect.reloadData()
                }
            }
            
        }
    }

    // CollectionView行数
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count;
    }
    
    
    // 获取单元格
     func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // storyboard里设计的单元格
        let identify:String = "ChannelViewCell"
        // 获取设计的单元格，不需要再动态添加界面元素
        let cell = (channelClect?.dequeueReusableCell(
            withReuseIdentifier: identify, for: indexPath))! as UICollectionViewCell
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width:0, height:14)
        cell.layer.shadowRadius = 45.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        
        // 添加imageView
        let img: UIImageView! = {
            let img = UIImageView(frame: CGRect(x:0, y:0, width:cell.frame.width, height:162))
            let url = URL(string: items[indexPath.row]["cover"].stringValue)
            img.kf.setImage(with: url)
//            img.image = Toucan(image: UIImage(named: "cardtest")!).maskWithRoundedRect(cornerRadius: 3).image
//            img.image = Toucan(image: pic).maskWithRoundedRect(cornerRadius: 3).image
            return img
        }()
        
        // 添加label
        let label: UILabel! = {
            let label = UILabel(frame: CGRect(x:0, y:162, width:cell.frame.width, height:40))
            label.text = items[indexPath.row]["title"].stringValue
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines=2
            return label
        }()
        let detaillabel: UILabel! = {
            let label = UILabel(frame: CGRect(x:0, y:200, width:cell.frame.width, height:14))
            label.text = listitems[indexPath.row]
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 12)
            return label
        }()
        
        cell.addSubview(img)
        cell.addSubview(label)
        cell.addSubview(detaillabel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item as Int
//        print("\(songlist[index])")
        if let delegate = self.delegate {
            delegate.viewController?(viewController: self, popWithValue: songlist[index])
        }
        
        navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}





