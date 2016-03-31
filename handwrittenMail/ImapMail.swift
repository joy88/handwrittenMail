//
//  ImapMail.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/7.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import Foundation

//MARK:单次获取的邮件数量
let NUMBEROFMSGLOAD:Int32 = 20;



class ImapMail : BaseMail {
    private var messageTotalList=[MCOIMAPMessage]();//当前目录下已经加载的邮件列表
    //MARK:初始化
    override init(_ maillogininfo: mailLoginInfo) {
        super.init(maillogininfo);
        
        let imapSession = MCOIMAPSession();
        
        
        
        self.mailconnection=imapSession;
        
        imapSession.hostname = maillogininfo.hostname;
        imapSession.port = maillogininfo.port;
        imapSession.username = maillogininfo.username;
        imapSession.password = maillogininfo.password;
        imapSession.connectionType = maillogininfo.connectionType;
        
        /*
         
         let imapOperation = imapSession.checkAccountOperation();
         
         let semaphore = dispatch_semaphore_create(0)
         
         
         imapOperation.start(){
         (error:NSError?)->Void in
         
         
         if (error == nil) {
         print("login account successed!");
         self.isCanBeConnected=true;
         // 在这里获取邮件，获取文件夹信息
         //[self loadIMAPFolder];
         
         }
         else
         {
         print("login account failure: %@\n", error);
         self.isCanBeConnected=false;
         }
         dispatch_semaphore_signal(semaphore);
         
         };
         
         dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);*/
        
        
    }
    //MARK:获取邮件目录
    override func getMailFolder()
    {
        var mailFolders=[MAILFOLDER]();
        
        
        let imapSession=self.mailconnection as! MCOIMAPSession;
        
        //连接时输出日志
        
        /*        imapSession.connectionLogger =
         {
         
         (connectionID, type, data)->Void in
         
         if data != nil
         {
         let strtemp=NSString(data: data, encoding:NSUTF8StringEncoding);
         
         print(strtemp);
         }
         }*/
        
        let imapFetchFolderOp = imapSession.fetchAllFoldersOperation();
        
        
        imapFetchFolderOp.start()
            {
                (error:NSError?,folders:[AnyObject]?)->Void in
                
                if (error == nil)
                {
                    
                    
                    mailFolders.removeAll();
                    
                    //O_C 代码 转换folder名为中文名,否则乱码
                    //                    static void testMUTF7(void)
                    //                    {
                    //                        int failure = 0;
                    //                        int success = 0;
                    //                        const char * mutf7string = "~peter/mail/&U,BTFw-/&ZeVnLIqe-";
                    //                        IMAPNamespace * ns = IMAPNamespace::namespaceWithPrefix(MCSTR(""), '/');
                    //                        Array * result = ns->componentsFromPath(String::stringWithUTF8Characters(mutf7string));
                    //                        if (strcmp(MCUTF8(result), "[~peter,mail,台北,日本語]") != 0) {
                    //                            failure ++;
                    //                        }
                    //                        else {
                    //                            success ++;
                    //                        }
                    //                        if (failure > 0) {
                    //                            printf("testMUTF7 ok: %i succeeded, %i failed\n", success, failure);
                    //                            global_failure ++;
                    //                            return;
                    //                        }
                    //                        printf("testMUTF7 ok: %i succeeded\n", success);
                    //                        global_success ++;
                    //                    }
                    //完毕
                    
                    //folder支持中文时会有到
                    let ns = MCOIMAPNamespace(prefix: "", delimiter: 47);//47="/"
                    
                    //先构建MailFolders
                    for folder in folders!
                    {
                        let tmpImapFolder=folder as! MCOIMAPFolder;
                        //文件夹名称
                        //不能直接用tmpImapFolder.path!转换一下,否则folder不支持中文
                        let tmpstr=ns.componentsFromPath(tmpImapFolder.path);
                        
                        
                        assert(tmpstr != nil)
                        
                        
                        
                        let folderName=tmpstr[0] as! String
                        
 
                        
                        print("foldername=\(folderName),\(tmpImapFolder.flags)");
                        
                        
                        let tempMailFolder=MAILFOLDER();
                        
                        tempMailFolder.folderNameAlias=folderName;
                        tempMailFolder.folderInfo=tmpImapFolder;
                        tempMailFolder.messageCount="";
                        
                        mailFolders.append(tempMailFolder);
                        
                        
                    }
                    
                    
                    //先更新目录,邮件数量为0
                    self.delegate?.RefreshMailFolderData(self.reAssignMailFolder(                     mailFolders));
                    
                    //开始更新每个目录下的邮件数量
                    for folder in folders!
                    {
                        let tmpImapFolder=folder as! MCOIMAPFolder;
                        //获取邮箱目录中邮件数量信息
                        var mailCount:Int32=0;
                        
                        //文件夹名称
                        //不能直接用tmpImapFolder.path!转换一下,否则folder不支持中文
                        
                        let tmpstr=ns.componentsFromPath(tmpImapFolder.path);
                        
                        
                        assert(tmpstr != nil)
                        
                        
                        
                        
                        let folderName=tmpstr[0] as! String//调式用
                        
                        
                        let imapFetchMailCountOp = imapSession.folderInfoOperation(tmpImapFolder.path);
                        
                        
                        imapFetchMailCountOp.start()
                            {
                                (error:NSError?,info:MCOIMAPFolderInfo?)->Void in
                                
                                
                                if error == nil
                                {
                                    
                                    mailCount=(info?.messageCount)!;
                                    
                                    //更新邮件数量
                                    self.delegate?.RefreshMailFolderMsgCount(tmpImapFolder, msgCount: Int(mailCount))
                                    
                                    
                                    
                                    //mail 数量
                                    print("\(folderName)'s msg count=\(mailCount)");
                                    
                                    
                                }
                                else
                                {
                                    print("get mail count of \(folderName) fail,\(error!)")
                                }
                                
   
                        }
                        
                        
                        
                    }
                    
                    print("Mail Folder's count=\(mailFolders.count)");
                    
                }
                else
                {
                    print("get mail folders failure: %@\n", error);
                    
                }
                
        }
        
    }
    //MARK:获取邮件列表
    override func getMailList(folder:String,delegate:RefreshMailListDataDelegate,upFresh:Bool)
    {
        var folderName=folder;


        
        let imapSession=self.mailconnection as! MCOIMAPSession;
        imapSession.timeout=NSTimeInterval(15);
 //       imapSession.allowsFolderConcurrentAccessEnabled=true;
        //后台日志
/*        imapSession.connectionLogger =
            {
                
                (connectionID, type, data)->Void in
                
                if data != nil
                {
                    let strtemp=NSString(data: data, encoding:NSUTF8StringEncoding);
                    
                    print(strtemp);
                }
        }*/

        
        
 //       folderName=imapSession.defaultNamespace.pathForComponents([folderName]);
        
        if folder=="$SAMEFOLDER"
        {
            folderName=self.mailFolderName;
        }
        else
        {
            if self.mailFolderName != folderName //表示切换了邮件目录
            {
                self.messageTotalList.removeAll();
                self.messageStart=0;
                self.messageCount=0;
                self.messageEnd=0;
            }
            self.mailFolderName=folderName;//保存一下,获取邮件正文信息的时候还要用
        }

          
        
        let requestKind = MCOIMAPMessagesRequestKind(rawValue: MCOIMAPMessagesRequestKind.Headers.rawValue | MCOIMAPMessagesRequestKind.Structure.rawValue |
            MCOIMAPMessagesRequestKind.InternalDate.rawValue | MCOIMAPMessagesRequestKind.HeaderSubject.rawValue |
            MCOIMAPMessagesRequestKind.Flags.rawValue);
        
        
        
        var messageList=[MCOIMAPMessage]();
        
        var messagecount:Int32=0;
        
        
        let imapFetchMailCountOp = imapSession.folderInfoOperation(folderName);
        
        imapFetchMailCountOp.start()
            {
                (error:NSError?,info:MCOIMAPFolderInfo?)->Void in
                
               
                if error == nil
                {
                    messagecount = (info?.messageCount)!;
                    self.messageCount=messagecount;//邮件总数记录下来
                    
                    if messagecount==0
                    {
                        
                        self.messageTotalList.removeAll();
                        
                        delegate.RefreshMailListData(self.messageTotalList,upFresh:upFresh);

                        return;
                    }
                    
                    // 获取邮件信息
                    var numberOfMsgLoad:Int32 = 0;
                    var msgLoadStart:Int32=0;
                    
                    if upFresh //下拉刷新
                    {
                        numberOfMsgLoad = messagecount-self.messageEnd;

                        if (numberOfMsgLoad > NUMBEROFMSGLOAD)
                        {
                            numberOfMsgLoad = NUMBEROFMSGLOAD
                            
                        }
                        
                        
                        
                        msgLoadStart=messagecount-numberOfMsgLoad;
                        
                        self.messageEnd=messagecount;
                        self.messageStart=msgLoadStart;

                        
                    }
                    else
                    {
                        numberOfMsgLoad = NUMBEROFMSGLOAD;

                        msgLoadStart=self.messageStart-numberOfMsgLoad-1;
                        
                        
                        if msgLoadStart<0
                        {
                            numberOfMsgLoad=NUMBEROFMSGLOAD+msgLoadStart+1;
                            msgLoadStart=0;
                        }
                        //要记录下当前的位置
                        self.messageStart=msgLoadStart;

                       }
                    print("self.messageStart=\(self.messageStart)");
                    
              //      print("self.messageStart=\(self.messageStart),self.messageEnd=\(self.messageEnd)");
                    
                    if numberOfMsgLoad<=0
                    {
                        return;
                    }

                    //新浪邮箱有点问题，好象在检索时是从0开始的,只能先这么处理一下了
                    if imapSession.hostname.containsString("sina.com")
                    {
                       // numberOfMsgLoad=numberOfMsgLoad-1;
                        
                    }
                    
                    let numbers = MCOIndexSet(range: MCORangeMake(UInt64(msgLoadStart+1), UInt64(numberOfMsgLoad-1)));
                    
                    
                    let imapMessagesFetchOp = imapSession.fetchMessagesByNumberOperationWithFolder(folderName,
                        requestKind:requestKind,
                        numbers:numbers);
                    
                    // 异步获取邮件
                    imapMessagesFetchOp.start()
                        {
                            (error:NSError?,messages:[AnyObject]?,vanishedMessages:MCOIndexSet?)->Void in
                            if error == nil
                            {
                                messageList=messages as! [MCOIMAPMessage];
                                messageList=messageList.reverse();
                                
                                if upFresh //下拉刷新
                                {
                                    self.messageTotalList.insertContentsOf(messageList, at:0)
                                }
                                else //上拉加载
                                {
                                    self.messageTotalList.appendContentsOf(messageList);                                 
                                }
                            }
                            else
                            {
                                print("get \(folderName)'s mail fail,because \(error)");
                                
                            }
                            
 //                           print("maillistcount=\("self.messageTotalList.count")");
                            
                            delegate.RefreshMailListData(self.messageTotalList,upFresh: upFresh);
                            
                            
                    }
                    
                    
                }
        }
        
    }
    
