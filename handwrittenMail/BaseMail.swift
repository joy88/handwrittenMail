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
class mailLoginInfo
{
    //imap
    var hostname:String = "smtp.exmail.qq.com";
    var port:UInt32 = 587;
    var username:String = "hello@qq.com";
    var password:String = "passward";
    var connectionType:MCOConnectionType = .TLS//.StartTLS
    
    var useOauth:Bool=false;
    var fetchFullMsg:Bool=false;
    
    //smtp
    var smtphostname:String = "smtp.exmail.qq.com";
    var smtpport:UInt32 = 587;
    var smtpusername:String = "hello@qq.com";
    var smtppassword:String = "passward";
    
    var nicklename:String="stone"//发信时用的呢称
    
}
//MARK:邮件目录类定义
class MAILFOLDER
{
    var folderNameAlias:String="Loading...";//文件夹名称
    var folderInfo=MCOIMAPFolder();//文件夾源数据
    var messageCount="";//邮件数量

}

//刷新邮件目录信息中数据
protocol RefreshMailDataDelegate
{
    func RefreshMailFolderData(objData:[MAILFOLDER]);//更新邮件目录
    func RefreshMailFolderMsgCount(mailFolder:MCOIMAPFolder,msgCount:Int);//更新目录下的邮件数量
}

//刷新邮件列表信息
protocol RefreshMailListDataDelegate
{
    //刷新邮件列表
    func RefreshMailListData(objData:[MCOIMAPMessage],upFresh:Bool);
    //更新邮件列表状态
    func setupStatus(status:String);
}

//刷新邮件列表信息
protocol RefreshMailDelegate
{
    //这个方法更简单
    func RefreshMailData(session:MCOIMAPSession,mailid:MCOIMAPMessage,folder:String);
  

}



protocol MailOperation {
    //获取邮件目录
    func getMailFolder();
    //获取邮件列表
    func getMailList(folder:String,delegate:RefreshMailListDataDelegate,upFresh:Bool);
    //获取邮件信息
    func getMail(mailid:MCOIMAPMessage, delegateMail:RefreshMailDelegate)
}

class BaseMail : NSObject, MailOperation {
    //MARK:邮件连接Session,需要在init中初始化
    var mailconnection:NSObject?;
    //MARK:邮件是否可以连接
    var isCanBeConnected:Bool=false;
    
    var deleteFolder="";
    var draftFolder="草稿箱";
    
    var delegate:RefreshMailDataDelegate?;
    
    var mailFolderName="INBOX";//当前邮件目录
    
    var messageStart:Int32=0;//MARK:当前已加载的邮件起始位置
    var messageEnd:Int32=0;//MARK:当前已加载的邮件结束位置
    var messageCount:Int32=0//MARK:邮件数量
   
    

    init(_ maillogininfo:mailLoginInfo) {
        self.mailconnection=nil;//NSObject();
    }
    //MARK:获取邮件目录
    func getMailFolder()
    {
    }
    //MARK:获取邮件列表
    func getMailList(folder:String,delegate:RefreshMailListDataDelegate,upFresh:Bool)
    {
        
    }

    //MARK:获取邮件信息
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


