//
//  AboutUSViewController.m
//  RFApp
//
//  Created by DT on 2019/3/29.
//  Copyright © 2019年 dayukeji. All rights reserved.
//

#import "AboutUSViewController.h"

@interface AboutUSViewController ()

@end

@implementation AboutUSViewController
{
    UIImageView *bgImage;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
//    bgImage.image = [UIImage imageNamed:@"bg.jpg"];
//    bgImage.userInteractionEnabled = YES;
//    [self.view addSubview:bgImage];
    [self setTitle:@"About us"];
    [self setLeftButton:@"fanhui"];
    [self createView];
}
-(void)createView{
//    UIImageView *iconImage = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-76)/2, 80, 76, 76)];
//    iconImage.image = [UIImage imageNamed:@"icon-76"];
//    iconImage.layer.masksToBounds = YES;
//    iconImage.layer.cornerRadius = 10;
//    [self.view addSubview:iconImage];
    
    UILabel *fixTitle = [MyUtility createLabelWithFrame:CGRectMake(25, 25, kScreenWidth-50, 30) title:@"Version(1.0)" textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    [self.view addSubview:fixTitle];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
