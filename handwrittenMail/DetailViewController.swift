//
//  DetailViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/5.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit

class DetailViewController:MCTMsgViewController,RefreshMailDelegate
{
//    private var mymessage=MCOIMAPMessage();//当前打开的邮件
//    private var mymsgPaser:MCOMessageParser?;//邮件解析
    
    var mywebView=MCOMessageView()//邮件正文
    
    private var mailFromLbl=UILabel()//"发件人"标签
    private var mailFromBtn=UIEmailButton()//发件人显示按钮
    private var infoHideBtn=UIButton()//"隐藏"或"显示"按钮
    
    private var mailToLbl=UILabel()//"收件人"标签
    private var mailToBtns=[UIEmailButton]();//收件人
    private var mailCcLbl=UILabel();//"抄送"按钮
    private var mailCcBtns=[UIEmailButton]()//抄送人
    
    private var lineLbl=UILabel();//灰色分割线
    private var lineLbl2=UILabel();//灰色分割线


    
    private var subjectLbl=UILabel()//邮件主题
    private var mailDateLbl=UILabel()//邮件收到时间
    
    private var attachLbl=UILabel()//附件标签"附件"
    private var attachBtns=[UIEmailButton]();//附件按钮

    
    
    var mailSender=MCOAddress(displayName: "石伟伟", mailbox: "Chinagis001@126.com")!;//发件人地址
    private var mailToLists=[MCOAddress]();//收件人地址列表
    private var mailCcLists=[MCOAddress]();//抄送人地址列表
    var mailSubject="邮件主题";
    var mailDate=NSDate();//邮件日期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //1.右边第一个按钮
        //编写新邮件
        let composeButton = UIBarButtonItem(barButtonSystemItem:.Compose, target: self, action:"newMail:")
        //2.second
        let replyButton = UIBarButtonItem(barButtonSystemItem:.Reply, target: self, action: nil)
        let trashButton = UIBarButtonItem(barButtonSystemItem:.Trash, target: self, action: nil)
        
        let organizeButton = UIBarButtonItem(barButtonSystemItem:.Organize, target: self, action: nil)
        //如果是自定义图片,必须得有imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal),否则是个纯色图片
        let moreButton = UIBarButtonItem(image: UIImage(named: "master3")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self,action: nil)
        
        
        
        let rightItems=[composeButton,replyButton,trashButton,organizeButton,moreButton];
        
        
        self.navigationItem.rightBarButtonItems = rightItems
        
        //开始生成窗口要素
        let temp=[MCOAddress(displayName: "石伟伟1", mailbox: "Chinagis001@126.com")!,MCOAddress(displayName: "石伟伟2", mailbox: "Chinagis001@126.com")!,MCOAddress(displayName: "石伟伟3", mailbox: "Chinagis001@126.com")!,MCOAddress(displayName: "石伟伟4", mailbox: "Chinagis001@126.com")!]
        
        self.setMailToList(temp);//        var mailToBtns=[UIEmailButton]();//收件人

        self.setMailCcList(temp);//        var mailCcBtns=[UIEmailButton]()//抄送人
       
        
//        var webView=UIWebView()//邮件正文
        
         self.mywebView=self.messageView;
 
//        self.mywebView.prefetchIMAPAttachmentsEnabled=true;

        self.mywebView.prefetchIMAPImagesEnabled=true;

//
//        var mailFromLbl=UILabel()//"发件人"标签
        self.view.addSubview(mailFromLbl)

//        var mailFromBtn=UIEmailButton()//发件人显示按钮
        mailFromBtn.addTarget(self,action: "emailClicked:",forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(mailFromBtn)
        

//        var infoHideBtn=UIButton()//"隐藏"或"显示"按钮
        //show or hide mainto and maincc
        infoHideBtn.addTarget(self,action: "hideMailToCC:",forControlEvents: UIControlEvents.TouchUpInside)

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedRotation",
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

    //通知监听触发的方法
    func receivedRotation(){
        var device = UIDevice.currentDevice()
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
    
    
    //只创建按钮,不布局,收件人列表
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
            var tmpBtn=UIEmailButton();
            tmpBtn.mailAddress=email;
            tmpBtn.addTarget(self,action: "emailClicked:",forControlEvents: UIControlEvents.TouchUpInside)
            mailToBtns.append(tmpBtn);
            self.view.addSubview(tmpBtn);
            
        }
        
    }
    
