//
//  TextMailComposerViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/4/5.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit
import RichEditorView

class TextMailComposerViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var detailViewController:DetailViewController?;//父窗口
    var oldMailContent:String?;//待编辑的老邮件
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorOptions.all()
        return toolbar
    }()
    
    var imapsession:MCOIMAPSession?//imap session
    
    var mailContentTemplate="";//邮件正文模板
    
    var mailTo=[MCOAddress]();//MARK:收件人
    var mailCc=[MCOAddress]();//MARK:抄送
    var mailTopic="";//MARK:邮件主题模板
    var mailOrign:UIImage?;//MARK:邮件原文,转发或回复时有用
    var mailHtmlbodyOrigin:String?//MARK:邮件HTML原文，转发或回复时有用
    var mailOriginAttachments:[MCOAttachment]?//MARK:邮件附件，转发时有用
    var mailOriginRelatedAttachments:[MCOAttachment]?//MARK:邮件releated附件，正文中的图片转发时有用
    
    private var mailToolBar=UIToolbar();//工具条窗口
    
    private var mailHeaderView:UIView=UIView();//收件人都录入窗口
    private var mailToLbl:UILabel=UILabel();//收件人地址标签
    var mailToInputText=ACTextArea();//收件人地址录入窗口
    private var mailCcLbl=UILabel();//抄送人地址标签
    var mailCcInputText=ACTextArea();//抄送人地址录入窗口
    private var mailTopicLbl=UILabel();//邮件主题标签
    var mailTopicInputText=UITextField();//邮件主题录入窗口;
    var mailComposerView=RichEditorView();//邮件内容录入窗口
    var Line1=UILabel();//分割线
    var Line2=UILabel();//分割线
    var Line3=UILabel();//分割线



    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor=UIColor.whiteColor();
        
        let viewWidth=self.preferredContentSize.width;

        self.AutoLayoutMailComposerView(0, startY: 0, frameWidth: viewWidth)
        
        //加载邮件头信息
        self.loadMailHeader();
        //加载转发时的原邮件信息\
