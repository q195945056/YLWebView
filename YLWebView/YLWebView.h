//
//  YLWebView.h
//  YLWebView
//
//  Created by yanmingjun on 16/1/28.
//  Copyright © 2016 youloft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YLWebView;

__TVOS_PROHIBITED @protocol YLWebViewDelegate <NSObject>

@optional
- (BOOL)webView:(YLWebView * _Null_unspecified)webView shouldStartLoadWithRequest:(NSURLRequest * _Null_unspecified)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(YLWebView * _Null_unspecified)webView;
- (void)webViewDidFinishLoad:(YLWebView * _Null_unspecified)webView;
- (void)webView:(YLWebView * _Null_unspecified)webView didFailLoadWithError:(nullable NSError *)error;

@end

@interface YLWebView : UIView

///使用UIWebView
- (_Null_unspecified instancetype)initWithFrame:(CGRect)frame usingUIWebView:(BOOL)usingUIWebView;

@property(weak, nonatomic, nullable)id<YLWebViewDelegate> delegate;

///内部使用的webView
@property (nonatomic, readonly, nonnull) __kindof UIView *realWebView;
///是否正在使用 UIWebView
@property (nonatomic, readonly) BOOL usingUIWebView;
///预估网页加载进度
@property (nonatomic, readonly) double estimatedProgress;

///back 层数
- (NSInteger)countOfHistory;
- (void)gobackWithStep:(NSInteger)step;

///---- UI 或者 WK 的API
@property (nonatomic, readonly, nonnull) UIScrollView *scrollView;

- (nullable id)loadRequest:(nonnull NSURLRequest *)request;
- (nullable id)loadHTMLString:(nonnull NSString *)string baseURL:(nullable NSURL *)baseURL;

@property (nonatomic, readonly, copy, nullable) NSString *title;
@property (nonatomic, readonly, nullable) NSURLRequest *request;
@property (nonatomic, readonly, nullable) NSURL *URL;

@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;

- (nullable id)goBack;
- (nullable id)goForward;
- (nullable id)reload;
- (nullable id)reloadFromOrigin;
- (void)stopLoading;

- (void)evaluateJavaScript:(nullable NSString *)javaScriptString completionHandler:(nullable void (^)(_Null_unspecified id,  NSError * _Nullable ))completionHandler;
///不建议使用这个办法  因为会在内部等待webView 的执行结果
- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(nullable NSString *)javaScriptString;

///是否根据视图大小来缩放页面  默认为YES
@property (nonatomic) BOOL scalesPageToFit;

@property (nonatomic) UIDataDetectorTypes dataDetectorTypes NS_AVAILABLE_IOS(3_0);

@property (nonatomic) BOOL allowsInlineMediaPlayback NS_AVAILABLE_IOS(4_0); // iPhone Safari defaults to NO. iPad Safari defaults to YES

@end