    //只创建按钮,不布局,抄送人列表
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
            var tmpBtn=UIEmailButton();
            tmpBtn.mailAddress=email;
            tmpBtn.addTarget(self,action: "emailClicked:",forControlEvents: UIControlEvents.TouchUpInside)

            mailCcBtns.append(tmpBtn);
            self.view.addSubview(tmpBtn);
        }
        
    }
    
    //只创建按钮,不布局,抄送人列表
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
            var tmpBtn=UIEmailButton();
            tmpBtn.tag=index;
            
            let email=MCOAddress(displayName: attachment.filename, mailbox: "s@s.s")//displayName中是文件名啊
        
            tmpBtn.mailAddress=email;

            tmpBtn.addTarget(self,action: "previewAttach:",forControlEvents: UIControlEvents.TouchUpInside)
            
            attachBtns.append(tmpBtn);
            
            self.view.addSubview(tmpBtn);
            
            index++;
        }
        
    }


    //email List自动布局,需和setMailFromList配合
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

    //响应email地址点击事件
    func emailClicked(button: UIEmailButton)
    {
//        let mainStoryboard = UIStoryboard(name:"Main", bundle:nil)
//        let viewController = mainStoryboard.instantiateInitialViewController()! as UIViewController
//        
//        self.presentViewController(viewController, animated: true, completion:nil)
        print(button.mailAddress.mailbox)
    }
    
    //show or hide mailto and maincc
    func hideMailToCC(button: UIButton)
    {
        //        let mainStoryboard = UIStoryboard(name:"Main", bundle:nil)
        //        let viewController = mainStoryboard.instantiateInitialViewController()! as UIViewController
        //
        //        self.presentViewController(viewController, animated: true, completion:nil)
        button.selected = !button.selected;
        self.AutoLayoutView(button.selected)
    }
    
    //刷新邮件内容--1
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

        
        
    }
    
    //刷新邮件内容--2
    func RefreshMailWithParser(session:MCOIMAPSession,msgPareser:MCOMessageParser,folder:String)
    {
        let header=msgPareser.header;
        
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

        
        //开始处理邮件信息
        
        // 获得邮件正文的HTML内容,供webView加载
        let bodyHtml = msgPareser.htmlBodyRendering();//return String
        
        
        // 获取附件(多个)
        let mailAttatchments = msgPareser.attachments() as NSArray//NSMutableArray *
        
        // 拿到一个附件MCOAttachment,可从中得到文件名，文件内容data
//         let attachment=mailAttatchments[0];//MCOAttachment
        
         print("attatchemnts count=\(mailAttatchments.count)");
        
        //                   print(html as String);
        //self.mywebView.setHtmlContent(bodyHtml);
        
 //       self.session=session;
   //     self.folder=folder;
        
//        self.mywebView.delegate =;
        self.session=session;
        self.folder=folder;

        self.mywebView.folder=folder;
        self.mywebView.message=msgPareser;

        
 //       self.message = msgPareser as MCOAbstractMessage


        
        self.AutoLayoutView();
      
        
        
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

    //编写新邮件
    func newMail(sender: AnyObject) {
        //added by shiww,弹出邮件编写界面
        let popVC = UIStoryboard(name: "Board", bundle: nil).instantiateInitialViewController()! as UIViewController
         popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        let popOverController = popVC.popoverPresentationController
        popVC.preferredContentSize=CGSizeMake(820,1093);
        popOverController?.permittedArrowDirections = .Any
        self.presentViewController(popVC, animated: true, completion: nil)

    }

}

