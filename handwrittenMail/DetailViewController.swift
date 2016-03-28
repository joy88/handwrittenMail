//
//  DetailViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/5.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit
import QuickLook

class DetailViewController:MCTMsgViewController,RefreshMailDelegate,QLPreviewControllerDataSource
{
    //MARK:Open In Controller,must like this
    private var docController:UIDocumentInteractionController?
    

    var mywebView=MCOMessageView()//MARK:邮件正文
    
    private var mailFromLbl=UILabel()//MARK:邮件正文"发件人"标签
    private var mailFromBtn=UIEmailButton()//MARK:邮件正文发件人显示按钮
    private var infoHideBtn=UIButton()//MARK:邮件正文"隐藏"或"显示"按钮
    
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

    
    
    var mailSender=MCOAddress(displayName: "石伟伟", mailbox: "Chinagis001@126.com")!;//MARK:发件人地址
    private var mailToLists=[MCOAddress]();//MARK:收件人地址列表
    private var mailCcLists=[MCOAddress]();//MARK:抄送人地址列表
    var mailSubject="邮件主题";
    var mailDate=NSDate();//MARK:邮件日期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.leftBarButtonItem?.title="Inbox"
        //1.右边第一个按钮
        //编写新邮件
        let composeButton = UIBarButtonItem(barButtonSystemItem:.Compose, target: self, action:#selector(DetailViewController.newMail(_:)))
        //2.回复邮件至发送人
        let replyButton = UIBarButtonItem(barButtonSystemItem:.Reply, target: self, action: #selector(DetailViewController.replyMail(_:)))
        replyButton.tag=0;//==1 代表回复全部
        
        //3.回复邮件至所有
        
        //如果是自定义图片,必须得有imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal),否则是个纯色图片
        let replyallButton = UIBarButtonItem(image: UIImage(named: "replyall")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self,action: #selector(DetailViewController.replyMail(_:)))
        replyallButton.tag=1;//==1 代表回复全部
        
        //4.转发邮件
        
        let forwardButton = UIBarButtonItem(image: UIImage(named: "forward")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self,action: #selector(DetailViewController.forwardMail(_:)))



        
        //3.delete mail
        let trashButton = UIBarButtonItem(barButtonSystemItem:.Trash, target: self, action: nil)
        
        let organizeButton = UIBarButtonItem(barButtonSystemItem:.Organize, target: self, action: nil)
        
        
        
        let rightItems=[composeButton,replyButton,replyallButton,forwardButton,trashButton,organizeButton];
        
        
        self.navigationItem.rightBarButtonItems = rightItems
        
        //开始生成窗口要素
   /*     let temp=[MCOAddress(displayName: "石伟伟1", mailbox: "Chinagis001@126.com")!,MCOAddress(displayName: "石伟伟2", mailbox: "Chinagis001@126.com")!,MCOAddress(displayName: "石伟伟3", mailbox: "Chinagis001@126.com")!,MCOAddress(displayName: "石伟伟4", mailbox: "Chinagis001@126.com")!]
        
        self.setMailToList(temp);//        var mailToBtns=[UIEmailButton]();//收件人

        self.setMailCcList(temp);//        var mailCcBtns=[UIEmailButton]()//抄送人
         */
 
        
//        var webView=UIWebView()//邮件正文
        
         self.mywebView=self.messageView;
        self.messageView.setHtmlContent("<html><head><title>Hello</title></head><body><h1>邮件正在加载中......</h1><ul><li>123</li><li>321</li><li>1234567</li></ul></body></html>")
 
//        self.mywebView.prefetchIMAPAttachmentsEnabled=true;

        self.mywebView.prefetchIMAPImagesEnabled=true;

//
//        var mailFromLbl=UILabel()//"发件人"标签
        self.view.addSubview(mailFromLbl)

//        var mailFromBtn=UIEmailButton()//发件人显示按钮
        mailFromBtn.addTarget(self,action: #selector(DetailViewController.emailClicked(_:)),forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(mailFromBtn)
        

//        var infoHideBtn=UIButton()//"隐藏"或"显示"按钮
        //show or hide mainto and maincc
        infoHideBtn.addTarget(self,action: #selector(DetailViewController.hideMailToCC(_:)),forControlEvents: UIControlEvents.TouchUpInside)

        self.view.addSubview(infoHideBtn)

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
        
        self.AutoLayoutView(infoHideBtn.selected);

        
        //监测设备的旋转
        //感知设备方向 - 开启监听设备方向
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        //添加通知，监听设备方向改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.receivedRotation),
            name: UIDeviceOrientationDidChangeNotification, object: nil)
     
        //关闭设备监听
        //UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
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
          mailFromLbl.setLabel("发件人:", x: marginSpace, y: top1, width: ctrWidth, height: ctrHight, fonSize: 18, isBold: true, color: black)
        
//        var mailFromBtn=UIEmailButton()//发件人显示按钮
        mailFromBtn.setEmailTitle(self.mailSender, x: (marginSpace+ctrWidth+xSpace), y: top1, width: ctrWidth, height: ctrHight, fonSize: 17, isBold: true, color: blue);
        
//        var infoHideBtn=UIButton()//"隐藏"或"显示"按钮
        infoHideBtn.selected=isHide;
        
        infoHideBtn.setTitle("显示", forState:.Selected);
        infoHideBtn.setTitle("隐藏", forState: .Normal);
        infoHideBtn.frame=CGRectMake(bounds.width-ctrWidth-2*marginSpace,top1,ctrWidth,ctrHight)
        infoHideBtn.setTitleColor(blue, forState: .Normal);//不加上这句,看不到,可以字体是白色的原因吧
        
//        print(infoHideBtn.frame);
//        
//        var mailToLbl=UILabel()//"收件人"标签
        
        top2=top1+ctrHight+ySpace
        
        mailToLbl.setLabel("收件人:", x: marginSpace, y: top2, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: false, color: black);
        
        
//        var mailToBtns=[UIEmailButton]();//收件人
        

        top3=self.AutoLayoutMailListBtn(self.mailToBtns,viewWidth: bounds.width-marginSpace, X: marginSpace+ctrWidth+xSpace, Y: top2, Width: ctrWidth, Hight: ctrHight, xSpace: xSpace, ySpace: ySpace, FontSize: 16, color: blue);

        
        
//        var mailCcLbl=UILabel();//"抄送"按钮
        top3=top3+ySpace;
        
        mailCcLbl.setLabel("抄送:", x: marginSpace, y: top3, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: false, color: black);

//        var mailCcBtns=[UIEmailButton]()//抄送人
        
        top4=self.AutoLayoutMailListBtn(self.mailCcBtns,viewWidth: bounds.width-marginSpace, X: marginSpace+ctrWidth+xSpace, Y: top3, Width: ctrWidth, Hight: ctrHight, xSpace: xSpace, ySpace: ySpace, FontSize: 16, color: blue);

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
        

        
        mailDateLbl.setLabel(strMailDate, x: marginSpace, y: top6, width: bounds.width-2*marginSpace, height: ctrHight, fonSize: 16, isBold: false, color: black);

        //附件标签和附件按钮
        top7=top6+ctrHight+ySpace;

        setAttachmentList();
        
        top8=top7;
        
        
        
        if (self.message != nil) && (self.message.attachments().count>0)
        {
            attachLbl.setLabel("附件:", x: marginSpace, y: top7, width: ctrWidth, height: ctrHight, fonSize: 19, isBold: true, color: red);
            
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
            
            let fileSize=Double(attachment.decodedSize())/(1024*1024);
            
            var strFileSize=String(format: "%.2f", fileSize)
            
            strFileSize = attachment.filename+"("+strFileSize+"M)";
            
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
        
        var tmpDirectory = NSTemporaryDirectory();
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
            
            op.start()
                {
                    (error:NSError?,data:NSData?)->Void in
                    if error==nil
                    {
                        if let attachData=data
                        {
                            attachData.writeToFile(tmpDirectory,atomically:true);
                            self.tempFilePath=tmpDirectory;
                            
                            self.shareDocument(self.tempFilePath,sender:sender)

                        }
                        
                        
                    }
                    else{
                        print("附件获取失败!");
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
//        let mainStoryboard = UIStoryboard(name:"Main", bundle:nil)
//        let viewController = mainStoryboard.instantiateInitialViewController()! as UIViewController
//        
//        self.presentViewController(viewController, animated: true, completion:nil)
        print(button.mailAddress.mailbox)
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
    
    //MARK:刷新邮件内容--1
    func RefreshMailData(session:MCOIMAPSession,mailid:MCOIMAPMessage,folder:String)
    {
        


        let header=mailid.header;

        self.mailSubject=header.subject;//邮件主题
        

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
        let composeMenu = UIAlertController(title: nil, message: "新邮件选项", preferredStyle: .ActionSheet)
        
        let handwrittenAction = UIAlertAction(title: "手写邮件", style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
            //added by shiww,弹出手写邮件编写界面
            let popVC = UIStoryboard(name: "Board", bundle: nil).instantiateInitialViewController()! as UIViewController
            popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            let popOverController = popVC.popoverPresentationController
            popVC.preferredContentSize=CGSizeMake(820,1093);
            popOverController?.permittedArrowDirections = .Any
            self.presentViewController(popVC, animated: true, completion: nil)
            
        };
        
        let digitalmailAction = UIAlertAction(title: "普通邮件", style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
            print("普通邮件代码实现在此!");
            
        };
        
        
//        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        
        composeMenu.addAction(handwrittenAction)
        composeMenu.addAction(digitalmailAction)
        
//        composeMenu.addAction(cancelAction)
        
        composeMenu.popoverPresentationController?.sourceView=sender.view;
        
        composeMenu.popoverPresentationController?.sourceRect=sender.view!.bounds;
        
        
        self.presentViewController(composeMenu, animated: true, completion: nil)

        
 
    }
    
    //MARK:全部回复邮件
    func replyMail(sender: AnyObject) {
        if self.message==nil
        {
            return;
        }
        //added by shiww,弹出邮件编写界面
        let popVC = UIStoryboard(name: "Board", bundle: nil).instantiateInitialViewController()! as! BoardViewController
        popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        let popOverController = popVC.popoverPresentationController
        popVC.preferredContentSize=CGSizeMake(820,1093);
        popOverController?.permittedArrowDirections = .Any
        
        let header=self.message.header;
        
        //self.mailSubject=header.subject;//邮件主题
        
        
        
        var tmpmailCcLists=[MCOAddress]();
        var tmpmailToLists=[MCOAddress]();
        
        if sender.tag==1 //回复全部,else 回复发件人
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
        
        popVC.mailTopic="回复:from石伟伟"+header.subject;//邮件主题;
        popVC.mailTo=tmpmailToLists;
        popVC.mailCc=tmpmailCcLists;
        popVC.mailOrign=self.mywebView.exportViewToPng();

        
        self.presentViewController(popVC, animated: true, completion: nil)
        
    }
    
    
    //MARK:转发邮件
    func forwardMail(sender: AnyObject) {
       // self.mywebView.exportViewToPng();
        let forwardMenu = UIAlertController(title: nil, message: "转发选项", preferredStyle: .ActionSheet)
        
        let readAction = UIAlertAction(title: "带附件", style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
            print("带附件代码实现在此!");
            self.forwardMailOperation(true);
        
        };
        
        let unreadAction = UIAlertAction(title: "不带附件", style: UIAlertActionStyle.Default)
        {
            (UIAlertAction) -> Void in
            
           print("不带附件代码实现在此!");
            self.forwardMailOperation(false);

            
        };
        
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        
        forwardMenu.addAction(readAction)
        forwardMenu.addAction(unreadAction)
        
        forwardMenu.addAction(cancelAction)
        
        forwardMenu.popoverPresentationController?.sourceView=sender.view;
        
        forwardMenu.popoverPresentationController?.sourceRect=sender.view!.bounds;

        
        self.presentViewController(forwardMenu, animated: true, completion: nil)
        
        
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
        popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        let popOverController = popVC.popoverPresentationController
        popVC.preferredContentSize=CGSizeMake(820,1093);
        popOverController?.permittedArrowDirections = .Any
        
        let header=self.message.header;
        
        
        
        popVC.mailTopic="from石伟伟 转发："+header.subject;//邮件主题;
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
        let index=sender.tag;
        let attachment=self.message.attachments()[index];
        
        if !(attachment is MCOIMAPPart)//paser出来的可以直接保存
        {
            return;
        }
        
        let msgpart=attachment as! MCOIMAPPart;
        
        let filename=attachment.filename//sender.mailAddress.displayName;

        var tmpDirectory = NSTemporaryDirectory();
        tmpDirectory=tmpDirectory+"/"+filename;
        
        let isDownloaded=NSFileManager.defaultManager().fileExistsAtPath(tmpDirectory);//判断一下是否已经下载
        
        if isDownloaded//已经下载
        {
            self.tempFilePath=tmpDirectory;
            let ql = QLPreviewController()
            
            ql.dataSource  = self;
            
            self.presentViewController(ql, animated: true, completion: nil)
        }
        else//未下载
        {
           
           // let part = self.message.mainPart as! MCOAbstractPart;//.partForUniqueID(msgpart.partUniqueID);
            
            
            let imapsession=self.session;
  
            let op = imapsession.fetchMessageAttachmentOperationWithFolder(self.folder,uid:self.message.uid,partID:msgpart.partID,encoding:msgpart.encoding,urgent:false);
            
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
                            
                            self.presentViewController(ql, animated: true, completion: nil)
                            

                        }
                        
                        
                    }
                    else{
                        print("附件获取失败!");
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

