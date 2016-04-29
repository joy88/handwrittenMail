//
//  DetailViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/5.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit
import QuickLook

class DetailViewController:MCTMsgViewController,RefreshMailDelegate,QLPreviewControllerDataSource,UIGestureRecognizerDelegate
{
    //MARK:点按手势，当是草稿邮或发件箱时点击进行编辑
    private var viewTap:UITapGestureRecognizer!;
    //MARK:允许编辑邮件，当是草稿箱或发件箱时有效
    var isDraftsOrSendMailFolder:Bool=false;
    
    //MARK:Open In Controller,must like this
    private var docController:UIDocumentInteractionController?
    
    private var mailTopicNewTemplate:String="From<mailsender>,";//新建邮件时的邮件主题模板
    private var mailTopicReplyTemplate:String="From<mailsender>的回复,";////回复邮件时的邮件主题模板
    private var mailTopicforwardTemplate:String="From<mailsender>的转发,";////回复邮件时的邮件主题模板
    private var mailContentTemplate="<mailto>:<br>";
//回复邮件时的邮件主题模板



    

    var mywebView=MCOMessageView()//MARK:邮件正文
    
    private var mailFromLbl=UILabel()//MARK:邮件正文"发件人"标签
    private var mailFromBtn=UIEmailButton()//MARK:邮件正文发件人显示按钮
//    private var infoHideBtn=UIButton()//MARK:邮件正文"隐藏"或"显示"按钮
    
    private var mailToLbl=UILabel()//MARK:邮件正文"收件人"标签
    private var mailToBtns=[UIEmailButton]();//MARK:邮件正文收件人
    private var mailCcLbl=UILabel();//MARK:邮件正文"抄送"按钮
    private var mailCcBtns=[UIEmailButton]()////MARK:邮件正文抄送人
    
    private var lineLbl=UILabel();//MARK:邮件正文灰色分割线
    private var lineLbl2=UILabel();//MARK:灰色分割线


    
    private var subjectLbl=UILabel()//MARK:邮件主题
    private var mailDateLbl=UILabel()//MARK:邮件收到时间
    
    private var attachLbl=UILabel()//MARK:附件标签"附件"
    private var attachBtns=[UIEmailButton]();//MARK:附件按钮
    
    private var tempFilePath="";//MARK:文件路径，供附件预览用

    
    
    var mailSender=MCOAddress(displayName: "", mailbox: "s@s.com")!;//MARK:发件人地址
    private var mailToLists=[MCOAddress]();//MARK:收件人地址列表
    private var mailCcLists=[MCOAddress]();//MARK:抄送人地址列表
    var mailSubject=BaseFunction.getIntenetString("邮件主题");
    var mailDate=NSDate();//MARK:邮件日期
    
