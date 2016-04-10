//
//  SetMailTemplateViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/4/10.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit
import RichEditorView

class SetMailTemplateViewController: UIViewController {

    //MARK:关闭窗口
    @IBAction func doClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    //MARK:保存邮件模板
    @IBAction func doOk(sender: AnyObject) {
        /// 1、利用NSUserDefaults存储数据
        let defaults = NSUserDefaults.standardUserDefaults();
        
        let newmailTemplate = self.newMailInput.text!;
        let replymailTemplate = self.replayMailInput.text!;
        let forwardmailTemplate = self.forwardMailInput.text!;
        let mailcontentTemplate = self.richEditorView.getHTML();

        
        defaults.setObject(newmailTemplate, forKey: "newmailTemplate");
        defaults.setObject(replymailTemplate, forKey: "replymailTemplate");
        defaults.setObject(forwardmailTemplate, forKey: "mailcontentTemplate");
        defaults.setObject(mailcontentTemplate, forKey: "mailcontentTemplate");
        
        
        //  3、同步数据
        defaults.synchronize();
        
        //4.关闭窗口
        self.dismissViewControllerAnimated(true,completion: nil);
 
    }
    
    @IBOutlet weak var forwardMailInput: UITextField!
    @IBOutlet weak var newMailInput: UITextField!
    @IBOutlet weak var replayMailInput: UITextField!
    @IBOutlet weak var richEditorView: RichEditorView!

    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorOptions.all()
        return toolbar
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        //初始化输入窗口
        
        richEditorView.delegate = self
        
        richEditorView.inputAccessoryView = toolbar
        
        toolbar.delegate = self
        toolbar.editor = richEditorView
        toolbar.options=[
            RichEditorOptions.Clear,
            RichEditorOptions.Undo, RichEditorOptions.Redo, RichEditorOptions.Bold, RichEditorOptions.Italic,
            RichEditorOptions.Strike, RichEditorOptions.Underline,
            RichEditorOptions.TextColor, RichEditorOptions.TextBackgroundColor,
            RichEditorOptions.Header(1), RichEditorOptions.Header(2), RichEditorOptions.Header(3), RichEditorOptions.Header(4), RichEditorOptions.Header(5),RichEditorOptions.Header(6),
            RichEditorOptions.Indent, RichEditorOptions.Outdent, RichEditorOptions.OrderedList, RichEditorOptions.UnorderedList,
            RichEditorOptions.AlignLeft, RichEditorOptions.AlignCenter, RichEditorOptions.AlignRight, RichEditorOptions.Image
        ]
        
        richEditorView.setPlaceholderText("在此输入邮件正文模板")
        richEditorView.setTextColor(UIColor.blackColor());
        richEditorView.scrollEnabled=true;
        richEditorView.clipsToBounds=true;
        
        //加载邮件模板信息
        let mailTemplates=SetMailTemplateViewController.getMailTemplate();
        
        newMailInput.text                  = mailTemplates[0]
        replayMailInput.text                  = mailTemplates[1]
        forwardMailInput.text              = mailTemplates[2]
        
        richEditorView.setHTML(mailTemplates[3])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static func getMailTemplate()->[String]
    {
        var strResult=["from#mainsender#,","from#mailsender#的回复-","from#mailsender#的转发-","Hi"];
        /// 1、利用NSUserDefaults存储数据
        let defaults = NSUserDefaults.standardUserDefaults();
        //  2、加载数据
        if defaults.stringForKey("newmailTemplate") != nil
        {
            strResult[0]                  = defaults.stringForKey("newmailTemplate")!
        }

        if defaults.stringForKey("replymailTemplate") != nil
        {
            strResult[1]                  = defaults.stringForKey("replymailTemplate")!
        }

        if defaults.stringForKey("forwardmailTemplate") != nil
        {
            strResult[2]                  = defaults.stringForKey("forwardmailTemplate")!
        }

        let html=defaults.stringForKey("mailcontentTemplate");
        
        if html != nil
        {
            strResult[3] = html!
        }
        
        return strResult;
   
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


//MARK:扩展,响应RichEditorToolbarDelegate
extension SetMailTemplateViewController: RichEditorToolbarDelegate {
    
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
        
    }
    
    
    func richEditorToolbarInsertLink(toolbar: RichEditorToolbar) {

    }
}

//MARK:响应,实现RichEditorDelegate
extension SetMailTemplateViewController: RichEditorDelegate {
    
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
