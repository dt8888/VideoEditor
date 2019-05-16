//
//  SetingViewController.m
//  SNHVideoEditorTool
//
//  Created by DT on 2019/5/7.
//  Copyright © 2019年 huangshuni. All rights reserved.
//

#import "SetingViewController.h"
#import "FeedBackViewController.h"
#import "AboutUSViewController.h"
#import "UserAgreementViewController.h"
@interface SetingViewController ()

@end

@implementation SetingViewController
{
      UIImageView *_arrowImage;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Setting"];
     [self setLeftButton:@"fanhui"];
//     self.view.backgroundColor = RGB(235,235,235);
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor blackColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self createVC];
}
-(void)createVC{
    UIView *nameView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, kScreenWidth, 60)];
    nameView.tag = 100;
    nameView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:nameView];
    UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [nameView addGestureRecognizer:nameTap];
    UILabel *nameTitle = [MyUtility createLabelWithFrame:CGRectMake(15, 0, 100, 60) title:@"Feedback" textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft numberOfLines:0];
    [nameView addSubview:nameTitle];
    _arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-26, 23, 12, 12)];
    _arrowImage.image = [UIImage imageNamed:@"jiantouyou"];
    [nameView addSubview:_arrowImage];
    
    UIView *selfView = [[UIView alloc]initWithFrame:CGRectMake(0, nameView.bottom+1, kScreenWidth, 60)];
    selfView.tag = 200;
    selfView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:selfView];
    UITapGestureRecognizer *selfTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [selfView addGestureRecognizer:selfTap];
    UILabel *selfTitle = [MyUtility createLabelWithFrame:CGRectMake(15, 0, 100, 60) title:@"Privacy Policy" textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft numberOfLines:0];
    [selfView addSubview:selfTitle];
    _arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-26, 23, 12, 12)];
    _arrowImage.image = [UIImage imageNamed:@"jiantouyou"];
    [selfView addSubview:_arrowImage];
    
    UIView *aboutView = [[UIView alloc]initWithFrame:CGRectMake(0, selfView.bottom+1, kScreenWidth, 60)];
    aboutView.tag = 300;
    aboutView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:aboutView];
    UITapGestureRecognizer *aboutTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [aboutView addGestureRecognizer:aboutTap];
    UILabel *aboutTitle = [MyUtility createLabelWithFrame:CGRectMake(15, 0, 100, 60) title:@"About us" textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft numberOfLines:0];
    [aboutView addSubview:aboutTitle];
    _arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-26, 23, 12, 12)];
    _arrowImage.image = [UIImage imageNamed:@"jiantouyou"];
    [aboutView addSubview:_arrowImage];
}

-(void)tap:(UITapGestureRecognizer*)tap{
    if (tap.view.tag==100){
        FeedBackViewController*nickNameVC = [[FeedBackViewController alloc]init];
        [self.navigationController pushViewController:nickNameVC animated:YES];
    }else if (tap.view.tag==300){
        AboutUSViewController*posswordVC = [[AboutUSViewController alloc]init];
        [self.navigationController pushViewController:posswordVC animated:YES];
    }else
    {
        UserAgreementViewController*userVC = [[UserAgreementViewController alloc]init];
         [self.navigationController pushViewController:userVC animated:YES];
    }
}
- (UIImage*)imageWithColor:(UIColor*)color{
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    // 开始画图的上下文
    UIGraphicsBeginImageContext(rect.size);
    
    // 设置背景颜色
    [color set];
    // 设置填充区域
    UIRectFill(CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // 返回UIImage
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    return image;
}

@end
