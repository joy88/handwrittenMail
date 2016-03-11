//
//  BaseMail.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/7.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import Foundation
import UIKit

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

//刷新邮件列表信息
protocol RefreshMailDelegate
{
    func RefreshMailData(mailid:MCOIMAPMessage,htmlContent:String)
}



protocol MailOperation {
    //获取邮件目录
    func getMailFolder()->MAILFOLDERS;
    //获取邮件列表
    func getMailList(folder:String,delegate:RefreshMailListDataDelegate);
    //获取邮件信息
    func getMail(mailid:MCOIMAPMessage, delegateMail:RefreshMailDelegate)
}

class BaseMail : NSObject, MailOperation {
//    var mailFolders:MAILFOLDERS?;//邮件目录
    //邮件连接Session,需要在init中初始化
    var mailconnection:NSObject?;
    //邮件是否可以连接
    var isCanBeConnected:Bool=false;
    
    var delegate:RefreshMailDataDelegate?;
    
    var mailFolderName="INBOX";//当前邮件目录
    
    

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
func getMail(mailid:MCOIMAPMessage, delegateMail:RefreshMailDelegate)
{

    }

 }


extension UILabel
{
    //代码创建UILabel
    func setLabel(label:String,x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat,fonSize:CGFloat,isBold:Bool,color:UIColor)
    {
        self.frame = CGRectMake(x,y,width,height);
        
        //给label 设值
        
        self.text = label;
        
        //设置是否默认换行
        
        
        self.numberOfLines = 0
        
        //设置label的背景颜色
        
        
        self.backgroundColor = UIColor.whiteColor();
        
        //设置label的文本信息展示样式，
        
        self.textAlignment = NSTextAlignment.Left
        
        //设置label的字体
        
        
        if isBold
        {
            self.font = UIFont.boldSystemFontOfSize(fonSize)
            
        }
        else
        {
            self.font = UIFont.systemFontOfSize(fonSize)
            
        }
        
        
        
        //设置label的文本颜色
        
        
        
        self.textColor = color;
        
    }
    
    
}

class UIEmailButton:UIButton
{
    var mailAddress=MCOAddress();//邮件地址
//    var emailAddress:String="";//电子邮件地址
    //代码创建UIButton,返回自适应后的新宽度,不允许改变高度
    
    func setEmailTitle(email:MCOAddress,x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat,fonSize:CGFloat,isBold:Bool,color:UIColor)->CGFloat//返回自适应的宽度
    {
        self.mailAddress=email;
        
        let emailAddress=mailAddress.mailbox;//邮件地址
        
        var newwidth=width;
        //给label 设值
        var btnTitle:String="";

        if mailAddress.displayName==nil
        {
        //提取出邮件地址@之前的信息供显示
            let range=emailAddress.rangeOfString("@", options: NSStringCompareOptions())
        
        
        if range != nil
        {
            let startIndex=range?.startIndex //=3
            
            btnTitle=emailAddress.substringToIndex(startIndex!);
            
            
        }
        else
        {
            btnTitle=emailAddress;
        }
        }
        else
        {
            btnTitle=mailAddress.displayName;
        }
        
        btnTitle=btnTitle+">";
        
        self.setTitle(btnTitle, forState: .Normal)
        
        //设置button的背景颜色
        
        
        self.backgroundColor = UIColor.whiteColor();
        
        
        
        //设置button的字体
        
        
        if isBold
        {
            self.titleLabel?.font = UIFont.boldSystemFontOfSize(fonSize)
            
        }
        else
        {
            self.titleLabel?.font = UIFont.systemFontOfSize(fonSize)
            
        }
        
        
        //设置label的文本颜色
        
        self.setTitleColor(color
            , forState: .Normal) ;
        
        //设置label的文本信息展示样式，
        
        self.titleLabel!.textAlignment = NSTextAlignment.Center
        
        //根据内容确定Button宽度
        
        let attri = [ NSFontAttributeName : (self.titleLabel?.font)!]
        
        
        let titleSize = NSString(string: btnTitle).sizeWithAttributes(attri)
        
        
        newwidth=titleSize.width+5;
        
        self.frame = CGRectMake(x,y,newwidth,height);
        
        return newwidth;
        
    }
    
}


