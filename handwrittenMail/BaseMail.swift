//
//  BaseMail.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/7.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import Foundation

extension Dictionary
{
    func getKeyValueOfIndex(index:Int)->[String]
    {
//        assert(index<self.count);
        
        let tempValue=Array(self.keys)[index];
        
        var str=["temp","temp"];
        
        str[0]="\(tempValue)";
        str[1]="\(self[tempValue]!)"
        
        return str;
        
    }
}
//邮件登录所需要的头信息
struct mailLoginInfo
{
    var hostname:String = "smtp.exmail.qq.com";
    var port:UInt32 = 587;
    var username:String = "hello@qq.com";
    var password:String = "passward";
    var connectionType:MCOConnectionType = .TLS//.StartTLS
}
//邮件目录
typealias MAILFOLDERS = Dictionary<String,Int32>;//文件夹名称，邮件数量

//class mailFolder:NSObject
//{
//    var mailfloder:Dictionary<String,Int32>=["temp",]
//    //文件夹名称
//    var folderName:String="temp";
//    //文件夹中的邮件数据
//    var mailCount:Int32=0;
//}
//刷新表中数据
protocol RefreshMailDataDelegate
{
    func RefreshMailFolderData(objData:MAILFOLDERS);
}

protocol MailOperation {
    //获取邮件目录
    func getMailFolder()->MAILFOLDERS;
    //获取邮件列表
    func getMailList(folder:String)->[String];
    //获取邮件信息
    func getMail(mailid:String)->String;

}

class BaseMail : NSObject, MailOperation {
//    var mailFolders:MAILFOLDERS?;//邮件目录
    //邮件连接Session,需要在init中初始化
    var mailconnection:NSObject?;
    //邮件是否可以连接
    var isCanBeConnected:Bool=false;
    
    var delegate:RefreshMailDataDelegate?;
    

    init(_ maillogininfo:mailLoginInfo) {
        self.mailconnection=nil;//NSObject();
    }
    //获取邮件目录
    func getMailFolder()->MAILFOLDERS
    {
        return MAILFOLDERS();
    }
    //获取邮件列表
    func getMailList(folder:String)->[String]
    {
        return [String]();
    }

    //获取邮件信息
    func getMail(mailid:String)->String
    {
        return "";
    }

 }
