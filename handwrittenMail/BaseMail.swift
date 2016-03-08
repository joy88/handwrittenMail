//
//  BaseMail.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/7.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import Foundation

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
class mailFolder:NSObject
{
    //文件夹名称
    var folderName:String="temp";
    //文件夹中的邮件数据
    var mailCount:Int32=0;
}
//刷新表中数据
protocol RefreshMailDataDelegate
{
    func RefreshData(objData:AnyObject?);
}

protocol MailOperation {
    //获取邮件目录
    func getMailFolder()->[mailFolder];
    //获取邮件列表
    func getMailList(folder:String)->[String];
    //获取邮件信息
    func getMail(mailid:String)->String;

}

class BaseMail : NSObject, MailOperation {
    //邮件连接Session,需要在init中初始化
    var mailconnection:NSObject?;
    //邮件是否可以连接
    var isCanBeConnected:Bool=false;
    
    var delegate:RefreshMailDataDelegate?;
    

    init(_ maillogininfo:mailLoginInfo) {
        self.mailconnection=nil;//NSObject();
    }
    //获取邮件目录
    func getMailFolder()->[mailFolder]
    {
        return [mailFolder]();
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