//        self.mailComposerView.setHTML(self.buildMessageHtmlBody())
        
        

        
        
        // Do any additional setup after loading the view, typically from a nib.
        mailComposerView.delegate = self
        mailComposerView.inputAccessoryView = toolbar
        
        toolbar.delegate = self
        toolbar.editor = mailComposerView
        toolbar.options=[
            RichEditorOptions.Clear,
            RichEditorOptions.Undo, RichEditorOptions.Redo, RichEditorOptions.Bold, RichEditorOptions.Italic,
            RichEditorOptions.Strike, RichEditorOptions.Underline,
            RichEditorOptions.TextColor, RichEditorOptions.TextBackgroundColor,
            RichEditorOptions.Header(1), RichEditorOptions.Header(2), RichEditorOptions.Header(3), RichEditorOptions.Header(4), RichEditorOptions.Header(5),RichEditorOptions.Header(6),
            RichEditorOptions.Indent, RichEditorOptions.Outdent, RichEditorOptions.OrderedList, RichEditorOptions.UnorderedList,
            RichEditorOptions.AlignLeft, RichEditorOptions.AlignCenter, RichEditorOptions.AlignRight, RichEditorOptions.Image
        ]
        
        mailComposerView.setPlaceholderText("在此输入邮件正文")
        mailComposerView.setTextColor(UIColor.blackColor());
        mailComposerView.scrollEnabled=true;
        mailComposerView.clipsToBounds=true;
        
      }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK:发邮件地址录入窗口自动布局
    private func AutoLayoutMailComposerView(startX:CGFloat,startY:CGFloat,frameWidth:CGFloat)
    {
 
        self.mailHeaderView.addSubview(mailToLbl);
        self.mailHeaderView.addSubview(mailToInputText);
        
        
        self.mailHeaderView.addSubview(mailCcLbl);
        
        self.mailHeaderView.addSubview(mailCcInputText);
        
        self.mailHeaderView.addSubview(mailTopicLbl);
        
        self.mailHeaderView.addSubview(mailTopicInputText);
        
        self.mailHeaderView.addSubview(Line1);//分割线
        self.mailHeaderView.addSubview(Line2);//分割线
        self.mailHeaderView.addSubview(Line3);//分割线

        
        
        let xSpace:CGFloat=10;//水平方向间隔
        let ySpace:CGFloat=10;//水平方向简隔
        let marginSpace:CGFloat=10;//左右两侧距边界的空白
        
        let ctrHight:CGFloat=25;//标准控件高度
        let ctrWidth:CGFloat=60;//标准控件宽度
        
        let blue=UIColor.blueColor();
        let gray=UIColor.lightGrayColor();
        
        var top0,top1,top2,top3,top4,top5:CGFloat;
        
//        private var mailToolBar=UIToolbar();//工具条窗口
        self.mailHeaderView.addSubview(mailToolBar);
        top0=ySpace;

        
        mailToolBar.frame=CGRectMake(0, startY,frameWidth,44);

        
        let cancelbutton = UIBarButtonItem(title: "取消", style:UIBarButtonItemStyle.Plain,target: self,action: #selector(TextMailComposerViewController.doCloseMailComposer(_:)))
        
        let flexButton1=UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.FlexibleSpace, target: self,action: nil)
        let titlebutton = UIBarButtonItem(title: "新邮件", style: UIBarButtonItemStyle.Plain, target: self,action: nil)
        
        titlebutton.tintColor=UIColor.blackColor();
        
        let flexButton2=UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.FlexibleSpace, target: self,action: nil)

        let sendbutton = UIBarButtonItem(title: "发送", style: UIBarButtonItemStyle.Plain, target: self,action: #selector(TextMailComposerViewController.doSendMail))

        
        let items=[cancelbutton,flexButton1,titlebutton,flexButton2,sendbutton];
       
        mailToolBar.setItems(items, animated: true)

        
        top1=top0+44+ySpace;
        
        //        private var mailToLbl:UILabel=UILabel();//收件人地址标签
        mailToLbl.setLabel("收件人:", x:marginSpace, y: top1, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: true, color: gray)
        mailToLbl.textAlignment = .Right
        
        //        var mailToInputText=ACTextArea();//收件人地址录入窗口
        mailToInputText.setTextArea((marginSpace+ctrWidth+xSpace), y: top1, width: frameWidth-ctrWidth-2*xSpace-marginSpace, height: ctrHight*2, fonSize: 16, isBold: true, color: blue,hasBorder: false);
        

        
        //        private var mailCcLbl=UILabel();//抄送人地址标签
        top2=top1+ctrHight*2+ySpace
        
        //第一条分割线
        Line1.text="";
        Line1.backgroundColor=UIColor.lightGrayColor();
        Line1.frame=CGRectMake(marginSpace, top2-ySpace+1, frameWidth-2*marginSpace, 1);

        
        mailCcLbl.setLabel("抄送:", x: marginSpace, y: top2, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: false, color: gray);
        mailCcLbl.textAlignment = .Right

        
        //        var mailCcInputText=ACTextArea();//抄送人地址录入窗口
        mailCcInputText.setTextArea((marginSpace+ctrWidth+xSpace), y: top2, width: frameWidth-ctrWidth-2*xSpace-marginSpace, height: ctrHight*2, fonSize: 17, isBold: true, color: blue,hasBorder: false);
        
        
        
        //        private var mailTopicLbl=UILabel();//邮件主题标签
        top3=top2+ySpace+ctrHight*2;
        
        //第二条分割线
        Line2.text="";
        Line2.backgroundColor=UIColor.lightGrayColor();
        Line2.frame=CGRectMake(marginSpace, top3-ySpace+1, frameWidth-2*marginSpace, 1);

        
        mailTopicLbl.setLabel("主题:", x: marginSpace, y: top3, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: false, color: gray);
        mailTopicLbl.textAlignment = .Right
        
        
        //        var mailTopicInputText=UITextField();//邮件主题录入窗口;
        mailTopicInputText.frame = CGRectMake((marginSpace+ctrWidth+xSpace), top3, frameWidth-ctrWidth-marginSpace*2-xSpace, ctrHight);
        
        mailTopicInputText.borderStyle=UITextBorderStyle.None

/*        mailTopicInputText.backgroundColor=white;
        mailTopicInputText.layer.borderWidth = 1;
        mailTopicInputText.layer.borderColor = gray.CGColor;
        mailTopicInputText.layer.cornerRadius = 4*/
     //   mailTopicInputText.textColor=UIColor.lightGrayColor();
        mailTopicInputText.clearButtonMode = .WhileEditing;

        
        
        //        private var mailComposerView:UIView=UIView();//收件人都录入窗口
        
        top4=top3+ySpace+ctrHight;
        
        //第三条分割线
        Line3.text="";
        Line3.backgroundColor=UIColor.lightGrayColor();
        Line3.frame=CGRectMake(marginSpace, top4-ySpace+1, frameWidth-2*marginSpace, 1);

        
        self.mailHeaderView.frame=CGRectMake(startX,startY,frameWidth, top4);
        
/*        mailHeaderView.layer.borderWidth = 1;
        mailHeaderView.layer.borderColor = blue.CGColor;
        
        mailHeaderView.layer.cornerRadius = 8
        mailHeaderView.layer.masksToBounds=true;
        
        mailHeaderView.backgroundColor=white;*/
        
        self.view.addSubview(mailHeaderView);
        mailHeaderView.hidden=false;

        
        top5=top4+5;
        
        self.view.addSubview(self.mailComposerView);
        
        let viewHeight=self.preferredContentSize.height;
        
        self.mailComposerView.frame=CGRectMake(startX+xSpace,top5,frameWidth-2*xSpace, viewHeight-top5-ySpace);
        
        /*
       mailComposerView.layer.borderWidth = 1;
       mailComposerView.layer.borderColor = gray.CGColor;*/
        
        mailComposerView.hidden=false;


       
    }
    
    //MARK:发送邮件
    func doSendMail()
    {
        //发送邮件
        let smtpSession=MCOSMTPSession();
        
        let smtpinfo=self.loadMailLoginInfo();
        smtpSession.hostname = smtpinfo.smtphostname;
        smtpSession.port = smtpinfo.smtpport;
        smtpSession.username = smtpinfo.smtpusername;
        smtpSession.password = smtpinfo.smtppassword;
        
        smtpSession.connectionType = MCOConnectionType.TLS;
        
        //连接时输出日志
  /*
                smtpSession.connectionLogger =
         {
         
         (connectionID, type, data)->Void in
         
         if data != nil
         {
         let strtemp=NSString(data: data, encoding:NSUTF8StringEncoding);
         
         print(strtemp);
         }
         }*/
        

        
        let smtpOperation = smtpSession.loginOperation();
        //发送邮件
        self.setSendButtonEnable(false);
        
        smtpOperation.start()
            {
                (error:NSError?)->Void in
                
                if (error == nil) {
                    // 构建邮件体的发送内容
                    var messageBuilder = MCOMessageBuilder();
                    messageBuilder.header.from = MCOAddress(displayName: smtpinfo.nicklename, mailbox:smtpinfo.smtpusername);   // 发送人
                    
                    var canSendMail=true;//是否符合发邮件的条件
                    
                    let mailTo=self.mailToInputText.getEmailLists();
                    
                    if mailTo.count==0
                    {
                        canSendMail=false;
                    }
                    
                    
                    messageBuilder.header.to=mailTo;       // 收件人（多人）
                    
                    let mailCc=self.mailCcInputText.getEmailLists();
                    
                    messageBuilder.header.cc = mailCc;      // 抄送（多人）
                    if self.mailTopicInputText.text==""
                    {
                        canSendMail=false;
                        
                    }
                    messageBuilder.header.subject = self.mailTopicInputText.text  // 邮件标题
                    if !canSendMail
                    {
                        self.ShowNotice("警告", "发送地址或邮件主题是否为空!");
                        //恢复发送按钮状态
                        self.setSendButtonEnable(true);
                        
                        return;//不能发送邮件了
                    }
                    
                    var htmlBody="<html><body><div></div>"//<div><img src=\"cid:123\"></div></body></html>";
                    
                    htmlBody=htmlBody+self.mailComposerView.getHTML();
                    
                    //需要处理一下HTML中添加的图片
                    TextMailComposerViewController.wrapLocalImgHtml(self.mailComposerView.webView, webHtml: &htmlBody, messageBuilder: &messageBuilder)
                    //处理完毕
                    
                    //如果是以图片形式回复或转发邮件,则需要把老邮件附件-图片格式
                    if self.mailOrign != nil
                    {
                        
                        var tempHtmlbody = "<br/><p>以下是原邮件内容</p><br/>";
                        
                        let path = NSBundle.mainBundle().pathForResource("forwadmailhead", ofType:"html");
                        if path != nil
                        {
                            do {
                                tempHtmlbody = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding);
                            }
                            catch let error as NSError {
                                print(error.localizedDescription)
                            }
                            
                            
                        }
                        
                        htmlBody=htmlBody+tempHtmlbody;
                        
                        
                        
 
                        let uuid = NSUUID().UUIDString;//必须要确保文件名唯一
                        
                        let cid="cngis-"+uuid;
                        
                        htmlBody=htmlBody+"<div><img src=\"cid:"+cid+"\"></div>";
                        
                        
                        let attachment=MCOAttachment(data: UIImagePNGRepresentation(self.mailOrign!), filename: "originMail.png");
                        attachment.contentID=cid;
                        messageBuilder.addRelatedAttachment(attachment);
                    }
                    //老邮件添加完毕
                    
                    //老邮件，htmlbody转发
                    if self.mailHtmlbodyOrigin != nil
                    {
                        
                        var tempHtmlbody = "<br/><p>以下是原邮件内容</p><br/>";
                        
                        let path = NSBundle.mainBundle().pathForResource("forwadmailhead", ofType:"html");
                        if path != nil
                        {
                            do {
                                tempHtmlbody = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding);
                            }
                            catch let error as NSError {
                                print(error.localizedDescription)
                            }
                            
                            
                        }
                        
                        
                        let originBodyHtml = NSMutableString(format: "%@<br/><br/>%@",tempHtmlbody.stringByReplacingOccurrencesOfString("\n",withString:"<br/>"),self.mailHtmlbodyOrigin!);
                        
                        htmlBody=htmlBody+(originBodyHtml as String);
                        
                        //添加hmtlinline附件
                        
                        if self.mailOriginRelatedAttachments != nil
                        {
                            for attachment in self.mailOriginRelatedAttachments!
                            {
                                messageBuilder.addRelatedAttachment(attachment);
                            }
                        }
                        
                        //添加邮件附件
                        if self.mailOriginAttachments != nil
                        {
                            for attachment in self.mailOriginAttachments!
                            {
                                messageBuilder.addAttachment(attachment);
                            }
                        }
                        
                        
                    }
                    //老邮件添加完毕
                    
                    
                    
                    htmlBody=htmlBody+"</body></html>";
                    
                    //   print("htmlBody=\(htmlBody)");
                    
                   
                    messageBuilder.htmlBody=htmlBody;
                    
                    
                    let rfc822Data = messageBuilder.data();
                    let sendOperation = smtpSession.sendOperationWithData(rfc822Data);
                    sendOperation.start()
                        {
                            (error:NSError?) -> Void in
                            if error==nil
                            {
                                print("发送成功!");
                                self.dismissViewControllerAnimated(true,completion: nil);
                                
                                if self.oldMailContent != nil //表明是编辑草稿箱中的老邮件,需要删除原邮件
                                {
                                    if self.detailViewController != nil
                                    {
                                        self.detailViewController?.deleteCurrentMsg();
                                    }
                                }
                            }
                            else
                            {
                                self.ShowNotice("提示", "发送不成功-\(error?.localizedDescription)");
                                print("发送不成功!%@",error);
                                
                            }
                            
                            self.setSendButtonEnable(true);
                            
                            
                    }
                    
                }
                else
                {
                    print("login account failure: %@", error);
                    
                    self.setSendButtonEnable(true);
                }
        }
    }
    
    //MARK:处理本地HTML中插入的图片
    static func wrapLocalImgHtml(webView:UIWebView,inout webHtml:String,inout messageBuilder:MCOMessageBuilder)
    {
        let imgSrcs=TextMailComposerViewController.getHtmlImages(webView);
        
//        print(imgSrcs);
        
       
        for imgsrc in imgSrcs
        {
            let result=TextMailComposerViewController.replaceHtmlImgForCID(&webHtml, fileImgSrc: imgsrc)
            
//            print(result[0]);
//            print(result[1])
            
            let attachment=MCOAttachment(contentsOfFile:result[0]);
            attachment.contentID=result[1];
            messageBuilder.addRelatedAttachment(attachment);
            
        }
        
  //      print(webHtml);
        

    }
    //MARK:关闭邮件地址录入窗口
    func doCloseMailComposer(sender:UIBarButtonItem)
    {
        let composeCloseMenu = UIAlertController(title: nil, message: "选项", preferredStyle: .ActionSheet)
        
        let deleteDraftAction = UIAlertAction(title: "放弃", style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
            self.dismissViewControllerAnimated(true,completion: nil);
            
        };
        
        let storeDraftAction = UIAlertAction(title: "存储草稿", style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
            //  print("存储草稿代码实现在此!");
            
            self.storeMessageToDrafts();           
            
            
            
        };
        
        
        //        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        
        composeCloseMenu.addAction(deleteDraftAction)
        composeCloseMenu.addAction(storeDraftAction)
        
        //        composeMenu.addAction(cancelAction)
        
        composeCloseMenu.popoverPresentationController?.sourceView=self.mailToolBar;
        let toolbarbounds=self.mailToolBar.bounds;
        
        let bounds=CGRectMake(toolbarbounds.origin.x, toolbarbounds.origin.y, sender.width, toolbarbounds.height)
        
        
        
        composeCloseMenu.popoverPresentationController?.sourceRect=bounds;
        
        
        self.presentViewController(composeCloseMenu, animated: true, completion: nil)
        

        
        

        
    }
    
    //MARK:将未发出的邮件保存到草稿箱
    private func storeMessageToDrafts()
    {
        if self.imapsession==nil{
            return;
        }
        let defaults = NSUserDefaults.standardUserDefaults();

        let tmpdraftsfolder=defaults.stringForKey("draftsbox");
        
        if tmpdraftsfolder==nil{
            return;
        }
        
        let draftsfolder=tmpdraftsfolder!;
        
        // 构建邮件体的发送内容
        let smtpinfo=self.loadMailLoginInfo();

        let messageBuilder = MCOMessageBuilder();
        messageBuilder.header.from = MCOAddress(displayName: smtpinfo.nicklename, mailbox:smtpinfo.smtpusername);   // 发送人
        
        
        let mailTo=self.mailToInputText.getEmailLists();
        
         messageBuilder.header.to=mailTo;       // 收件人（多人）
        
        let mailCc=self.mailCcInputText.getEmailLists();
        
        messageBuilder.header.cc = mailCc;      // 抄送（多人）

        if self.mailTopicInputText.text != nil
        {
            messageBuilder.header.subject = self.mailTopicInputText.text;// 邮件标题
        }
        else
        {
            messageBuilder.header.subject = "";// 邮件标题

        }
        
        var htmlBody="<html><body><div></div>"//<div><img src=\"cid:123\"></div></body></html>";
        
        htmlBody=htmlBody+self.mailComposerView.getHTML();
        
        
        //如果是以图片形式回复或转发邮件,则需要把老邮件附件-图片格式
        if self.mailOrign != nil
        {
            
            var tempHtmlbody = "<br/><p>以下是原邮件内容</p><br/>";
            
            let path = NSBundle.mainBundle().pathForResource("forwadmailhead", ofType:"html");
            if path != nil
            {
                do {
                    tempHtmlbody = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding);
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                
            }
            
            htmlBody=htmlBody+tempHtmlbody;
            
            
            let uuid = NSUUID().UUIDString;//必须要确保文件名唯一
            
            let cid="cngis-"+uuid;
            
            htmlBody=htmlBody+"<div><img src=\"cid:"+cid+"\"></div>";
            
            
            let attachment=MCOAttachment(data: UIImagePNGRepresentation(self.mailOrign!), filename: "originMail.png");
            attachment.contentID=cid;
            messageBuilder.addRelatedAttachment(attachment);
        }
        //老邮件添加完毕
        
        //老邮件，htmlbody转发
        if self.mailHtmlbodyOrigin != nil
        {
            
            var tempHtmlbody = "<br/><p>以下是原邮件内容</p><br/>";
            
            let path = NSBundle.mainBundle().pathForResource("forwadmailhead", ofType:"html");
            if path != nil
            {
                do {
                    tempHtmlbody = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding);
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                
            }
            
            
            let originBodyHtml = NSMutableString(format: "%@<br/><br/>%@",tempHtmlbody.stringByReplacingOccurrencesOfString("\n",withString:"<br/>"),self.mailHtmlbodyOrigin!);
            
            htmlBody=htmlBody+(originBodyHtml as String);
            
            //添加hmtlinline附件
            
            if self.mailOriginRelatedAttachments != nil
            {
                for attachment in self.mailOriginRelatedAttachments!
                {
                    messageBuilder.addRelatedAttachment(attachment);
                }
            }
            
            //添加邮件附件
            if self.mailOriginAttachments != nil
            {
                for attachment in self.mailOriginAttachments!
                {
                    messageBuilder.addAttachment(attachment);
                }
            }
            
            
        }
        //老邮件添加完毕
        
        //老邮件编辑
        if self.oldMailContent != nil
        {
               //添加hmtlinline附件
            
            if self.mailOriginRelatedAttachments != nil
            {
                for attachment in self.mailOriginRelatedAttachments!
                {
                    messageBuilder.addRelatedAttachment(attachment);
                }
            }
            
            //添加邮件附件
            if self.mailOriginAttachments != nil
            {
                for attachment in self.mailOriginAttachments!
                {
                    messageBuilder.addAttachment(attachment);
                }
            }
            
        }
        //编辑老邮件时邮件附件添加完毕

        
        htmlBody=htmlBody+"</body></html>";
        
        //   print("htmlBody=\(htmlBody)");
        
        messageBuilder.htmlBody=htmlBody;
        
        
        let rfc822Data = messageBuilder.data();
        
        let op = self.imapsession!.appendMessageOperationWithFolder(draftsfolder,messageData:rfc822Data,flags:MCOMessageFlag.Draft);
        op.start { (error:NSError?, createdUID:UInt32) in
            if error==nil{
                print("保存到草稿箱成功!");
                self.dismissViewControllerAnimated(true,completion: nil);
            }
            else
            {
                print("保存到草稿箱失败!");
            }
            
        }
 
    }
    
    
    //MARK:回复邮件时构建邮件头信息
    private func loadMailHeader()
    {
        //收件人
        var items=[ACAddressBookElement]();
        for mailto in self.mailTo
        {
            let item=ACAddressBookElement();
            
            item.email=mailto.mailbox;
            item.first_name=mailto.displayName;
            item.last_name="";
            items.append(item)
            
        }
        self.mailToInputText.loadItems(items);
        
        //收件人
        items.removeAll();
        
        
        for mailcc in self.mailCc
        {
            let item=ACAddressBookElement();
            
            item.email=mailcc.mailbox;
            item.first_name=mailcc.displayName;
            item.last_name="";
            items.append(item)
            
        }
        self.mailCcInputText.loadItems(items);
        
        if self.oldMailContent != nil //是待编辑的邮件
        {
            self.mailTopicInputText.text=self.mailTopic;
            self.mailComposerView.setHTML(self.oldMailContent!)
        }
        else
        {
            self.setMailHeadTemplate();//预处理邮件模板
            self.setMailContentTemplate();
        }
        
        
    }
    
    //MARK:处理邮件内容模板
    private func setMailContentTemplate()
    {
        //邮件内容模板
        let mailCc=self.mailCcInputText.getEmailLists();
        let mailTo=self.mailToInputText.getEmailLists();
        //1.替换发件人
        var strTemp="";
        
        for mailto in mailTo
        {
            strTemp=strTemp+mailto.displayName+" ";
        }
        
        self.mailContentTemplate=self.mailContentTemplate.stringByReplacingOccurrencesOfString("#mailto#", withString: strTemp, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        //2.替换抄送人
        strTemp="";
        
        for mailcc in mailCc
        {
            strTemp=strTemp+mailcc.displayName+" ";
        }
        
        
        if mailCc.count>0
        {

            strTemp="抄送"+strTemp;
            
            self.mailContentTemplate=self.mailContentTemplate.stringByReplacingOccurrencesOfString("#mailcc#", withString: strTemp, options: NSStringCompareOptions.LiteralSearch, range: nil)
            
        }
        else
        {
            strTemp="无";
            
            self.mailContentTemplate=self.mailContentTemplate.stringByReplacingOccurrencesOfString("#mailcc#", withString: strTemp, options: NSStringCompareOptions.LiteralSearch, range: nil)
            
        }
        //3.替换发信日期
        strTemp=NSDate().toString(format: DateFormat.Custom("YYYY-MM-dd EEEE HH:mm"));
        
        self.mailContentTemplate=self.mailContentTemplate.stringByReplacingOccurrencesOfString("#maildate#", withString: strTemp, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        self.mailComposerView.setHTML(self.mailContentTemplate);

        
    }

    
    //MARK:处理邮件头模板
    private func setMailHeadTemplate()
    {
       let logininfo=self.loadMailLoginInfo()
        let mailsender=logininfo.nicklename;
        
        self.mailTopic=self.mailTopic.stringByReplacingOccurrencesOfString("#mailsender#", withString: mailsender, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        //邮件主题
        self.mailTopicInputText.text=self.mailTopic;
        
      }
    
    

    
    private func buildMessageHtmlBody()->String
    {
 //       return "以下是转发的邮件内容";
        
        let messageBuilder = MCOMessageBuilder();

        var htmlBody="<html><body><div></div>"//<div><img src=\"cid:123\"></div></body></html>";
        
        htmlBody=htmlBody+self.mailComposerView.getHTML();
        
        
        //如果是回复或转发邮件,则需要把老邮件附件-图片格式
        if self.mailOrign != nil
        {
            
            
            var tempHtmlbody = "<br/><p>以下是原邮件内容</p><br/>";
            
            let path = NSBundle.mainBundle().pathForResource("forwadmailhead", ofType:"html");
            if path != nil
            {
                do {
                    tempHtmlbody = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding);
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                
            }
            
            htmlBody=htmlBody+tempHtmlbody;
            
            
            
            
            let uuid = NSUUID().UUIDString;//必须要确保文件名唯一
            
            let cid="cngis-"+uuid;
            
            htmlBody=htmlBody+"<div><img src=\"cid:"+cid+"\"></div>";
            
            
            let attachment=MCOAttachment(data: UIImagePNGRepresentation(self.mailOrign!), filename: "originMail.png");
            attachment.contentID=cid;
            messageBuilder.addRelatedAttachment(attachment);
        }
        //老邮件添加完毕
        
        //老邮件，htmlbody转发
        if self.mailHtmlbodyOrigin != nil
        {
            
            var tempHtmlbody = "<br/><p>以下是原邮件内容</p><br/>";
            
            let path = NSBundle.mainBundle().pathForResource("forwadmailhead", ofType:"html");
            if path != nil
            {
                do {
                    tempHtmlbody = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding);
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                
            }
            
            
            let originBodyHtml = NSMutableString(format: "%@<br/><br/>%@",tempHtmlbody.stringByReplacingOccurrencesOfString("\n",withString:"<br/>"),self.mailHtmlbodyOrigin!);
            
            htmlBody=htmlBody+(originBodyHtml as String);
            
            //添加hmtlinline附件
            
            if self.mailOriginRelatedAttachments != nil
            {
                for attachment in self.mailOriginRelatedAttachments!
                {
                    messageBuilder.addRelatedAttachment(attachment);
                }
            }
            
            //添加邮件附件
            if self.mailOriginAttachments != nil
            {
                for attachment in self.mailOriginAttachments!
                {
                    messageBuilder.addAttachment(attachment);
                }
            }
            
            
        }
        //老邮件添加完毕
        
        
        
        htmlBody=htmlBody+"</body></html>";
        
        return htmlBody;

    
    }
    

    private func setSendButtonEnable(enable:Bool=true)
    {
        let sendBarBtnItem=self.mailToolBar.items![4];
        
        
        if enable
        {
            sendBarBtnItem.enabled=true;
            sendBarBtnItem.tintColor=UIColor.blueColor();
        }
        else
        {
            sendBarBtnItem.enabled=false;
            sendBarBtnItem.tintColor=UIColor.darkGrayColor();
        }
    }
    
    //MARK:得到一个webview中的IMG标签,并返回包含file://标签的字符串(实际上为本地的图片地址),最多得到10个,why,因为笨
    static func  getHtmlImages(webview:UIWebView)->[String]
    {
        var imgSrcs=[String]();
        for i in 0...9
        {
            let js="document.getElementsByTagName(\"img\")[\(i)].src;"
            let webHtml = webview.stringByEvaluatingJavaScriptFromString(js);
            
            if webHtml != nil
            {
                if webHtml!.containsString("file:///")//不是本地IMG文件不返回
                {
                    imgSrcs.append(webHtml!)
                }
            }
            
        }
        
        return imgSrcs;
        
    }
    
    //MARK:替换本地fileImgSrc为CID并返回,[0]=filename,[1]=uuid
    static func  replaceHtmlImgForCID(inout webHTML:String,fileImgSrc:String)->[String]
    {
        var result=["filename","uuid"];
        
        let uuid="cngis-"+NSUUID().UUIDString;
        
        let cid="cid:"+uuid;
        
        webHTML=webHTML.stringByReplacingOccurrencesOfString(fileImgSrc, withString: cid, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        result[0]=(fileImgSrc as NSString).substringFromIndex(7);
        
        result[1]=uuid;
        
        return result;
        
    }


}

//MARK:扩展,响应RichEditorToolbarDelegate
extension TextMailComposerViewController: RichEditorToolbarDelegate {
    
    private func randomColor() -> UIColor {
        let colors = [
            UIColor.redColor(),
            UIColor.orangeColor(),
            UIColor.yellowColor(),
            UIColor.greenColor(),
            UIColor.blueColor(),
            UIColor.purpleColor(),
            UIColor.blackColor()
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }
    
    func richEditorToolbarChangeTextColor(toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }
    
    func richEditorToolbarChangeBackgroundColor(toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }
    
    func richEditorToolbarInsertImage(toolbar: RichEditorToolbar) {
        //        richEditorView.insertImage("http://",alt: "test");
        //判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            //设置是否允许编辑
            //            picker.allowsEditing = editSwitch.on
            //弹出控制器，显示界面
            self.presentViewController(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }

    }
    
    //选择图片成功后代理
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //查看info对象
        //        print(info)
        //获取选择的原图
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //不能放到临时目录下,再次启动时会被删除,好象只能放到Documents,建个子目录也不行
        let imagePath = NSHomeDirectory() + "/Library/Caches"
        
        let uuid = NSUUID().UUIDString;//必须要确保文件名唯一
        
        var imageUrl=imagePath+"/"+uuid+".JPG";
        
        
        
        UIImageJPEGRepresentation(image, 1.0)!.writeToFile(imageUrl,atomically:true);
        
        
        
        imageUrl="file://"+imageUrl;
        
 //       print(imageUrl);
        
        
        
        let srcimag=String.init(format:"<img src = \"%@\" alt=\" \" width=\"750\"/>", imageUrl);
        
        
        
        
        self.mailComposerView.insertHtml(srcimag);
        

        
        
 /*
         //采用编码内嵌的方式,导致占用大量的内存空间,舍弃
         let imageData = UIImageJPEGRepresentation(image,1);
         
         let imageSource = String.init(format:"data:image/jpg;base64,%@",imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)));
         
         let srcimag=String.init(format:"<img src = \"%@\" alt=\" \" width=\"750\"/>", imageSource);
         
         
         
         //   print(srcimag)
        
//        self.mailComposerView.insertImage(imageSource,alt: "img");
        self.mailComposerView.insertHtml(srcimag);
 */

         //图片控制器退出
        picker.dismissViewControllerAnimated(true, completion: {
            () -> Void in
        })
    }

    
    func richEditorToolbarInsertLink(toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if let hasSelection = toolbar.editor?.rangeSelectionExists() where hasSelection {
            toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
        }
    }
}

//MARK:响应,实现RichEditorDelegate
extension TextMailComposerViewController: RichEditorDelegate {
    
    func richEditor(editor: RichEditorView, heightDidChange height: Int)
    {
//        print("editor height=\(height),webview height=\(editor.webView.bounds)");
    }
    
    func richEditor(editor: RichEditorView, contentDidChange content: String) {
        //        if content.isEmpty {
        //            htmlTextView.text = "HTML Preview"
        //        } else {
        //            htmlTextView.text = content
        //        }
    }
    
    func richEditorTookFocus(editor: RichEditorView) { }
    
    func richEditorLostFocus(editor: RichEditorView) { }
    
    func richEditorDidLoad(editor: RichEditorView) { }
    
    func richEditor(editor: RichEditorView, shouldInteractWithURL url: NSURL) -> Bool { return true }
    
    func richEditor(editor: RichEditorView, handleCustomAction content: String) { }
    
}

//MARK:响应,RichEditorView扩展,增加InsertHtml功能
extension RichEditorView
{
    private func escape(string: String) -> String {
        let unicode = string.unicodeScalars
        var newString = ""
        for var i = unicode.startIndex; i < unicode.endIndex; i = i.successor() {
            let char = unicode[i]
            if char.value < 9 || (char.value > 9 && char.value < 32) // < 32 == special characters in ASCII, 9 == horizontal tab in ASCII
                || char.value == 39 { // 39 == ' in ASCII
                let escaped = char.escape(asASCII: true)
                newString.appendContentsOf(escaped)
            } else {
                newString.append(char)
            }
        }
        return newString
    }

    //插件HTML代码
    public func insertHtml(html: String) {
        runJS("RE.prepareInsert();")
        runJS("RE.insertHTML('\(escape(html))');")
    }
}






