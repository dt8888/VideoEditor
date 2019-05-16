//
//  MyUtility.h
//  YJJSApp
//
//  Created by DT on 2018/3/21.
//  Copyright © 2018年 dt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MyUtility : NSObject
{
     dispatch_source_t _timer;
}
@property (nonatomic) NSInteger seconds ;
// 创建View视图的方法
+ (UIView *)createViewWithFrame:(CGRect)frame;
+(UIView *)createViewWithFrame:(CGRect)frame WithBorder:(CGFloat)border;
// 创建Label的方法
+ (UILabel *)createLabelWithFrame:(CGRect)frame title:(NSString *)title textColor:(UIColor *)color font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment numberOfLines:(NSInteger)numberOfLines;

// 创建Label的另外一个方法
+ (UILabel *)createLabelWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font;

// 创建按钮的方法
+ (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title textColor:(UIColor *)color  imageName:(NSString *)imageName target:(id)target action:(SEL)action isCorner:(BOOL)isCorner isDriction:(int)driction;

// 创建图片视图的方法
+ (UIImageView *)createImageViewWithFrame:(CGRect)frame imageName:(NSString *)imageName isCorner:(BOOL)isCorner;

//// 创建文字输入框的方法
//+ (YJTextField *)createTextField:(CGRect)frame placeHolder:(NSString *)placeHolder font:(CGFloat)font  textColor:(UIColor*)color;
//
//// 创建文字输入框的方法
//+ (YJTextView *)createTextView:(CGRect)frame placeHolder:(NSString *)placeHolder font:(CGFloat)font  textColor:(UIColor*)color;

/**
 *  判断UILabel所占尺寸的大小
 *
 *  @param text     文字内容
 *  @param font     字体
 *  @param maxSize  允许所占最大的尺寸
 *
 *  @return         文字占的尺寸
 */
+ (CGSize)labelAutoCalculateRectWith:(NSString*)text font:(UIFont*)font maxSize:(CGSize)maxSize;

+ (CGSize)labelAutoCalculateRectWith:(NSString*)text maxSize:(CGSize)maxSize attributes:(NSDictionary *)attributesDict;

-(void)countdownSecond:(NSInteger)seconds  returnTitle:(void(^)(NSString *title))returnTitle;
+(CGFloat) getFileSize:(NSString *)path;
+(CGSize)getVideoSize:(NSURL*)url;
@end
