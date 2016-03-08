//
//  ImapMail.swift
//  handwrittenMail
//
//  Created by shiweiwei on 16/3/7.
//  Copyright © 2016年 shiweiwei. All rights reserved.
//

import Foundation

class ImapMail : BaseMail {
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

    }
    //获取邮件目录
    override func getMailFolder()->[mailFolder]
    {
        var mailFolders=[mailFolder(),mailFolder(),mailFolder(),mailFolder()];
        
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
                        
                        var tmpmailFolder=mailFolder();//必须在循环体内定义,否则出现相同值

                        
                        tmpmailFolder.folderName=tmpstr[0] as! String
                        
                        //获取邮箱目录中邮件数量信息
                        tmpmailFolder.mailCount=0;

//                        let imapFetchMailCountOp = imapSession.folderInfoOperation("INBOX");
//                        
//                        imapFetchMailCountOp.start()
//                            {
//                                (error:NSError?,info:MCOIMAPFolderInfo?)->Void in
//                                
//                                if error == nil
//                                {
//                                    tmpmailFolder.mailCount=(info?.messageCount)!;
//                                }
//                                else
//                                {
//                                   print("get mail count of \(tmpmailFolder.folderName) fail,\(error!)")
//                                }
//                            }

                        //mail 数量
                        print("foldername=\(tmpmailFolder.folderName)");

                        
                        mailFolders.append(tmpmailFolder);
                    }
                    
                    print("Mail Folder's count=\(mailFolders.count)");

                    
                    self.delegate!.RefreshData(mailFolders);
                    
                }
                else
                {
                    print("get mail folders failure: %@\n", error);
 
                }
                
            }
        

/*        let requestKind = MCOIMAPMessagesRequestKind.Headers |  MCOIMAPMessagesRequestKind.Structure |
            MCOIMAPMessagesRequestKind.InternalDate | MCOIMAPMessagesRequestKind.HeaderSubject |
            MCOIMAPMessagesRequestKind.Flags;*/

        imapSession.allowsFolderConcurrentAccessEnabled=true;
        
        let imapFetchMailCountOp = imapSession.folderInfoOperation("INBOX");
        
        imapFetchMailCountOp.start()
            {
                (error:NSError?,info:MCOIMAPFolderInfo?)->Void in
                if error == nil
                {
                    print("inbox mail count=\((info?.messageCount)!)");
                }
                else
                {
                    print("get mail count of inbox fail,\(error!)")
                }
        }

        
        return mailFolders;
    }
    //获取邮件列表
    override func getMailList(folder:String)->[String]
    {
        var strList=["Letter1","Letter2","Letter3","Letter4","Letter5"]

        return strList;
    }
    
    //获取邮件信息
    override func getMail(mailid:String)->String
    {
        return "http://news.163.com";
    }
    
}
