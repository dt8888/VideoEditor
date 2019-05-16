//
//  PopUpWindowView.h
//  YJJSApp
//
//  Created by DT on 2018/6/7.
//  Copyright © 2018年 dt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopUpWindowView : UIView
@property(nonatomic,strong)UIView *bGView;
@property(nonatomic,assign)CGFloat selfHeight;
@property(copy,nonatomic)void (^ButtonClick)(NSString*);
-(instancetype)initWithShareRegistHeight:(NSString *)title selectArr:(NSArray *)array;
@end