    //MARK:获取邮件信息
    override func getMail(mailid:MCOIMAPMessage, delegateMail:RefreshMailDelegate)
    {
        
        let imapSession=self.mailconnection as! MCOIMAPSession;
        
         delegateMail.RefreshMailData(imapSession, mailid: mailid, folder: self.mailFolderName);
        
     
     }
    
    private func reAssignMailFolder(mailFolders:[MAILFOLDER])->[MAILFOLDER]
    {
        
        var resultfolders=[MAILFOLDER(),MAILFOLDER(),MAILFOLDER()];

        //1.先处理成合适的中文名
        for mailfolder in mailFolders
        {
            var folderName=mailfolder.folderNameAlias;
            
            var folderUperName=folderName.uppercaseString;
            
            let tmpImapFolder=mailfolder.folderInfo;
            
            if tmpImapFolder.flags.contains(.Inbox)
            {
                folderName="收件箱";
            }
            else
            if folderUperName.containsString("INBOX")// || folderUperName.containsString("收件")
            {
                folderName="收件箱";
            }
            
            
            if tmpImapFolder.flags.contains(.SentMail)
            {
                folderName="已发送";
            }
            else
            if folderUperName.containsString("SENT MESSAGES") &&                (resultfolders[1].folderInfo.path == nil)

            {
                folderName="已发送";
            }
            
            
            if tmpImapFolder.flags.contains(.Drafts)
            {
                folderName="草稿箱";
            }
            else
            if folderUperName.containsString("DRAFT") || folderUperName.containsString("草稿")
            {
                folderName="草稿箱";
            }
            
            
            
            if tmpImapFolder.flags.contains(.Spam)
            {
                folderName="垃圾邮件";
            }
            else
            if folderUperName.containsString("SPAM") || folderUperName.containsString("JUNK")
            {
                folderName="垃圾邮件";
            }
            
            
            if tmpImapFolder.flags.contains(.Trash)
            {
                folderName="废纸篓";
            }
            else            
            if folderUperName.containsString("DELETE")
            {
                folderName="废纸篓";
            }
            
            mailfolder.folderNameAlias=folderName;
            
            //2.把收件箱\已发送和草稿箱提到前三位

            switch folderName {
            case "收件箱":
                resultfolders[0]=mailfolder;
            case "已发送":
                resultfolders[1]=mailfolder;
            case "草稿箱":
                resultfolders[2]=mailfolder;
                self.draftFolder=mailfolder.folderInfo.path;//删除邮件时有用
            default:
                resultfolders.append(mailfolder);
                if folderName == "废纸篓"
                {
                    self.deleteFolder=mailfolder.folderInfo.path;//删除邮件时有用  
                }

            }
            
            print(mailfolder.folderNameAlias+","+mailfolder.folderInfo.path);
          
            
        }
        
        return resultfolders;
        
    }
 
    
}
