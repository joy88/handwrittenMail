//
//  BaseMail.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/7.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import Foundation

struct EmailInfo //邮件头信息
{
    var mailId=String();// = [NSString stringWithFormat:@"%d",msg.uid];
    var subject=String();// = [self stringReplaceNil:msg.header.subject];
    var name=String();//= [self stringReplaceNil:(msg.header.from.displayName?msg.header.from.displayName:[self mailBox2Display:msg.header.from.mailbox])];
    var sendTime=NSDate();//= [self stringReplaceNil:[self dateFormatString:msg.header.receivedDate]];
    var attach = Int();// msg.attachments.count;
}


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
typealias MAILFOLDERS = Dictionary<String,mailFolderMeta>;//文件夹名称，邮件数量

struct mailFolderMeta
{
    var folderName:String="Loading...";//文件夹名称
    var mailCount:Int32=0;//已读邮件数量
    //未读邮件数量
    var unreadMailCount:Int32=0;
    //文件夹标志
    var folderFlag=MCOIMAPFolderFlag.None;
}
//刷新邮件目录信息中数据
protocol RefreshMailDataDelegate
{
    func RefreshMailFolderData(objData:MAILFOLDERS);
}

//刷新邮件列表信息
protocol RefreshMailListDataDelegate
{
    func RefreshMailListData(objData:[MCOIMAPMessage]);
}


protocol MailOperation {
    //获取邮件目录
    func getMailFolder()->MAILFOLDERS;
    //获取邮件列表
    func getMailList(folder:String,delegate:RefreshMailListDataDelegate);
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
    func getMailList(folder:String,delegate:RefreshMailListDataDelegate)
    {
        
    }

    //获取邮件信息
    func getMail(mailid:String)->String
    {
        return "";
    }

 }
