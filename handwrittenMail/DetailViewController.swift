//
//  DetailViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/5.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,RefreshMailDelegate
{
    
    var webView=UIWebView()//邮件正文
    
    private var mailFromLbl=UILabel()//"发件人"标签
    private var mailFromBtn=UIEmailButton()//发件人显示按钮
    private var infoHideBtn=UIButton()//"隐藏"或"显示"按钮
    
    private var mailToLbl=UILabel()//"收件人"标签
    private var mailToBtns=[UIEmailButton]();//收件人
    private var mailCcLbl=UILabel();//"抄送"按钮
    private var mailCcBtns=[UIEmailButton]()//抄送人
    
    private var lineLbl=UILabel();//灰色分割线

    
    private var subjectLbl=UILabel()//邮件主题
    private var mailDateLbl=UILabel()//邮件收到时间
    
    var mailSender=MCOAddress(displayName: "石伟伟", mailbox: "Chinagis001@126.com")!;//发件人地址
    private var mailToLists=[MCOAddress]();//收件人地址列表
    private var mailCcLists=[MCOAddress]();//抄送人地址列表
    var mailSubject="邮件主题";
    var mailDate=NSDate();//邮件日期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //1.右边第一个按钮
        let composeButton = UIBarButtonItem(barButtonSystemItem:.Compose, target: self, action: nil)
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
        self.view.addSubview(webView)
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
        
        var top1,top2,top3,top4,top5,top6,top7:CGFloat;
        
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


        //        var webView=UIWebView()//邮件正文
        top7=top6+ctrHight+ySpace;
        
        webView.frame=CGRectMake(marginSpace, top6, bounds.width-2*marginSpace,bounds.height-top7);
        
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
    
    //刷新邮件内容
    func RefreshMailData(mailid:MCOIMAPMessage,htmlContent:String)
    {
        
//        info.mailId = "\(msg.uid)";
//        info.subject = msg.header.subject;
//        info.name = (msg.header.from.displayName != nil) ? msg.header.from.displayName:msg.header.from.mailbox;
//        info.sendTime = msg.header.receivedDate;//[self
//        info.attach = msg.attachments().count;
        

        self.mailSubject=mailid.header.subject;//邮件主题
        
 //       info.name = (msg.header.from.displayName != nil) ? msg.header.from.displayName:msg.header.from.mailbox;

        self.mailSender = mailid.header.from//发件人
        self.mailDate=mailid.header.receivedDate;//收件日期
        
        var tmpmailCcLists=[MCOAddress]();
        var tmpmailToLists=[MCOAddress]();

        
        if mailid.header.to != nil
        {
            
            tmpmailToLists=mailid.header.to as! [MCOAddress];
        }
        
        if mailid.header.cc != nil
        {
            tmpmailCcLists=mailid.header.cc as! [MCOAddress];

        }
        
        self.setMailCcList(tmpmailCcLists)
        self.setMailToList(tmpmailToLists)
        
        
        webView.loadHTMLString(htmlContent, baseURL: nil);
        
        
        self.AutoLayoutView();
        
        
    }

  }

