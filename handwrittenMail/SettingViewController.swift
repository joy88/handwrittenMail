//
//  SettingViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/24.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    //MARK:设置默认的邮件参数
    @IBAction func doSwithMailConfig(sender: UISegmentedControl) {
        let mail126=mailLoginInfo();
        mail126.hostname="imap.126.com"
        mail126.port=993;
        mail126.smtphostname="smtp.126.com"
        mail126.smtpport=465;
        
        let mail163=mailLoginInfo();
        mail163.hostname="imap.163.com"
        mail163.port=993;
        mail163.smtphostname="smtp.163.com"
        mail163.smtpport=465;
        
        let mailsina=mailLoginInfo();
        mailsina.hostname="imap.sina.com"
        mailsina.port=993;
        mailsina.smtphostname="smtp.sina.com"
        mailsina.smtpport=465;
        
        let mailqq=mailLoginInfo();
        mailqq.hostname="imap.qq.com"
        mailqq.port=993;
        mailqq.smtphostname="smtp.qq.com"
        mailqq.smtpport=465;
        
        let mailgmail=mailLoginInfo();
        mailgmail.hostname="imap.gmail.com"
        mailgmail.port=993;
        mailgmail.smtphostname="smtp.gmail.com"
        mailgmail.smtpport=465;

        let mailyahoo=mailLoginInfo();
        mailyahoo.hostname="imap.mail.yahoo.com"
        mailyahoo.port=993;
        mailyahoo.smtphostname="smtp.mail.yahoo.com"
        mailyahoo.smtpport=465;

        
        let mailConfigs=[mail126,mail163,mailsina,mailqq,mailgmail,mailyahoo]
        
        let index=sender.selectedSegmentIndex;
        
        if index>=0
        {
            let mailconfig=mailConfigs[index];
            
            self.imapHost.text=mailconfig.hostname;
            self.imapPort.text="\(mailconfig.port)";
            self.smtpHost.text=mailconfig.smtphostname;
            self.smtpPort.text="\(mailconfig.smtpport)"
        }
        

    }
    var masterView:MasterViewController?;
    //MARK:退出系统
    @IBAction func exit(sender: AnyObject) {
        exit(0);        
    }
    //MARK:SMTP账号密码和收件箱一致
    @IBAction func sendEqualInbox(sender: AnyObject) {
        smtpUser.text=imapUser.text;
        smtpPassword.text=imapPassword.text;
    }
    @IBOutlet weak var smtpPort: WTReTextField!
    @IBOutlet weak var smtpHost: WTReTextField!
    @IBOutlet weak var smtpPassword: WTReTextField!
    @IBOutlet weak var nickleName: WTReTextField!
    @IBOutlet weak var smtpUser: WTReTextField!
    @IBOutlet weak var imapPort: WTReTextField!
    @IBOutlet weak var imapHost: WTReTextField!
    @IBOutlet weak var imapPassword: WTReTextField!
    @IBOutlet weak var imapUser: WTReTextField!
    
    //MARK:设置邮件模板
    @IBAction func setMailTemplate(sender: AnyObject) {
        //added by shiww,弹出邮件模板设置界面
        let popVC = SetMailTemplateViewController();
        
       
        popVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        popVC.preferredContentSize=popVC.view.frame.size;
        
        self.presentViewController(popVC, animated: true,completion: nil)

        
    }
     override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        /// 1、利用NSUserDefaults存储数据
        let defaults = NSUserDefaults.standardUserDefaults();
        //  2、加载数据
  
        smtpPort.text                  = defaults.stringForKey("smtpport")
        smtpHost.text                  = defaults.stringForKey("smtphost")
        smtpPassword.text              = defaults.stringForKey("smtppassword")
        nickleName.text                = defaults.stringForKey("nicklename")
        smtpUser.text                  = defaults.stringForKey("smtpuser")
        imapPort.text                  = defaults.stringForKey("imapport")
        imapHost.text                  = defaults.stringForKey("imaphost")
        imapPassword.text              = defaults.stringForKey("imappassword")
        imapUser.text                  = defaults.stringForKey("imapuser")
        
