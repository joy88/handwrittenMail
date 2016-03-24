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
    
    private var mailContent=String();
    
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
    }
    
    //MARK:加右边按钮
    func setupRightBarButtonItem()
    {
        let rightButtonItem = UIBarButtonItem(title: "编辑", style: UIBarButtonItemStyle.Plain, target: self,action: "rightBarButtonItemClicked")
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
    }
    //MARK:增加事件
    func rightBarButtonItemClicked()
    {
        
        let row = self.mailList.count
        let indexPath = NSIndexPath(forRow:row,inSection:0)
//        self.mailList.append("超图")
//        self.mailList.append("http://www.supermap.com.cn")
        self.tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        
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

        var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UIMailListViewCell
        
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
        
        timeStamp=timePrefix+timeStamp;


        
        
        cell.mailDateLbl.text=timeStamp;
        
        timeStamp=sendtime.toString(format: DateFormat.Custom("YYYY-MM-DD EEEE HH:mm"));
        
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
    // UITableViewDelegate协议方法，点击时调用,显示邮件信息
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
  
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
            
 
        }
    }
    
    //MARK:刷新邮件列表
    func RefreshMailListData(objData:[MCOIMAPMessage])
    {
        self.mailList=objData;
        let tableview=self.view as! UITableView;
        tableview.reloadData();
        self.setupStatus("邮件列表刚刚更新");

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
                print("undo/redo设置成功!")
                
            }
            
        }
        
    }
    
    
}
