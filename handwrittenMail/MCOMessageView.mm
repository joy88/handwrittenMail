//
//  MCOMessageView.m
//  testUI
//
//  Created by DINH Viêt Hoà on 1/19/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCOMessageView.h"
//#import "handwrittenMail-swift.h"
#import "swift-oc.h"

@interface MCOMessageView () <MCOHTMLRendererIMAPDelegate>

@end

@implementation MCOMessageView {
    
     UIWebView * _webView;
    NSString * _folder;
    MCOAbstractMessage * _message;
    __weak id <MCOMessageViewDelegate> _delegate;
    BOOL _prefetchIMAPImagesEnabled;
    BOOL _prefetchIMAPAttachmentsEnabled;
}

@synthesize folder = _folder;
@synthesize delegate = _delegate;
@synthesize prefetchIMAPImagesEnabled = _prefetchIMAPImagesEnabled;
@synthesize prefetchIMAPAttachmentsEnabled = _prefetchIMAPAttachmentsEnabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    [self setAutoresizesSubviews:YES];
    if(self) {
        _webView = [[UIWebView alloc] initWithFrame:[self bounds]];
 //       [_webView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        [_webView setDelegate:self];
          _webView.scalesPageToFit=YES;//支持手势缩放
         _webView.multipleTouchEnabled=YES;//支持手势缩放
        _webView.userInteractionEnabled=YES;//支持交互
        //_webView.backgroundColor=[UIColor blueColor];
        //_webView.automaticallyAdjustsScrollViewInsets = NO
        //ADDED BY SHIWW,长按保存图片
        UILongPressGestureRecognizer* longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        longPressed.delegate = self;
        [_webView addGestureRecognizer:longPressed];
        //added end
        
        [self addSubview:_webView];
        
       }
    
    return self;
}

//UIGestureRecognizerDelegate 代理 -added
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    otherGestureRecognizer.cancelsTouchesInView = NO;
    
    if ([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        otherGestureRecognizer.enabled = NO;
        NSLog(@"Long");
    }
    NSLog(@"Simultaneously %@ and %@", gestureRecognizer.class, otherGestureRecognizer.class);
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"Should %@ begin", gestureRecognizer.class);
    return YES;
}
//UIGestureRecognizerDelegate 代理 -added end


-(void) longPressed :(UILongPressGestureRecognizer*) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        return;
    }
    
    CGPoint touchPoint = [sender locationInView:self.webView];
    
//    NSLog(@"Hello from (%f, %f)", touchPoint.x, touchPoint.y);
    
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [self.webView stringByEvaluatingJavaScriptFromString:imgURL];
    //    NSLog(@"urlToSave :%@",urlToSave);
    if (urlToSave.length == 0) {
        return;
    }
    
    NSURL * imageURL = [NSURL URLWithString:urlToSave];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];

    UIImage * image = [UIImage imageWithData:imageData];
    
    [self saveImage:touchPoint image:image];
}



- (void) dealloc
{
    _message = nil;
    _folder = nil;
    _webView = nil;
}

- (void) setMessage:(MCOAbstractMessage *)message
{
    _message = message;
    
    [_webView stopLoading];
    [self _refresh];
}

- (MCOAbstractMessage *) message
{
    return _message;
}

//added by shiww
- (UIWebView *) webView
{
    return _webView;
}
//added end
-  (void) layoutSubviews
{
    _webView.frame =CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height);//added by shiww
 }
//added by shiww
- (void) _refresh
{
 /*   _webView.frame =self.bounds;//added by shiww
    
    if (self.subviews.count==0)
    {
        [self addSubview:_webView];
    }*/
    
//    NSLog(@"%@",_webView.frame);

    NSString * content;
    
    if (_message == nil) {
        content = nil;
    }
    else {
        if ([_message isKindOfClass:[MCOIMAPMessage class]]) {
            content = [(MCOIMAPMessage *) _message htmlRenderingWithFolder:_folder delegate:self];
 
//            NSLog(@"%@", content);
        }
        else if ([_message isKindOfClass:[MCOMessageBuilder class]]) {
            content = [(MCOMessageBuilder *) _message htmlRenderingWithDelegate:self];
        }
        else if ([_message isKindOfClass:[MCOMessageParser class]]) {
//            content = [(MCOMessageParser *) _message htmlRenderingWithDelegate:self];
           
            content=[(MCOMessageParser *) _message  htmlBodyRendering];
        }
        else {
            content = nil;
            MCAssert(0);
        }
    }
	if (content == nil) {
		[_webView loadHTMLString:@"" baseURL:nil];
		return;
	}
    
    
   // NSLog(@"%@", content);

    
    //提取完毕
    
	NSMutableString * html = [NSMutableString string];
	NSURL * jsURL = [[NSBundle mainBundle] URLForResource:@"MCOMessageViewScript" withExtension:@"js"];
    /*
	[html appendFormat:@"<html><head><script src=\"%@\"></script></head><body'>%@</body><iframe src='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border: none;'></iframe></html>",
	 [jsURL absoluteString], content];*/
    
    [html appendFormat:@"<html><head><style>img{max-width:1000px !important;height: auto}</style><script src=\"%@\"></script></head><body'>%@</body><iframe src='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border: none;'></iframe></html>",
     [jsURL absoluteString], content];

    
    
	[_webView loadHTMLString:html baseURL:nil];
}

