//
//  BaseFunction.swift
//  MyDiaryForEvernote
//
//  Created by shiweiwei on 16/2/26.
//  Copyright © 2016年 shiww. All rights reserved.
//

import Foundation

class BaseFunction:NSObject
{
    //返回国际化字符串
    static func getIntenetString(key:String)->String{
        let string=NSLocalizedString(key,comment:"");
//        print("key=\(key),string=\(string)");
        return string;
    }

}
