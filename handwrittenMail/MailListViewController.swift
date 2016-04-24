//
//  MailListViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/6.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit

class MailListViewController: UITableViewController,RefreshMailListDataDelegate {
    
    
    var mail:BaseMail!;

    var mailList=[MCOIMAPMessage]();
    
//    var t:MCOMessageParser?;
    
//    private var mailContent=String();
    
    var detailViewController: DetailViewController? = nil
    
    //MARK:下拉刷新,上拉加载
    func setupRefresh(){
        self.tableView.addHeaderWithCallback({
            self.setupStatus(BaseFunction.getIntenetString("正在加载邮件列表"));

              let delayInSeconds = Int64(NSEC_PER_SEC) * 2
            let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                self.mail.getMailList("$SAMEFOLDER",delegate:self,upFresh:true)
                self.tableView.headerEndRefreshing()
            })
            
        })
        
        
        
        self.tableView.addFooterWithCallback({
            
            self.setupStatus(BaseFunction.getIntenetString("正在加载邮件列表"));

              let delayInSeconds:Int64 = Int64(NSEC_PER_SEC) * 2
            let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                self.mail.getMailList("$SAMEFOLDER",delegate:self,upFresh:false)
                self.tableView.footerEndRefreshing()
                
                //self.tableView.setFooterHidden(true)
            })
        })
    }

    
    //MARK:viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if let split = self.splitViewController
        {
            let controllers = split.viewControllers
            
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        setupRightBarButtonItem();
        
        //3.加底部状态信息
        let statusbutton = UIBarButtonItem(title: BaseFunction.getIntenetString("刚刚更新"), style: UIBarButtonItemStyle.Plain, target: self,action: nil)
        let flexButton=UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.FlexibleSpace, target: self,action: nil)
        
        
        let items=[flexButton,statusbutton,flexButton];
        //必须加上topViewController，否则不管用
        self.navigationController?.topViewController!.setToolbarItems(items, animated: true)
        
        self.navigationController?.setToolbarHidden(false, animated:true)
        
        
        //登记一个可重用的CELL
        let nib = UINib(nibName: "UIMailListViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "maillist")
        
        setupRefresh();//下拉刷新,上拉加载
        
        self.navigationItem.title=BaseFunction.getIntenetString("收件箱")
        
        self.tableView.editing = false;//默认tableview的editing 是不开启的
        
    }
    
    //MARK:加右边按钮
    func setupRightBarButtonItem()
    {
        let rightButtonItem = UIBarButtonItem(title:BaseFunction.getIntenetString("编辑"), style: UIBarButtonItemStyle.Plain, target: self,action: #selector(MailListViewController.deleteMultiMails))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
    }
    //MARK:多选删除邮件
    func deleteMultiMails()
    {
        
        //1-允许多选
        
        self.tableView.allowsMultipleSelectionDuringEditing = !self.tableView.allowsMultipleSelectionDuringEditing;
        

        //0-切换编辑状态
        self.tableView.editing = !self.tableView.editing
        
          //2--加上全选和删除按钮
        if self.tableView.editing
        {
            setDeleteButtons();
        }
        else
        {
            //3.加底部状态信息
            let statusbutton = UIBarButtonItem(title: BaseFunction.getIntenetString("刚刚更新"), style: UIBarButtonItemStyle.Plain, target: self,action: nil)
            let flexButton=UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.FlexibleSpace, target: self,action: nil)

    
            let items=[flexButton,statusbutton,flexButton];
            //必须加上topViewController，否则不管用
            self.navigationController?.topViewController!.setToolbarItems(items, animated: true)
            
        }
        
        
    }
    
    //MARK:设置全选删除邮件列表时的container
    //没有判断是否存在，全部新建
    private func setDeleteButtons()
    {
        //3.加底部状态信息
        let selectButton = UIBarButtonItem(title:BaseFunction.getIntenetString("全选"), style: UIBarButtonItemStyle.Plain, target: self,action: #selector(MailListViewController.selectAllMail))
        let flexButton=UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.FlexibleSpace, target: self,action: nil)
        let deleteButton =  UIBarButtonItem(title: BaseFunction.getIntenetString("删除"), style: UIBarButtonItemStyle.Plain, target: self,action: #selector(MailListViewController.deleteSelectedMails));
       
        
        let items=[selectButton,flexButton,deleteButton];
        //必须加上topViewController，否则不管用
        self.navigationController?.topViewController!.setToolbarItems(items, animated: true)
        
        /*
    
        let height=self.navigationController!.toolbar.bounds.height;
        let width:CGFloat=90;
    
    //
    //2.先设置底部按钮--全选
    
        let wholeView=self.view;//.superview!;
    
    print(wholeView.frame.size);
    
    
    
    self.bottomView = UIView(frame: CGRectMake(0, wholeView.frame.size.height-height,wholeView.frame.size.width, height));
    bottomView!.backgroundColor=UIColor.lightGrayColor();
    wholeView.addSubview(bottomView!);
        bottomView!.hidden=true;
    wholeView.bringSubviewToFront(bottomView!)
    
    selectedBtn = UIButton(type:UIButtonType.System);
    selectedBtn.setTitle("全选",forState:UIControlState.Normal);
    selectedBtn.setTitleColor(UIColor.whiteColor(), forState:UIControlState.Normal);
    selectedBtn.frame = CGRectMake(0,0, width, height);
    selectedBtn.addTarget(self,action:#selector(MailListViewController.selectAllMail),forControlEvents:.TouchUpInside);//全选
    
    bottomView!.addSubview(selectedBtn);
    
    
    //1.先设置底部按钮--删除
    deleteBtn = UIButton(type:UIButtonType.System);
    deleteBtn.setTitle("删除",forState:UIControlState.Normal);
    deleteBtn.setTitleColor(UIColor.whiteColor(), forState:UIControlState.Normal);
    deleteBtn.backgroundColor=UIColor.redColor()
    
    deleteBtn.frame = CGRectMake(bottomView!.frame.size.width-width,0, width, height);
    
    deleteBtn.addTarget(self,action:#selector(MailListViewController.deleteSelectedMails),forControlEvents:.TouchUpInside);//全选
    
    
    bottomView!.addSubview(deleteBtn);*/
    
    }
    
    //MARK:选择所有邮件
    func selectAllMail()
    {
      //选择所有邮件
        let Rows = self.tableView.indexPathsForVisibleRows!;
        
        for index in Rows
        {
        
        self.tableView.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.None)
        }
    
        
    }
    //MARK:delete选择的邮件
    func deleteSelectedMails()
    {
        //删除选择的邮件
        let allSelected=self.tableView.indexPathsForSelectedRows;
        if allSelected != nil
        {
            allSelected?.sort({ (a, b) -> Bool in
                a.row>b.row
            })
        self.delCurrentMsgs(allSelected!);
        
//        if allSelected?.count<=0//什么也没选
//        {
//            return;
//        }
//        for eachSel in allSelected!
//        {
//            self.delCurrentMsg(eachSel);//单个删除的方法不科学，可以批量提交
//        }
        self.deleteMultiMails();//关闭编辑状态
        }
    }
    
    //设置tableview是否可编辑
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    //选择编辑的方式,按照选择的方式对表进行处理
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
   
    }
    
    //选择你要对表进行处理的方式  默认是删除方式
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return (UITableViewCellEditingStyle.Delete)
    }
    
    //选中时将选中行的在self.dataArray 中的数据添加到删除数组self.deleteArr中

 /*   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        print("row = %d",indexPath.row)
    }*/
    
    //取消选中时将选中行的在self.dataArray 中的数据从删除数组self.deleteArr中删除
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        print("row = %d",indexPath.row)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       // print("count=\(mailList.count)");
        return mailList.count;
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        print(tableView.frame.width);
        
        let identifier="maillist";

        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UIMailListViewCell
        