//设置HTML内容,自动注入加载图像的JS代码,added by shiww
- (void) setHtmlContent:(NSString *)content
{
    NSMutableString * html = [NSMutableString string];
    NSURL * jsURL = [[NSBundle mainBundle] URLForResource:@"MCOMessageViewScript" withExtension:@"js"];
    [html appendFormat:@"<html><head><script src=\"%@\"></script></head><body'>%@</body><iframe src='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border: none;'></iframe></html>",
     [jsURL absoluteString], content];
    [_webView loadHTMLString:html baseURL:nil];
}


- (BOOL) _isCID:(NSURL *)url
{
	NSString *theScheme = [url scheme];
	if ([theScheme caseInsensitiveCompare:@"cid"] == NSOrderedSame)
        return YES;
    return NO;
}

- (BOOL) _isXMailcoreImage:(NSURL *)url
{
	NSString *theScheme = [url scheme];
	if ([theScheme caseInsensitiveCompare:@"x-mailcore-image"] == NSOrderedSame)
        return YES;
    return NO;
}

- (void) _loadImages
{
	NSString * result = [_webView stringByEvaluatingJavaScriptFromString:@"findCIDImageURL()"];
	NSData * data = [result dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error = nil;
	NSArray * imagesURLStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	
	for(NSString * urlString in imagesURLStrings) {
		MCOAbstractPart * part = nil;
		NSURL * url;
		
		url = [NSURL URLWithString:urlString];
		if ([self _isCID:url]) {
            NSLog(@"url is cidurl:%@", url);
			part = [self _partForCIDURL:url];
		}
		else if ([self _isXMailcoreImage:url]) {
            NSLog(@"url is x-mailcore-img:%@", url);
			NSString * specifier = [url resourceSpecifier];
			NSString * partUniqueID = specifier;
			part = [self _partForUniqueID:partUniqueID];
		}
		
		if (part == nil)
			continue;
		
		NSString * partUniqueID = [part uniqueID];
		NSData * data = [[self delegate] MCOMessageView:self dataForPartWithUniqueID:partUniqueID];
		
		void (^replaceImages)(NSError *error) = ^(NSError *error) {
			NSData * downloadedData = [[self delegate] MCOMessageView:self dataForPartWithUniqueID:partUniqueID];
			NSData * previewData = [[self delegate] MCOMessageView:self previewForData:downloadedData isHTMLInlineImage:[self _isCID:url]];
			NSString * filename = [NSString stringWithFormat:@"%lu", (unsigned long)urlString.hash];
			NSURL * cacheURL = [self _cacheJPEGImageData:previewData withFilename:filename];
			
			NSDictionary * args = @{ @"URLKey": urlString, @"LocalPathKey": cacheURL.absoluteString };
			NSString * jsonString = [self _jsonEscapedStringFromDictionary:args];
			
			NSString * replaceScript = [NSString stringWithFormat:@"replaceImageSrc(%@)", jsonString];
			[_webView stringByEvaluatingJavaScriptFromString:replaceScript];
		};
		
		if (data == nil) {
			[[self delegate] MCOMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
				replaceImages(error);
			}];
		} else {
			replaceImages(nil);
		}
	}
}

- (NSString *) _jsonEscapedStringFromDictionary:(NSDictionary *)dictionary
{
	NSData * json = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
	NSString * jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
	return jsonString;
}

- (NSURL *) _cacheJPEGImageData:(NSData *)imageData withFilename:(NSString *)filename
{
	NSString * path = [[NSTemporaryDirectory() stringByAppendingPathComponent:filename] stringByAppendingPathExtension:@"jpg"];
	[imageData writeToFile:path atomically:YES];
	return [NSURL fileURLWithPath:path];
}

