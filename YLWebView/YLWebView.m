//
//  YLWebView.m
//  YLWebView
//
//  Created by yanmingjun on 16/1/28.
//  Copyright © 2016年 youloft. All rights reserved.
//

#import "YLWebView.h"
#import <WebKit/WebKit.h>

@interface YLWebView () <WKNavigationDelegate, WKUIDelegate, UIWebViewDelegate>

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, copy) NSString *title;

@end

@implementation YLWebView
@synthesize scalesPageToFit = _scalesPageToFit;


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame usingUIWebView:NO];
}
- (instancetype)initWithFrame:(CGRect)frame usingUIWebView:(BOOL)usingUIWebView
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _usingUIWebView = usingUIWebView;
        [self commonInit];
    }
    return self;
}
-(void)commonInit
{
    Class wkWebView = NSClassFromString(@"WKWebView");
    if(wkWebView && self.usingUIWebView == NO)
    {
        [self initWKWebView];
        _usingUIWebView = NO;
    }
    else
    {
        [self initUIWebView];
        _usingUIWebView = YES;
    }
    self.scalesPageToFit = YES;
    
    [self.realWebView setFrame:self.bounds];
    [self.realWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.realWebView];
}
-(void)initWKWebView
{
    static WKWebViewConfiguration *configuration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
    });
    
    WKWebView* webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.bounds configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    _realWebView = webView;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"title"])
    {
        self.title = change[NSKeyValueChangeNewKey];
    }
}
-(void)initUIWebView
{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    webView.delegate = self;
    _realWebView = webView;
}

#pragma mark- UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    [self callback_webViewDidFinishLoad];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self callback_webViewDidStartLoad];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self callback_webViewDidFailLoadWithError:error];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL resultBOOL = [self callback_webViewShouldStartLoadWithRequest:request navigationType:navigationType];
    return resultBOOL;
}

#pragma mark- WKNavigationDelegate
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL resultBOOL = [self callback_webViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    if(resultBOOL)
    {
        self.request = navigationAction.request;
        if(navigationAction.targetFrame == nil)
        {
            [webView loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self callback_webViewDidStartLoad];
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self callback_webViewDidFinishLoad];
    
    
    
    
}

//- (void)printCookie;
//{
////    if (self.usingUIWebView) {
////        NSString *cookie = [(UIWebView *)self.realWebView stringByEvaluatingJavaScriptFromString:@"document.cookie"];
////        NSLog(@"%@", cookie);
//
//        NSHTTPCookieStorage *myCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//        for (NSHTTPCookie *cookie in [myCookie cookies]) {
//            NSLog(@"%@", cookie);
//        }
//
//
////        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.request.URL]; // 这里的HOST是你web服务器的域名地址
////        // 设置header，通过遍历cookies来一个一个的设置header
////        for (NSHTTPCookie *cookie in cookies){
////            NSLog(@"%@", cookie);
////            // cookiesWithResponseHeaderFields方法，需要为URL设置一个cookie为NSDictionary类型的header，注意NSDictionary里面的forKey需要是@"Set-Cookie"
//////            NSArray *headeringCookie = [NSHTTPCookie cookiesWithResponseHeaderFields:
//////                                        [NSDictionary dictionaryWithObject:
//////                                         [[NSString alloc] initWithFormat:@"%@=%@",[cookie name],[cookie value]]
//////                                                                    forKey:@"Set-Cookie"]
//////                                                                              forURL:[NSURL URLWithString:HOST]];
//////
//////            // 通过setCookies方法，完成设置，这样只要一访问URL为HOST的网页时，会自动附带上设置好的header
//////            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:headeringCookie
//////                                                               forURL:[NSURL URLWithString:HOST]
//////                                                      mainDocumentURL:nil];
////        }
//
////    } else {
////        [(WKWebView *)self.realWebView evaluateJavaScript:@"sessionStorage.cookie" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
////            NSLog(@"%@", object);
////        }];
////    }
////    WKWebsiteDataStore *defaultDataStore = [NSClassFromString(@"WKWebsiteDataStore") defaultDataStore];
////    NSSet *types = [NSSet setWithObjects:WKWebsiteDataTypeSessionStorage, nil];
////    [defaultDataStore fetchDataRecordsOfTypes:types completionHandler:^(NSArray<WKWebsiteDataRecord *> * _Nonnull results) {
////        NSLog(@"%@", results);
////    }];
//}


- (void)webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self callback_webViewDidFailLoadWithError:error];
}
- (void)webView: (WKWebView *)webView didFailNavigation:(WKNavigation *) navigation withError: (NSError *) error
{
    [self callback_webViewDidFailLoadWithError:error];
}

