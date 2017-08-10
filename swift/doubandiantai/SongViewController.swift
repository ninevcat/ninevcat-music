//
//  ViewController.swift
//  doubandiantai
//
//  Created by 秦昊 on 2017/7/4.
//  Copyright © 2017年 秦昊. All rights reserved.
//

import UIKit
import Accelerate
import MediaPlayer
import Toucan
import SwiftyJSON
import Kingfisher

class SongViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, ChannelViewControllerDelegate {
    
    var items:[JSON] = []
    
    // 声明一个媒体播放器的实例
//    var audioplayer: MPMoviePlayerController!
    
    var imageVwbg: UIImageView!
    var imageMask: UIImageView!
    var imageVwfw: UIImageView!
    var imageVwfn: UIImageView!
    
    var btnMenu: UIButton!
    
    var songDuration: UILabel!
    
    var ctrlView: UIView!
    
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        
        // MARK: - 初始化Image View
        // 初始化Image View(background)
        imageVwbg = {
            let image = UIImageView(frame: self.view.frame)
            image.contentMode = .scaleAspectFill
            image.clipsToBounds = true
            let bg = UIImage(named: "bgtest")?.gaussianBlur(blur: 0.1)
            image.image = bg
            return image
        }()
        
        // 初始化紫色遮罩
        imageMask = {
            let image = UIImageView(frame: self.view.frame)
            image.image = UIImage(named: "mask")
            return image
        }()
        
        
        // 初始化Image View(封面外圆)
        imageVwfw = {
            let image = UIImageView(frame: CGRect(x:115, y:38,width:self.view.bounds.size.width*145/375, height:self.view.bounds.size.height*145/667))
            // 增加边框颜色
            let imageVwfwup = Toucan(image: UIImage(named: "thumb")!).maskWithEllipse(borderWidth: 6, borderColor: UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 0.7)).image
            image.contentMode = .scaleAspectFill
            image.clipsToBounds = true
            image.image = imageVwfwup
            return image
        }()
        
        // 初始化Image View(封面内圆)
        imageVwfn = {
            let image = UIImageView(frame: CGRect(x:166, y:88,width:self.view.bounds.size.width*45/375, height:self.view.bounds.size.height*45/667))
            image.image = UIImage(named: "thumb_oval")
            image.alpha = 0.7
            return image
        }()
        
        
        // 初始化菜单按钮
        btnMenu = {
            let btn = UIButton(frame: CGRect(x:330, y:34,width:self.view.bounds.size.width*33/375, height:self.view.bounds.size.height*21/667))
            let icon = UIImage(named:"menu")?.withRenderingMode(.alwaysOriginal)
            // 设置图标
            btn.setImage(icon, for:.normal)
            // 添加点击方法
            btn.addTarget(self, action: #selector(gotoChannel(_:)), for: .touchUpInside)
            return btn
        }()
        
        
        // label音乐时长
        songDuration = {
            let label = UILabel(frame:CGRect(x:174, y:103, width:33, height:16))
            label.text = "00:00"
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 10)
            return label
        }()
        
        
        // MARK: -  初始化控制条
        ctrlView = {
            let view = UIView(frame:CGRect(x:0, y:221, width:self.view.bounds.size.width, height:54))
            view.backgroundColor = UIColor(red: 156/255, green: 169/255, blue: 232/255, alpha: 0.3)

            return view
        }()
        // 控制条的按钮
        //循环播放按钮
        let btnLoop: UIButton = {
            let btn = UIButton(frame:CGRect(x:28, y:12, width:32, height:32))
            let onIcon = UIImage(named:"looponIcon")?.withRenderingMode(.alwaysOriginal)
            let offIcon = UIImage(named:"loopoffIcon")?.withRenderingMode(.alwaysOriginal)
            //设置图标
            btn.setImage(offIcon, for:.normal)
            btn.setImage(onIcon, for:.highlighted)
            // 添加点击方法
            btn.addTarget(self, action: #selector(loopbtnAct(_:)), for: .touchUpInside)
            return btn
        }()
        // 上一首按钮
        let btnPrev: UIButton = {
            let btn = UIButton(frame:CGRect(x:100, y:12, width:32, height:32))
            let icon = UIImage(named:"prevIcon")?.withRenderingMode(.alwaysOriginal)
            //设置图标
            btn.setImage(icon, for:.normal)
            // 添加点击方法
            btn.addTarget(self, action: #selector(prevbtnAct(_:)), for: .touchUpInside)
            return btn
        }()
        // 播放暂停按钮
        let btnPlayMode: UIButton = {
            let btn = UIButton(frame:CGRect(x:164, y:5, width:46, height:46))
            let onIcon = UIImage(named:"playIcon")?.withRenderingMode(.alwaysOriginal)
            let offIcon = UIImage(named:"pauseIcon")?.withRenderingMode(.alwaysOriginal)
            //设置图标
            btn.setImage(offIcon, for:.normal)
            btn.setImage(onIcon, for:.highlighted)
            // 添加点击方法
            btn.addTarget(self, action: #selector(playbtnAct(_:)), for: .touchUpInside)
            return btn
        }()
        // 下一首按钮
        let btnNext: UIButton = {
            let btn = UIButton(frame:CGRect(x:244, y:12, width:32, height:32))
            let icon = UIImage(named:"nextIcon")?.withRenderingMode(.alwaysOriginal)
            //设置图标
            btn.setImage(icon, for:.normal)
            // 添加点击方法
            btn.addTarget(self, action: #selector(nextbtnAct(_:)), for: .touchUpInside)
            return btn
        }()
        // 随机播放按钮
        let btnRanm: UIButton = {
            let btn = UIButton(frame:CGRect(x:316, y:12, width:32, height:32))
            let onIcon = UIImage(named:"ranmonIcon")?.withRenderingMode(.alwaysOriginal)
            let offIcon = UIImage(named:"ranmoffIcon")?.withRenderingMode(.alwaysOriginal)
            //设置图标
            btn.setImage(offIcon, for:.normal)
            btn.setImage(onIcon, for:.highlighted)
            // 添加点击方法
            btn.addTarget(self, action: #selector(ranmbtnAct(_:)), for: .touchUpInside)
            return btn
        }()
        // 进度条
        let progressBar: UIView = {
            let view = UIView(frame:CGRect(x:0, y:0.5, width:self.view.bounds.size.width, height:2))
            view.backgroundColor = UIColor(red: 107/255, green: 123/255, blue: 212/255, alpha: 1.0)
            
            return view
        }()
        ctrlView.addSubview(progressBar)
        ctrlView.addSubview(btnLoop)
        ctrlView.addSubview(btnPrev)
        ctrlView.addSubview(btnPlayMode)
        ctrlView.addSubview(btnNext)
        ctrlView.addSubview(btnRanm)
        
        
        // MARK: -  初始化tableView
        tableView = {
            let table = UITableView(frame: CGRect(x:0, y:275,width:self.view.bounds.size.width, height:392))
            table.delegate = self
            table.dataSource = self
//            table.bounces = false
            // 创建一个重用的单元格
            table.register(UITableViewCell.self, forCellReuseIdentifier: "SongList")
            table.rowHeight = 44
            //自适应高度
            //table.rowHeight = UITableViewAutomaticDimension
            // 去除多余的单元格
            table.tableFooterView = UIView()
            // 去除滚动条
            table.showsVerticalScrollIndicator = false
            // 设置分割线的颜色和内边距
            table.separatorColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 0.6)
            table.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
            // 设置cell的背景色为透明
            table.backgroundColor = UIColor.clear;
            
            return table
            
        }()
        
        self.view.addSubview(self.imageVwbg!)
        self.view.addSubview(self.imageMask!)
        self.view.addSubview(self.btnMenu!)
        self.view.addSubview(self.imageVwfw!)
        self.view.addSubview(self.imageVwfn!)
        self.view.addSubview(self.songDuration!)
        self.view.addSubview(self.tableView!)
        self.view.addSubview(self.ctrlView!)
        
        
        
        //httpGet(songhref)
    }
    
    func gotoChannel(_ button:UIButton){
        let vc = ChannelViewController()
        //设置代理
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func loopbtnAct(_ button:UIButton){
        
    }
    
    func prevbtnAct(_ button:UIButton){
        
    }
    func playbtnAct(_ button:UIButton){
        
    }
    func nextbtnAct(_ button:UIButton){
        
    }
    func ranmbtnAct(_ button:UIButton){
        
    }
    
    // 获取网络数据
    func httpGet(_ href:String){
        Network.AnalyzeGet(href, params: nil) { (Json, status) in
            if status == "0"{
                if Json["data"].arrayValue.count > 0{
                    self.items = Json["data"].arrayValue
                    let url = self.items[0]["album"]["picUrl"].stringValue
                    self.analyzepicUrl(url)
                }else {
                    let dic:[String:Any] = [
                        "album":[
                            "picUrl": "http://upload-images.jianshu.io/upload_images/1709268-457fc56daaeb20f7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240"
                            ]
                        ,
                        "artists": [
                            ["name": "----"]
                        ],
                        "name":"电台节目"
                    ]
                    self.items = [JSON(dic)]
                    let url = self.items[0]["album"]["picUrl"].stringValue
                    self.analyzepicUrl(url)
                }
                self.tableView.reloadData()
                self.tableView.setContentOffset(CGPoint.zero,  animated: true)
            }
        }
        
    }
    // MARK:- 处理网络图片 -
    func analyzepicUrl(_ url:String){
        let rowData = URL(string: url)
        self.imageVwbg.kf.setImage(with: rowData, placeholder: nil, options: nil, progressBlock: nil) { (image, error, type, url) in
            self.setfwPic(image!)
        }
        self.imageVwfw.kf.setImage(with: rowData, placeholder: nil, options: nil, progressBlock: nil) { (image, error, type, url) in
            self.setbgPic(image!)
        }
    }
    
    // MARK:- ChannelViewControllerDelegate -
    func viewController(viewController: ChannelViewController, popWithValue: String) {
        httpGet(popWithValue)
    }
    
    
    // MARK:- 设置背景及封面 -
    func setbgPic(_ bg:UIImage){
        let resizedImage = Toucan(image: bg).resize(CGSize(width: 145, height: 145), fitMode: Toucan.Resize.FitMode.crop).image
        let resizedAndMaskedImage =  Toucan(image: resizedImage).maskWithEllipse(borderWidth: 6, borderColor: UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 0.7)).image
        self.imageVwfw.image = resizedAndMaskedImage
    }
    func setfwPic(_ img:UIImage){
        self.imageVwbg.image = img.gaussianBlur(blur: 0.1)
    }
    
    // MARK:- tableViewDelegate -
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell{
            let identifier = "SongList"
            //        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as UITableViewCell
            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle,reuseIdentifier: identifier)
            // 设置单元格的样式
            let label: UILabel = {
                let label = UILabel(frame: CGRect(x:70, y:3, width:cell.frame.width-70, height:25))
                label.text = items[indexPath.row]["name"].stringValue
                label.textColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 0.6)
                label.highlightedTextColor = .white
                return label
            }()
            let detaillabel: UILabel = {
                let label = UILabel(frame: CGRect(x:70, y:22, width:cell.frame.width-70, height:20))
                if items[indexPath.row]["artists"].arrayValue.count > 0{
                    label.text = items[indexPath.row]["artists"][0]["name"].stringValue
                }
                label.textColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 0.5)
                label.highlightedTextColor = .white
                label.font = UIFont.systemFont(ofSize: 12)
                return label
            }()
            let img: ImageView  = {
                let img = ImageView(frame: CGRect(x:15, y:2, width:40, height:40))
                let url = URL(string: items[indexPath.row]["album"]["picUrl"].stringValue)
                img.kf.setImage(with: url)
                return img
            }()
            // 默认背景透明
            cell.backgroundColor = UIColor.clear
            // 选中背景修改成紫色
            cell.selectedBackgroundView = UIView()
            cell.selectedBackgroundView?.backgroundColor = UIColor(red: 156/255, green: 169/255, blue: 232/255, alpha: 1.0)
            
            cell.addSubview(img)
            cell.addSubview(label)
            cell.addSubview(detaillabel)
            return cell
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 点击后播放音乐
        let index = indexPath.row as Int
        let url = items[index]["album"]["picUrl"].stringValue
        analyzepicUrl(url)
        // 点击cell高亮后消失
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: UImage

extension UIImage{
    //增加模糊的效果（需要添加Accelerate.Framework）
    func gaussianBlur(blur:Double) ->UIImage{
        var blurAmount = blur
        //高斯模糊参数(0-1)之间，超出范围强行转成0.5
        if(blurAmount < 0.0||blurAmount > 1.0) {
            blurAmount = 0.5
        }
        var boxSize = Int(blurAmount * 40)
        boxSize = boxSize - (boxSize % 2) + 1
        let img = self.cgImage
        var inBuffer = vImage_Buffer()
        var outBuffer = vImage_Buffer()
        let inProvider = img!.dataProvider
        let inBitmapData = inProvider!.data
        inBuffer.width = vImagePixelCount(img!.width)
        inBuffer.height = vImagePixelCount(img!.height)
        inBuffer.rowBytes = img!.bytesPerRow
        inBuffer.data = UnsafeMutableRawPointer(mutating:CFDataGetBytePtr(inBitmapData))
        
        //手动申请内存
        let pixelBuffer = malloc(img!.bytesPerRow * img!.height)
        outBuffer.width = vImagePixelCount(img!.width)
        outBuffer.height = vImagePixelCount(img!.height)
        outBuffer.rowBytes = img!.bytesPerRow
        outBuffer.data = pixelBuffer
        var error = vImageBoxConvolve_ARGB8888(&inBuffer,
                                              &outBuffer,nil,vImagePixelCount(0),vImagePixelCount(0),
                                              UInt32(boxSize),UInt32(boxSize),nil,vImage_Flags(kvImageEdgeExtend))
        if(kvImageNoError != error){
            error = vImageBoxConvolve_ARGB8888(&inBuffer,
                                               &outBuffer,nil,vImagePixelCount(0),vImagePixelCount(0),
                                               UInt32(boxSize),UInt32(boxSize),nil,vImage_Flags(kvImageEdgeExtend))
            if(kvImageNoError != error){
                error = vImageBoxConvolve_ARGB8888(&inBuffer,                                                   &outBuffer,nil,vImagePixelCount(0),vImagePixelCount(0),UInt32(boxSize),UInt32(boxSize),nil,vImage_Flags(kvImageEdgeExtend))
            }
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(data: outBuffer.data,
                            width:Int(outBuffer.width),
                            height:Int(outBuffer.height),
                            bitsPerComponent:8,
                            bytesPerRow: outBuffer.rowBytes,
                            space: colorSpace,
                            bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)
        let imageRef = ctx!.makeImage()
        //手动申请内存
        free(pixelBuffer)
        
        return UIImage(cgImage: imageRef!)
        
    }
    
}
