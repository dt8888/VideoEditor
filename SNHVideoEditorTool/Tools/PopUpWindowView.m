//
//  PopUpWindowView.m
//  YJJSApp
//
//  Created by DT on 2018/6/7.
//  Copyright © 2018年 dt. All rights reserved.
//

#import "PopUpWindowView.h"
#import "UIViewAdditions.h"
#import "MyUtility.h"
#define kScreenHeight [UIScreen mainScreen].bounds.size.height//获取屏幕高度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width//获取屏幕宽度
@implementation PopUpWindowView
{
    NSArray *_selectArray;

}
-(instancetype)initWithShareRegistHeight:(NSString *)title selectArr:(NSArray *)array
{
    self=[super init];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (self) {
        if (self.bGView==nil) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            view.backgroundColor = [UIColor blackColor];
            view.alpha = 0.3;
            
            [window addSubview:view];
            self.bGView =view;
        }
        
        _selectArray = array;
        self.center = CGPointMake(kScreenWidth/2, kScreenHeight/2);
        self.bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        [window addSubview:self];
        self.selfHeight = 50+array.count*51;
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-self.selfHeight, kScreenWidth, self.selfHeight)];
        [backView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:backView];
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:backView.bounds  byRoundingCorners:UIRectCornerTopRight |  UIRectCornerTopLeft    cornerRadii:CGSizeMake(8, 8)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = backView.bounds;
        maskLayer.path = maskPath.CGPath;
        backView.layer.mask = maskLayer;
        
        UILabel *titleText  =[MyUtility createLabelWithFrame:CGRectMake(30, 20, kScreenWidth-60, 20) title:title textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15] textAlignment:NSTextAlignmentCenter numberOfLines:0];
        [backView addSubview:titleText];
        
        UIButton *coloseBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth-40, 20, 25, 25)];
        [coloseBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [coloseBtn  addTarget:self action:@selector(colseBtn) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:coloseBtn];
        
        for(int i=0;i<array.count;i++){
            UIView *bgView= [[UIView alloc]initWithFrame:CGRectMake(0,  titleText.bottom+i*(50+1), kScreenWidth, 51)];
            bgView.tag= 100+i;
            [backView addSubview:bgView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
            [bgView addGestureRecognizer:tap];
            
            UILabel *selectText  =[MyUtility createLabelWithFrame:CGRectMake(0, 0, kScreenWidth, 50) title:array[i] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:12*kScreenWidth/375] textAlignment:NSTextAlignmentCenter numberOfLines:0];
            [bgView addSubview:selectText];
            
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, selectText.bottom, kScreenWidth, 1)];
            lineView.backgroundColor= [UIColor whiteColor];
            lineView.alpha = 0.1;
            [bgView addSubview:lineView];
            if(i==array.count-1){
                lineView.hidden = YES;
            }
        }
        [self show:YES];
    }
    return self;
}
-(void)tapView:(UITapGestureRecognizer *)tap{
    NSString *selectSting = _selectArray[tap.view.tag-100];
    [self hide:YES];
    if (self.ButtonClick) {
        self.ButtonClick(selectSting);
    }
}

//关闭
-(void)colseBtn{
      [self hide:YES];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch  locationInView:self];
    if (point.y<kScreenHeight-self.selfHeight){
        [self hide:YES];
    }
}

- (void)show:(BOOL)animated
{
    if (animated)
    {
        self.transform = CGAffineTransformTranslate(self.transform,0,self.selfHeight);
        __weak PopUpWindowView *weakSelf = self;
        [UIView animateWithDuration:.3 animations:^{
            weakSelf.transform = CGAffineTransformTranslate(weakSelf.transform,0,0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.3 animations:^{
                weakSelf.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

- (void)hide:(BOOL)animated
{
    [self endEditing:YES];
    if (self.bGView != nil) {
        __weak PopUpWindowView *weakSelf = self;
        [UIView animateWithDuration: animated ?0.3: 0 animations:^{
            weakSelf.transform = CGAffineTransformTranslate(weakSelf.transform,0,self.selfHeight);
        } completion:^(BOOL finished) {
            [weakSelf.bGView removeFromSuperview];
            [weakSelf removeFromSuperview];
            weakSelf.bGView=nil;
        }];
    }
}
@end