- (MCOAbstractPart *) _partForCIDURL:(NSURL *)url
{
    return [_message partForContentID:[url resourceSpecifier]];
}

- (MCOAbstractPart *) _partForUniqueID:(NSString *)partUniqueID
{
    return [_message partForUniqueID:partUniqueID];
}

- (NSData *) _dataForIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    NSData * data;
    NSString * partUniqueID = [part uniqueID];
    data = [[self delegate] MCOMessageView:self dataForPartWithUniqueID:partUniqueID];
    if (data == NULL) {
        [[self delegate] MCOMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
            [self _refresh];
        }];
    }
    return data;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([[[request URL] scheme] isEqual:@"mailto"]) {
        //added by shiww,调用自身发邮件的程序，而不是调用系统的
        NSString *mailAddress=[[request URL] absoluteString];
        //NSString *mailAddress=@"chinagis001@126.com";
        [self newMail:mailAddress];
        return NO;
    }
    
    NSURLRequest *responseRequest = [self webView:webView resource:nil willSendRequest:request redirectResponse:nil fromDataSource:nil];
    
    if(responseRequest == request) {
        return YES;
    } else {
        [webView loadRequest:responseRequest];
        return NO;
    }
}

- (NSURLRequest *)webView:(UIWebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(id)dataSource
{
    if ([[[request URL] scheme] isEqualToString:@"x-mailcore-msgviewloaded"]) {
        [self _loadImages];
    }
	
	return request;
}

- (BOOL) MCOAbstractMessage:(MCOAbstractMessage *)msg canPreviewPart:(MCOAbstractPart *)part
{
    static NSMutableSet * supportedImageMimeTypes = NULL;
    if (supportedImageMimeTypes == NULL) {
        supportedImageMimeTypes = [[NSMutableSet alloc] init];
        [supportedImageMimeTypes addObject:@"image/png"];
        [supportedImageMimeTypes addObject:@"image/gif"];
        [supportedImageMimeTypes addObject:@"image/jpg"];
        [supportedImageMimeTypes addObject:@"image/jpeg"];
    }
    static NSMutableSet * supportedImageExtension = NULL;
    if (supportedImageExtension == NULL) {
        supportedImageExtension = [[NSMutableSet alloc] init];
        [supportedImageExtension addObject:@"png"];
        [supportedImageExtension addObject:@"gif"];
        [supportedImageExtension addObject:@"jpg"];
        [supportedImageExtension addObject:@"jpeg"];
    }
    
    if ([supportedImageMimeTypes containsObject:[[part mimeType] lowercaseString]]) {
        return YES;
    }
    
    NSString * ext = nil;
    if ([part filename] != nil) {
        if ([[part filename] pathExtension] != nil) {
            ext = [[[part filename] pathExtension] lowercaseString];
        }
    }
    if (ext != nil) {
        if ([supportedImageExtension containsObject:ext])
            return YES;
    }
    
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView:canPreviewPart:)]) {
        return false;
    }
    return [[self delegate] MCOMessageView:self canPreviewPart:part];
}

- (BOOL) MCOAbstractMessage:(MCOAbstractMessage *)msg shouldShowPart:(MCOAbstractPart *)part
{
    return YES;//by shiww
}


- (NSDictionary *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateValuesForHeader:(MCOMessageHeader *)header
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView:templateValuesForHeader:)]) {
        return nil;
    }
    return [[self delegate] MCOMessageView:self templateValuesForHeader:header];
}