//        if(cell == nil)
//        {
//            cell=UIMailListViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier);
//        }
        
        
        let msg = mailList[indexPath.row];
        
        var info = EmailInfo();
        
        info.mailId = "\(msg.uid)";
        info.subject = "\(msg.header.subject)";
        info.name = (msg.header.from.displayName != nil) ? msg.header.from.displayName:msg.header.from.mailbox;
        //[self stringReplaceNil:(msg.header.from.displayName?msg.header.from.displayName:[self mailBox2Display:msg.header.from.mailbox])];
        info.sendTime = msg.header.receivedDate;//[self stringReplaceNil:[self dateFormatString:msg.header.receivedDate]];
        info.attach = msg.attachments().count;
        
        
        if msg.flags.contains(MCOMessageFlag.Seen)
        {
            cell.mailFlagImg.image=UIImage(named:"read");//已读,未读标志
        }
        else
        {
            cell.mailFlagImg.image=UIImage(named:"unread");//已读,未读标志
            
        }
        cell.mailFromLbl.text=info.name;//发件人
        
        let sendtime = info.sendTime;
        var timeStamp = sendtime.toString(format: DateFormat.Custom("HH:mm"));//HH：两位字符串表示“小时”（例如08或19）
        var timePrefix="";
        if sendtime.isToday()
        {
            timePrefix="";
        }
        else
        if sendtime.isYesterday()
        {
            timePrefix=BaseFunction.getIntenetString("昨天");
        }
        else
        if sendtime.isYesterday()
        {
            timePrefix=sendtime.weekdayName
        }
        else
            {
                timePrefix=sendtime.toShortDateString();
        }
        
        timePrefix=timePrefix+" ";
        
        timeStamp=timePrefix+timeStamp;


        
        
        cell.mailDateLbl.text=timeStamp;
        
        timeStamp=sendtime.toString(format: DateFormat.Custom("YYYY-MM-dd EEEE HH:mm"));
        
        cell.mailDigestLbl.text=timeStamp;//目前没有提取摘要信息
        
        cell.mailSubjectLbl.text=info.subject;
        
        if info.attach > 0
        {
        cell.mailAttatchImgFlag.image=UIImage(named:"hasattatch");//是否有附件
        }
        else{
            cell.mailAttatchImgFlag.image=UIImage(named:"read");//是否有附件
 
        }
        
        
        return cell;
        
    }
    
    

    // MARK:点击邮件列表,显示邮件信息
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if self.tableView.editing==true
        {
           //正在编辑
            return;
        }
  
        if indexPath.row >= 0
        {
     
            self.mail.getMail(self.mailList[indexPath.row], delegateMail: detailViewController!)
            
  
            if !self.mailList[indexPath.row].flags.contains(MCOMessageFlag.Seen)
            {
            
            let delayInSeconds = Int64(NSEC_PER_SEC) * 1
            let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                //设置read/unread状态
                self.setReaded(true,uid:UInt64(self.mailList[indexPath.row].uid),folder:self.mail.mailFolderName)
                
                self.mailList[indexPath.row].flags=[self.mailList[indexPath.row].flags,MCOMessageFlag.Seen];
                
                let tableview=self.view as! UITableView;
                
                
                tableview.reloadRowsAtIndexPaths([indexPath],withRowAnimation:UITableViewRowAnimation.None);
              
            })
            }
            
         //隐藏MasterView
            let splitViewController = UIApplication.sharedApplication().keyWindow?.rootViewController as! UISplitViewController
            //navigationController!.parentViewController as! UISplitViewController;
            splitViewController.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryHidden;
        }
    }
    
    //MARK:刷新邮件列表
    func RefreshMailListData(objData:[MCOIMAPMessage],upFresh:Bool)
    {
        self.mailList=objData;
        let tableview=self.view as! UITableView;
        tableview.reloadData();
        
        self.setupStatus(BaseFunction.getIntenetString("邮件列表刚刚更新"));

        if !upFresh //只有下拉时才刷新
        {
          return;
        }
        
        //默认选中第一个
        if(self.mailList.count<=0)
        {
            self.detailViewController?.clearAll();//清空当前邮件显示的内容
            return;
        }
        
        let selectedIndex:Int = 0;
        
        let selectedIndexPath = NSIndexPath(forRow:selectedIndex,inSection:0);
        
        self.tableView.selectRowAtIndexPath(selectedIndexPath,animated:false,scrollPosition:UITableViewScrollPosition.None);
        
        //加上这一句,才会触发点击事件
        self.tableView.delegate!.tableView!(self.tableView,didSelectRowAtIndexPath:selectedIndexPath);
        
        

    }
    
    //返回行高
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath:NSIndexPath) -> CGFloat
    {
        //计算行高，返回，textview根据数据计算高度
        return 111;
    }
    
    //MARK:设置底部状态栏信息
    func setupStatus(info:String)
    {
        if !self.tableView.editing
        {
            let statusbar=self.navigationController?.topViewController! .toolbarItems![1];
        statusbar?.title=info;
        }
    }
    
    //Mark:设置消息为已读/未读
    func setReaded(readed:Bool,uid:UInt64,folder:String)
    {
        let imapSession=self.mail.mailconnection as! MCOIMAPSession;
        let folderName = imapSession.defaultNamespace.pathForComponents([folder]);
        
        let op2 = imapSession.storeFlagsOperationWithFolder(folderName,
                                                            uids:MCOIndexSet(index:uid),kind:(readed ? MCOIMAPStoreFlagsRequestKind.Set:MCOIMAPStoreFlagsRequestKind.Remove),
                                                            flags:MCOMessageFlag.Seen);
        
        op2.start { (error:NSError?) in
            if error==nil
            {
//                print("undo/redo设置成功!")
                
            }
            
        }
        
    }
    
    
    //左滑操作
    override func tableView(tableView: UITableView,
                            editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?{
        // 1
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title:BaseFunction.getIntenetString("删除") , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            // 2
            let deleteMenu = UIAlertController(title: nil, message: BaseFunction.getIntenetString("删除"), preferredStyle: .ActionSheet)
            
            let deleteAction = UIAlertAction(title: BaseFunction.getIntenetString("确认删除"), style: UIAlertActionStyle.Default)
            {
                //删除邮件
                (UIAlertAction) -> Void in
                
                self.delCurrentMsgs([indexPath]);

                
            }
            let cancelAction = UIAlertAction(title: BaseFunction.getIntenetString("CANCEL"), style: UIAlertActionStyle.Cancel, handler: nil)
            
            deleteMenu.addAction(deleteAction)
            deleteMenu.addAction(cancelAction)
            
//            deleteMenu.popoverPresentationController?.sourceView=tableView.cellForRowAtIndexPath(indexPath);
//            
//            var bounds=(tableView.cellForRowAtIndexPath(indexPath)?.bounds)!;
//            
//            bounds=CGRect(x:0,y: bounds.origin.y,width: bounds.width,height: bounds.height);
//            
//            
//            deleteMenu.popoverPresentationController?.sourceRect=bounds;

            
            self.presentViewController(deleteMenu, animated: true, completion: nil)
        })
       // shareAction.backgroundColor=UIColor(patternImage: UIImage(named: "trash")!);
        // 3
        let unreadAction =  UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: BaseFunction.getIntenetString("已读?") , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            // 4
            let setreadMenu = UIAlertController(title: nil, message: BaseFunction.getIntenetString("阅读状态"), preferredStyle: .ActionSheet)
            
            let readAction = UIAlertAction(title: BaseFunction.getIntenetString("已读"), style: UIAlertActionStyle.Default)
            {
                (UIAlertAction) -> Void in
                
                self.setcurrentMsgRead(indexPath,readed: true);
                
            };

            let unreadAction = UIAlertAction(title:  BaseFunction.getIntenetString("未读"), style: UIAlertActionStyle.Default)
            {
                (UIAlertAction) -> Void in
                
                self.setcurrentMsgRead(indexPath,readed: false);
                
            };

            
            let cancelAction = UIAlertAction(title:BaseFunction.getIntenetString("CANCEL"), style: UIAlertActionStyle.Cancel, handler: nil)
            
            setreadMenu.addAction(readAction)
            setreadMenu.addAction(unreadAction)

            setreadMenu.addAction(cancelAction)
            
            