//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
//    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
//    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
//
//    for (NSHTTPCookie *cookie in cookies) {
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//    }
//
//    decisionHandler(WKNavigationResponsePolicyAllow);
//}
#pragma mark- WKUIDelegate
/////--  支持alert和confirm
//- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;
//{
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.title message:message preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[Utilities localString:@"好"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler();
//    }];
//    [alertController addAction:cancelAction];
//    [APPDELEGATE.mainTabVC presentViewController:alertController animated:YES completion:nil];
//}
//
//- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.title message:message preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[Utilities localString:@"取消"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler(NO);
//    }];
//    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:[Utilities localString:@"好"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler(YES);
//    }];
//    [alertController addAction:cancelAction];
//    [alertController addAction:confirmAction];
//    [APPDELEGATE.mainTabVC presentViewController:alertController animated:YES completion:nil];
//}
//
//- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler;
//{
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.title message:prompt preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = defaultText;
//    }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[Utilities localString:@"取消"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler(nil);
//    }];
//    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:[Utilities localString:@"好"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        UITextField *textField = alertController.textFields.firstObject;
//        completionHandler(textField.text);
//    }];
//    [alertController addAction:cancelAction];
//    [alertController addAction:confirmAction];
//    [APPDELEGATE.mainTabVC presentViewController:alertController animated:YES completion:nil];
//}

#pragma mark- CALLBACK IMYVKWebView Delegate

- (void)callback_webViewDidFinishLoad
{
    if([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [self.delegate webViewDidFinishLoad:self];
    }
}
- (void)callback_webViewDidStartLoad
{
    if([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [self.delegate webViewDidStartLoad:self];
    }
}
- (void)callback_webViewDidFailLoadWithError:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}
-(BOOL)callback_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType
{
    BOOL resultBOOL = YES;
    if([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        if(navigationType == -1) {
            navigationType = UIWebViewNavigationTypeOther;
        }
        resultBOOL = [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return resultBOOL;
}

#pragma mark- 基础方法

- (void)setDataDetectorTypes:(UIDataDetectorTypes)dataDetectorTypes {
    if (_dataDetectorTypes != dataDetectorTypes) {
        _dataDetectorTypes = dataDetectorTypes;
        if (_usingUIWebView) {
            [(UIWebView*)self.realWebView setDataDetectorTypes:dataDetectorTypes];
        } else {
            //            [(WKWebView*)self.realWebView setDataDetectorTypes:dataDetectorTypes];
        }
    }
}

- (void)setAllowsInlineMediaPlayback:(BOOL)allowsInlineMediaPlayback {
    if (_allowsInlineMediaPlayback == allowsInlineMediaPlayback) {
        _allowsInlineMediaPlayback = allowsInlineMediaPlayback;
        if (_usingUIWebView) {
            [(UIWebView*)self.realWebView setAllowsInlineMediaPlayback:allowsInlineMediaPlayback];
        } else {
            //            [(WKWebView*)self.realWebView setAllowsInlineMediaPlayback:allowsInlineMediaPlayback];
        }
    }
}


-(UIScrollView *)scrollView
{
    return [(id)self.realWebView scrollView];
}

- (id)loadRequest:(NSURLRequest *)request
{
    self.request = request;
    
    if(_usingUIWebView)
    {
        [(UIWebView*)self.realWebView loadRequest:request];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView loadRequest:request];
    }
}
- (id)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if(_usingUIWebView)
    {
        [(UIWebView*)self.realWebView loadHTMLString:string baseURL:baseURL];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView loadHTMLString:string baseURL:baseURL];
    }
}
-(NSURLRequest *)request
{
    if(_usingUIWebView)
    {
        return [self.realWebView request];;
    }
    else
    {
        return _request;
    }
}
-(NSURL *)URL
{
    if(_usingUIWebView)
    {
        return [(UIWebView*)self.realWebView request].URL;;
    }
    else
    {
        return [(WKWebView*)self.realWebView URL];
    }
}
-(BOOL)isLoading
{
    return [self.realWebView isLoading];
}
-(BOOL)canGoBack
{
    return [self.realWebView canGoBack];
}
-(BOOL)canGoForward
{
    return [self.realWebView canGoForward];
}

- (id)goBack
{
    if(_usingUIWebView)
    {
        [(UIWebView*)self.realWebView goBack];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView goBack];
    }
}
- (id)goForward
{
    if(_usingUIWebView)
    {
        [(UIWebView*)self.realWebView goForward];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView goForward];
    }
}
- (id)reload
{
    if(_usingUIWebView)
    {
        [(UIWebView*)self.realWebView reload];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView reload];
    }
}
- (id)reloadFromOrigin
{
    if(_usingUIWebView)
    {
        [(UIWebView *)self.realWebView reload];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.realWebView reloadFromOrigin];
    }
}
- (void)stopLoading
{
    [self.realWebView stopLoading];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    if(_usingUIWebView)
    {
        NSString* result = [(UIWebView*)self.realWebView stringByEvaluatingJavaScriptFromString:javaScriptString];
        if(completionHandler)
        {
            completionHandler(result,nil);
        }
    }
    else
    {
        return [(WKWebView*)self.realWebView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
}
-(NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString
{
    if(_usingUIWebView)
    {
        NSString* result = [(UIWebView*)self.realWebView stringByEvaluatingJavaScriptFromString:javaScriptString];
        return result;
    }
    else
    {
        __block NSString* result = nil;
        __block BOOL isExecuted = NO;
        [(WKWebView*)self.realWebView evaluateJavaScript:javaScriptString completionHandler:^(id obj, NSError *error) {
            NSLog(@"%@", javaScriptString);
            NSString *tempS = obj;
            if (tempS && ![tempS isKindOfClass:[NSString class]]) {
                tempS = [NSString stringWithFormat:@"%@", tempS];
            }
            result = tempS;
            isExecuted = YES;
        }];
        
        while (isExecuted == NO) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        return result;
    }
}
-(void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    if(_usingUIWebView)
    {
        UIWebView* webView = _realWebView;
        webView.scalesPageToFit = scalesPageToFit;
    }
    else
    {
        if(_scalesPageToFit == scalesPageToFit)
        {
            return;
        }
        
        WKWebView* webView = _realWebView;
        
        NSString *jScript = @"var meta = document.createElement('meta'); \
        meta.name = 'viewport'; \
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
        var head = document.getElementsByTagName('head')[0];\
        head.appendChild(meta);";
        
        if(scalesPageToFit)
        {
            WKUserScript *wkUScript = [[NSClassFromString(@"WKUserScript") alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
            [webView.configuration.userContentController addUserScript:wkUScript];
        }
        else
        {
            NSMutableArray* array = [NSMutableArray arrayWithArray:webView.configuration.userContentController.userScripts];
            for (WKUserScript *wkUScript in array)
            {
                if([wkUScript.source isEqual:jScript])
                {
                    [array removeObject:wkUScript];
                    break;
                }
            }
            for (WKUserScript *wkUScript in array)
            {
                [webView.configuration.userContentController addUserScript:wkUScript];
            }
        }
    }
    
    _scalesPageToFit = scalesPageToFit;
}
-(BOOL)scalesPageToFit
{
    if(_usingUIWebView)
    {
        return [_realWebView scalesPageToFit];
    }
    else
    {
        return _scalesPageToFit;
    }
}

-(NSInteger)countOfHistory
{
    if(_usingUIWebView)
    {
        UIWebView* webView = self.realWebView;
        
        int count = [[webView stringByEvaluatingJavaScriptFromString:@"window.history.length"] intValue];
        if (count)
        {
            return count;
        }
        else
        {
            return 1;
        }
    }
    else
    {
        WKWebView* webView = self.realWebView;
        return webView.backForwardList.backList.count;
    }
}
-(void)gobackWithStep:(NSInteger)step
{
    if(self.canGoBack == NO)
        return;
    
    if(step > 0)
    {
        NSInteger historyCount = self.countOfHistory;
        if(step >= historyCount)
        {
            step = historyCount - 1;
        }
        
        if(_usingUIWebView)
        {
            UIWebView* webView = self.realWebView;
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.history.go(-%ld)", (long) step]];
        }
        else
        {
            WKWebView* webView = self.realWebView;
            WKBackForwardListItem* backItem = webView.backForwardList.backList[step];
            [webView goToBackForwardListItem:backItem];
        }
    }
    else
    {
        [self goBack];
    }
}
#pragma mark-  如果没有找到方法 去realWebView 中调用
-(BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL hasResponds = [super respondsToSelector:aSelector];
    if(hasResponds == NO)
    {
        hasResponds = [self.delegate respondsToSelector:aSelector];
    }
    if(hasResponds == NO)
    {
        hasResponds = [self.realWebView respondsToSelector:aSelector];
    }
    return hasResponds;
}
//- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
//{
//    NSMethodSignature* methodSign = [super methodSignatureForSelector:selector];
//    if(methodSign == nil)
//    {
//        if([self.realWebView respondsToSelector:selector])
//        {
//            methodSign = [self.realWebView methodSignatureForSelector:selector];
//        }
//        else
//        {
//            methodSign = [(id)self.delegate methodSignatureForSelector:selector];
//        }
//    }
//    return methodSign;
//}
//- (void)forwardInvocation:(NSInvocation*)invocation
//{
//    if([self.realWebView respondsToSelector:invocation.selector])
//    {
//        [invocation invokeWithTarget:self.realWebView];
//    }
//    else
//    {
//        [invocation invokeWithTarget:self.delegate];
//    }
//}

#pragma mark- 清理
-(void)dealloc
{
    if(_usingUIWebView)
    {
        UIWebView* webView = _realWebView;
        webView.delegate = nil;
    }
    else
    {
        WKWebView* webView = _realWebView;
        webView.UIDelegate = nil;
        webView.navigationDelegate = nil;
        
        [webView removeObserver:self forKeyPath:@"title"];
    }
    [_realWebView scrollView].delegate = nil;
    [_realWebView stopLoading];
    [(UIWebView*)_realWebView loadHTMLString:@"" baseURL:nil];
    [_realWebView stopLoading];
    [_realWebView removeFromSuperview];
    _realWebView = nil;
}

@end
