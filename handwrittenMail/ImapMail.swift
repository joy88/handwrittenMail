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
    override func getMailFolder()->MAILFOLDERS
    {
        var mailFolders:MAILFOLDERS=["INBOX":mailFolderMeta(),"已发送":mailFolderMeta(),"草稿箱":mailFolderMeta()];
        
        if !self.isCanBeConnected
        {
//            return mailFolders;
        }
        
        let imapSession=self.mailconnection as! MCOIMAPSession;
        
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

                    
                    for folder in folders!
                    {
                        let tmpImapFolder=folder as! MCOIMAPFolder;
                        //文件夹名称
                        //不能直接用tmpImapFolder.path!转换一下,否则folder不支持中文
                        let tmpstr=ns.componentsFromPath(tmpImapFolder.path);
                       
                        
                        assert(tmpstr != nil)
                        
 

                        
                        let folderName=tmpstr[0] as! String
                        
                        
                        //获取邮箱目录中邮件数量信息
                        var mailCount:Int32=0;
                        

                        let imapFetchMailCountOp = imapSession.folderInfoOperation(tmpImapFolder.path);
                        
                        imapFetchMailCountOp.start()
                            {
                                (error:NSError?,info:MCOIMAPFolderInfo?)->Void in
                                
                                if error == nil
                                {
                                    
                                    mailCount=(info?.messageCount)!;
                                    
                                    var folderMeta=mailFolderMeta();

                                    
                                    folderMeta.folderName=folderName;
                                    
                                    folderMeta.folderFlag = tmpImapFolder.flags
                                    
                                    folderMeta.mailCount=mailCount;

                                    //mail 数量
                                   // print("foldername=\(folderName)");
                                    
                                    mailFolders.updateValue(folderMeta,forKey: folderName);
                                    
                                    self.delegate!.RefreshMailFolderData(mailFolders);
                                    
                                }
                                else
                                {
                                   print("get mail count of \(folderName) fail,\(error!)")
                                }
                            }
                        


                    }
                    
                  //  print("Mail Folder's count=\(mailFolders.count)");

                    
                    
                }
                else
                {
                    print("get mail folders failure: %@\n", error);
 
                }
                
            }
        

        
        return mailFolders;
    }
    //MARK:获取邮件列表
    override func getMailList(folder:String,delegate:RefreshMailListDataDelegate,upFresh:Bool)
    {
        var folderName=folder;//"INBOX";

        
        let imapSession=self.mailconnection as! MCOIMAPSession;
        
        
        folderName=imapSession.defaultNamespace.pathForComponents([folderName]);
        
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
                        
                        delegate.RefreshMailListData(self.messageTotalList);

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
                        
         //               print("numberOfMsgLoad=\(numberOfMsgLoad),messagecount=\(messagecount)");
                    
//                        if (messagecount<numberOfMsgLoad)
//                        {
//                            numberOfMsgLoad=messagecount;
//                        }
                        
                        
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

                    
                    
                    let numbers = MCOIndexSet(range: MCORangeMake(UInt64(msgLoadStart+1), UInt64(numberOfMsgLoad)));
                    
                    
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
                            
                            delegate.RefreshMailListData(self.messageTotalList);
                            
                            
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
 
    
}
