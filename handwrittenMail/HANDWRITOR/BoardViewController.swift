//
//  ViewController.swift
//  DrawingBoard
//
//  Created by ZhangAo on 15-2-15.
//  Copyright (c) 2015年 zhangao. All rights reserved.
//

import UIKit

//MARK:- BoardViewController定义

class BoardViewController: UIViewController,UIPopoverPresentationControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
   
    var mailTo=[MCOAddress]();//MARK:收件人
    var mailCc=[MCOAddress]();//MARK:抄送
    var mailTopic="";//MARK:邮件主题
    var mailOrign:UIImage?;//MARK:邮件原文,转发或回复时有用
    var mailHtmlbodyOrigin:String?//MARK:邮件HTML原文，转发或回复时有用
    var mailOriginAttachments:[MCOAttachment]?//MARK:邮件附件，转发时有用
    var mailOriginRelatedAttachments:[MCOAttachment]?//MARK:邮件releated附件，正文中的图片转发时有用
    
    var imapsession:MCOIMAPSession?//imap session,保存到草稿箱时用


    @IBOutlet weak var btnExit: UIButton!//关闭窗口按钮
    
    @IBOutlet weak var btnInsertImg: UIButton!//MARK:插入图片
  
 //    @IBOutlet weak var toolboxView: UIView!
    
    var brushes = [PencilBrush(), LineBrush(), DashLineBrush(), RectangleBrush(), EllipseBrush(), HightlightBrush(),EraserBrush(),ImageBrush()];
    //added by shiww,让系统支持多页
    var pages=Pages();
    
    @IBAction func doShowMailComposer(sender: AnyObject) {
        self.mailComposerView.hidden = !self.mailComposerView.hidden;
    }

     //切换笔刷
    func doPenSwitch(sender: UIButton) {
        if sender.selected && sender.tag != 8
        {
            return;
        }//added by shiww,如果是同一个按钮,直接返回.
        //如果点了不同的按钮,则切换笔刷
        
        let btnList=[btnPencil,btnPenLine,btnPenDashLine,btnPenBox,btnPenCircle,btnPenHLight,btnPenEraser,btnInsertImg];
        for btnTemp in btnList
        {
            if btnTemp.tag != sender.tag
            {
                btnTemp.selected=false;
            }
            else
            {
                btnTemp.selected=true;
                if btnTemp.tag==5//added by shiww,如果是高亮笔刷,颜色设置为黄色
                {
                    self.saveSystemPara();
                    self.board.strokeColor=UIColor.yellowColor();
                }
                else
                {
                    let defaults = NSUserDefaults.standardUserDefaults();
                    if  (defaults.objectForKey("strokeWidth") != nil)
                    {
                        self.board.strokeWidth = defaults.objectForKey("strokeWidth") as! CGFloat;
                    }
                    if  (defaults.objectForKey("strokeColor") != nil)
                    {
                        self.board.strokeColor = defaults.colorForKey("strokeColor")!
                    }
                    
                }
            }
        }
        self.board.brush = self.brushes[sender.tag];
        
        //added by shiww
        if sender.tag==7 && sender.selected//是插入图片
        {
            let pickerController = UIImagePickerController();
            pickerController.delegate = self;
            self.presentViewController(pickerController, animated: true, completion: nil);
        }
        
    }
    
    // MARK: UIImagePickerControllerDelegate Methods,插入图片时把图片传给笔刷
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if self.board.brush is ImageBrush
        {
            let imgBrush=self.board.brush as! ImageBrush
            
            let imagePic = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            imgBrush.image=imagePic;
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    @IBOutlet weak var btnPenEraser: UIButton!
    @IBOutlet weak var btnPenHLight: UIButton!
    @IBOutlet weak var btnPenCircle: UIButton!
    @IBOutlet weak var btnPenBox: UIButton!
    @IBOutlet weak var btnPenDashLine: UIButton!
    @IBOutlet weak var btnPenLine: UIButton!
    @IBOutlet weak var btnPencil: UIButton!
    
    //added by shiww,保存页面到本地文件中,图片格式
    
    @IBAction func saveCurrentPages(sender: UIButton) {
        if self.pages.savePageMetainfo()
        {
            self.pages.savePage(self.board.takeImage(false));
            self.pages.savePage(self.board.takeImage(true),forEvernote:true);
            
        }
        
    }
    
    private func loadImagefromFile(filename:String)
    {
        // 获取 Documents 目录
        let docDirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray;
        let docDir = docDirs[0] as! String;
        
        let pagefilePath=docDir+"/"+filename+".png";
        
        if let tempImage=UIImage(contentsOfFile: pagefilePath)
        {
            self.board.loadImage(tempImage);
        }
        
    }
    
    private func saveImageToFile(filename:String)->Bool
    {
        // 获取 Documents 目录
        let docDirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray;
        let docDir = docDirs[0] as! String;
        
        let pagefilePath=docDir+"/"+filename+".png";
        
        //        print(pagefilePath);
        
        let saveResult=UIImagePNGRepresentation(self.board.takeImage(false))!.writeToFile(pagefilePath, atomically: true);
        
        if saveResult
        {
            //            print("write pagedata to \(pagefilePath) succeed!");
        }
        return saveResult;
    }
    
    @IBOutlet var board: Board!//绘图区域
    
    @IBOutlet var topView: UIView!//工具条
    
    private var mailComposerView:UIView=UIView();//收件人都录入窗口
    private var mailToLbl:UILabel=UILabel();//收件人地址标签
    var mailToInputText=ACTextArea();//收件人地址录入窗口
    private var mailSendBtn=UIButton();//发送按钮
    private var mailCcLbl=UILabel();//抄送人地址标签
    var mailCcInputText=ACTextArea();//抄送人地址录入窗口
    private var mailCancelBtn=UIButton();//关闭按钮
    private var mailTopicLbl=UILabel();//邮件主题标签
    var mailTopicInputText=UITextField();//邮件主题录入窗口;
    
    
    
    
    
    @IBAction func doSetBkground(sender: UIButton) {
        //added by shiww,设置背景信纸
        let popVC=SetBkgroundViewCtrller();
        popVC.mainViewController=self;
        
        popVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        popVC.popoverPresentationController!.delegate = self
        let popOverController = popVC.popoverPresentationController
        popOverController!.sourceView = sender;
        popOverController!.sourceRect = sender.bounds
        popVC.preferredContentSize=CGSizeMake(535,628);
        popOverController?.permittedArrowDirections = .Any
        self.presentViewController(popVC, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*
        //处理一下视图大小
        //1.让board充满大小
        let viewBounds=self.view.bounds;
        var viewFrame=CGRectMake(0,0,viewBounds.width,viewBounds.height);
        self.board.frame=viewFrame;
        //2.让工具条充满
        viewFrame=CGRectMake(0,0,viewBounds.width,self.topView.bounds.height);
        self.topView.frame=viewFrame;
        //处理完毕
        */

        self.board.brush = brushes[0]
        
        self.loadSystemPara();
        
        
        
        
        //added by shiww,设置按钮图片和按钮事件
        let btnList=[btnPencil,btnPenLine,btnPenDashLine,btnPenBox,btnPenCircle,btnPenHLight,btnPenEraser];
        for btnTemp in btnList
        {
            btnTemp.imageView?.contentMode=UIViewContentMode.ScaleToFill;
            btnTemp.addTarget(self,action:#selector(BoardViewController.doPenSwitch(_:)),forControlEvents:.TouchUpInside);//点击事件
            
            //添加长按事件
            let longPress=UILongPressGestureRecognizer(target: self, action: #selector(BoardViewController.doSetBrush(_:)));
            longPress.minimumPressDuration=0.4;
            btnTemp.addGestureRecognizer(longPress);
            
        }
        
        btnPencil.setImage(UIImage(named: "pencil"), forState: UIControlState.Normal);
        btnPencil.setImage(UIImage(named: "pencilck"), forState: UIControlState.Selected);
        btnPencil.selected=true;
        
        
        btnPenLine.setImage(UIImage(named: "penline"), forState: UIControlState.Normal);
        btnPenLine.setImage(UIImage(named: "penlineck"), forState: UIControlState.Selected);
        
        btnPenDashLine.setImage(UIImage(named: "pendashline"), forState: UIControlState.Normal);
        btnPenDashLine.setImage(UIImage(named: "pendashlineck"), forState: UIControlState.Selected);
        
        btnPenBox.setImage(UIImage(named: "penbox"), forState: UIControlState.Normal);
        btnPenBox.setImage(UIImage(named: "penboxck"), forState: UIControlState.Selected);
        
        btnPenCircle.setImage(UIImage(named: "pencircle"), forState: UIControlState.Normal);
        btnPenCircle.setImage(UIImage(named: "pencircleck"), forState: UIControlState.Selected);
        
        btnPenHLight.setImage(UIImage(named: "penhighlight"), forState: UIControlState.Normal);
        btnPenHLight.setImage(UIImage(named: "penhighlightck"), forState: UIControlState.Selected);
        
        btnPenEraser.setImage(UIImage(named: "peneraser"), forState: UIControlState.Normal);
        btnPenEraser.setImage(UIImage(named: "peneraserck"), forState: UIControlState.Selected);
        
       
        
        //为页码标签框添加长按事件
        let longPress=UILongPressGestureRecognizer(target: self, action: #selector(BoardViewController.doRemoveCurPage(_:)));
        longPress.minimumPressDuration=0.4;
        self.labPages.addGestureRecognizer(longPress);
        
        //插入图片按钮初始化
        btnInsertImg.setImage(UIImage(named: "insertimg"), forState: UIControlState.Normal);
        btnInsertImg.setImage(UIImage(named: "insertimgck"), forState: UIControlState.Selected);
        btnInsertImg.addTarget(self,action:#selector(BoardViewController.doPenSwitch(_:)),forControlEvents:.TouchUpInside);//点击事件
        
        //初始化邮件发送信息录入窗口//by shiww
    
        AutoLayoutMailComposerView(10,startY:60,frameWidth:self.board.bounds.width-20);
        
        self.loadMailHeader();//回复邮件时加载邮件头信息
        self.setMailHeadTemplate();//处理邮件模板信息
        
        //划动手势支持,added by shiww
        //上划关闭工具条
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(BoardViewController.handleSwipeGesture(_:)))
        swipeUpGesture.direction = UISwipeGestureRecognizerDirection.Up;
        
        swipeUpGesture.numberOfTouchesRequired=2;
        
        self.view.addGestureRecognizer(swipeUpGesture)
        //下划显示工具条
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(BoardViewController.handleSwipeGesture(_:)))
        swipeDownGesture.direction = UISwipeGestureRecognizerDirection.Down
        swipeDownGesture.numberOfTouchesRequired=2;
        self.view.addGestureRecognizer(swipeDownGesture)
        
        
        //added by shiww,加载最后一次保存的数据
        if !self.pages.loadPageMetainfo()
        {
            return;
        }
        
        let tempImage=self.pages.loadPage()
        self.board.loadImage(tempImage);
        
        let image=UIImage(named: self.board.bkImgName)!
        self.setBackgroundColor(image);

        
        self.labPages.setTitle("\(self.pages.CurrentPage)/\(self.pages.PageCount)", forState: UIControlState.Normal);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if let err = error {
            let alertController = UIAlertController(title: BaseFunction.getIntenetString("ERROR"), message: err.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert);
            alertController.addAction(UIAlertAction(title: BaseFunction.getIntenetString("CLOSE"), style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated:true,completion:nil);
            
        } else {
            let alertController = UIAlertController(title: BaseFunction.getIntenetString("INFO"), message: BaseFunction.getIntenetString("SAVE_SUCCEED"), preferredStyle: UIAlertControllerStyle.Alert);
            alertController.addAction(UIAlertAction(title: BaseFunction.getIntenetString("OK"), style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated:true,completion:nil);
        }
    }
    
    @IBAction func doUndo(sender: UIButton) {
        self.undo();
    }
    
    @IBOutlet weak var labPages: UIButton!
    //MARK:- 页码操作
    //删除当前页
    
    func doRemoveCurPage(sender: UILongPressGestureRecognizer)
    {
        if sender.state != UIGestureRecognizerState.Began
        {
            return;
        }
        
        if self.pages.PageCount<=1//只有一页,就不让删除了
        {
            return;
        }
        
        let alertController = UIAlertController(title: BaseFunction.getIntenetString("WARNING"), message: BaseFunction.getIntenetString("DELETE_PAGE_CONFIRM"), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: BaseFunction.getIntenetString("CANCEL"), style: .Cancel) { (action) in
            
            return;//返回,不清空了!
            // ...
        }
        
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: BaseFunction.getIntenetString("OK"), style: .Destructive) { (action) in
            self.pages.removePage();//执行删除操作
            let tempImage=self.pages.loadPage();
            self.board.loadImage(tempImage);
            self.labPages.setTitle("\(self.pages.CurrentPage)/\(self.pages.PageCount)", forState: UIControlState.Normal);
            //清除undo/redo
            self.board.clearUndoRedo();
            return;
        }
        
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true,completion:nil);
        
        
    }
    //前一页
    @IBAction func prevPage(sender: UIButton) {
        //保存当前页
        self.pages.savePage(self.board.takeImage(false));
        self.pages.savePage(self.board.takeImage(true),forEvernote:true);
        
        //加载上一页
        if self.pages.CurrentPage>1
        {
            let tempImage=self.pages.prevPage();
            //清除undo/redo
            self.board.clearUndoRedo();
            self.board.addUndoImage(tempImage);
            self.board.loadImage(tempImage);
            self.labPages.setTitle("\(self.pages.CurrentPage)/\(self.pages.PageCount)", forState: UIControlState.Normal);
        }
        
    }
    //后一页
    @IBAction func nextPage(sender: UIButton)
    {
//        print(sender.tag)
        //保存当前页
        self.pages.savePage(self.board.takeImage(false));
        
        self.pages.savePage(self.board.takeImage(true),forEvernote:true);
        
        
        //是最后一页，则增加一页
        if self.pages.CurrentPage==self.pages.PageCount
        {
//            self.ShowNotice("info","Add new Page");
            
            self.pages.addPage();
            if self.pages.savePageMetainfo()
            {
                self.board.clearAll(true);
                self.self.labPages.setTitle("\(self.pages.CurrentPage)/\(self.pages.PageCount)", forState: UIControlState.Normal);
                //清除undo/redo
                self.board.clearUndoRedo();
            }
            return;
        }
        
        //加载下一页,如果不是最后一页

        if self.pages.CurrentPage<self.pages.PageCount
        {
//            self.ShowNotice("info","Toggle to next Page");

            let tempImage=self.pages.nextPage();
            //清除undo/redo
            self.board.clearUndoRedo();
            self.board.addUndoImage(tempImage);
            
            self.board.loadImage(tempImage);
            
            self.labPages.setTitle("\(self.pages.CurrentPage)/\(self.pages.PageCount)", forState: UIControlState.Normal);
            return;
            
        }

    }
    //清除当前页面内容
    @IBAction func clearCurPage(sender: AnyObject) {
        
        
        let alertController = UIAlertController(title:BaseFunction.getIntenetString("WARNING"), message:BaseFunction.getIntenetString("CLEAR_PAGE_CONFIRM"), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title:BaseFunction.getIntenetString("CANCEL"), style: .Cancel) { (action) in
            
            return;//返回,不清空了!
            // ...
        }
        
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: BaseFunction.getIntenetString("OK"), style: .Destructive) { (action) in
            self.board.clearAll()
        }
        
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true,completion:nil);
    }
     //笔刷设置
    func doSetBrush(sender : UILongPressGestureRecognizer) {
        
        if sender.state != UIGestureRecognizerState.Began
        {
            return;
        }
        
        let popVC=PaintingBrushSetting();
        popVC.mainViewController=self;
        
        popVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        popVC.popoverPresentationController!.delegate = self
        let popOverController = popVC.popoverPresentationController
        popOverController!.sourceView = sender.view;
        popOverController!.sourceRect = sender.view!.bounds
        popVC.preferredContentSize=CGSizeMake(455,268);
        popOverController?.permittedArrowDirections = .Any
        self.presentViewController(popVC, animated: true, completion: nil)
        
    }
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    //保存为图片
    @IBAction func doSaveAlbum(sender: AnyObject) {
        self.saveToAlbum();
    }
    @IBAction func doRedo(sender: UIButton) {
        self.redo();
    }
    
    
    func undo() {
        self.board.undo()
    }
    
    func redo() {
        self.board.redo()
    }
    
    
    func saveToAlbum() {
        UIImageWriteToSavedPhotosAlbum(self.board.takeImage(), self, #selector(BoardViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    
    
    func setBackgroundColor(image:UIImage)
    {
        //added by shiww,to support retina
        let bounds=CGRect(x: 0,y: 0,width: self.preferredContentSize.width,height: self.preferredContentSize.height);//self.view.bounds,不知道为什么,必须设置为固定大小,否则会得到屏幕大小
        
        UIGraphicsBeginImageContextWithOptions(bounds.size,false,0);
        image.drawInRect(bounds);
//        print(bounds);
        let tempImage=UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        //added end
        self.board.backgroundColor = UIColor(patternImage: tempImage);
        
        self.saveSystemPara();
        
    }
    
    //MARK:划动手势支持,确定是否显示工具条
    func handleSwipeGesture(sender: UISwipeGestureRecognizer){
        //划动的方向
        let direction = sender.direction
        //判断是上下左右
        switch (direction){
        case UISwipeGestureRecognizerDirection.Left:
            //            print("Left")
            break
        case UISwipeGestureRecognizerDirection.Right:
            //            print("Right")
            break
        case UISwipeGestureRecognizerDirection.Up://关闭工具条
            //            print("Up")
            UIView.beginAnimations(nil, context: nil)
            topView.hidden=true;
            UIView.commitAnimations()
            break
        case UISwipeGestureRecognizerDirection.Down://打开工具条
            //            print("Down")
            UIView.setAnimationDelay(1.0)
            topView.hidden=false;
            UIView.commitAnimations()
            break
        default:
            break
        }
    }
    //MARK:保存系统参数
    func saveSystemPara()
    {
        /// 1、利用NSUserDefaults存储数据
        let defaults = NSUserDefaults.standardUserDefaults();
        //  2、存储数据
        defaults.setObject(self.board.strokeWidth, forKey: "strokeWidth");
        defaults.setColor(self.board.strokeColor, forKey: "strokeColor");
        defaults.setObject(self.board.pencilSense, forKey: "pencilSense");
        //        print(self.board.backgroundColor);
        defaults.setObject(self.board.bkImgName, forKey: "bkImgName");
        //  3、同步数据
        defaults.synchronize();
        
    }
    //MARK:加载系统参数
    private func loadSystemPara()
    {
        let defaults = NSUserDefaults.standardUserDefaults();
        if  (defaults.objectForKey("strokeWidth") != nil)
        {
            self.board.strokeWidth = defaults.objectForKey("strokeWidth") as! CGFloat;
        }
        if  (defaults.objectForKey("strokeColor") != nil)
        {
            self.board.strokeColor = defaults.colorForKey("strokeColor")!
        }
        if  (defaults.objectForKey("pencilSense") != nil)
        {
            self.board.pencilSense = defaults.objectForKey("pencilSense") as! CGFloat;
        }
        if  (defaults.objectForKey("bkImgName") != nil)
        {
            self.board.bkImgName = defaults.stringForKey("bkImgName")!;
        }
        else
        {
            self.board.bkImgName="background1";
        }
        
        
    }
    
    //MARK:发邮件地址录入窗口自动布局
    private func AutoLayoutMailComposerView(startX:CGFloat,startY:CGFloat,frameWidth:CGFloat)
    {

        
        self.mailComposerView.addSubview(mailToLbl);
        self.mailComposerView.addSubview(mailToInputText);
        mailToInputText.text.keyboardType = .EmailAddress;


        self.mailComposerView.addSubview(mailSendBtn);

        self.mailComposerView.addSubview(mailCcLbl);

        self.mailComposerView.addSubview(mailCcInputText);
        mailCcInputText.text.keyboardType = .EmailAddress;


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
        mailSendBtn.titleLabel?.lineBreakMode = .ByWordWrapping;
        
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
    
    //MARK:关闭窗口
    @IBAction func viewExit(sender: UIButton) {
        
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
        
        
        composeCloseMenu.popoverPresentationController?.sourceView = sender;

        composeCloseMenu.popoverPresentationController?.sourceRect=sender.bounds;
        
        
        self.presentViewController(composeCloseMenu, animated: true, completion: nil)
  
    }
    
    
    //MARK:发送邮件
    func doSendMail(sender: UIButton)
    {
        //发送邮件
        let smtpSession=MCOSMTPSession();
        
        let smtpinfo=self.loadMailLoginInfo();
        smtpSession.hostname = smtpinfo.smtphostname;
        smtpSession.port = smtpinfo.smtpport;
        smtpSession.username = smtpinfo.smtpusername;
        smtpSession.password = smtpinfo.smtppassword;
        
        smtpSession.connectionType = MCOConnectionType.TLS;
        
        let smtpOperation = smtpSession.loginOperation();
        //发送邮件
        self.setSendButtonEnable(false);

        smtpOperation.start()
        {
            (error:NSError?)->Void in
            
            if (error == nil) {
                // 构建邮件体的发送内容
                let messageBuilder = MCOMessageBuilder();
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
                
                htmlBody=htmlBody+"<div style=\"padding: 15px 15px 1px 15px;text-align:center;background-color:#eef2f3;\">\n"
                
                htmlBody=htmlBody+"<div>\n";
                
                let strImagePrefix="<div style=\"padding: 0px 0px 0px 0px;margin-bottom:15px;\">\n<div style=\"max-width:750px;margin:0px auto 0px auto;padding:0px 0px 0px 0px;display:block;background-color:white;background-color:#ffffff;box-shadow:0px 1px 3px rgba(0,0,0,.25);-webkit-box-shadow:0px 1px 3px rgba(0,0,0,.25);border-radius:4px;\">";
                
                
                self.saveCurrentPages(UIButton());//保存一下当前手写信息
                
                let pageLists=self.pages.getPageLists();
                
                
                for pageList in pageLists
                {
                    
                    let uuid = NSUUID().UUIDString;//必须要确保文件名唯一
                    
                    let cid="cngis-"+uuid;
                    
                   // htmlBody=htmlBody+"<div><center><img src=\"cid:"+cid+"\" style=\"border:10px solid lightgray\"  width=\"750px\" ></center></div>";
                    
                    let strimage=strImagePrefix+"<img src=\"cid:"+cid+"\" width=\"100%\" style=\"margin: 0px; padding:0px; border-radius:4px;\"/>\n</div>\n</div>";
                    htmlBody=htmlBody+strimage;
                    
 //                   print(strimage);

                    
                    let attachment=MCOAttachment(contentsOfFile:pageList);
                    attachment.contentID=cid;
                    messageBuilder.addRelatedAttachment(attachment);

                    
                }
                htmlBody=htmlBody+"</div>\n</div>";

                
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
                    
                    
                    let attachment=MCOAttachment(data: UIImageJPEGRepresentation(self.mailOrign!,0.8), filename: cid+".jpg");
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
                //监测一下邮件发送的进度
                
                sendOperation.progress =
                    {
                        (nowValue:UInt32,totalValue:UInt32)->Void in
                        
//                print("nowvalue=\(nowValue),totalValue=\(totalValue)");//,percent=\(nowValue*100/totalValue)");
                        
                        if totalValue != 0
                        {
                            let wndTitle=String(format: "发送中\n  %2d%%",nowValue*100/totalValue);
                            self.setWindowTitle(wndTitle)
                        }
                };
                

                sendOperation.start()
                    {
                        (error:NSError?) -> Void in
                        if error==nil
                        {
                            print("发送成功!");
                            self.dismissViewControllerAnimated(true,completion: nil);
                        }
                        else
                        {
                            self.ShowNotice("提示", "发送不成功-\(error?.localizedDescription)");
                            print("发送不成功!%@",error);
                            //存放到草稿箱中
                            self.setSendButtonEnable(true);
                            self.setWindowTitle("发送");
   
                        }
                        


                }

            }
            else
            {
                print("login account failure: %@", error);
                
                self.setSendButtonEnable(true);
        }
     }
    }
    
    //MARK:显示邮件发送进度信息
    private func setWindowTitle(wndTitle:String)
    {
        self.mailSendBtn.setTitle(wndTitle, forState:.Normal);
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
        
        htmlBody=htmlBody+"<div style=\"padding: 15px 15px 1px 15px;text-align:center;background-color:#eef2f3;\">\n"
        
        htmlBody=htmlBody+"<div>\n";
        
        let strImagePrefix="<div style=\"padding: 0px 0px 0px 0px;margin-bottom:15px;\">\n<div style=\"max-width:750px;margin:0px auto 0px auto;padding:0px 0px 0px 0px;display:block;background-color:white;background-color:#ffffff;box-shadow:0px 1px 3px rgba(0,0,0,.25);-webkit-box-shadow:0px 1px 3px rgba(0,0,0,.25);border-radius:4px;\">";
        
        
        self.saveCurrentPages(UIButton());//保存一下当前手写信息
        
        let pageLists=self.pages.getPageLists();
        
        
        for pageList in pageLists
        {
            
            let uuid = NSUUID().UUIDString;//必须要确保文件名唯一
            
            let cid="cngis-"+uuid;
            
            // htmlBody=htmlBody+"<div><center><img src=\"cid:"+cid+"\" style=\"border:10px solid lightgray\"  width=\"750px\" ></center></div>";
            
            let strimage=strImagePrefix+"<img src=\"cid:"+cid+"\" width=\"100%\" style=\"margin: 0px; padding:0px; border-radius:4px;\"/>\n</div>\n</div>";
            htmlBody=htmlBody+strimage;
            
            //                   print(strimage);
            
            
            let attachment=MCOAttachment(contentsOfFile:pageList);
            attachment.contentID=cid;
            messageBuilder.addRelatedAttachment(attachment);
            
            
        }
        
        htmlBody=htmlBody+"</div>\n</div>";
        
        
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
        
            htmlBody=htmlBody+"<div><center><img src=\"cid:"+cid+"\" style=\"border:10px solid lightgray\"  width=\"750px\" ></center></div>";

            
            
            let attachment=MCOAttachment(data: UIImageJPEGRepresentation(self.mailOrign!,0.8), filename: cid+".jpg");
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

    //MARK:关闭邮件地址录入窗口
    func doCloseMailComposer(sender: UIButton)
    {
        self.mailComposerView.hidden=true;
        //self.mailToInputText.getEmailLists();
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
        
        //邮件主题
        self.mailTopicInputText.text=self.mailTopic;

        
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
    
    private func setSendButtonEnable(enable:Bool=true)
    {
        let sendBarBtnItem=self.mailSendBtn;
        let cancelBtnItem=self.btnExit;
        
        
        if enable
        {
            sendBarBtnItem.enabled=true;
            sendBarBtnItem.backgroundColor=UIColor.greenColor();
            
            cancelBtnItem.enabled=true;
            
        }
        else
        {
            sendBarBtnItem.enabled=false;
            sendBarBtnItem.backgroundColor=UIColor.lightGrayColor();
            
            cancelBtnItem.enabled=false;
            
        }
    }




}


//MARK:ACTextArea扩展
extension ACTextArea
{
    //MARK:代码创建UILabel
    func setTextArea(x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat,fonSize:CGFloat,isBold:Bool,color:UIColor,hasBorder:Bool=true)
    {
        self.frame = CGRectMake(x,y,width,height);
        
        self.backgroundColor = UIColor.whiteColor();
        
        //设置字体
        
        
        if isBold
        {
            self.font = UIFont.boldSystemFontOfSize(fonSize)
            
        }
        else
        {
            self.font = UIFont.systemFontOfSize(fonSize)
            
        }
        if hasBorder
        {
            self.layer.borderWidth = 1;
            self.layer.borderColor = UIColor.grayColor().CGColor;
            
            self.layer.cornerRadius = 8
            self.layer.masksToBounds=true;
        }
        
        //       self.loadItems(["Felipe Saint-Jean","Test User","Jack"]);
        let arr = ACAddressBookDataSource();
        self.placeholder="email...";
        self.autoCompleteDataSource = arr;
        
        
        
    }
    
    
    //MARK:获取邮件地址
    func getEmailLists()->[MCOAddress]
    {
        var emailLists=[MCOAddress]();
        
        var tempStr="";
        
        var displayName="";
        var email:String="";
        
        for item in self.items
        {
            
            
            if item is ACAddressBookElement
            {
                let a=item as! ACAddressBookElement;
                displayName="\(a.last_name)"+"\(a.first_name)";
                email=a.email;
                emailLists.append(MCOAddress(displayName: displayName, mailbox: email));

            }
            
            if item is String
            {
                tempStr="\(item)";
                
                let atRange=tempStr.rangeOfString("@");
                
                if atRange != nil
                {
                    displayName=tempStr;
                    email=tempStr
                    emailLists.append(MCOAddress(displayName: displayName, mailbox: email));

                }
                
            }
        }
        
        return emailLists;
        
    }
    
}


//MARK:- 在Controller里扩展一个消息提示框
extension UIViewController//实现一个提示框
{
    func ShowNotice(caption:String,_ message:String)//显示一个可以自动消失的消息提示框,by shiww//必须用支持国际化的字符串
    {
        let intelCaption=BaseFunction.getIntenetString(caption);
        let intelMessage=BaseFunction.getIntenetString(message);
        
        let alertController = UIAlertController(title: intelCaption,
                                                message: intelMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alertController, animated: true)
        {
    //        let timmer:NSTimer =
                NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:#selector(UIViewController.removeIt(_:)), userInfo:alertController, repeats:false);
        }
    }
    
    
    func removeIt(sender:NSTimer)    {
        let alertVC=sender.userInfo as! UIAlertController;
        
        //设置动画效果，动画时间长度 1 秒。
        UIView.animateWithDuration(1, animations:
            {()-> Void in
                alertVC.view.alpha = 0.0
            },
                                   completion:{
                                    (finished:Bool) -> Void in
                                    alertVC.dismissViewControllerAnimated(true,completion:nil);
        })
    }
    
    
}
//MARK:- NSUserDefaults中扩展UIColor存储

//必须做一个扩展,否则UIColor存不进去
extension NSUserDefaults {
    
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = dataForKey(key) {
            color = NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedDataWithRootObject(color)
        }
        setObject(colorData, forKey: key)
    }
    
}



