//
//  Network.swift
//  HTInspection
//
//  Created by 烨南张 on 16/9/26.
//  Copyright © 2016年 YeNan. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

//封装的AFNetworking和Alamofire解析方法
struct Network {
    
    private static func AnalyzeHttp(_ method: HTTPMethod, url:String, params:[String:Any]?, contentType:[String]? = nil,  block:@escaping ((_ Json:JSON,_ status:String)->Void)){
        
        let URL = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) ?? url
        
        var request = Alamofire.request(URL, method: method, parameters: params)
        
        if contentType != nil{
            request = request.validate(contentType: contentType!)
        }

        request.responseJSON { (response) in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    block(json,"0")
                }else{
                    block("接口数据错误","-1")
                }
            case .failure(let error):
                block(["Status":"-1","error":error.localizedDescription],"-1")
            }
            
        }
        
    }
    
    //post解析方法
    static func AnalyzePost(_ url:String, params:[String:Any]?, contentType:[String]? = nil, block:@escaping ((_ Json:JSON,_ status:String)->Void)){
        
        self.AnalyzeHttp(.post, url: url, params: params, contentType: contentType, block: block)
    
    }
    
    //get解析方法
    static func AnalyzeGet(_ url:String, params:[String:Any]?, contentType:[String]? = nil, block:@escaping ((_ Json:JSON,_ status:String)->Void)){

         self.AnalyzeHttp(.get, url: url, params: params, contentType: contentType, block: block)
    }
    
    
    //测试用方法
    static func AnalyzeText(_ url:String){
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
}
