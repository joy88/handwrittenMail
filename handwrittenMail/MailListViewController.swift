//
//  MailListViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/6.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit

class MailListViewController: UITableViewController {
    
    var mail:BaseMail!;

    var mailList=[String]();
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
        self.mailList.append("超图")
        self.mailList.append("http://www.supermap.com.cn")
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
        
        let identifier="mymaillist";
        var cell=tableView.dequeueReusableCellWithIdentifier(identifier);
        if(cell == nil){
            cell=UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier);
        }
        
        
        //       let cell = tableView.dequeueReusableCellWithIdentifier("mymaillist", forIndexPath: indexPath)
        
        
        cell!.textLabel!.text = mailList[indexPath.row]
        cell!.imageView!.image = UIImage(named:"green")
        
        
        return cell!
        
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
    
    func refresh()
    {
        let tableview=self.view as! UITableView;
        tableview.reloadData();
    }
    
}
