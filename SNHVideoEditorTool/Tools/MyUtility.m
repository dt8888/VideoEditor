//
//  MyUtility.m
//  YJJSApp
//
//  Created by DT on 2018/3/21.
//  Copyright © 2018年 dt. All rights reserved.
//

#import "MyUtility.h"
#import <Photos/Photos.h>
@implementation MyUtility

+ (UIView *)createViewWithFrame:(CGRect)frame
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    return view;
}

+(UIView *)createViewWithFrame:(CGRect)frame WithBorder:(CGFloat)border{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = frame.size.height/2;
    view.layer.borderColor = [UIColor redColor].CGColor;
    view.layer.borderWidth = 1;
    return view;
}
+ (UILabel *)createLabelWithFrame:(CGRect)frame title:(NSString *)title textColor:(UIColor *)color font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment numberOfLines:(NSInteger)numberOfLines
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    if (title) {
        label.text = title;
    }
    if (color) {
        label.textColor = color;
    }
    if (font) {
        label.font = font;
    }
    if (textAlignment) {
        label.textAlignment = textAlignment;
    }
    if (numberOfLines) {
        label.numberOfLines = numberOfLines;
    }
    return label;
}

+ (UILabel *)createLabelWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font
{
    return [self createLabelWithFrame:frame title:title textColor:[UIColor blackColor] font:font textAlignment:NSTextAlignmentLeft numberOfLines:1];
}

+ (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title textColor:(UIColor *)color  imageName:(NSString *)imageName target:(id)target action:(SEL)action isCorner:(BOOL)isCorner isDriction:(int)driction
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    if(imageName){
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    if (title) {
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
    if (target && action) {
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    if(isCorner){
//        btn.layer.cornerRadius = 17;
//        btn.layer.masksToBounds = YES;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:btn.bounds  byRoundingCorners:UIRectCornerTopRight |  UIRectCornerBottomRight    cornerRadii:CGSizeMake(0, 17)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = btn.bounds;
        maskLayer.path = maskPath.CGPath;
        btn.layer.mask = maskLayer;
    }
    //上下
    if(driction==1){
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height+15 ,-btn.imageView.frame.size.width, 0.0,0.0)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(-25, 0.0,0.0, -btn.titleLabel.bounds.size.width)];
    }else if (driction==2)
    {
        //zuoyou
        btn.contentMode = UIViewContentModeScaleAspectFit;
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width, 0, btn.imageView.frame.size.width)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width+5, 0, -btn.titleLabel.bounds.size.width)];
    }else if(driction==3){
        btn.contentMode = UIViewContentModeScaleAspectFit;
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    }
    
    return btn;
}

//+ (YJTextField *)createTextField:(CGRect)frame placeHolder:(NSString *)placeHolder font:(CGFloat)font textColor:(UIColor *)color
//{
//    YJTextField *textField = [[YJTextField alloc] initWithFrame:frame];
//    if (placeHolder) {
//        textField.placeholder = placeHolder;
//        if(![placeHolder isEqualToString:@""]){
//              textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
//        }
//    }
//    textField.tintColor = greenColor;
//    if(font){
//        textField.font = [UIFont  systemFontOfSize:font];
//    }
//    if(color){
//        textField.textColor = color;
//    }
//    textField.borderStyle = UITextBorderStyleNone;
//    return textField;
//}
//// 创建文字输入框的方法
//+ (YJTextView *)createTextView:(CGRect)frame placeHolder:(NSString *)placeHolder font:(CGFloat)font  textColor:(UIColor*)color {
//
//    YJTextView *textView = [[YJTextView alloc] initWithFrame:frame];
//     textView.tintColor = RGB(197, 152, 110);
//    if (placeHolder) {
//        textView.placeholder =placeHolder;
//    }
//    if(font){
//        textView.font = [UIFont  systemFontOfSize:font];
//    }
//    if(color){
//        textView.textColor = color;
//    }
//    textView.textContainerInset = UIEdgeInsetsMake(10,0, 0, 0);
//    return textView;
//}

+ (UIImageView *)createImageViewWithFrame:(CGRect)frame imageName:(NSString *)imageName isCorner:(BOOL)isCorner
{
    UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:frame];
    if([imageName containsString:@"http"]){
//        [tmpImageView sd_setImageWithURL:[NSURL URLWithString:imageName]];
    }else
    {
           tmpImageView.image = [UIImage imageNamed:imageName];
    }
 
     [tmpImageView setClipsToBounds:YES];
    [tmpImageView setContentMode:UIViewContentModeScaleAspectFill];
    if(isCorner){
        tmpImageView.layer.masksToBounds = YES;
        tmpImageView.layer.cornerRadius = 5;
    }
    return tmpImageView;
}
/**
 *  判断UILabel所占尺寸的大小
 *
 *  @param text    文字内容
 *  @param font    字体
 *  @param maxSize 允许所占最大的尺寸
 *
 *  @return 文字占的尺寸
 */
+ (CGSize)labelAutoCalculateRectWith:(NSString*)text font:(UIFont*)font maxSize:(CGSize)maxSize
{
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode=NSLineBreakByWordWrapping;
    NSDictionary* attributes =@{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize labelSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
    labelSize.height = ceil(labelSize.height);
    labelSize.width = ceil(labelSize.width);
    return labelSize;
}

+ (CGSize)labelAutoCalculateRectWith:(NSString*)text maxSize:(CGSize)maxSize attributes:(NSDictionary *)attributesDict
{
    CGSize labelSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:attributesDict context:nil].size;
    labelSize.height = ceil(labelSize.height);
    labelSize.width = ceil(labelSize.width);
    return labelSize;
}

- (void)countdownSecond:(NSInteger)seconds  returnTitle:(void(^)(NSString *title))returnTitle
{
    if (_timer)
    {
        dispatch_source_cancel(_timer);
        //        dispatch_release(_timer);
        _timer = nil;
    }
    __block NSInteger timeout = seconds; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            //            dispatch_release(_timer);
            _timer = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                self.seconds = timeout  ;
                returnTitle(@"-1");
            });
        }else{
            int seconds = timeout % 61;
            NSString *strTime = [NSString stringWithFormat:@"%.2d秒后获取", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                self.seconds = timeout  ;
                returnTitle(strTime);
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

+(CGFloat) getFileSize:(NSString *)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;//KB
    }
    return filesize;
}
+(CGSize)getVideoSize:(NSURL*)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack = tracks[0];
    CGSize videoSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    videoSize = CGSizeMake(fabs(videoSize.width), fabs(videoSize.height));
    
//     AVAsset *asset = [AVAsset assetWithURL:url];
//    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
//    if([tracks count] > 0) {
//        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
//        CGAffineTransform t = videoTrack.preferredTransform;//这里的矩阵有旋转角度，转换一下即可
       NSLog(@"=====hello  width:%f===height:%f",videoSize.width,videoSize.height);//宽高
        return videoSize;
//    }
//    return CGSizeZero;
}
@end
