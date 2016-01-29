//
//  ViewController.m
//  YLWebView
//
//  Created by yanmingjun on 16/1/28.
//  Copyright © 2016年 youloft. All rights reserved.
//

#import "ViewController.h"
#import "YLWebView.h"

@interface ViewController () <YLWebViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    YLWebView *webView = [[YLWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - YLWebViewDelegate Methods
- (void)webViewDidFinishLoad:(YLWebView *)webView {
    
}

- (BOOL)webView:(YLWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

@end