//            setreadMenu.popoverPresentationController?.sourceView=tableView.cellForRowAtIndexPath(indexPath);
//            
//            var bounds=(tableView.cellForRowAtIndexPath(indexPath)?.bounds)!;
//            
//            bounds=CGRect(x:0,y: bounds.origin.y,width: bounds.width,height: bounds.height);
//            
//            
//            setreadMenu.popoverPresentationController?.sourceRect=bounds;
//
            
            
            self.presentViewController(setreadMenu, animated: true, completion: nil)
        })
        // 5
        return [shareAction,unreadAction]
    }
    
    //MARK:批量删除邮件
    func  delCurrentMsgs(indexPaths: [NSIndexPath])
    {
        if indexPaths.count <= 0
        {
            return;
        }
        
        
        let imapSession=self.mail.mailconnection as! MCOIMAPSession;
        let folderName = self.mail.mailFolderName;//imapSession.defaultNamespace.pathForComponents([self.mail.m]);
        
        
          let deleteFolder = self.mail.deleteFolder //imapSession.defaultNamespace.pathForComponents(["已删除"]);
        
        let draftFolder = self.mail.draftFolder//imapSession.defaultNamespace.pathForComponents(["草稿箱"]);
        
        //这里判断是不是“已删除”和“草稿箱”两个文件夹，如果不是那么使用copyMessage来复制邮件到“已删除”
        let uids=MCOIndexSet();
        //0--先把要删除的UID保存下来
        for indexPath in indexPaths
        {
            let index=indexPath.row;
            uids.addIndex(UInt64(self.mailList[index].uid))
        }
        //1--再删除列表

        var i=indexPaths.count;
        
        while(i>0)
        {
            let index=indexPaths[i-1].row;
//            print(index);
            self.mailList.removeAtIndex(index);
            i=i-1;
        }
        //2--刷新
        self.tableView.reloadData();
        
        if self.tableView.numberOfRowsInSection(0)>0
        {
            let selectedIndex:Int = 0;
            
            let selectedIndexPath = NSIndexPath(forRow:selectedIndex,inSection:0);
            
            self.tableView.selectRowAtIndexPath(selectedIndexPath,animated:false,scrollPosition:UITableViewScrollPosition.None);
            
            //加上这一句,才会触发点击事件
            self.tableView.delegate!.tableView!(self.tableView,didSelectRowAtIndexPath:selectedIndexPath);
        }
        else
        {
            detailViewController?.clearAll();
        }

        
        
        if (folderName != deleteFolder) && (folderName != draftFolder)
        {
            let op = imapSession.copyMessagesOperationWithFolder(folderName,uids:uids,destFolder:deleteFolder);
            
            op.start()
                {
                    (error:NSError?,uidMapping:[NSObject : AnyObject]?)->Void in
                    if error==nil
                    {
                        
                        self.unturnedDeleteMails(uids)
                    }
                    
            }
            
        }
        else
        {
            self.unturnedDeleteMails(uids);
        }
        
    }
    
    //MARK:真正地批量删除邮件,而不是复制到"已删除"目录中
    private func unturnedDeleteMails(uids:MCOIndexSet)
    {
        
        let imapSession=self.mail.mailconnection as! MCOIMAPSession;
        let folderName = self.mail.mailFolderName;//imapSession.defaultNamespace.pathForComponents([self.mail.m]);
        //先添加删除flags
        let op2 = imapSession.storeFlagsOperationWithFolder(folderName,            uids:uids,
                                                            kind:MCOIMAPStoreFlagsRequestKind.Set,
                                                            flags:MCOMessageFlag.Deleted);
        
        op2.start()
            {
                (error:NSError?) in
                if error==nil{
                    let deleteOp = imapSession.expungeOperation(folderName);
                    
                    deleteOp.start(){
                        (error:NSError?) in
                        
                        if error==nil{
                            print("real delete succeeded!");
                            
                        }
                        else{
                            print("real delete failed!");
                            
                        }
                    }
                }
        }
        
    }


    
 
    //MARK:设置当前邮件为未读或已读
    private func setcurrentMsgRead(indexPath: NSIndexPath,readed:Bool)
    {
        //点击时自动设置为未读,现在又可手工设置,二者冲突不知如何解决?以下代码现在还不起作用,有待修改
          let delayInSeconds = Int64(NSEC_PER_SEC) * 1
        let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
        dispatch_after(popTime, dispatch_get_main_queue(), {
            //设置read/unread状态
            self.setReaded(readed,uid:UInt64(self.mailList[indexPath.row].uid),folder:self.mail.mailFolderName)
            
            if readed
            {
                if !self.mailList[indexPath.row].flags.contains(MCOMessageFlag.Seen)
                {
                self.mailList[indexPath.row].flags=[self.mailList[indexPath.row].flags,MCOMessageFlag.Seen];
                }
            }
            else
            {
                if self.mailList[indexPath.row].flags.contains(MCOMessageFlag.Seen)
                {

                   self.mailList[indexPath.row].flags.remove(MCOMessageFlag.Seen);
                }
            }
            
            let tableview=self.tableView;
            
            
            tableview.reloadRowsAtIndexPaths([indexPath],withRowAnimation:UITableViewRowAnimation.None);
            
        })
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
         if self.tableView.editing
         {
            self.deleteMultiMails()
        }
    }
    
    
}
