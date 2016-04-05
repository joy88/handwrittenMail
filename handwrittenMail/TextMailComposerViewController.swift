//
//  TextMailComposerViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/4/5.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit

class TextMailComposerViewController: UIViewController {
    
    var mailTo=[MCOAddress]();//MARK:收件人
    var mailCc=[MCOAddress]();//MARK:抄送
    var mailTopic="";//MARK:邮件主题
    var mailOrign:UIImage?;//MARK:邮件原文,转发或回复时有用
    var mailHtmlbodyOrigin:String?//MARK:邮件HTML原文，转发或回复时有用
    var mailOriginAttachments:[MCOAttachment]?//MARK:邮件附件，转发时有用
    var mailOriginRelatedAttachments:[MCOAttachment]?//MARK:邮件releated附件，正文中的图片转发时有用
    
    private var mailComposerView:UIView=UIView();//收件人都录入窗口
    private var mailToLbl:UILabel=UILabel();//收件人地址标签
    var mailToInputText=ACTextArea();//收件人地址录入窗口
    private var mailSendBtn=UIButton();//发送按钮
    private var mailCcLbl=UILabel();//抄送人地址标签
    var mailCcInputText=ACTextArea();//抄送人地址录入窗口
    private var mailCancelBtn=UIButton();//关闭按钮
    private var mailTopicLbl=UILabel();//邮件主题标签
    var mailTopicInputText=UITextField();//邮件主题录入窗口;


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        //        private var mailComposerView:UIView=UIView();//收件人都录入窗口
        //        private var mailToLbl:UILabel=UILabel();//收件人地址标签
        //        var mailToInputText=ACTextArea();//收件人地址录入窗口
        //        private var mailSendBtn=UIButton();//发送按钮
        //        private var mailCcLbl=UILabel();//抄送人地址标签
        //        var mailCcInputText=ACTextArea();//抄送人地址录入窗口
        //        private var mailCancelBtn=UIButton();//关闭按钮
        //        private var mailTopicLbl=UILabel();//邮件主题标签
        //        var mailTopicInputText=UITextField();//邮件主题录入窗口;
        
        
        self.mailComposerView.addSubview(mailToLbl);
        self.mailComposerView.addSubview(mailToInputText);
        
        self.mailComposerView.addSubview(mailSendBtn);
        
        self.mailComposerView.addSubview(mailCcLbl);
        
        self.mailComposerView.addSubview(mailCcInputText);
        
        self.mailComposerView.addSubview(mailCancelBtn);
        self.mailComposerView.addSubview(mailTopicLbl);
        
        self.mailComposerView.addSubview(mailTopicInputText);
        
        
        let xSpace:CGFloat=10;//水平方向间隔
        let ySpace:CGFloat=10;//水平方向简隔
        let marginSpace:CGFloat=10;//左右两侧距边界的空白
        
        let ctrHight:CGFloat=25;//标准控件高度
        let ctrWidth:CGFloat=60;//标准控件宽度
        
        let black=UIColor.blackColor();
        let green=UIColor.greenColor();
        let red=UIColor.redColor();
        let white=UIColor.whiteColor();
        let blue=UIColor.blueColor();
        
        var top1,top2,top3,top4:CGFloat;
        
        
        top1=ySpace;
        
        //        private var mailToLbl:UILabel=UILabel();//收件人地址标签
        mailToLbl.setLabel("收件人:", x:marginSpace, y: top1, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: true, color: black)
        //        var mailToInputText=ACTextArea();//收件人地址录入窗口
        mailToInputText.setTextArea((marginSpace+ctrWidth+xSpace), y: top1, width: frameWidth-ctrWidth*2-4*xSpace, height: ctrHight*3, fonSize: 17, isBold: true, color: blue);
        
        //        private var mailSendBtn=UIButton();//发送按钮
        
        mailSendBtn.setTitle("发送", forState:.Normal);
        
        mailSendBtn.frame=CGRectMake(frameWidth-ctrWidth-marginSpace,top1,ctrWidth,ctrHight*3)
        mailSendBtn.setTitleColor(white, forState: .Normal);//不加上这句,看不到,可以字体是白色的原因吧
        mailSendBtn.backgroundColor=green;
        
        mailSendBtn.layer.cornerRadius = 8
        mailSendBtn.layer.masksToBounds=true;
        
        mailSendBtn.addTarget(self,action: #selector(BoardViewController.doSendMail(_:)),forControlEvents: UIControlEvents.TouchUpInside)//发送邮件
        
        
        
        
        //        private var mailCcLbl=UILabel();//抄送人地址标签
        top2=top1+ctrHight*3+ySpace
        
        mailCcLbl.setLabel("抄送:", x: marginSpace, y: top2, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: false, color: black);
        
        //        var mailCcInputText=ACTextArea();//抄送人地址录入窗口
        mailCcInputText.setTextArea((marginSpace+ctrWidth+xSpace), y: top2, width: frameWidth-ctrWidth*2-2*xSpace-2*marginSpace, height: ctrHight*3, fonSize: 17, isBold: true, color: blue);
        
        //        private var mailCancelBtn=UIButton();//关闭按钮
        mailCancelBtn.setTitle("关闭", forState:.Normal);
        
        mailCancelBtn.frame=CGRectMake(frameWidth-ctrWidth-marginSpace,top2,ctrWidth,ctrHight*3)
        mailCancelBtn.setTitleColor(white, forState: .Normal);//不加上这句,看不
        mailCancelBtn.backgroundColor=red;
        
        mailCancelBtn.layer.cornerRadius = 8
        mailCancelBtn.layer.masksToBounds=true;
        
        mailCancelBtn.addTarget(self,action: #selector(BoardViewController.doCloseMailComposer(_:)),forControlEvents: UIControlEvents.TouchUpInside)//关闭窗口
        
        
        
        //        private var mailTopicLbl=UILabel();//邮件主题标签
        top3=top2+ySpace+ctrHight*3;
        
        mailTopicLbl.setLabel("主题:", x: marginSpace, y: top3, width: ctrWidth, height: ctrHight, fonSize: 16, isBold: false, color: black);
        
        
        //        var mailTopicInputText=UITextField();//邮件主题录入窗口;
        mailTopicInputText.frame = CGRectMake((marginSpace+ctrWidth+xSpace), top3, frameWidth-ctrWidth-marginSpace*2-xSpace, ctrHight);
        mailTopicInputText.backgroundColor=white;
        
        mailTopicInputText.borderStyle=UITextBorderStyle.RoundedRect
        
        
        //        private var mailComposerView:UIView=UIView();//收件人都录入窗口
        
        top4=top3+ySpace+ctrHight;
        
        self.mailComposerView.frame=CGRectMake(startX,startY,frameWidth, top4);
        
        mailComposerView.layer.borderWidth = 1;
        mailComposerView.layer.borderColor = blue.CGColor;
        
        mailComposerView.layer.cornerRadius = 8
        mailComposerView.layer.masksToBounds=true;
        
        mailComposerView.backgroundColor=white;
        
        self.view.addSubview(mailComposerView);
        mailComposerView.hidden=true;
        
    }


}
