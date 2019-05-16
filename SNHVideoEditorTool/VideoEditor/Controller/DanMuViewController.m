//
//  DanMuViewController.m
//  SNHVideoEditorTool
//
//  Created by DT on 2019/5/6.
//  Copyright © 2019年 huangshuni. All rights reserved.
//

#import "DanMuViewController.h"
#import "SRVideoPlayer.h"
#import "YJTextField.h"
#import "WHToast.h"
#import "WTBottomInputView.h"

@interface DanMuViewController ()<WTBottomInputViewDelegate>
@property(nonatomic,strong)SRVideoPlayer *player;
@property(nonatomic,strong)UIImageView *imageView;

@end

@implementation DanMuViewController
{
    WTBottomInputView * bottomView;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [bottomView showView];  //此句用于在跳回时让bottomBox显示
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
      [bottomView hideView];   //此句用于在跳出其他页时让bottomBox消失
    [self.player.renderer stop];
    [self.player.danmuTimer invalidate];
    //测试定时器
    [self.player.timer invalidate];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setTitle:@"Video Editing"];
    [self setLeftButton:@"fanhui"];
    [self setRightTitleButton:@"Share" isShow:YES];
    [self setUpView];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor blackColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
}
- (void)backAction {
     [bottomView hideView]; 
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setUpView{
    self.view.backgroundColor = [UIColor blackColor];
    bottomView = [[WTBottomInputView alloc]init];
    bottomView.delegate = self;
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:bottomView];
    
    _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 400)];
    [_imageView setUserInteractionEnabled:YES];
    [self.view addSubview:_imageView];
    
    self.player = [SRVideoPlayer playerWithVideoURL:self.videoUrl playerView:_imageView playerSuperView:_imageView.superview];
    self.player.url=nil;
     self.player.isShowDanMu = YES;
    self.player.playerEndAction = SRVideoPlayerEndActionLoop;
    [self.player play];
}

- (void)WTBottomInputViewSendTextMessage:(NSString *)message
{
    self.player.danMuText = message;
}

-(void)tapRightBtn{
    UIImage *imageToShare = [self imageWithView:_imageView];
    NSArray *activityItems = @[imageToShare];
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
    activityController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {
            [WHToast showMessage:@"Share success"  duration:1 finishHandler:^{
            }];
            //分享 成功
        } else  {
            [WHToast showMessage:@"Cancel share"  duration:1 finishHandler:^{
                
            }];
            //分享 取消
        }
    };
}

-(UIImage*)imageWithView:(UIView*)view{
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(_imageView.bounds.size, NO, scale);
    [_imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (UIImage*)imageWithColor:(UIColor*)color{
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    // 开始画图的上下文
    UIGraphicsBeginImageContext(rect.size);
    
    // 设置背景颜色
    [color set];
    // 设置填充区域
    UIRectFill(CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // 返回UIImage
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    return image;
}

@end
