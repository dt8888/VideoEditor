//
//  YJTextField.m
//  YJJSApp
//
//  Created by DT on 2018/3/28.
//  Copyright © 2018年 dt. All rights reserved.
//

#import "YJTextField.h"
#import "UIViewAdditions.h"
#define RGB(r,g,b)      [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f]
#define kScreenHeight [UIScreen mainScreen].bounds.size.height//获取屏幕高度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width//获取屏幕宽度
@implementation YJTextField
- (id)initWithFrame:(CGRect)frame
{
    if (frame.size.height==0) {
        frame.size.height=43;
    }
    self = [super initWithFrame:frame];
    if (self) {
        [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [self setClearButtonMode:UITextFieldViewModeWhileEditing];
        UIView *v=[[UIView alloc] init];
        
        CGRect rect=v.frame;
        v.tag=1001;
        rect.size.height=41;
        [v setFrame:rect];
        
        v.backgroundColor=RGB(240, 240, 242);
        UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        lineView.backgroundColor=RGB(193, 195, 198);
        [v addSubview:lineView];
        
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn setTitle:@"Done" forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
        btn.frame=CGRectMake(kScreenWidth-56, 0, 56, 41);
        [btn addTarget:self action:@selector(hideKeyBoard) forControlEvents:UIControlEventTouchUpInside];
        [v addSubview:btn];
        [self setInputAccessoryView:v];
        [self setLeftViewMode:UITextFieldViewModeAlways];
    }
    return self;
}
-(void)hideKeyBoard{
    
    UIView *v=[self viewWithTag:1001];
    v.origin=CGPointMake(0, kScreenHeight);
    [self resignFirstResponder];
}
@end
