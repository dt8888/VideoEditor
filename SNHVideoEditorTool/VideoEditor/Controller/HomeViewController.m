//
//  HomeViewController.m
//  SNHVideoEditorTool
//
//  Created by DT on 2019/5/5.
//  Copyright © 2019年 huangshuni. All rights reserved.
//

#import "HomeViewController.h"
#import "MyUtility.h"
#import "SNHVideoTrimmerController.h"
#import "TZImagePickerController.h"
#import "DanMuViewController.h"
#import <Photos/Photos.h>
#import "SetingViewController.h"
#define COL_COUNT 2

#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]
@interface HomeViewController ()<UINavigationControllerDelegate>
@property (nonatomic, assign)BOOL isCanUseSideBack;  // 手势是否启动
@end

@implementation HomeViewController
{
    UIScrollView *_bgScrollView;
    CGFloat bottomH;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self startSideBack];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self cancelSideBack];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    bottomH = 100;
    self.navigationController.delegate = self;
    self.title = @"视频编辑";
    self.view.backgroundColor = [UIColor blackColor];
//    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
//    bgView.image = [UIImage imageNamed:@"bg"];
//    bgView.userInteractionEnabled = YES;
//    [self.view addSubview:bgView];
    [self createView];
    [self createNav];
}
-(void)createNav{
    
    UILabel*title = [MyUtility createLabelWithFrame:CGRectMake(0, 40, kScreenWidth,25) title:@"Fast player" textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:18] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    title.font = [UIFont systemFontOfSize:16 weight:0.6];
    [self.view addSubview:title];
    
    UIButton *rightbBarButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth-50, 40, 25, 25)];
    [rightbBarButton setImage:[UIImage imageNamed:@"shezhi"] forState:UIControlStateNormal];
    [rightbBarButton addTarget:self action:@selector(tapMine) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:rightbBarButton];
}
-(void)createView{
    _bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 100, kScreenWidth, kScreenHeight-100)];
    [self.view addSubview:_bgScrollView];
    NSArray *titleArr = @[@"Video Clip",@"Video Converter",@"Video Barrage",@"Video Compress",@"Video Crop"];
     NSArray *imageArr = @[@"caijian",@"zhuanhuan",@"danmu",@"yasuo",@"caijian1"];
      NSArray *colorArr = @[RGB(0, 139, 139),RGB(218, 165, 32),RGB(219,112,147),RGB(72, 61, 139),RGB(100, 149, 237)];
       CGFloat margin = 25;
    CGFloat width =(kScreenWidth-3*margin)/2;
    CGFloat higth =(kScreenWidth-3*margin)/2*5/4;
    for(int i=0;i<titleArr.count;i++){
        NSInteger row = i /COL_COUNT;
        NSInteger col = i %COL_COUNT;
        CGFloat picX = margin + (width + margin) * col;
        CGFloat picY = margin + (higth + margin) * row;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(picX, picY, width, higth)];
        view.layer.masksToBounds = YES;
        view.tag = 100+i;
        view.layer.cornerRadius =5;
        view.backgroundColor = colorArr[i];
        [_bgScrollView addSubview:view];
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
        [view addGestureRecognizer:tapView];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((width-30)/2, 50, 30, 30)];
        imageView.image = [UIImage imageNamed:imageArr[i]];
        [view addSubview:imageView];
        
        UILabel*title = [MyUtility createLabelWithFrame:CGRectMake(0, higth-70, width,20) title:titleArr[i] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16] textAlignment:NSTextAlignmentCenter numberOfLines:0];
        title.font = [UIFont systemFontOfSize:16 weight:0.6];
        [view addSubview:title];
        bottomH = view.bottom+30;
    }
    
    _bgScrollView.contentSize = CGSizeMake(0, bottomH);
}
//点击
-(void)tapView:(UITapGestureRecognizer*)tap{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = NO;
//    imagePickerVc.allowCrop = YES;
    NSInteger width = SCREEN_WIDTH;
    NSInteger Height = (SCREEN_WIDTH / (16.0/9));
    imagePickerVc.cropRect = CGRectMake((SCREEN_WIDTH - width)/2, (SCREEN_HEIGHT - Height)/2, width, Height);
    
    WS(ws);
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage,id asset){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Processing...";
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionOriginal;
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            NSURL *url = urlAsset.URL;
            dispatch_async(dispatch_get_main_queue(), ^{
                  [MBProgressHUD hideHUDForView:ws.view animated:YES];
                NSString * sandboxExtensionTokenKey = info[@"PHImageFileSandboxExtensionTokenKey"];
                NSArray * arr = [sandboxExtensionTokenKey componentsSeparatedByString:@";"];
                 NSString * filePath = [arr[arr.count - 1]substringFromIndex:9];
                CGFloat size = [MyUtility getFileSize:filePath];
                if(tap.view.tag!=102){
                    SNHVideoTrimmerController *vc = [[SNHVideoTrimmerController alloc] init];
                    vc.videoUrl = url;
                    vc.fileSize = size;
                    vc.changeAsset = asset;
                    vc.flag = tap.view.tag;
                    [self.navigationController pushViewController:vc animated:YES];
                }else
                {
                    DanMuViewController *danVC = [[DanMuViewController alloc]init];
                    danVC.videoUrl = url;
                      [self.navigationController pushViewController:danVC animated:YES];
                }
            });
        }];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

-(void)tapMine{
    SetingViewController *setVC = [[SetingViewController alloc]init];
    [self.navigationController pushViewController:setVC animated:YES];
}

#pragma UINavigationControllerDelegate方法
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}

/**
 * 关闭ios右滑返回
 */
-(void)cancelSideBack{
    self.isCanUseSideBack = NO;
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate=self;
    }
}
/*
 开启ios右滑返回
 */
- (void)startSideBack {
    self.isCanUseSideBack=YES;
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    return self.isCanUseSideBack;
}
@end
