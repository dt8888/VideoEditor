//
//  SNHVideoEditViewController.m
//  SNHVideoEditorTool
//
//  Created by huangshuni on 2017/7/27.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import "SNHVideoEditViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SNHVideoTool.h"
#import "MBProgressHUD+SHN.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#import "WHToast.h"
#import "SRVideoPlayer.h"
@interface SNHVideoEditViewController ()
@property (strong, nonatomic)  UIImageView *videoPlayerViewGif;
@property(nonatomic,strong)SRVideoPlayer *player;
@property(nonatomic,strong)UIImageView *imageView;
@property (nonatomic, strong) UIButton *saveBtn;//保存按钮

@end

@implementation SNHVideoEditViewController

#pragma mark - =================== life cycle ===================
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor blackColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self setupUI];
    [self setLeftButton:@"fanhui"];
//    [self addPlayObserver];
}


#pragma mark - =================== define ===================
- (void)setupUI {

    self.view.backgroundColor = [UIColor blackColor];
    if(self.imagesArr.count<=0){
        _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 30, [UIScreen mainScreen].bounds.size.width-20, 400)];
        [_imageView setUserInteractionEnabled:YES];
        [self.view addSubview:_imageView];
        
        self.player = [SRVideoPlayer playerWithVideoURL:self.vedioUrls playerView:_imageView playerSuperView:_imageView.superview];
        self.player.url=nil;
        [self.player.renderer stop];
//          self.player.isShowDanMu = NO;
        self.player.playerEndAction = SRVideoPlayerEndActionStop;
        [self.player play];
    }else
    {
          self.videoPlayerViewGif = [[UIImageView alloc]initWithFrame:CGRectMake(10, 30, SCREEN_WIDTH-20, 400)];
           [self.view addSubview:self.videoPlayerViewGif];
                self.videoPlayerViewGif.animationImages = self.imagesArr;
               self.videoPlayerViewGif.animationDuration = 6;
                self.videoPlayerViewGif.animationRepeatCount = 0;
                [self.videoPlayerViewGif startAnimating];
    }
    
    
//    self.timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.playerLayer.frame), SCREEN_WIDTH - 20, 30)];
//    [self.timeSlider addTarget:self action:@selector(timeSliderValueChange:) forControlEvents:UIControlEventValueChanged];
//    [self.timeSlider setThumbImage:[self thumbImage] forState:UIControlStateNormal];
//    self.timeSlider.maximumValue = model.endTime - model.beginTime;
//    self.timeSlider.minimumTrackTintColor = [UIColor orangeColor];
//    [self.view addSubview:self.timeSlider];
    
    
    self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveBtn.frame = CGRectMake(SCREEN_WIDTH/2 - 35, 550, 70, 30);
    self.saveBtn.backgroundColor = RGB(248, 103, 79);
    [self.saveBtn setTitle:@"Save" forState:UIControlStateNormal];
    self.saveBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(saveVideo) forControlEvents:UIControlEventTouchUpInside];
    self.saveBtn.layer.cornerRadius = 3;
    self.saveBtn.layer.masksToBounds = YES;
    [self.view addSubview:self.saveBtn];
    
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
#pragma mark 保存到系统相册
- (void)saveVideo {
    if(self.imagesArr.count<=0){
        [[SNHVideoTool shared] writeVideoToPhotoLibraryWithOutputPath:self.vedioUrls success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [WHToast showMessage:@"Save successful"  duration:1 finishHandler:^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
            });
            
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [WHToast showMessage:@"Save video failed, please save it again!"  duration:1 finishHandler:^{
                }];
            });
        }];
    }else
    {
        [self saveGifToPhoto];
    }
    
}


- (UIImage *)thumbImage{

    CGSize size = CGSizeMake(20, 20);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *whiteColor = [UIColor whiteColor];
    CGContextSetFillColorWithColor(context, [whiteColor CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, 20, 20));
    
    UIColor *innerColor = [UIColor orangeColor];
    CGContextSetFillColorWithColor(context, [innerColor CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(5, 5, 10, 10));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//#pragma mark 添加观察者
//- (void)addPlayObserver{
//    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//}
//
//- (void)removeObserver {
//    [self.playerItem removeObserver:self forKeyPath:@"status"];
//    self.playbackTimeObserver = nil;
//}
//
//- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
//    WS(ws);
//    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
//        CGFloat currentTime = CMTimeGetSeconds(playerItem.currentTime);
//        [ws.timeSlider setValue:currentTime];
//    }];
//}

#pragma mark 返回
- (void)tapRightBtn {
    
    self.player = nil;
//    [self.player destroyPlayer];
    [self.navigationController popViewControllerAnimated:NO];
//    [self removeObserver];
}

//#pragma mark - =================== observer ===================
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"status"]) {
//        AVPlayerItem *playerItem = (AVPlayerItem *)object;
//        if ([playerItem status] == AVPlayerItemStatusReadyToPlay) {
//             [self monitoringPlayback:self.playerItem];// 监听播放状态
//        }
//    }
//}
//
//#pragma mark - =================== 滑动时间条 ===================
//- (void)timeSliderValueChange:(UISlider *)slider {
//    NSLog(@"%.2f",slider.value);
//    
//    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, 23)];
//}

//保存到自己的相册中
- (void)saveGifToPhoto{
     [self.player pause];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Processing...";
    WS(ws);
    if ([self getFileIntoSaveGif]) {
        NSDictionary *metadata = @{@"UTI":(__bridge NSString *)kUTTypeGIF};
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
        [library writeImageDataToSavedPhotosAlbum:[self getFileIntoSaveGif] metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
             [MBProgressHUD hideHUDForView:ws.view animated:YES];
            if (error) {
                [WHToast showMessage:@"Save video failed, please save it again!"  duration:1 finishHandler:^{
                }];
            }else{
                [WHToast showMessage:@"Save successful"  duration:1 finishHandler:^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
            }
        }];
        
    }
}
//获取到保存在documnet文件中的gif数据
-(NSData *)getFileIntoSaveGif{
    NSData *imageData = [NSData dataWithContentsOfFile:self.gifPath];
    return imageData;
    
}
@end
