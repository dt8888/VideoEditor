
//
//  WTBottomInputView.m
//  zkjkClient
//
//  Created by Tao on 2018/7/6.
//  Copyright © 2018年 Tao. All rights reserved.
//

#import "WTBottomInputView.h"
#import "UIView+Ext.h"
#define WTWidth [UIScreen mainScreen].bounds.size.width
#define WTHeight [UIScreen mainScreen].bounds.size.height
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define STATUS_BAR_HEIGHT (iPhoneX ? 44.f : 20.f)
#define NAVIGATION_BAR_HEIGHT (iPhoneX ? 88.f : 64.f)
#define TAB_BAR_HEIGHT (iPhoneX ? (49.f+34.f) : 49.f)
#define HOME_INDICATOR_HEIGHT (iPhoneX ? 34.f : 0.f)

@interface WTBottomInputView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView * bottomBgView;

@property (nonatomic, strong) UIButton * senderBtn;

@end

@implementation WTBottomInputView
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.frame = CGRectMake(0, WTHeight-TAB_BAR_HEIGHT, WTWidth, TAB_BAR_HEIGHT);
        self.backgroundColor = [UIColor clearColor];
        
        [self addNotification];
        [self setUI];
    }
    return self;
}

#pragma mark--添加通知---
-(void)addNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = keyboardF.origin.y;
    
    self.Y = 0;
    self.height = WTHeight;
    self.bottomBgView.Y = WTHeight-TAB_BAR_HEIGHT;
    
    [UIView animateWithDuration:duration animations:^{
        self.bottomBgView.Y = keyboardY-49;
    }];
}
- (void)keyboardWillhide:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = keyboardF.origin.y;
    
    self.Y = WTHeight-TAB_BAR_HEIGHT;
    self.height = TAB_BAR_HEIGHT;
    self.bottomBgView.Y = 0;
    
    [UIView animateWithDuration:duration animations:^{
        self.bottomBgView.Y = 0;
    }];
}
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
//    NSDictionary *userInfo = notification.userInfo;
//    // 动画的持续时间
//    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    // 键盘的frame
//    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat keyboardY = keyboardF.origin.y;
//
//    [UIView animateWithDuration:duration animations:^{
//        self.bottomBgView.Y = keyboardY-49;
//    }];
}
- (void)keyboardDidChangeFrame:(NSNotification *)notification
{

}
- (void)setUI
{
    [self addSubview:self.bottomBgView];
    [self.bottomBgView addSubview:self.textField];
    [self.bottomBgView addSubview:self.senderBtn];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapPress:)];
    tapGesture.numberOfTapsRequired=1;
    [self addGestureRecognizer:tapGesture];
}
- (void)handleTapPress:(UITapGestureRecognizer *)gestureRecognizer
{
    [self endEditing:YES];
}
- (UIView *)bottomBgView
{
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WTWidth, TAB_BAR_HEIGHT)];
        _bottomBgView.backgroundColor = [UIColor blackColor];
        
        UIView * bLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _bottomBgView.width, 0.5f)];
        bLine.backgroundColor = [UIColor blackColor];
        [_bottomBgView addSubview:bLine];
    }
    return _bottomBgView;
}
- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc]initWithFrame:CGRectMake(15, 7, WTWidth-15-91, 35)];
        _textField.font = [UIFont systemFontOfSize:16];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.layer.masksToBounds = YES;
        _textField.placeholder=@"说点什么...";
        _textField.layer.cornerRadius = 4.0f;
        _textField.layer.borderWidth = 0.5f;
        _textField.layer.borderColor= [UIColor whiteColor].CGColor;
        _textField.returnKeyType = UIReturnKeySend;
        _textField.delegate = self;
    }
    return _textField;
}

- (UIButton *)senderBtn
{
    if (!_senderBtn) {
        _senderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _senderBtn.frame = CGRectMake(WTWidth-76, 7, 61, 35);
        [_senderBtn setBackgroundColor:RGB(248, 103, 79)];
        [_senderBtn setTitle:@"添加" forState:UIControlStateNormal];
        _senderBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _senderBtn.layer.cornerRadius = 4;
        _senderBtn.layer.masksToBounds = YES;
        [_senderBtn addTarget:self action:@selector(senderBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _senderBtn;
}
- (void)senderBtnClick
{
    if (self.textField.text.length<=0) {
        return;
    }
    [self endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(WTBottomInputViewSendTextMessage:)]) {
        [self.delegate WTBottomInputViewSendTextMessage:self.textField.text];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]){
        [self senderBtnClick];
        return NO;
    }
    return YES;
}

- (void)showView
{
    [self setHidden:NO];
}
- (void)hideView
{
    [self setHidden:YES];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
