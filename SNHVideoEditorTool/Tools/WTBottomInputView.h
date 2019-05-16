//
//  WTBottomInputView.h
//  zkjkClient
//
//  Created by Tao on 2018/7/6.
//  Copyright © 2018年 Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WTBottomInputViewDelegate <NSObject>

-(void)WTBottomInputViewSendTextMessage:(NSString *)message;

@end

@interface WTBottomInputView : UIView

@property (nonatomic, strong) UITextField * textField;

@property(nonatomic,weak)id<WTBottomInputViewDelegate>delegate;

- (void)showView;
- (void)hideView;

@end
