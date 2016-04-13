//
//  ACAddressBookDataSource.m
//  AutoCompleteCell
//
//  Created by Felipe Saint Jean on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACAddressBookDataSource.h"
#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>

@implementation ACAddressBookElement
@synthesize first_name;
@synthesize last_name;
@synthesize email;


-(NSString *)getDisplayText{
    
    //added by shiww,这里返回的是:人名<email>,by shiww
    if (self.first_name && self.last_name && self.email)
    {
//        NSLog([NSString stringWithFormat:@"%@ %@ <%@>",self.first_name,self.last_name,self.email]);

        return [NSString stringWithFormat:@"%@%@ <%@>",self.last_name,self.first_name,self.email];
    }
    else if (self.first_name)
        return [NSString stringWithFormat:@"%@ <%@>",self.first_name,self.email];
    else 
        return self.email; 
    
}
    
@end


@implementation ACAddressBookDataSource

- (void)filterContentForSearchText:(NSString*)searchText withCallback:(void (^)(NSArray *suggestions))update
{
    //added by shiww,new code in ios9.0
    
    
    [filtered removeAllObjects];
    
    CNContactStore *stroe = [[CNContactStore alloc]init];
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {//首次访问通讯录会调用
        [stroe requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if (error) return;
             if (!granted)
             {
                 //拒绝
                 NSLog(@"拒绝访问通讯录");//访问通讯录
                 return;
             }
         }];
    };
    
    
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] != CNAuthorizationStatusAuthorized)
    {
        //无权限访问
        return;
    }
    
    
    NSPredicate *predicate = nil;
    //提取电话，email、日期、URL 数据
    NSArray *mycontacts = [stroe unifiedContactsMatchingPredicate:predicate keysToFetch:
                         @[CNContactGivenNameKey,CNContactFamilyNameKey,
                           CNContactPhoneNumbersKey,
                           CNContactEmailAddressesKey]
                                                          error:nil];
    
    if (mycontacts == NULL) {
        NSLog(@"%s, AddressBook is null. Return!", __FUNCTION__);
        return;
    }
    for (int i = 0; i < mycontacts.count; i++) {
      
        CNContact *person = mycontacts[i];
        //获取姓名
        NSString * firstName=person.givenName;
        NSString * lastName=person.familyName;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF contains[cd] %@)", searchText];
        
        
        
        BOOL resultFN = [predicate evaluateWithObject:firstName];
        BOOL resultLN = [predicate evaluateWithObject:lastName];
        
        
        //获取电话
        /*
         for (int j = 0; j < person.phoneNumbers.count; j ++) {
         CNLabeledValue *phone = [person.phoneNumbers objectAtIndex:j];
         //根据本地语言进行显示对于的label
         NSString *label =  [CNLabeledValue localizedStringForLabel:phone.label];
         label = [label stringByAppendingString:@": "];
         CNPhoneNumber *num  = phone.value;
         NSString *phone2 = [label stringByAppendingString:[num valueForKey:@"digits"]];
         [info addPhone:phone2];
         }*/
        
        
        //获取email
        for (int k = 0; k < person.emailAddresses.count; k ++)
        {
            CNLabeledValue *email = [person.emailAddresses objectAtIndex:k];
            NSString *value = email.value;
            
            ACAddressBookElement *el = [[ACAddressBookElement alloc] init];
            
            el.first_name = firstName;
            el.last_name = lastName ;
            el.email =value;
            
            BOOL resultEmail = [predicate evaluateWithObject:el.email];
            
            if(resultFN || resultLN || resultEmail)
            {
                [filtered addObject:el];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (update) update(filtered);
                });

            }
            
        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (update) update(filtered);
//        });
        
        
    }
    
}


-(id)init{
    self = [super init];
    if (self){
        filtered = [[NSMutableArray alloc] init];
        
       // [contacts sortUsingFunction:(int(*)(id, id, void*))ABPersonComparePeopleByName context:(void*)ABPersonGetSortOrdering()];
        //CFRelease(addressBook);
    }
    return self;
}

-(void)cancel{

}
-(void)getSuggestionsFor:(NSString *)searchString withCallback:(void (^)(NSArray *suggestions))update{
    [self filterContentForSearchText:searchString withCallback:update];
    
}

@end
