//
//  FeedBackViewController.m
//  RFApp
//
//  Created by DT on 2019/3/20.
//  Copyright © 2019年 dayukeji. All rights reserved.
//

#import "FeedBackViewController.h"
#import "YJTextView.h"
#import "WHToast.h"
@interface FeedBackViewController ()<UITextFieldDelegate,UITextViewDelegate>

@end

@implementation FeedBackViewController
{
    YJTextView *_textV;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Feedback"];
    [self setLeftButton:@"fanhui"];
    [self createView];
}
-(void)createView{
    _textV =[[YJTextView alloc]initWithFrame:CGRectMake(25, 40, kScreenWidth-50, 200)];
    _textV.backgroundColor = [UIColor whiteColor];
    _textV.delegate=self;
    _textV.placeholderFont = [UIFont systemFontOfSize:14];
    _textV.placeholder = @"Please input your feedback information. ";
    [self.view addSubview:_textV];
    
    UIButton *loginBtn = [MyUtility createButtonWithFrame:CGRectMake(25, _textV.bottom+20, kScreenWidth-50, 45) title:@"Submit" textColor:[UIColor whiteColor] imageName:@"" target:self action:@selector(quitLogin) isCorner:NO isDriction:4];
    loginBtn.backgroundColor = RGB(248, 103, 79);
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:loginBtn];
}
-(void)quitLogin{
    [WHToast showMessage:@"We have received your feedback. Thank you very much."  duration:1 finishHandler:^{
    }];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"%@",textField.text);
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_textV resignFirstResponder];
    [_textV endEditing:NO];
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
