//
//  YJTextView.h
//  YJJSApp
//
//  Created by DT on 2018/3/28.
//  Copyright © 2018年 dt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJTextView : UITextView
@property(strong,nonatomic) NSString *placeholder;
@property(strong,nonatomic) UIColor *placeholderColor;
@property(strong,nonatomic) UIFont * placeholderFont;
@property(assign,nonatomic)NSInteger textLength;
@end
