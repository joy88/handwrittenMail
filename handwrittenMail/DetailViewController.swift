//
//  DetailViewController.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/5.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = detailItem {
            
            if let myWebview = webView {
                let url = NSURL(string: detailItem as! String)
                let request = NSURLRequest(URL: url!)
                myWebview.scalesPageToFit = false
                myWebview.loadRequest(request)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        //1.右边第一个按钮
        let composeButton = UIBarButtonItem(barButtonSystemItem:.Compose, target: self, action: nil)
        //2.second
        let replyButton = UIBarButtonItem(barButtonSystemItem:.Reply, target: self, action: nil)
        let trashButton = UIBarButtonItem(barButtonSystemItem:.Trash, target: self, action: nil)
        
        let organizeButton = UIBarButtonItem(barButtonSystemItem:.Organize, target: self, action: nil)
        //如果是自定义图片,必须得有imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal),否则是个纯色图片
        let moreButton = UIBarButtonItem(image: UIImage(named: "master3")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self,action: nil)
        
        
        
        let rightItems=[composeButton,replyButton,trashButton,organizeButton,moreButton];
        
        
        self.navigationItem.rightBarButtonItems = rightItems
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

