//
//  SettingViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/24.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var smtpPort: UITextField!
    @IBOutlet weak var smtpHost: UITextField!
    @IBOutlet weak var smtpPassword: UITextField!
    @IBOutlet weak var nickleName: UITextField!
    @IBOutlet weak var smtpUser: UITextField!
    @IBOutlet weak var imapPort: UITextField!
    @IBOutlet weak var imapHost: UITextField!
    @IBOutlet weak var imapPassword: UITextField!
    @IBOutlet weak var imapUser: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        /// 1、利用NSUserDefaults存储数据
        let defaults = NSUserDefaults.standardUserDefaults();
        //  2、加载数据
  
        smtpPort.text                  = defaults.objectForKey("smtpport")?.string
        smtpHost.text                  = defaults.objectForKey("smtphost")?.string
        smtpPassword.text              = defaults.objectForKey("smtppassword")?.string
        nickleName.text                = defaults.objectForKey("nicklename")?.string
        smtpUser.text                  = defaults.objectForKey("smtpuser")?.string
        imapPort.text                  = defaults.objectForKey("imapport")?.string
        imapHost.text                  = defaults.objectForKey("imaphost")?.string
        imapPassword.text              = defaults.objectForKey("imappassword")?.string
        imapUser.text                  = defaults.objectForKey("imapuser")?.string
   
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
        
        maillogininfo.smtpport  = UInt32(defaults.stringForKey("smtpport")!)!;
        
        maillogininfo.smtphostname = defaults.stringForKey("smtphost")!
        
        maillogininfo.smtppassword              = defaults.stringForKey("smtppassword")!
        
        maillogininfo.nicklename              = defaults.stringForKey("nicklename")!
        maillogininfo.smtpusername              = defaults.stringForKey("smtpuser")!
        maillogininfo.port              = UInt32(defaults.stringForKey("imapport")!)!
        maillogininfo.hostname              = defaults.stringForKey("imaphost")!
        maillogininfo.password              = defaults.stringForKey("imappassword")!
        maillogininfo.username              = defaults.stringForKey("imapuser")!
        
        return maillogininfo;
    }
}
