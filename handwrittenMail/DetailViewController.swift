//
//  DetailViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/5.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var webView=UIWebView()//邮件正文
    
    var mailFromLbl=UILabel()//"发件人"标签
    var mailFromBtn=UIEmailButton()//发件人显示按钮
    var infoHideBtn=UIButton()//"隐藏"或"显示"按钮
    
    var mailToLbl=UILabel()//"收件人"标签
    var mailToBtn=[UIEmailButton]();//收件人
    var mailCcLbl=UILabel();//"抄送"按钮
    var mailCcBtn=[UIEmailButton]()//抄送人
    
    var lineLbl=UILabel();//灰色分割线

    
    var subjectLbl=UILabel()//邮件主题
    var mailDateLbl=UILabel()//邮件收到时间

    
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = detailItem {
            
                let url = NSURL(string: detailItem as! String)
                let request = NSURLRequest(URL: url!)
                self.webView.scalesPageToFit = false
                self.webView.loadRequest(request)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
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
        self.AutoLayoutView();
        
//        var webView=UIWebView()//邮件正文
        self.view.addSubview(webView)
//        
//        var mailFromLbl=UILabel()//"发件人"标签
        self.view.addSubview(mailFromLbl)

//        var mailFromBtn=UIEmailButton()//发件人显示按钮
        self.view.addSubview(mailFromBtn)

//        var infoHideBtn=UIButton()//"隐藏"或"显示"按钮
        self.view.addSubview(infoHideBtn)

//
//        var mailToLbl=UILabel()//"收件人"标签
        self.view.addSubview(mailToLbl)

//        var mailToBtn=[UIEmailButton]();//收件人
        for mailbtn in mailToBtn
        {
            self.view.addSubview(mailbtn)
        }

//        var mailCcLbl=UILabel();//"抄送"按钮
        self.view.addSubview(mailCcLbl)

//        var mailCcBtn=[UIEmailButton]()//抄送人
        for ccbtn in mailCcBtn
        {
            self.view.addSubview(ccbtn)
        }


//
//        var lineLbl=UILabel();//灰色分割线
        self.view.addSubview(lineLbl)

//
//        
//        var subjectLbl=UILabel()//邮件主题
        self.view.addSubview(subjectLbl)

//        var mailDateLbl=UILabel()//邮件收到时间
        self.view.addSubview(mailDateLbl)
        
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
        mailFromBtn.setEmailTitle("shiweiwei@superamp.com", x: (marginSpace+ctrWidth+xSpace), y: top1, width: ctrWidth, height: ctrHight, fonSize: 17, isBold: true, color: blue);
        
//        var infoHideBtn=UIButton()//"隐藏"或"显示"按钮
        infoHideBtn.setTitle("隐藏", forState: .Normal);
        infoHideBtn.frame=CGRectMake(bounds.width-ctrWidth-2*marginSpace,top1,ctrWidth,ctrHight)
        infoHideBtn.setTitleColor(blue, forState: .Normal);//不加上这句,看不到,可以字体是白色的原因吧
        
        print(infoHideBtn.frame);
//        
//        var mailToLbl=UILabel()//"收件人"标签
        
        top2=top1+ctrHight+ySpace
        
        mailToLbl.setLabel("收件人:", x: marginSpace, y: top2, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: false, color: black);
        
        
//        var mailToBtn=[UIEmailButton]();//收件人
        

        if mailToBtn.count==0
        {
            var tempBtn1=UIEmailButton();
        
            mailToBtn.append(tempBtn1);
        }
        
        for a in mailToBtn
        {
        
            a.setEmailTitle("shiweiwei@superamp.com", x: (marginSpace+ctrWidth+xSpace), y: top2, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: false, color: blue);
        }
        

        
        
//        var mailCcLbl=UILabel();//"抄送"按钮
        top3=top2+ctrHight+ySpace;
        
        mailCcLbl.setLabel("抄送:", x: marginSpace, y: top3, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: false, color: black);

//        var mailCcBtn=[UIEmailButton]()//抄送人
        
        if mailCcBtn.count==0
        {
            var tempBtn2=UIEmailButton();
            mailCcBtn.append(tempBtn2);
        }

 
        for b in mailCcBtn
        {
            b.setEmailTitle("shiweiwei@superamp.com", x: (marginSpace+ctrWidth+xSpace), y: top3, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: false, color: blue);
        }
        
        

        //画一条线
//        var lineLbl=UILabel();//灰色分割线
        top4=top3+ySpace+ctrHight;
        
        lineLbl.text="";
        lineLbl.backgroundColor=UIColor.darkGrayColor();
        lineLbl.frame=CGRectMake(marginSpace, top4, bounds.width-2*marginSpace, 1);

//
//        var subjectLbl=UILabel()//邮件主题
        top5=top4+ySpace+1;
        
        subjectLbl.setLabel("邮件主题", x: marginSpace, y: top5, width: bounds.width-2*marginSpace, height: ctrHight, fonSize: 20, isBold: true, color: black);

        
//        var mailDateLbl=UILabel()//邮件收到时间
        top6=top5+ctrHight+ySpace;
        
        mailDateLbl.setLabel("邮件收到时间", x: marginSpace, y: top6, width: bounds.width-2*marginSpace, height: ctrHight, fonSize: 16, isBold: false, color: black);


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
    
}

