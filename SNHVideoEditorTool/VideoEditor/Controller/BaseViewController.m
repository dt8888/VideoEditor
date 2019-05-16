//
//  BaseViewController.m
//  技师外快宝
//
//  Created by DT on 2019/3/11.
//  Copyright © 2019年 dayukeji. All rights reserved.
//

#import "BaseViewController.h"
#import "UIViewController+BarButton.h"

@interface BaseViewController ()
@property (nonatomic, assign)BOOL isCanUseSideBack;  // 手势是否启动
@end

@implementation BaseViewController
{
        UILabel *titleLabel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchView:)];
    [self.bgImage  addGestureRecognizer:tap];
    self.view.backgroundColor = [UIColor whiteColor];
    

}
-(void)touchView:(UITapGestureRecognizer *)tap{
    [self.view endEditing:YES];
    [tap.view endEditing:YES];
}
-(void)setTitle:(NSString *)title
{
    if (title == nil || [title length] == 0) {
    }
    else
    {
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 64)];
        titleLabel.text = title;
          titleLabel.font = [UIFont systemFontOfSize:16 weight:0.4];
        titleLabel.textColor = [UIColor whiteColor];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        titleLabel.adjustsFontSizeToFitWidth = YES;  //文字自动适应UILabel的宽度
        self.navigationItem.titleView = titleLabel;
    }
}
-(void)setLeftButton:(NSString*)imgStr{
    [self addLeftBarButtonWithImage:[UIImage imageNamed:imgStr] action:@selector(tapLeftBtn)];
}

-(void)setRightButton:(NSString *)imageStr
{
       [self addRightBarButtonWithImage:[UIImage imageNamed:imageStr] action:@selector(tapRightBtn)];
    
}
-(void)setRightTitleButton:(NSString *)titleStr isShow:(BOOL)isshow;{
    [self addRightBarButtonItemWithTitle:titleStr action:@selector(tapRightBtn) isShow:isshow];
}
-(void)tapRightBtn{
    
}
-(void)tapLeftBtn{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 * 关闭ios右滑返回
 */
-(void)cancelSideBack{
    self.isCanUseSideBack = NO;
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate=self;
    }
}
/*
 开启ios右滑返回
 */
- (void)startSideBack {
    self.isCanUseSideBack=YES;
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    return self.isCanUseSideBack;
}
-(void)prsentToLoginViewController{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationLoginIn" object:nil];
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