- (NSDictionary *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateValuesForPart:(MCOAbstractPart *)part
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView:templateValuesForPartWithUniqueID:)]) {
        return nil;
    }
    return [[self delegate] MCOMessageView:self templateValuesForPartWithUniqueID:[part uniqueID]];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForMainHeader:(MCOMessageHeader *)header
{
    return @" ";//added by shiww
/*    if (![[self delegate] respondsToSelector:@selector(MCOMessageView_templateForMainHeader:)]) {
        return nil;
    }
    return [[self delegate] MCOMessageView_templateForMainHeader:self];*/
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForImage:(MCOAbstractPart *)header
{
    NSString * templateString;
    if ([[self delegate] respondsToSelector:@selector(MCOMessageView_templateForImage:)]) {
        templateString = [[self delegate] MCOMessageView_templateForImage:self];
    }
    else {
        templateString = @"<img src=\"{{URL}}\"/>";
    }
    templateString = [NSString stringWithFormat:@"<div id=\"{{CONTENTID}}\">%@</div>", templateString];
    return templateString;
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForAttachment:(MCOAbstractPart *)part
{
    return @" ";//added by shiww

/*    if (![[self delegate] respondsToSelector:@selector(MCOMessageView_templateForAttachment:)]) {
        return NULL;
    }
    NSString * templateString = [[self delegate] MCOMessageView_templateForAttachment:self];
    templateString = [NSString stringWithFormat:@"<div id=\"{{CONTENTID}}\">%@</div>", templateString];
    return templateString;*/
}

- (NSString *) MCOAbstractMessage_templateForMessage:(MCOAbstractMessage *)msg
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView_templateForMessage:)]) {
        return NULL;
    }
    return [[self delegate] MCOMessageView_templateForMessage:self];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForEmbeddedMessage:(MCOAbstractMessagePart *)part
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView_templateForEmbeddedMessage:)]) {
        return NULL;
    }
    return [[self delegate] MCOMessageView_templateForEmbeddedMessage:self];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForEmbeddedMessageHeader:(MCOMessageHeader *)header
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView_templateForEmbeddedMessageHeader:)]) {
        return NULL;
    }
    return [[self delegate] MCOMessageView_templateForEmbeddedMessageHeader:self];
}

- (NSString *) MCOAbstractMessage_templateForAttachmentSeparator:(MCOAbstractMessage *)msg
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView_templateForAttachmentSeparator:)]) {
        return NULL;
    }
    return [[self delegate] MCOMessageView_templateForAttachmentSeparator:self];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg filterHTMLForPart:(NSString *)html
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView:filteredHTMLForPart:)]) {
        return html;
    }
    return [[self delegate] MCOMessageView:self filteredHTMLForPart:html];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg filterHTMLForMessage:(NSString *)html
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView:filteredHTMLForMessage:)]) {
        return html;
    }
    return [[self delegate] MCOMessageView:self filteredHTMLForMessage:html];
}

- (NSData *) MCOAbstractMessage:(MCOAbstractMessage *)msg dataForIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    if (part != NULL)
    {
        NSLog(@"***************************************************\n"
              @"file:%s,"
              @"line:%d\n"
              @"partID:%@\n"
              @"filename:%@\n"
              @"mimeType:%@\n"
              @"uniqueID:%@\n"
              @"contentID:%@\n"
              @"contentLocation:%@\n"
              @"contentDescription:%@\n"
              @"charset:%@\n"
              @"encoding:%d\n"
              @"***************************************************", __FILE__, __LINE__, part.partID, part.filename, part.mimeType, part.uniqueID, part.contentID, part.contentLocation, part.contentDescription, part.charset, part.encoding);
    }

    NSData *data    = [self _dataForIMAPPart:part folder:folder];
    return data;
}

- (void) MCOAbstractMessage:(MCOAbstractMessage *)msg prefetchAttachmentIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    if (part != NULL)
    {
        NSLog(@"%@", part.partID);
        NSLog(@"%@", part.filename);
        NSLog(@"%@", part.mimeType);
        NSLog(@"%@", part.uniqueID);
        NSLog(@"%@", part.contentID);
        NSLog(@"%@", part.contentLocation);
        NSLog(@"%@", part.contentDescription);
        NSLog(@"%@", part.charset);
        NSLog(@"%d", part.encoding);
    }

    if (!_prefetchIMAPAttachmentsEnabled)
        return;
    
    NSString * partUniqueID = [part uniqueID];
    [[self delegate] MCOMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
        // do nothing
    }];
}

- (void) MCOAbstractMessage:(MCOAbstractMessage *)msg prefetchImageIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{

    if (part != NULL)
    {
        NSLog(@"%@", part.partID);
        NSLog(@"%@", part.filename);
        NSLog(@"%@", part.mimeType);
        NSLog(@"%@", part.uniqueID);
        NSLog(@"%@", part.contentID);
        NSLog(@"%@", part.contentLocation);
        NSLog(@"%@", part.contentDescription);
        NSLog(@"%@", part.charset);
        NSLog(@"%d", part.encoding);
    }

    if (!_prefetchIMAPImagesEnabled)
        return;
    
    NSString * partUniqueID = [part uniqueID];
    [[self delegate] MCOMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
        // do nothing
    }];

  }




@end
