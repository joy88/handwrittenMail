//
//  ImapMail.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/7.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import Foundation



class ImapMail : BaseMail {
    //JS代码串
 //   private var jsCode:String="";
    //初始化
    override init(_ maillogininfo: mailLoginInfo) {
        super.init(maillogininfo);
        
        let imapSession = MCOIMAPSession();
        
        
  /*
        imapSession.connectionLogger = {
            (connectionID:unsafePointer,type:MCOConnectionLogType, data:NSData)->Void in
            print("ID: %p, type: %d, data: %@", connectionID,type,NSString(data: data, encoding: NSUTF8StringEncoding));
        };*/
        
        self.mailconnection=imapSession;
        
        imapSession.hostname = maillogininfo.hostname;
        imapSession.port = maillogininfo.port;
        imapSession.username = maillogininfo.username;
        imapSession.password = maillogininfo.password;
        imapSession.connectionType = maillogininfo.connectionType;
        
        let imapOperation = imapSession.checkAccountOperation();
     
 //       let semaphore = dispatch_semaphore_create(0)

        
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
            
//        dispatch_semaphore_signal(semaphore);
            
        };
        
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        //获取要在webveiw中注入的JScipt代码
        
/*        jsCode = NSBundle.mainBundle().URLForResource("WebviewDelegate", withExtension:"js")!.path!;
        
        do {
            jsCode = try NSString(contentsOfFile: jsCode, encoding: NSUTF8StringEncoding) as String
        }
        catch {/* error handling here */}
        
        print(jsCode);*/
            

    }
    //获取邮件目录
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
                                    print("foldername=\(folderName)");
                                    
                                    mailFolders.updateValue(folderMeta,forKey: folderName);
                                    
                                    self.delegate!.RefreshMailFolderData(mailFolders);
                                    
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
        

        
        return mailFolders;
    }
    //获取邮件列表
    override func getMailList(folder:String,delegate:RefreshMailListDataDelegate)
    {
        
        let requestKind = MCOIMAPMessagesRequestKind(rawValue: MCOIMAPMessagesRequestKind.Headers.rawValue | MCOIMAPMessagesRequestKind.Structure.rawValue |
            MCOIMAPMessagesRequestKind.InternalDate.rawValue | MCOIMAPMessagesRequestKind.HeaderSubject.rawValue |
            MCOIMAPMessagesRequestKind.Flags.rawValue);
        
        
        
        var messageList=[MCOIMAPMessage]();
        
        var messagecount:Int32=0;
        
        let imapSession=self.mailconnection as! MCOIMAPSession;
        
        var folderName=folder;//"INBOX";
        folderName=imapSession.defaultNamespace.pathForComponents([folderName]);
        
        self.mailFolderName=folderName;//保存一下,获取邮件正文信息的时候还要用

        
        
        let imapFetchMailCountOp = imapSession.folderInfoOperation(folderName);
        
        imapFetchMailCountOp.start()
            {
                (error:NSError?,info:MCOIMAPFolderInfo?)->Void in
                
                if error == nil
                {
                    messagecount = (info?.messageCount)!;
                    
                    if messagecount==0
                    {
                        let messageList=[MCOIMAPMessage]();
                        
                        delegate.RefreshMailListData(messageList);

                        return;
                    }
                    
                    // 获取邮件信息
                    
                    var numberOfMessages:Int32 = 50;
                    
                    if messagecount<numberOfMessages
                    {
                        numberOfMessages=messagecount;
                    }
                    
                    numberOfMessages -= 1;
                    
                    let numbers = MCOIndexSet(range: MCORangeMake(UInt64(messagecount-numberOfMessages), UInt64(numberOfMessages)));
                    
                    
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
                            }
                            else
                            {
                                print("get \(folderName)'s mail fail,because \(error)");
                                
                            }
                            delegate.RefreshMailListData(messageList);
                            
                            
                    }
                    
                    
                }
        }
        
    }
    
    //获取邮件信息
    override func getMail(mailid:MCOIMAPMessage, delegateMail:RefreshMailDelegate)
    {
        
        let imapSession=self.mailconnection as! MCOIMAPSession;
        
         delegateMail.RefreshMailData(imapSession, mailid: mailid, folder: self.mailFolderName);
        
     
        
 /*
        let fetchContentOp = imapSession.fetchMessageOperationWithFolder(self.mailFolderName,uid:mailid.uid);
        
        
        fetchContentOp.start
            {
                (error:NSError?, data:NSData?)->Void in
                
                if error==nil
                {
                    // 解析邮件内容
                    let msgPareser = MCOMessageParser(data: data);
                    
                    delegateMail.RefreshMailWithParser(imapSession, msgPareser: msgPareser, folder: self.mailFolderName);
                    
                }
                
        }
        //获取邮件纯文件信息代码
        /*
        let messageRenderingOperation = imapSession.plainTextBodyRenderingOperationWithMessage(mailid,folder: self.mailFolderName);
        
        messageRenderingOperation.start
        {
        (plainTextBodyString:String?,error:NSError?)->Void in
        if error==nil
        {
        
        print(plainTextBodyString!);
        //delegateMail.RefreshMailData();
        delegateMail.RefreshMailData(mailid)//, msgParser:MCOMessageParser());
        }
        
        }
        */
 */
    }
    
}