//        _cardNumber.pattern = @"^(\\d{4}(?: )){3}\\d{4}$";
//        _cardholder.pattern = @"^[a-zA-Z ]{3,}$";
//        _validUntil.pattern = @"^(1[0-2]|(?:0)[1-9])(?:/)\\d{2}$";
        
        imapPort.pattern = "^\\d{3}$";
        smtpPort.pattern = imapPort.pattern ;//验证三位数字
        
        smtpUser.pattern = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
        imapUser.pattern=smtpUser.pattern//验证email
        
        /*
         //域名验证的正则没搞对
        smtpHost.pattern = "[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(/.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+/.?";//验证域名

        
        imapHost.pattern=smtpHost.pattern;*/


        
//        _date.pattern = @"^(3[0-1]|[1-2][0-9]|(?:0)[1-9])(?:\\.)(1[0-2]|(?:0)[1-9])(?:\\.)[1-9][0-9]{3}$";
//        _time.pattern = @"^(2[0-3]|1[0-9]|(?:0)[0-9])(?::)([0-5][0-9])$";

    }

    //MARK:保存收件和发件信息
    @IBAction func setupOk(sender: AnyObject) {
        
        /// 1、利用NSUserDefaults存储数据
        let defaults = NSUserDefaults.standardUserDefaults();
        //  2、存储数据
//        @IBOutlet weak var smtpPort: UITextField!
//        @IBOutlet weak var smtpHost: UITextField!
//        @IBOutlet weak var smtpPassword: UITextField!
//        @IBOutlet weak var nickleName: UITextField!
//        @IBOutlet weak var smtpUser: UITextField!
//        @IBOutlet weak var imapPort: UITextField!
//        @IBOutlet weak var imapHost: UITextField!
//        @IBOutlet weak var imapPassword: UITextField!
//        @IBOutlet weak var imapUser: UITextField!
        let   smtpport =      smtpPort.text
        let smtphost =      smtpHost.text
        let smtppassword =  smtpPassword.text
        let nicklename =    nickleName.text
        let smtpuser =      smtpUser.text
        let imapport =      imapPort.text
        let imaphost =      imapHost.text
        let imappassword =  imapPassword.text
        let imapuser =      imapUser.text

        
        defaults.setObject(smtpport, forKey: "smtpport");
        defaults.setObject(smtphost, forKey: "smtphost");
        defaults.setObject(smtppassword, forKey: "smtppassword");
        defaults.setObject(nicklename, forKey: "nicklename");
        defaults.setObject(smtpuser, forKey: "smtpuser");
        defaults.setObject(imapport, forKey: "imapport");
        defaults.setObject(imaphost, forKey: "imaphost");
        defaults.setObject(imappassword, forKey: "imappassword");
        defaults.setObject(imapuser, forKey: "imapuser");

     
        //  3、同步数据
        defaults.synchronize();
        

        self.dismissViewControllerAnimated(true)
        {
            //重新登录并刷新邮件列表
            self.masterView?.startLogin();

        }


    }
    //MARK:关闭设备窗口
    @IBAction func setupCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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

}

// MARK:对UIViewController做一个扩展,使之可以加载保存的邮件登录信息
extension UIViewController
{
    func loadMailLoginInfo()->mailLoginInfo
    {
        let defaults = NSUserDefaults.standardUserDefaults();

        let maillogininfo=mailLoginInfo();
        
        if defaults.stringForKey("smtpport") != nil
        {
            maillogininfo.smtpport  = UInt32(defaults.stringForKey("smtpport")!)!;
            
            maillogininfo.smtphostname = defaults.stringForKey("smtphost")!
            
            maillogininfo.smtppassword              = defaults.stringForKey("smtppassword")!
            
            maillogininfo.nicklename              = defaults.stringForKey("nicklename")!
            maillogininfo.smtpusername              = defaults.stringForKey("smtpuser")!
            maillogininfo.port              = UInt32(defaults.stringForKey("imapport")!)!
            maillogininfo.hostname              = defaults.stringForKey("imaphost")!
            maillogininfo.password              = defaults.stringForKey("imappassword")!
            maillogininfo.username              = defaults.stringForKey("imapuser")!

        }
        
        
        return maillogininfo;
    }
}