    //MARK:手势代理
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        var result=false;
        if isDraftsOrSendMailFolder
        {
            if (gestureRecognizer is UITapGestureRecognizer)
            {
                result=true;
            }
        }
        return result;
    }
    
    //MARK:响应点击事件,打开邮件编辑窗口
    func viewTap(recognizer:UIPanGestureRecognizer)
    {
        if self.message == nil{
            return;
        }
        if !isDraftsOrSendMailFolder //不是草稿箱
        {
            return;
        }
        if recognizer.state == .Ended
        {
            if self.mywebView.webView.loading
            {
                self.ShowNotice(BaseFunction.getIntenetString("WARNING"), BaseFunction.getIntenetString("请页面加载完毕后再进行编辑操作!"));
                return;
            }
            self.editOldMailOperation();
        }
    }
    
    
    //MARK:编辑老邮件
    private func editOldMailOperation()
    {
        if self.message==nil
        {
            return;
        }
        //added by shiww,弹出邮件编写界面,代码仅供测试
        let popVC = TextMailComposerViewController();
        
        
        popVC.detailViewController=self;
        
        popVC.imapsession=self.session;
        
        popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        let popOverController = popVC.popoverPresentationController
        popVC.preferredContentSize = CGSize(width: 750,height: 1000);
        popOverController?.permittedArrowDirections = .Any
        
        
        let header=self.message.header;
        
        
        
        popVC.mailTopic="\(header.subject)";//邮件主题;
        
        var tmpmailCcLists=[MCOAddress]();
        var tmpmailToLists=[MCOAddress]();
        
        if header.to != nil
        {
            
            tmpmailToLists=header.to as! [MCOAddress];
        }
        
        if header.cc != nil
        {
            tmpmailCcLists=header.cc as! [MCOAddress];
            
        }
        
        
        popVC.mailTo=tmpmailToLists;
        popVC.mailCc=tmpmailCcLists;
        
        if self.message.attachments().count==0
        {
            
            
            popVC.mailHtmlbodyOrigin=nil;
            
            //直接取已加载的HTML代码
            let lJs = "document.documentElement.innerHTML";
            let webHtml = self.mywebView.webView.stringByEvaluatingJavaScriptFromString(lJs);
           
            popVC.oldMailContent=webHtml!;
            
            popVC.mailOriginAttachments=nil;
            popVC.mailOriginRelatedAttachments=nil;
            popVC.mailOrign=nil;
            
 
            self.presentViewController(popVC, animated: true, completion: nil)

            return;
        }
        
        //如果有附件的情况下,还是需要重新从网络上获取附件信息
        
        
        let imapsession=self.session;
        
        let fetchContentOp = imapsession.fetchMessageOperationWithFolder(self.folder,uid:self.message.uid,urgent:true);
        
        fetchContentOp.start()
            {
                (error:NSError?, data:NSData?)->Void in
                if error==nil
                {
                    
                    let msgPareser = MCOMessageParser(data:data);
                    
                   // let bodyHtml=msgPareser.htmlBodyRendering();
                    
                    popVC.mailHtmlbodyOrigin=nil;
                    
                    //直接取已加载的HTML代码
                    let lJs = "document.documentElement.innerHTML";
                    let webHtml = self.mywebView.webView.stringByEvaluatingJavaScriptFromString(lJs);
                    
//                    print(webHtml)
                    //调试运行时都会丢失缓存文件,正常不会这样!
                    /*
                    let js="document.getElementsByTagName(\"img\")[0].src;"
                    let filetemp = self.mywebView.webView.stringByEvaluatingJavaScriptFromString(js);
                    
                    var strTemp:String=filetemp!
                    
                    strTemp = (strTemp as NSString).substringFromIndex(7);
                    
                    print(strTemp)
                    
                    
                    
                    if NSFileManager.defaultManager().fileExistsAtPath(strTemp)
                    {
                        print("file exist!")
                    }
                    else
                    {
                        print("file don't exist")
                    }*/
                    
                    popVC.oldMailContent=webHtml!;

//                    popVC.oldMailContent=bodyHtml;//原邮件内容
                    
                    
                    popVC.mailOriginAttachments=nil;
                    popVC.mailOriginRelatedAttachments=nil;
                    
                    // 添加正文里的附加资源
                    /*不需要了,直接加载webview中的HTML
                    let inattachments = msgPareser.htmlInlineAttachments;
                    
                    
                    popVC.mailOriginRelatedAttachments=inattachments() as? [MCOAttachment];
 
                             */
 
                    
                    let attachments=msgPareser.attachments;
 
                    
                    popVC.mailOriginAttachments=attachments() as? [MCOAttachment];
                    
                    self.presentViewController(popVC, animated: true, completion: nil)
                    
                }
                else
                {
                    print("获取邮件全文信息失败!")
                }
                
                
        }
        
    }
    
    


    //MARK:视图初始化
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //增加草稿邮件的点击手势
        viewTap=UITapGestureRecognizer(target: self, action:#selector(DetailViewController.viewTap(_:)));
        viewTap.numberOfTapsRequired=2;
        viewTap.delegate=self;
        self.view.addGestureRecognizer(viewTap);

        
        self.navigationItem.leftBarButtonItem?.title=BaseFunction.getIntenetString("邮箱");
        self.navigationItem.title=BaseFunction.getIntenetString("收件箱");
        //1.右边第一个按钮
        //编写新邮件
        let composeButton = UIBarButtonItem(image:UIImage(named: "composemail")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain,target:self,action:#selector(DetailViewController.newMail(_:)))
        //2.回复邮件至发送人
        let replyButton = UIBarButtonItem(image: UIImage(named: "reply")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DetailViewController.replyMail(_:)))
        replyButton.tag=0;//==1 代表回复全部
        
        //3.回复邮件至所有
        
        //如果是自定义图片,必须得有imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal),否则是个纯色图片
        let replyallButton = UIBarButtonItem(image: UIImage(named: "replyall")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self,action: #selector(DetailViewController.replyMail(_:)))
        replyallButton.tag=1;//==1 代表回复全部
        
        //4.转发邮件
        
        let forwardButton = UIBarButtonItem(image: UIImage(named: "forward")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self,action: #selector(DetailViewController.forwardMail(_:)))
        
        //3.delete mail
        let trashButton = UIBarButtonItem(image: UIImage(named: "deletemail")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DetailViewController.beginDeleteCurrentMsg(_:)))
        
        let organizeButton = UIBarButtonItem(image: UIImage(named: "bugreport")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DetailViewController.reportBug));//给作者写信
            
            
        //    UIBarButtonItem(barButtonSystemItem:.Organize, target: self, action: #selector(DetailViewController.clearAll));
        
        
        
        let rightItems=[composeButton,replyButton,replyallButton,forwardButton,trashButton,organizeButton];
        
        
        self.navigationItem.rightBarButtonItems = rightItems
        
        //开始生成窗口要素
 //        var webView=UIWebView()//邮件正文
        
         self.mywebView=self.messageView;
        self.messageView.setHtmlContent("<html><head><title>Hello</title></head><body><h1>邮件正在加载中......</h1></body></html>")
 
        self.mywebView.prefetchIMAPAttachmentsEnabled=false;

        self.mywebView.prefetchIMAPImagesEnabled=true;

//
//        var mailFromLbl=UILabel()//"发件人"标签
        self.view.addSubview(mailFromLbl)

//        var mailFromBtn=UIEmailButton()//发件人显示按钮
        mailFromBtn.addTarget(self,action: #selector(DetailViewController.emailClicked(_:)),forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(mailFromBtn)
        

//        var infoHideBtn=UIButton()//"隐藏"或"显示"按钮
        //show or hide mainto and maincc
/*        infoHideBtn.addTarget(self,action: #selector(DetailViewController.hideMailToCC(_:)),forControlEvents: UIControlEvents.TouchUpInside)

        self.view.addSubview(infoHideBtn)*/

//
//        var mailToLbl=UILabel()//"收件人"标签
        self.view.addSubview(mailToLbl)

 
//        var mailCcLbl=UILabel();//"抄送"按钮
        self.view.addSubview(mailCcLbl)

 
//
//        var lineLbl=UILabel();//灰色分割线
        self.view.addSubview(lineLbl)
        self.view.addSubview(lineLbl2)

//
//        
//        var subjectLbl=UILabel()//邮件主题
        self.view.addSubview(subjectLbl)

//        var mailDateLbl=UILabel()//邮件收到时间
        self.view.addSubview(mailDateLbl)
        
//        self.AutoLayoutView(infoHideBtn.selected);
//        self.AutoLayoutView(true);
        
        self.clearAll();

        
        //监测设备的旋转
        //感知设备方向 - 开启监听设备方向
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        //添加通知，监听设备方向改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.receivedRotation),
            name: UIDeviceOrientationDidChangeNotification, object: nil)
     
        //关闭设备监听
        //UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
        //加上这句，UIWebView顶部不会出现一个空白条了，找了好久才找到斛方案啊。
        self.automaticallyAdjustsScrollViewInsets = false;
        //加载邮件模板
        self.loadMailTemplate();
        

    }
    //MARK:加载邮件模板
    private func loadMailTemplate()
    {
        let mailTemplates=SetMailTemplateViewController.getMailTemplate();
        self.mailTopicNewTemplate=mailTemplates[0];
        self.mailTopicReplyTemplate=mailTemplates[1];
        self.mailTopicforwardTemplate=mailTemplates[2];
        self.mailContentTemplate=mailTemplates[3];

        
    }
    
    //MARK:开始删除当前邮件
    func beginDeleteCurrentMsg(sender: AnyObject)
    {
        let deleteMenu = UIAlertController(title: nil, message: BaseFunction.getIntenetString("确认要删除当前邮件?"), preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: BaseFunction.getIntenetString("确认删除"), style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
            self.deleteCurrentMsg()
            
            
        };
        
        let refuseAction = UIAlertAction(title: BaseFunction.getIntenetString("取消删除"), style: UIAlertActionStyle.Default,handler: nil)
        
        deleteMenu.addAction(deleteAction)
        deleteMenu.addAction(refuseAction)
        
        
        deleteMenu.popoverPresentationController?.sourceView=sender.view;
        
        deleteMenu.popoverPresentationController?.sourceRect=sender.view!.bounds;
        
        
        self.presentViewController(deleteMenu, animated: true, completion: nil)
        
        
        
    }
    

    //MARK:删除当前邮件
    func deleteCurrentMsg()
    {
        
        let masterViewController=self.parentViewController?.parentViewController?.childViewControllers[0].childViewControllers[0] as? MasterViewController;
        
        let maillistViewController=masterViewController!.maillistViewController;
        
        if maillistViewController != nil
        {
//            let indexpaths=maillistViewController?.tableView.indexPathsForSelectedRows;
            
            let mailList=maillistViewController?.mailList;
            let msg=self.mywebView.message as! MCOIMAPMessage;
            let indexpath=mailList?.indexOf(msg)
            
            
            if indexpath != nil
            {
                let tmppath=NSIndexPath(forRow:indexpath!,inSection:0);
               // print(tmppath.row);
                maillistViewController?.delCurrentMsgs([tmppath])
            }
           
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func AutoLayoutView(isHide:Bool=false)//自动生成视图布局
    {
        let bounds=self.view.bounds;
        
        let xSpace:CGFloat=10;//水平方向间隔
        let ySpace:CGFloat=10;//水平方向简隔
        let topSpace:CGFloat=10;//离view上部间隔
        let marginSpace:CGFloat=10;//左右两侧距边界的空白
        
        let ctrHight:CGFloat=25;//标准控件高度
        let ctrWidth:CGFloat=60;//标准控件宽度
        
        let black=UIColor.blackColor();
        let blue=UIColor.blueColor();
        let red=UIColor.redColor();
        
        var top1,top2,top3,top4,top5,top6,top7,top8:CGFloat;
        
        var navHeight:CGFloat=0;
        
        if let navCtrFrame=self.navigationController?.navigationBar.frame
        {
            navHeight=navCtrFrame.origin.y+navCtrFrame.height;
        }
        
        top1=topSpace+navHeight;//要考虑加上导航栏的高度

//        var mailFromLbl=UILabel()//"发件人"标签
          mailFromLbl.setLabel(BaseFunction.getIntenetString("发件人:"), x: marginSpace, y: top1, width: ctrWidth, height: ctrHight, fonSize: 18, isBold: true, color: black)
        
//        var mailFromBtn=UIEmailButton()//发件人显示按钮
        mailFromBtn.setEmailTitle(self.mailSender, x: (marginSpace+ctrWidth+xSpace), y: top1, width: ctrWidth, height: ctrHight, fonSize: 17, isBold: true, color: blue);
        
//        var infoHideBtn=UIButton()//"隐藏"或"显示"按钮
/*        infoHideBtn.selected=isHide;
        
        infoHideBtn.setTitle("显示", forState:.Selected);
        infoHideBtn.setTitle("隐藏", forState: .Normal);
        infoHideBtn.frame=CGRectMake(bounds.width-ctrWidth-2*marginSpace,top1,ctrWidth,ctrHight)
        infoHideBtn.setTitleColor(blue, forState: .Normal);//不加上这句,看不到,可以字体是白色的原因吧
        */
//        print(infoHideBtn.frame);
//        
//        var mailToLbl=UILabel()//"收件人"标签
        
        top2=top1+ctrHight+ySpace
        
        mailToLbl.setLabel(BaseFunction.getIntenetString("收件人:"), x: marginSpace, y: top2, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: false, color: black);
        
        
//        var mailToBtns=[UIEmailButton]();//收件人
        

        top3=self.AutoLayoutMailListBtn(self.mailToBtns,viewWidth: bounds.width-marginSpace, X: marginSpace+ctrWidth+xSpace, Y: top2, Width: ctrWidth, Hight: ctrHight, xSpace: xSpace, ySpace: ySpace, FontSize: 16, color: blue);

        
        
//        var mailCcLbl=UILabel();//"抄送"按钮
        top3=top3+ySpace;
        
        if self.mailCcBtns.count>0
        {
            self.mailCcLbl.hidden=false;

        
        mailCcLbl.setLabel(BaseFunction.getIntenetString("抄送:"), x: marginSpace, y: top3, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: false, color: black);

//        var mailCcBtns=[UIEmailButton]()//抄送人
        
        top4=self.AutoLayoutMailListBtn(self.mailCcBtns,viewWidth: bounds.width-marginSpace, X: marginSpace+ctrWidth+xSpace, Y: top3, Width: ctrWidth, Hight: ctrHight, xSpace: xSpace, ySpace: ySpace, FontSize: 16, color: blue);
        }
        else{
            self.mailCcLbl.hidden=true;
            top4=top3;
        }

        //画一条线
//        var lineLbl=UILabel();//灰色分割线
        top4=top4+ySpace;
        
        lineLbl.text="";
        lineLbl.backgroundColor=UIColor.darkGrayColor();
        lineLbl.frame=CGRectMake(marginSpace, top4, bounds.width-2*marginSpace, 1);

//
//        var subjectLbl=UILabel()//邮件主题
        top5=top4+ySpace+1;
        
        subjectLbl.setLabel(self.mailSubject, x: marginSpace, y: top5, width: bounds.width-2*marginSpace, height: ctrHight, fonSize: 20, isBold: true, color: black);

        
//        var mailDateLbl=UILabel()//邮件收到时间
        top6=top5+ctrHight+ySpace;
        
        let dateFormatter=NSDateFormatter();
        dateFormatter.dateFormat="YYYY-MM-dd HH:mm:ss"
        let strMailDate=dateFormatter.stringFromDate(self.mailDate);
        

        
        mailDateLbl.setLabel(strMailDate, x: marginSpace, y: top6, width: bounds.width-2*marginSpace, height: ctrHight, fonSize: 16, isBold: false, color: UIColor.grayColor());

        //附件标签和附件按钮
        top7=top6+ctrHight+ySpace;

        setAttachmentList();
        
        top8=top7;
        
        
        
        if (self.message != nil) && (self.message.attachments().count>0)
        {
            attachLbl.setLabel(BaseFunction.getIntenetString("附件:"), x: marginSpace, y: top7, width: ctrWidth, height: ctrHight, fonSize: 19, isBold: true, color: black);
            
            self.view.addSubview(attachLbl);
            
             top8=self.AutoLayoutMailListBtn(self.attachBtns,viewWidth: bounds.width-marginSpace, X: marginSpace+ctrWidth+xSpace, Y: top7, Width: ctrWidth, Hight: ctrHight, xSpace: xSpace, ySpace: ySpace, FontSize: 16, color: red);

        }
        
        top8 = top8+1;


        //灰线
        lineLbl2.text="";
        lineLbl2.backgroundColor=UIColor.darkGrayColor();
        lineLbl2.frame=CGRectMake(marginSpace, top8, bounds.width-2*marginSpace, 1);

        //        var webView=UIWebView()//邮件正文
        
        self.mywebView.frame=CGRectMake(marginSpace,top8+3, bounds.width-2*marginSpace,bounds.height-top8);
        
      //  print("mywebview bounds=\(mywebView.frame)");
 
        
        //

    }

    //MARK:通知监听触发的方法
    func receivedRotation(){
        let device = UIDevice.currentDevice()
        switch device.orientation{
        case .Portrait,.PortraitUpsideDown,.LandscapeLeft,.LandscapeRight:
            self.AutoLayoutView();//旋转时,重新布局视图
/*        case .FaceUp:
            orientationLabel.text = "设备平放，Home键朝上"
        case .FaceDown:
            orientationLabel.text = "设备平放，Home键朝下"
        case .Unknown:
            orientationLabel.text = "方向未知"*/
        default:
            print("方向未知")
        }
    }
    
    
    //MARK:只创建按钮,不布局,收件人列表
    func setMailToList(emaillist:[MCOAddress])
    {
        self.mailToLists=emaillist;
        //1.先把以前的按钮从subview中给去掉
        for btn in self.mailToBtns
        {
            btn.removeFromSuperview();
        }
        mailToBtns.removeAll();
        
        for email in mailToLists
        {
            let tmpBtn=UIEmailButton();
            tmpBtn.mailAddress=email;
            tmpBtn.addTarget(self,action: #selector(DetailViewController.emailClicked(_:)),forControlEvents: UIControlEvents.TouchUpInside)
            mailToBtns.append(tmpBtn);
            self.view.addSubview(tmpBtn);
            
        }
        
    }
    
    //MARK:只创建按钮,不布局,抄送人列表
    func setMailCcList(emaillist:[MCOAddress])
    {
        self.mailCcLists=emaillist;
        //1.先把以前的按钮从subview中给去掉
        for btn in self.mailCcBtns
        {
            btn.removeFromSuperview();
        }
        mailCcBtns.removeAll();
        
        for email in mailCcLists
        {
            let tmpBtn=UIEmailButton();
            tmpBtn.mailAddress=email;
            tmpBtn.addTarget(self,action: #selector(DetailViewController.emailClicked(_:)),forControlEvents: UIControlEvents.TouchUpInside)

            mailCcBtns.append(tmpBtn);
            self.view.addSubview(tmpBtn);
        }
        
    }
    
    //MARK:只创建按钮,不布局,抄送人列表
    func setAttachmentList()
    {
        if self.message == nil{
            return;
        }
        //1.先把以前的按钮从subview中给去掉
        attachLbl.removeFromSuperview();
        
        for btn in self.attachBtns
        {
            btn.removeFromSuperview();
        }
        attachBtns.removeAll();
        
        var index=0;
        
        for attachment in self.message.attachments()
        {
            let tmpBtn=UIEmailButton();
            tmpBtn.tag=index;
            
            var fileSize:Double=0.0;
            
            if attachment.encoding == MCOEncoding.EncodingBase64
            {
                fileSize=Double(attachment.decodedSize())/(1024*1024);
            }
            else
            {
                fileSize=Double(attachment.size)/(1024*1024);
                
            }
            
            var strFileSize=String(format: "%.2f", fileSize)
            
//            let strTemp=attachment.filename;
            
            //added by shiww,test
            /*
            let (data, enc) = UTF8ToGB2312(strTemp)
            let gbkStr = NSString(data: data!, encoding: enc)!
            
            print("GBK string is: \(gbkStr)")
            
            let string: NSString = strTemp
            let dddd = string.dataUsingEncoding(NSUTF8StringEncoding)
            
            let tttt=attachment.decodedStringForData(dddd);
            
            print(strTemp);*/
            
            strFileSize = "\(attachment.filename)"+"("+strFileSize+"M)";
            
            let email=MCOAddress(displayName:strFileSize, mailbox: "s@s.s")//displayName中是文件名啊
        
            tmpBtn.mailAddress=email;

            tmpBtn.addTarget(self,action: #selector(DetailViewController.previewAttach(_:)),forControlEvents: UIControlEvents.TouchUpInside)
            
            //添加长按事件,和按分享附件
            let longPress=UILongPressGestureRecognizer(target: self, action: #selector(DetailViewController.shareAttachment(_:)));
            longPress.minimumPressDuration=0.4;
            tmpBtn.addGestureRecognizer(longPress);

            
            attachBtns.append(tmpBtn);
            
            self.view.addSubview(tmpBtn);
            
            index += 1;
        }
        
    }
    
    private  func UTF8ToGB2312(str: String) -> (NSData?, UInt) {
        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.HZ_GB_2312.rawValue))
        
        let data = str.dataUsingEncoding(enc, allowLossyConversion: false)
        
        return (data, enc)
    }
    
    //MARK:长按附件按钮，分享附件到其他系统中
    func shareAttachment(sender : UILongPressGestureRecognizer) {
        
        if sender.state != UIGestureRecognizerState.Began
        {
            return;
        }
        
        
        let index=sender.view!.tag;
        
        let attachment=self.message.attachments()[index];
        
        if !(attachment is MCOIMAPPart)//paser出来的可以直接保存
        {
            return;
        }
        
        let msgpart=attachment as! MCOIMAPPart;
        
        let filename=attachment.filename//sender.mailAddress.displayName;
        
        var tmpDirectory = NSHomeDirectory() + "/Library/Caches"
        
        tmpDirectory=tmpDirectory+"/"+filename;
        
        let isDownloaded=NSFileManager.defaultManager().fileExistsAtPath(tmpDirectory);//判断一下是否已经下载
        
        if isDownloaded//已经下载
        {
            self.tempFilePath=tmpDirectory;
           
            self.shareDocument(self.tempFilePath,sender:sender)
        }
        else//未下载
        {
            
            
            let imapsession=self.session;
            
            let op = imapsession.fetchMessageAttachmentOperationWithFolder(self.folder,uid:self.message.uid,partID:msgpart.partID,encoding:msgpart.encoding,urgent:false);
            
            //监测一下附件下载的进度
            let attachmentBtn=sender.view as! UIEmailButton;
            
            let oldBtnTitle=attachmentBtn.titleForState(.Normal);
            
            op.progress =
                {
                    (nowValue:UInt32,totalValue:UInt32)->Void in

                    //                    print("nowvalue=\(nowValue),totalValue=\(totalValue)");//,percent=\(nowValue*100/totalValue)");
                    if totalValue != 0
                    {
                        let btnTitle=String(format:BaseFunction.getIntenetString("正在下载,已完成%2d%%"),nowValue*100/totalValue);
                        attachmentBtn.setTitle(btnTitle, forState: .Normal)
                    }
            };
            

            op.start()
                {
                    (error:NSError?,data:NSData?)->Void in
                    if error==nil
                    {
                        if let attachData=data
                        {
                            attachData.writeToFile(tmpDirectory,atomically:true);
                            self.tempFilePath=tmpDirectory;
                            
                            attachmentBtn.setTitle(oldBtnTitle, forState: .Normal)
                            
                            self.shareDocument(self.tempFilePath,sender:sender)

                        }
                        
                        
                    }
                    else{
                        print("附件获取失败!");
                        attachmentBtn.setTitle(oldBtnTitle, forState: .Normal)
                    }
            }
            
        }
        

        
        
     }
    
    //MARK:分享附件
    private func shareDocument(file:String,sender:UILongPressGestureRecognizer)
    {
        
        let url = NSURL(fileURLWithPath: file);
        self.docController = UIDocumentInteractionController(URL: url)
        
      //  docController.UTI=""
            
        self.docController?.presentOptionsMenuFromRect((sender.view?.frame)!,inView:self.view, animated:true);

    }

  
    //MARK:email List自动布局,需和setMailFromList配合
    //viewWdith=self.view.Bounds.width
    func AutoLayoutMailListBtn(emaillistBtn:[UIEmailButton],viewWidth:CGFloat,X:CGFloat,Y:CGFloat,Width:CGFloat,Hight:CGFloat,xSpace:CGFloat,ySpace:CGFloat,FontSize:CGFloat,isBold:Bool=false,color:UIColor,isHidden:Bool=false)->CGFloat//返回右下角坐标的Y值
    {
        var result:CGFloat=Y+Hight;//默认是一行
        //1.先把以前的按钮从subview中给去掉
        var widthSum:CGFloat=0;
        var btnX=X;
        var btnY=Y;
        var trueWidth:CGFloat=0;
        for emailBtn in emaillistBtn
        {
//            if emailBtn.emailAddress=="tanxiujuan20@163.com"
//            {
//                print(emailBtn.emailAddress);
//            }
            
            trueWidth=emailBtn.setEmailTitle(emailBtn.mailAddress, x: btnX, y: btnY, width: Width, height: Hight, fonSize: FontSize, isBold:isBold , color: color)
            
            widthSum=btnX+trueWidth;
            
            if widthSum<=viewWidth //不换行
            {
                btnX=btnX+trueWidth+xSpace;
                btnY=btnY+0;
            }
            else//换行
            {
                btnX=X+0;
                btnY=btnY+Hight+ySpace;
                
                trueWidth=emailBtn.setEmailTitle(emailBtn.mailAddress, x: btnX, y: btnY, width: Width, height: Hight, fonSize: FontSize, isBold:isBold , color: color)
                
                btnX=btnX+trueWidth+xSpace;
                
            }
        }
        
        result=btnY+Hight;
        
        return result;
    }

    //MARK:响应email地址点击事件
    func emailClicked(button: UIEmailButton)
    {
        let showEmailAddressMenu = UIAlertController(title: nil, message: BaseFunction.getIntenetString("邮件地址信息"), preferredStyle: .ActionSheet)
        
        let mailDisaplayName="\(button.mailAddress.displayName)";
        let mailAddress=button.mailAddress.mailbox;
        
        let dispalyNameAction = UIAlertAction(title: mailDisaplayName, style: UIAlertActionStyle.Default,handler: nil)
        
         let mailBoxAction = UIAlertAction(title:mailAddress, style: UIAlertActionStyle.Default,handler: nil)
        
        showEmailAddressMenu.addAction(dispalyNameAction)
        showEmailAddressMenu.addAction(mailBoxAction)
        
        
        showEmailAddressMenu.popoverPresentationController?.sourceView=button;
        
        showEmailAddressMenu.popoverPresentationController?.sourceRect=button.bounds;
        
        
        self.presentViewController(showEmailAddressMenu, animated: true, completion: nil)
    }
    
    //MARK:show or hide mailto and maincc
    func hideMailToCC(button: UIButton)
    {
        //        let mainStoryboard = UIStoryboard(name:"Main", bundle:nil)
        //        let viewController = mainStoryboard.instantiateInitialViewController()! as UIViewController
        //
        //        self.presentViewController(viewController, animated: true, completion:nil)
        button.selected = !button.selected;
        self.AutoLayoutView(button.selected)
    }
    
    //给作者写信
    func reportBug()
    {
        self.newTextMail("chinagis001@126.com");
    }
    
    //MARK:清空DetailView的内容
    func clearAll()
    {
        var navHeight:CGFloat=0;
        
        if let navCtrFrame=self.navigationController?.navigationBar.frame
        {
            navHeight=navCtrFrame.origin.y+navCtrFrame.height;
        }
        
        let bounds=self.view.bounds;
        self.mywebView.frame=CGRectMake(0,navHeight,bounds.width,bounds.height-navHeight);
        
        self.view.bringSubviewToFront(mywebView)
        
        self.message=nil;
        self.mywebView.webView.loadHTMLString("<div><br></div><div><br></div><div><br></div><h1 style=\"text-align: center;\">当前没有选择邮件</h1>", baseURL: nil);
    }
    
    //MARK:刷新邮件内容--1
    func RefreshMailData(session:MCOIMAPSession,mailid:MCOIMAPMessage,folder:String)
    {
        


        let header=mailid.header;

        self.mailSubject="\(header.subject)";//邮件主题
        

        self.mailSender = header.from//发件人
        self.mailDate = header.receivedDate;//收件日期
        
        var tmpmailCcLists=[MCOAddress]();
        var tmpmailToLists=[MCOAddress]();

        
        if header.to != nil
        {
            
            tmpmailToLists=header.to as! [MCOAddress];
        }
        
        if header.cc != nil
        {
            tmpmailCcLists=header.cc as! [MCOAddress];

        }
        
        self.setMailCcList(tmpmailCcLists)
        self.setMailToList(tmpmailToLists)
        

        
        self.session=session;
//        self.session.connectionLogger =
//            {
//                (connectionID, type, data)->Void in
//                
//                if data != nil
//                {
//                    let strtemp=NSString(data: data, encoding:NSUTF8StringEncoding);
//                    
//                    print(strtemp);
//                }
//        }
        self.folder=folder;
        self.message=mailid;
        

//        if self.attachments != nil{
//        print("attatch count=\(self.attachments.count)");
//        
//        if self.attachments.count>0
//        {
//            let attachment=self.attachments[0] as! MCOAttachment
//            print(attachment.filename);
//
//        }
//        }
        
        self.AutoLayoutView();

     
        self.refresh();
        
        //设置邮件状态为已读
        
     
        
    }
    

/*
    //UIWebViewDelegate//实现自动加载邮件中的图片

    func webView(webView: UIWebView,
        shouldStartLoadWithRequest request: NSURLRequest,
        navigationType: UIWebViewNavigationType) -> Bool
    {
        let responseRequest = self.webView(self.mywebView,resource:nil,willSendRequest:request,redirectResponse:nil,fromDataSource:nil);
        
        if responseRequest == request
        {
            return true;
        } else {
            self.mywebView.loadRequest(responseRequest);
            return false;
        }

    }

 
    func webView(sender:UIWebView,resource:AnyObject?,willSendRequest request:NSURLRequest, redirectResponse:NSURLResponse?,fromDataSource:AnyObject?)->NSURLRequest
{
    
    if request.URL!.scheme=="x-mailcore-msgviewloaded"
    {
       self.loadImages();
    }
    
    return request;
    
}
    

    // 加载网页中的图片
    func loadImages()
    {
   
        let result = self.mywebView.stringByEvaluatingJavaScriptFromString("findCIDImageURL()");
        
    print("-----加载网页中的图片-----");
    print(result);
    
    if (result == nil || result=="")
    {
        return;
    }
    
    let data = result!.dataUsingEncoding(NSUTF8StringEncoding);
    var error:NSError? = nil;
        
        
        var imagesURLStrings:[String]?=nil;
        
        do
        {
        
            try imagesURLStrings = NSJSONSerialization.JSONObjectWithData(data! ,options:NSJSONReadingOptions()) as? [String];
        }
        catch
        {
            return;
        }
    
    for urlString in imagesURLStrings!
    {
        var part:MCOAbstractPart? = nil;
        var url = NSURL(string:urlString);
        
    
    if self._isCID(url!)
    {
        part = self._partForCIDURL(url!);
    }
    else if self._isXMailcoreImage(url!)
    {
        let specifier = url!.resourceSpecifier;
        let partUniqueID = specifier;
        part = self._partForUniqueID(partUniqueID);
    }
    
    if (part == nil)
    {
        continue;
    }
    
    let partUniqueID = part!.uniqueID;
        
        
        let attachment:MCOAttachment  = (mymsgPaser!.partForUniqueID(partUniqueID) as? MCOAttachment)!;
        
    var data = attachment.data;
    
    if data != nil
    {
    
    //获取文件路径
    let tmpDirectory = NSTemporaryDirectory();
    let filePath =
        NSURL(fileURLWithPath: tmpDirectory).URLByAppendingPathComponent(attachment.filename).path!;
    
    let fileManger=NSFileManager.defaultManager;
    if !fileManger().fileExistsAtPath(filePath)
    {
        //不存在就去请求加载
        let attachmentData=attachment.data;
        attachmentData.writeToFile(filePath,atomically:true);
        NSLog("资源：%@已经下载至%@", attachment.filename,filePath);
    }
    
    let cacheURL = NSURL.fileURLWithPath(filePath);
        
    let args:NSDictionary=["URLKey": urlString,"LocalPathKey": cacheURL.absoluteString];
    
    let jsonString = self._jsonEscapedStringFromDictionary(args);
    let replaceScript = "replaceImageSrc\(jsonString)";
    self.mywebView.stringByEvaluatingJavaScriptFromString(replaceScript);
    }
    }
    }

    func _jsonEscapedStringFromDictionary(dictionary:NSDictionary)->String
    
    {
        
        do
        {
            
            let json = try NSJSONSerialization.dataWithJSONObject(dictionary,options:NSJSONWritingOptions())
            
            let jsonString = NSString(data:json,encoding:NSUTF8StringEncoding) as! String
            
            return jsonString;
        }
        catch
        {
            return "";
        }

    

    }
    
    func _cacheJPEGImageData(imageData:NSData,withFilename filename:String)->NSURL
    {
    
    let path = (NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(filename)).URLByAppendingPathComponent("jpg").path!;
    imageData.writeToFile(path,atomically:true);
    return NSURL.fileURLWithPath(path);
    }
    
    func _partForCIDURL(url:NSURL)->MCOAbstractPart
    {
        return message.partForContentID(url.resourceSpecifier);
    }
    
    func _partForUniqueID(partUniqueID:String)->MCOAbstractPart
    {
        return message.partForUniqueID(partUniqueID);
    }
    
    
    func _isCID(url:NSURL)->Bool
    {
        let theScheme = url.scheme;
        if theScheme.caseInsensitiveCompare("cid") == NSComparisonResult.OrderedSame
        {
            return true;
        }
        return false;
    }
    
    func _isXMailcoreImage(url:NSURL)->Bool
    {
       let theScheme = url.scheme;
        if theScheme.caseInsensitiveCompare("x-mailcore-image") == NSComparisonResult.OrderedSame

    {
        return true;
  
        }
    return false;
    }
*/

    //MARK:编写新邮件
    func newMail(sender: AnyObject) {
        
        let composeMenu = UIAlertController(title: nil, message: BaseFunction.getIntenetString("新邮件选项"), preferredStyle: .ActionSheet)
        
        let handwrittenAction = UIAlertAction(title:BaseFunction.getIntenetString("手写邮件"), style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
            //added by shiww,弹出手写邮件编写界面
            let popVC = UIStoryboard(name: "Board", bundle: nil).instantiateInitialViewController()! as! BoardViewController;
            
            popVC.mailTopic=self.mailTopicNewTemplate;//设置邮件主题模板

            
            popVC.imapsession=self.session;//保存到草稿箱时要用

            popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            let popOverController = popVC.popoverPresentationController
            popVC.preferredContentSize = CGSize(width: 750,height: 1000);
            popOverController?.permittedArrowDirections = .Any
            self.presentViewController(popVC, animated: true, completion: nil)
            
        };
        
        let digitalmailAction = UIAlertAction(title: BaseFunction.getIntenetString("普通邮件"), style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
          //  print("普通邮件代码实现在此!");
            
            self.newTextMail();
            
            
            
        };
        
        
//        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        
        composeMenu.addAction(handwrittenAction)
        composeMenu.addAction(digitalmailAction)
        
//        composeMenu.addAction(cancelAction)
        
        composeMenu.popoverPresentationController?.sourceView=sender.view;
        
        composeMenu.popoverPresentationController?.sourceRect=sender.view!.bounds;
        
        
        self.presentViewController(composeMenu, animated: true, completion: nil)

        
 
    }
    
    //MARK:非手写邮件
    func newTextMail(mailAddress:String="")
    {
        //added by shiww,弹出手写邮件编写界面
        let popVC = TextMailComposerViewController();
        
        popVC.mailTopic=self.mailTopicNewTemplate;//设置邮件主题模板
        popVC.mailContentTemplate=self.mailContentTemplate;//邮件内容模板
        
        popVC.imapsession=self.session;//邮件保存到草稿箱时有用
        if mailAddress.characters.count>0
        {
            popVC.mailTo=[MCOAddress(mailbox:mailAddress)]
        }
  
        
        popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        let popOverController = popVC.popoverPresentationController
        popVC.preferredContentSize=CGSizeMake(750,1000);
        popOverController?.permittedArrowDirections = .Any
        self.presentViewController(popVC, animated: true, completion: nil)

        
    }
    
    //MARK:全部回复邮件
    func replyMail(sender: AnyObject) {
        
        let composeMenu = UIAlertController(title: nil, message: BaseFunction.getIntenetString("回复邮件选项"), preferredStyle: .ActionSheet)
        
        let handwrittenAction = UIAlertAction(title: BaseFunction.getIntenetString("手写邮件"), style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
            //added by shiww,弹出手写邮件编写界面
            self.doReplyMail(sender.tag)
            
        };
        
        let digitalmailAction = UIAlertAction(title:BaseFunction.getIntenetString("普通邮件"), style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
            //print("普通邮件代码实现在此!");
            
            self.doReplyTextMail(sender.tag)
            
            
            
            
        };
        
        
        //        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        
        composeMenu.addAction(handwrittenAction)
        composeMenu.addAction(digitalmailAction)
        
        //        composeMenu.addAction(cancelAction)
        
        composeMenu.popoverPresentationController?.sourceView=sender.view;
        
        composeMenu.popoverPresentationController?.sourceRect=sender.view!.bounds;
        
        
        self.presentViewController(composeMenu, animated: true, completion: nil)
        
        
      }
    
    
    //MARK:回复普通邮件
    //MARK:非手写邮件
    func doReplyTextMail(tag:Int)
    {
        if self.message==nil
        {
            return;
        }

        //added by shiww,弹出普通邮件编写界面
        let popVC = TextMailComposerViewController();
        popVC.imapsession=self.session;//邮件保存到草稿箱时有用

        
        
        popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        let popOverController = popVC.popoverPresentationController
        popVC.preferredContentSize=CGSizeMake(750,1000);
        popOverController?.permittedArrowDirections = .Any

        let header=self.message.header;
        
        //self.mailSubject=header.subject;//邮件主题
        
        
        
        var tmpmailCcLists=[MCOAddress]();
        var tmpmailToLists=[MCOAddress]();
        
        if tag==1 //回复全部,else 回复发件人
        {
            
            if header.to != nil
            {
                
                tmpmailCcLists=header.to as! [MCOAddress];
            }
            
            if header.cc != nil
            {
                tmpmailCcLists.appendContentsOf(
                    header.cc as! [MCOAddress]);
                
            }
        }
        
        tmpmailToLists.append(header.from);
        
        popVC.mailTo=tmpmailToLists;
        popVC.mailCc=tmpmailCcLists;
        popVC.mailOrign=self.mywebView.exportViewToPng();
        
        popVC.mailTopic=self.mailTopicReplyTemplate+header.subject;//主题采用"回复"模板
        popVC.mailContentTemplate=self.mailContentTemplate;//邮件内容模板
        
        
        self.presentViewController(popVC, animated: true, completion: nil)

        
    }
    

    //MARK:回复手写邮件
    func doReplyMail(tag:Int)
    {
        
        if self.message==nil
        {
            return;
        }
        //added by shiww,弹出邮件编写界面
        let popVC = UIStoryboard(name: "Board", bundle: nil).instantiateInitialViewController()! as! BoardViewController

        popVC.imapsession=self.session;//保存到草稿箱时要用
        


        popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        let popOverController = popVC.popoverPresentationController
        popVC.preferredContentSize=CGSizeMake(750,1000);
        popOverController?.permittedArrowDirections = .Any
        
        let header=self.message.header;
        
        //self.mailSubject=header.subject;//邮件主题
        popVC.mailTopic=self.mailTopicReplyTemplate+header.subject;//主题采用"回复"模板

        
        
        var tmpmailCcLists=[MCOAddress]();
        var tmpmailToLists=[MCOAddress]();
        
        if tag==1 //回复全部,else 回复发件人
        {
            
            if header.to != nil
            {
                
                tmpmailCcLists=header.to as! [MCOAddress];
            }
            
            if header.cc != nil
            {
                tmpmailCcLists.appendContentsOf(
                    header.cc as! [MCOAddress]);
                
            }
        }
        
        tmpmailToLists.append(header.from);
        
        //popVC.mailTopic="回复:from石伟伟"+header.subject;//邮件主题;
        popVC.mailTo=tmpmailToLists;
        popVC.mailCc=tmpmailCcLists;
        popVC.mailOrign=self.mywebView.exportViewToPng();
        
        
        self.presentViewController(popVC, animated: true, completion: nil)
        

    }
    
    //MARK:转发邮件
    func forwardMail(sender: AnyObject) {
       // self.mywebView.exportViewToPng();
        let forwardMenu = UIAlertController(title: nil, message: BaseFunction.getIntenetString("转发选项"), preferredStyle: .ActionSheet)
        
        let forwardhandwithattachAction = UIAlertAction(title: BaseFunction.getIntenetString("手写邮件-带附件"), style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
           // print("带附件代码实现在此!");
            self.forwardMailOperation(true);
        
        };
        
        let forwardhandnoattachAction = UIAlertAction(title: BaseFunction.getIntenetString("手写邮件-不带附件"), style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
          // print("不带附件代码实现在此!");
            self.forwardMailOperation(false);

            
        };
        
        let forwardtextwithattachAction = UIAlertAction(title: BaseFunction.getIntenetString("普通邮件-带附件"), style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
         //   print("带附件代码转发普通邮件年实现在此!");
            self.forwardTextMailOperation(true);
            
        };
        
        let forwardtextnoattachAction = UIAlertAction(title: BaseFunction.getIntenetString("普通邮件-不带附件"), style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
          //  print("不带附件代码转发普通邮件年实现在此!");
            self.forwardTextMailOperation(false);
            
            
        };
        

        
        
        let cancelAction = UIAlertAction(title: BaseFunction.getIntenetString("CANCEL"), style: UIAlertActionStyle.Cancel, handler: nil)
        
        forwardMenu.addAction(forwardhandwithattachAction)
        forwardMenu.addAction(forwardhandnoattachAction)
        forwardMenu.addAction(forwardtextwithattachAction)
        forwardMenu.addAction(forwardtextnoattachAction)

        
        forwardMenu.addAction(cancelAction)
        
        forwardMenu.popoverPresentationController?.sourceView=sender.view;
        
        forwardMenu.popoverPresentationController?.sourceRect=sender.view!.bounds;

        
        self.presentViewController(forwardMenu, animated: true, completion: nil)
        
        
    }
    
    //MARK：转发普通邮件--带附件或不带附件
    private func forwardTextMailOperation(withAttachment:Bool=true)
    {
        if self.message==nil
        {
            return;
        }
        //added by shiww,弹出邮件编写界面
        let popVC = TextMailComposerViewController();
        popVC.imapsession=self.session;//邮件保存到草稿箱时有用

        
        popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        let popOverController = popVC.popoverPresentationController
        popVC.preferredContentSize=CGSizeMake(750,1000);
        popOverController?.permittedArrowDirections = .Any
        
        let header=self.message.header;
        
        
        
        popVC.mailTopic=self.mailTopicforwardTemplate+header.subject;//邮件主题模板;
        popVC.mailContentTemplate=self.mailContentTemplate;//邮件内容模板
        //把当前邮件转化为图片转发
        //popVC.mailOrign=self.mywebView.exportViewToPng();
        
        //把当前邮件原文转发
        //1.首先获得邮件HTMLBODY
        
        let imapsession=self.session;
        
        let fetchContentOp = imapsession.fetchMessageOperationWithFolder(self.folder,uid:self.message.uid,urgent:true);
        
        fetchContentOp.start()
            {
                (error:NSError?, data:NSData?)->Void in
                if error==nil
                {
                    
                    let msgPareser = MCOMessageParser(data:data);
                    
                 //   let bodyHtml=msgPareser.htmlBodyRendering();
                    let bodyHtml=msgPareser.htmlRenderingWithDelegate(nil);

                    
                    popVC.mailHtmlbodyOrigin=nil;
                    popVC.mailHtmlbodyOrigin=bodyHtml;//邮件正文
                    
                    popVC.mailOriginAttachments=nil;
                    popVC.mailOriginRelatedAttachments=nil;
                    
                    // 添加正文里的附加资源
                    let inattachments = msgPareser.htmlInlineAttachments;
                    
                    
                    popVC.mailOriginRelatedAttachments=inattachments() as? [MCOAttachment];
                    
                    
                    if withAttachment //要带附件
                    {
                        
                        let attachments=msgPareser.attachments;
                        
                        popVC.mailOriginAttachments=attachments() as? [MCOAttachment];
                    }
                    
                    self.presentViewController(popVC, animated: true, completion: nil)
                    
                }
                else
                {
                    print("获取邮件全文信息失败!")
                }
                
                
        }
        
    }
    

    
    //MARK：转发邮件--带附件或不带附件
    private func forwardMailOperation(withAttachment:Bool=true)
    {
        if self.message==nil
        {
            return;
        }
        //added by shiww,弹出邮件编写界面
        let popVC = UIStoryboard(name: "Board", bundle: nil).instantiateInitialViewController()! as! BoardViewController
        
        popVC.imapsession=self.session;//保存到草稿箱时要用
        
        popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        let popOverController = popVC.popoverPresentationController
        
        popVC.preferredContentSize = CGSize(width: 750,height: 1000);
        
        popOverController?.permittedArrowDirections = .Any
        
        let header=self.message.header;
        
        
        
        popVC.mailTopic=self.mailTopicforwardTemplate+header.subject;//邮件主题模板;
        //把当前邮件转化为图片转发
        //popVC.mailOrign=self.mywebView.exportViewToPng();
        
        //把当前邮件原文转发
        //1.首先获得邮件HTMLBODY
        
        let imapsession=self.session;
        
        let fetchContentOp = imapsession.fetchMessageOperationWithFolder(self.folder,uid:self.message.uid,urgent:true);
        
        fetchContentOp.start()
            {
                (error:NSError?, data:NSData?)->Void in
                if error==nil
                {
                    
                    let msgPareser = MCOMessageParser(data:data);
                    
                    let bodyHtml=msgPareser.htmlBodyRendering();
                    
                    popVC.mailHtmlbodyOrigin=nil;
                    popVC.mailHtmlbodyOrigin=bodyHtml;//邮件正文
                    
                    popVC.mailOriginAttachments=nil;
                    popVC.mailOriginRelatedAttachments=nil;
                    
                    // 添加正文里的附加资源
                    let inattachments = msgPareser.htmlInlineAttachments;
                    
                    
                    popVC.mailOriginRelatedAttachments=inattachments() as? [MCOAttachment];

                    
                    if withAttachment //要带附件
                    {
                        
                        let attachments=msgPareser.attachments;
                        
                        popVC.mailOriginAttachments=attachments() as? [MCOAttachment];
                    }
                    
                    self.presentViewController(popVC, animated: true, completion: nil)
                    
                }
                else
                {
                    print("获取邮件全文信息失败!")
                }
                
                
        }
        
    }
    
    //MARK:点击下载和预览附件
    func previewAttach(sender: UIEmailButton)
    {
        sender.enabled=false;//避免多次点击
        
        let index=sender.tag;
        
        let attachment=self.message.attachments()[index];
        
        if !(attachment is MCOIMAPPart)//paser出来的可以直接保存
        {
            return;
        }
        
        let msgpart=attachment as! MCOIMAPPart;
        
        let filename=attachment.filename//sender.mailAddress.displayName;

        var tmpDirectory = NSHomeDirectory() + "/Library/Caches"
;
        tmpDirectory=tmpDirectory+"/"+filename;
        
        let isDownloaded=NSFileManager.defaultManager().fileExistsAtPath(tmpDirectory);//判断一下是否已经下载
        
        if isDownloaded//已经下载
        {
            self.tempFilePath=tmpDirectory;
            let ql = QLPreviewController()
            
            ql.dataSource  = self;
            
            self.presentViewController(ql, animated: true)
            {
                sender.enabled=true;//又可以点击了
            }
        }
        else//未下载
        {
           
           // let part = self.message.mainPart as! MCOAbstractPart;//.partForUniqueID(msgpart.partUniqueID);
            
            
            let imapsession=self.session;
  
            let op = imapsession.fetchMessageAttachmentOperationWithFolder(self.folder,uid:self.message.uid,partID:msgpart.partID,encoding:msgpart.encoding,urgent:false);
            
            //监测一下附件下载的进度
            let oldBtnTitle=sender.titleForState(.Normal);
            
            op.progress =
                {
                    (nowValue:UInt32,totalValue:UInt32)->Void in
                    
//                    print("nowvalue=\(nowValue),totalValue=\(totalValue)");//,percent=\(nowValue*100/totalValue)");
                    if totalValue != 0
                    {
                        let btnTitle=String(format: BaseFunction.getIntenetString("正在下载,已完成%2d%%"),nowValue*100/totalValue);
                        sender.setTitle(btnTitle, forState: .Normal)
                    }
            };
            
            
            op.start()
                {
                    (error:NSError?,data:NSData?)->Void in
                    if error==nil
                    {
                        if let attachData=data
                        {
                            attachData.writeToFile(tmpDirectory,atomically:true);
                            self.tempFilePath=tmpDirectory;
                            let ql = QLPreviewController()
                            
                            ql.dataSource  = self;
                            
                            self.presentViewController(ql, animated: true)
                            {
                                sender.enabled=true;//又可以点击了
                                sender.setTitle(oldBtnTitle, forState: .Normal)

                            }
                            

                        }
                        
                        
                    }
                    else{
                      //  print("附件获取失败!");
                        sender.enabled=true;//又可以点击了
                        sender.setTitle(oldBtnTitle, forState: .Normal)
                    }
            }
            
            //attachment.writeToFile(tmpDirectory,atomically:true);
        }
        
    }
    //MARK:Quick Look支持--1
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int{
        return 1
    }
    //MARK:Quick Look支持--2

    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem
    {
        let doc = NSURL(fileURLWithPath: self.tempFilePath)
        return doc;
    }
   
}

//MARK:MCOMessageView的扩展,可以将webview的内容保存为图片
extension MCOMessageView
{
    //处理点击邮件地址发送邮件操作
    func newMail(mailAddress:String)->Void
    {
        
        let address=(mailAddress as NSString).substringFromIndex(7);//截去mailto:

        //print(address);

        
        let composeMenu = UIAlertController(title: BaseFunction.getIntenetString("新邮件选项"), message:nil, preferredStyle:.Alert)
        
        let appDelegate=UIApplication.sharedApplication().delegate as! AppDelegate;
        
        let splitViewController=appDelegate.window!.rootViewController as! UISplitViewController
        
        let controllers = splitViewController.viewControllers
        
        let detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController

        
        let handwrittenAction = UIAlertAction(title:BaseFunction.getIntenetString("手写邮件"), style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
            //added by shiww,弹出手写邮件编写界面
            let popVC = UIStoryboard(name: "Board", bundle: nil).instantiateInitialViewController()! as! BoardViewController;
            
            popVC.mailTopic=detailViewController!.mailTopicNewTemplate;//设置邮件主题模板
            popVC.mailTo=[MCOAddress(mailbox:address)];
            
            
            popVC.imapsession=detailViewController!.session;//保存到草稿箱时要用
            
            popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            let popOverController = popVC.popoverPresentationController
            popVC.preferredContentSize = CGSize(width: 750,height: 1000);
            popOverController?.permittedArrowDirections = .Any
            detailViewController!.presentViewController(popVC, animated: true, completion: nil)
            
        };
        
        let digitalmailAction = UIAlertAction(title: BaseFunction.getIntenetString("普通邮件"), style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
            //  print("普通邮件代码实现在此!");
            
            detailViewController!.newTextMail(address);
            
            
            
        };
        
        
            let cancelAction = UIAlertAction(title: BaseFunction.getIntenetString("CANCEL"), style: UIAlertActionStyle.Cancel, handler: nil)
        
        composeMenu.addAction(handwrittenAction)
        composeMenu.addAction(digitalmailAction)
        
                composeMenu.addAction(cancelAction)
        
        /*
        composeMenu.popoverPresentationController?.sourceView=self;
        
        let sourceRect=CGRectMake(400,300, 10, 10);

        
        composeMenu.popoverPresentationController?.sourceRect=sourceRect;*/
        
        
        detailViewController!.presentViewController(composeMenu, animated: true, completion: nil)
        
        
    }

    //处理长按保存图片操作
    func saveImage(pnt:CGPoint,image:UIImage)->Void
    {
        //还需仔细测试
        let saveImageMenu = UIAlertController(title: nil, message:nil, preferredStyle: .ActionSheet)
        
        let saveImageAction = UIAlertAction(title:BaseFunction.getIntenetString("保存图片"), style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)            
            //added by shiww,保存图片
         };
        
        let cancelImageAction = UIAlertAction(title:BaseFunction.getIntenetString("CANCEL"), style: UIAlertActionStyle.Default,handler:nil)
        
        
        saveImageMenu.addAction(saveImageAction)
        saveImageMenu.addAction(cancelImageAction)
        
        
        saveImageMenu.popoverPresentationController?.sourceView=self;
        
        let sourceRect=CGRectMake(pnt.x, pnt.y, 10, 10);
        
        saveImageMenu.popoverPresentationController?.sourceRect=sourceRect;
        
        let appDelegate=UIApplication.sharedApplication().delegate as! AppDelegate;
        
        let splitViewController=appDelegate.window!.rootViewController as! UISplitViewController
        
        let controllers = splitViewController.viewControllers
        
        let detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        
        detailViewController!.presentViewController(saveImageMenu,animated: true, completion: nil)
        
        
    }
    //整个WebView视图保存为图片
    func exportViewToPng()->UIImage
    {
        let scrollView=self.webView.scrollView;
        
        let boundsSize = self.webView.bounds.size;
        let boundsWidth = self.webView.bounds.size.width;
        let boundsHeight = self.webView.bounds.size.height;
        
        let offset = scrollView.contentOffset;
        scrollView.setContentOffset(CGPointMake(0,0),animated: false);
        
        
        var contentHeight = scrollView.contentSize.height;
         var images = [UIImage]();
        while (contentHeight > 0)
        {
            UIGraphicsBeginImageContext(boundsSize);
            self.layer.renderInContext(UIGraphicsGetCurrentContext()!);
            let image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            images.append(image);
            
            let offsetY = scrollView.contentOffset.y;
            scrollView.setContentOffset(CGPointMake(0, offsetY + boundsHeight),animated: false);
            contentHeight -= boundsHeight;
        }
        
        scrollView.setContentOffset(offset,animated:false);
        
        UIGraphicsBeginImageContext(scrollView.contentSize);
        
        var idx:CGFloat=0;
        for image in images
        {
            image.drawInRect(CGRectMake(0, boundsHeight*idx, boundsWidth, boundsHeight));
            idx++;
        };
        let fullImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
//        UIImageWriteToSavedPhotosAlbum(fullImage, self,nil, nil)

        return fullImage;
    }
    
}

