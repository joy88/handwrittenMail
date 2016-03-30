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
            self.setupStatus("正在加载邮件列表");

              let delayInSeconds = Int64(NSEC_PER_SEC) * 2
            let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                self.mail.getMailList("$SAMEFOLDER",delegate:self,upFresh:true)
                self.tableView.headerEndRefreshing()
            })
            
        })
        
        
        
        self.tableView.addFooterWithCallback({
            
            self.setupStatus("正在加载邮件列表");

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
        let statusbutton = UIBarButtonItem(title: "刚刚更新", style: UIBarButtonItemStyle.Plain, target: self,action: nil)
        statusbutton.width=0;//调左边距的(self.navigationController?.toolbar.bounds.width)!;
        
        
        let items=[statusbutton];
        //必须加上topViewController，否则不管用
        self.navigationController?.topViewController!.setToolbarItems(items, animated: true)
        
        self.navigationController?.setToolbarHidden(false, animated:true)
        
        
        //登记一个可重用的CELL
        let nib = UINib(nibName: "UIMailListViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "maillist")
        
        setupRefresh();//下拉刷新,上拉加载
        
        self.navigationItem.title="INBOX"
        
        self.tableView.editing = false;//默认tableview的editing 是不开启的
        
    }
    
    //MARK:加右边按钮
    func setupRightBarButtonItem()
    {
        let rightButtonItem = UIBarButtonItem(title: "编辑", style: UIBarButtonItemStyle.Plain, target: self,action: #selector(MailListViewController.rightBarButtonItemClicked))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
    }
    //MARK:增加事件
    func rightBarButtonItemClicked()
    {
        //MARK:---功能尚未完成------
        //0-切换编辑状态
        self.tableView.editing = !self.tableView.editing
        
        //1-允许多选

        self.tableView.allowsMultipleSelectionDuringEditing = true;
        /*这也是一种方式
        //3.加底部状态信息
        let leftbutton = UIBarButtonItem(title: "全选", style: UIBarButtonItemStyle.Plain, target: self,action: nil)
        let rightbutton = UIBarButtonItem(title: "删除", style: UIBarButtonItemStyle.Plain, target: self,action: nil)

        
        
        let items=[leftbutton,rightbutton];
        //必须加上topViewController，否则不管用
        self.navigationController?.topViewController!.setToolbarItems(items, animated: true)
        */
        
        self.navigationController?.setToolbarHidden(!(self.navigationController!.toolbar.hidden)
, animated:false)
        
        let height=self.navigationController!.toolbar.bounds.height;
        let width:CGFloat=90;
        
  
        //
        //2.先设置底部按钮--全选
        
        let wholeView=self.view.superview!;
        
        print(wholeView.frame.size);
        
  
        
        let bottomView = UIView(frame: CGRectMake(0, wholeView.frame.size.height-height,wholeView.frame.size.width, height));
        bottomView.backgroundColor=UIColor.lightGrayColor();
        wholeView.addSubview(bottomView);
        wholeView.bringSubviewToFront(bottomView)
        
        let selectedBtn = UIButton(type:UIButtonType.System);
        selectedBtn.setTitle("全选",forState:UIControlState.Normal);
        selectedBtn.setTitleColor(UIColor.whiteColor(), forState:UIControlState.Normal);
        selectedBtn.frame = CGRectMake(0,0, width, height);
        selectedBtn.addTarget(self,action:#selector(MailListViewController.selectAllMail),forControlEvents:.TouchUpInside);//全选
        
        bottomView.addSubview(selectedBtn);
        
        
        //1.先设置底部按钮--删除
        let deleteBtn = UIButton(type:UIButtonType.System);
        deleteBtn.setTitle("删除",forState:UIControlState.Normal);
        deleteBtn.setTitleColor(UIColor.whiteColor(), forState:UIControlState.Normal);
        deleteBtn.backgroundColor=UIColor.redColor()
        
        deleteBtn.frame = CGRectMake(bottomView.frame.size.width-width,0, width, height);
        
        deleteBtn.addTarget(self,action:#selector(MailListViewController.deleteSelectedMails),forControlEvents:.TouchUpInside);//全选
        
     
        bottomView.addSubview(deleteBtn);


    
        
        
    }
    
    //MARK:选择所有邮件
    func selectAllMail()
    {
      //选择所有邮件
        
    }
    //MARK:delete选择的邮件
    func deleteSelectedMails()
    {
        //删除选择的邮件
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
        
        let identifier="maillist";

        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UIMailListViewCell
        
//        if(cell == nil)
//        {
//            cell=UIMailListViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier);
//        }
        
        
        let msg = mailList[indexPath.row];
        
        var info = EmailInfo();
        
        info.mailId = "\(msg.uid)";
        info.subject = msg.header.subject;
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
            timePrefix="昨天";
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
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
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
            
//            detailViewController!.navigationItem.leftBarButtonItem?.title=self.navigationItem.title!;
//            print(detailViewController!.navigationItem.leftBarButtonItem?.title);

            
  
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
    func RefreshMailListData(objData:[MCOIMAPMessage])
    {
        self.mailList=objData;
        let tableview=self.view as! UITableView;
        tableview.reloadData();
        
        self.setupStatus("邮件列表刚刚更新");

        
        //默认选中第一个
        if(self.mailList.count<=0)
        {
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
        let statusbar=self.navigationController?.topViewController!.toolbarItems![0];
        statusbar?.title=info;
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
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "删除" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            // 2
            let deleteMenu = UIAlertController(title: nil, message: "删除", preferredStyle: .ActionSheet)
            
            let deleteAction = UIAlertAction(title: "确定删除", style: UIAlertActionStyle.Default)
            {
                //删除邮件
                (UIAlertAction) -> Void in
                
                self.delCurrentMsg(indexPath);

                
            }
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
            
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
        let unreadAction =  UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "已读?" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            // 4
            let setreadMenu = UIAlertController(title: nil, message: "阅读状态", preferredStyle: .ActionSheet)
            
            let readAction = UIAlertAction(title: "已读", style: UIAlertActionStyle.Default)
            {
                (UIAlertAction) -> Void in
                
                self.setcurrentMsgRead(indexPath,readed: true);
                
            };

            let unreadAction = UIAlertAction(title: "未读", style: UIAlertActionStyle.Default)
            {
                (UIAlertAction) -> Void in
                
                self.setcurrentMsgRead(indexPath,readed: false);
                
            };

            
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
            
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
    
    //MARK:删除当前邮件
    private func  delCurrentMsg(indexPath: NSIndexPath)
    {
        if indexPath.row < 0
        {
            return;
        }
        
        let index=indexPath.row;
        
        let imapSession=self.mail.mailconnection as! MCOIMAPSession;
        let folderName = self.mail.mailFolderName;//imapSession.defaultNamespace.pathForComponents([self.mail.m]);
        let deleteFolder = imapSession.defaultNamespace.pathForComponents(["已删除"]);
        let draftFolder = imapSession.defaultNamespace.pathForComponents(["草稿箱"]);
        //这里判断是不是“已删除”和“草稿箱”两个文件夹，如果不是那么使用copyMessage来复制邮件到“已删除”
        
        self.mailList.removeAtIndex(indexPath.row);
        self.tableView.reloadData();

        
        if (folderName != deleteFolder) && (folderName != draftFolder)
        {
            let op = imapSession.copyMessagesOperationWithFolder(folderName,uids:MCOIndexSet(index:UInt64(self.mailList[index].uid)),destFolder:deleteFolder);
            
            op.start()
                {
                    (error:NSError?,uidMapping:[NSObject : AnyObject]?)->Void in
                    if error==nil
                    {
                
                        self.unturnedDelete(self.mailList[index].uid,indexPath: indexPath)
                    }
                
            }
            
        }
        else
        {
            self.unturnedDelete(self.mailList[index].uid,indexPath: indexPath);
        }
        
    }
    
    
    //MARK:真正地删除邮件,而不是复制到"已删除"目录中
    private func unturnedDelete(uid:UInt32,indexPath: NSIndexPath)
    {
        if indexPath.row < 0
        {
            return;
        }
        
        let index=indexPath.row;
        
        let imapSession=self.mail.mailconnection as! MCOIMAPSession;
        let folderName = self.mail.mailFolderName;//imapSession.defaultNamespace.pathForComponents([self.mail.m]);
        //先添加删除flags
        let op2 = imapSession.storeFlagsOperationWithFolder(folderName,            uids:MCOIndexSet(index:UInt64(self.mailList[index].uid)),
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
    
    
    
}
