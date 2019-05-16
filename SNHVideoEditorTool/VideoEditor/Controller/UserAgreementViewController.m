//
//  UserAgreementViewController.m
//  RFApp
//
//  Created by DT on 2019/3/23.
//  Copyright © 2019年 dayukeji. All rights reserved.
//

#import "UserAgreementViewController.h"

@implementation UserAgreementViewController
{
    NSString *_strURL;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Privacy Policy"];
         _strURL =@"http://kk.gezhongxinqun.com/only-privacy.html";
  [self setLeftButton:@"fanhui"];
    [self createView];
}
-(void)createView{
    WKWebView *webView =  [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_strURL]];
    [webView loadRequest:request];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
}
@end
