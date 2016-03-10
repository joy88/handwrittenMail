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
        let statusbutton = UIBarButtonItem(title: "编辑加底部状态信息", style: UIBarButtonItemStyle.Plain, target: self,action: nil)
        statusbutton.width=0;//调左边距的(self.navigationController?.toolbar.bounds.width)!;
        
        
        let items=[statusbutton];
        //必须加上topViewController，否则不管用
        self.navigationController?.topViewController!.setToolbarItems(items, animated: true)
        
        self.navigationController?.setToolbarHidden(false, animated:true)
        
        //登记一个可重用的CELL
        var nib = UINib(nibName: "UIMailListViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "maillist")
    }
    
    //加右边按钮
    func setupRightBarButtonItem()
    {
        let rightButtonItem = UIBarButtonItem(title: "编辑", style: UIBarButtonItemStyle.Plain, target: self,action: "rightBarButtonItemClicked")
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
    }
    //增加事件
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
        print("count=\(mailList.count)");
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
        
        
        cell.mailFlagImg.image=UIImage(named:"green");//已读,未读标志
        cell.mailFromLbl.text=info.name;//发件人
        cell.mailDateLbl.text="\(info.sendTime)";
        cell.mailDigestLbl.text="\(info.sendTime)";
        
        cell.mailSubjectLbl.text=info.subject;
        cell.mailAttatchImgFlag.image=UIImage(named:"green");//是否有附件
        
        
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
    // UITableViewDelegate协议方法，点击时调用
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        /*       // 跳转到detailViewController，取消选中状态
        self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        //更具定义的Segue Indentifier进行跳转
        self.performSegueWithIdentifier("ShowMaillist", sender: siteLists![indexPath.row])*/
        
        if indexPath.row >= 0
        {
            //            self.detailViewController?.hidesBottomBarWhenPushed=true;
            
            self.mailContent = self.mail.getMail("temp");
            
            
            
            detailViewController!.detailItem = mailContent;
            
        }
    }
    
    
    func RefreshMailListData(objData:[MCOIMAPMessage])
    {
        self.mailList=objData;
        let tableview=self.view as! UITableView;
        tableview.reloadData();
    }
    
    //返回行高
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath:NSIndexPath) -> CGFloat
    {
        //计算行高，返回，textview根据数据计算高度
        return 111;
    }
}
