//
//  SNHVideoTrimmerController.m
//  SNH
//
//  Created by huangshuni on 2017/7/13.
//  Copyright © 2017年 Mirco. All rights reserved.
//

#import "SNHVideoTrimmerController.h"
#import "SNHVideoTrimmer.h"
#import "SNHVideoEditor.h"
#import "SNHScrollCellView.h"
#import "MBProgressHUD.h"
#import "SNHVideoEditViewController.h"
#import "NSString+TimeConvert.h"
#import "MBProgressHUD+SHN.h"
#import "WHToast.h"
#import "PopUpWindowView.h"
#import "VideoSelectedManger.h"
#import "UIViewAdditions.h"
#import "SRVideoBottomBar.h"
#import "Masonry.h"
#import "JPImageresizerView.h"
#define SRVideoPlayerImageName(fileName) [@"SRVideoPlayer.bundle" stringByAppendingPathComponent:fileName]
@interface SNHVideoTrimmerController ()<SNHVideoTrimmerDelegate,SNHScrollCellViewDelegate,SRVideoBottomBarDelegate>
@property (nonatomic, strong) VideoSelectedManger *videoManager;
@property (nonatomic, strong) JPImageresizerConfigure *configure;
@property (nonatomic, weak) JPImageresizerView *imageresizerView;
@property (strong, nonatomic) UIView *videoPlayerView;
@property (strong, nonatomic) UIView *videoTrimmerBgView;
@property (strong, nonatomic) SNHVideoTrimmerView *trimmerView;
@property (strong, nonatomic) SNHScrollCellView *scrollCellView;
@property (strong, nonatomic) UIButton *trimBtn;
@property (strong, nonatomic) UIButton *mergeBtn;
@property (strong, nonatomic) UIButton *speedBtn;
@property (strong, nonatomic) UIButton *playBtn;
@property (nonatomic, strong) SRVideoBottomBar *bottomBar;
@property (nonatomic, strong) AVAsset *asset;
@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) NSTimer *playbackTimeCheckerTimer;
@property (assign, nonatomic) CGFloat videoPlaybackPosition;
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;
@property (assign, nonatomic) CGFloat startTime;
@property (assign, nonatomic) CGFloat stopTime;
@property (nonatomic, assign) CGRect  playerViewOriginalRect;
@property (nonatomic, assign) CGRect  cutVideoRect;
@property (nonatomic, assign) CGFloat  rotationAngal;
@property (assign, nonatomic) BOOL restartOnPlay;
@property (nonatomic, assign) BOOL isFullScreen;


//videos trimmed
@property (strong, nonatomic) NSMutableArray *videoPartsArr;

@end

@implementation SNHVideoTrimmerController
{
    NSURL *_cutUrl;
    UIScrollView*_bgView;
    UILabel*_originTitle;
    UILabel*_targetTitle;
    NSString *_compressType;
}
#pragma mark - =================== lifecycle ===================
- (void)viewDidLoad {
    [super viewDidLoad];
    _compressType = AVAssetExportPresetHighestQuality;
    // Do any additional setup after loading the view.
    [self setTitle:@"Video Editing"];
    [self setLeftButton:@"fanhui"];
    if(self.flag==100||self.flag==103){
        [self setRightTitleButton:@"Save" isShow:YES];
    }else if(self.flag==101){
           [self setRightTitleButton:@"Converter" isShow:YES];
    }else if(self.flag==104){
        [self setRightTitleButton:@"Next" isShow:YES];
    }
    else
    {
          [self setRightTitleButton:@"" isShow:NO];
    }
   
    [self setupUI];
    [self setupTrimmerView];
    if(self.flag==104){
         [self createView];
    }
}

-(void)createView{
    __weak typeof(self) wSelf = self;
    JPImageresizerView *imageresizerView = [[JPImageresizerView alloc]initWithResizeImage:self.videoPlayerView
                                                                               palyLayer:self.playerLayer originSize:CGSizeMake([MyUtility getVideoSize:self.videoUrl].width, [MyUtility getVideoSize:self.videoUrl].height)
                                                                                    frame:[UIScreen mainScreen].bounds maskType:JPNormalMaskType frameType:JPClassicFrameType animationCurve:JPAnimationCurveEaseInOut strokeColor:[UIColor whiteColor] bgColor:[UIColor blackColor] maskAlpha:1 verBaseMargin:2 horBaseMargin:2 resizeWHScale:0 contentInsets:UIEdgeInsetsMake(0, 0, 0, 0) imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
    } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
    }];
    imageresizerView.frameView.getCutRect = ^(CGRect rect) {
        self.cutVideoRect = rect;
    };
//    imageresizerView.getRotationAngal = ^(CGFloat angel) {
//        self.rotationAngal = angel;
//    };
    [self.view insertSubview:imageresizerView atIndex:0];
    self.imageresizerView = imageresizerView;
    self.configure = nil;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    self.player = nil;
    [self stopPlaybackTimeChecker];
}

#pragma mark - =================== setter ===================
-(void)setVideoUrl:(NSURL *)videoUrl {
    _videoUrl = videoUrl;
    _asset = [AVURLAsset URLAssetWithURL:_videoUrl options:nil];
}

- (SRVideoBottomBar *)bottomBar {
    
    if (!_bottomBar) {
        _bottomBar = [SRVideoBottomBar videoBottomBar];
        _bottomBar.delegate = self;
        _bottomBar.userInteractionEnabled = NO;
    }
    return _bottomBar;
}
#pragma mark - =================== define ===================
- (void)backAction {
    [self stopPlaybackTimeChecker];
//    [self deleteTempVideoParts];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 设置播放器和剪切视图
- (void)setupTrimmerView {


    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
//    self.playerLayer.frame = CGRectMake(0, 0, self.videoPlayerView.width, 272);
    self.playerLayer.frame = self.videoPlayerView.bounds;
    [self.videoPlayerView.layer addSublayer:self.playerLayer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnVideoLayer:)];
    [self.videoPlayerView addGestureRecognizer:tap];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn.frame = CGRectMake(0, 0, 80, 80);
    self.playBtn.center = self.videoPlayerView.center;
    [self.playBtn setImage:[UIImage imageNamed:@"videoEditor_play_h"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playBtn];


    self.videoPlaybackPosition = 0;
    [self tapOnVideoLayer:tap];
    
    // set properties for trimmer view
    self.trimmerView = [[SNHVideoTrimmerView alloc] init];
    self.trimmerView.frame = self.videoTrimmerBgView.bounds;
    [self.videoTrimmerBgView addSubview:self.trimmerView];
    [self.trimmerView setThemeColor:RGB(248, 103, 79)];
    [self.trimmerView setAsset:self.asset];
    [self.trimmerView setShowsRulerView:NO];
    [self.trimmerView setShowsTimerView:YES];
    [self.trimmerView setRulerLabelInterval:10];
    [self.trimmerView setMinLength:3.0];
    [self.trimmerView setTrackerColor:RGB(248, 103, 79)];
    [self.trimmerView setDelegate:self];

    // important: reset subviews
    [self.trimmerView resetSubviews];
    
    //刚进入时视频播放器在开始
    [self seekVideoToPos:self.startTime];

}


#pragma mark 点击视频播放器
- (void)tapOnVideoLayer:(UITapGestureRecognizer *)tap
{
    if (self.isPlaying == NO) {
        return;
    }
    self.playBtn.hidden = NO;
    
    if (self.isPlaying) {
        [self.player pause];
        [self stopPlaybackTimeChecker];
    }else {
        if (_restartOnPlay){
            [self seekVideoToPos: self.startTime];
            [self.trimmerView seekToTime:self.startTime];
            _restartOnPlay = NO;
        }
        [self.player play];
        [self startPlaybackTimeChecker];
    }
    self.isPlaying = !self.isPlaying;
    [self.trimmerView hideTracker:!self.isPlaying];
}

#pragma mark 点击播放按钮
- (void)playAction:(UIButton *)btn {
    
    btn.hidden = YES;
    
    if (self.isPlaying) {
        [self.player pause];
        [self stopPlaybackTimeChecker];
    }else {
        if (_restartOnPlay){
            [self seekVideoToPos: self.startTime];
            [self.trimmerView seekToTime:self.startTime];
            _restartOnPlay = NO;
        }
        [self.player play];
        [self startPlaybackTimeChecker];
    }
    self.isPlaying = !self.isPlaying;
    [self.trimmerView hideTracker:!self.isPlaying];
}

- (void)startPlaybackTimeChecker
{
    [self stopPlaybackTimeChecker];
    
    self.playbackTimeCheckerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onPlaybackTimeCheckerTimer) userInfo:nil repeats:YES];
}

- (void)stopPlaybackTimeChecker
{
    if (self.playbackTimeCheckerTimer) {
        [self.playbackTimeCheckerTimer invalidate];
        self.playbackTimeCheckerTimer = nil;
    }
}


#pragma mark - PlaybackTimeCheckerTimer

- (void)onPlaybackTimeCheckerTimer
{
    CMTime curTime = [self.player currentTime];
    Float64 seconds = CMTimeGetSeconds(curTime);
    if (seconds < 0){
        seconds = 0; // this happens! dont know why.
    }
    self.videoPlaybackPosition = seconds;
    
    [self.trimmerView seekToTime:seconds];
    
    if (self.videoPlaybackPosition >= self.stopTime) {
        //被注释的三步可以用来重复播放截取片段
//        self.videoPlaybackPosition = self.startTime;
//        [self seekVideoToPos: self.startTime];
//        [self.trimmerView seekToTime:self.startTime];
        
        [self stopPlaybackTimeChecker];
        _restartOnPlay = YES;
        [self.player pause];
        self.isPlaying = NO;
        self.playBtn.hidden = NO;
        [self seekVideoToPos:self.startTime];
        [self.trimmerView seekToTime:self.startTime];
        [self.trimmerView hideTracker:true];
    }
}

- (void)seekVideoToPos:(CGFloat)pos
{
    self.videoPlaybackPosition = pos;
    CMTime time = CMTimeMakeWithSeconds(self.videoPlaybackPosition, self.player.currentTime.timescale);
    //NSLog(@"seekVideoToPos time:%.2f", CMTimeGetSeconds(time));
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark 删除视频片段
- (void)deleteVideoPart:(NSIndexPath *)indexPath{
    
    SNHVideoModel *model = self.videoPartsArr[indexPath.row];
    if (model) {
        [self.videoPartsArr removeObjectAtIndex:indexPath.row];
        self.scrollCellView.datasArr = self.videoPartsArr;
    }
    
}


#pragma mark 剪切视频
- (void)tapRightBtn {
    if(self.flag==100||self.flag==103){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Processing...";
        
        WS(ws);
        SNHVideoEditor *editor = [[SNHVideoEditor alloc] init];
        [editor loadAsset:self.videoUrl beginTime:self.startTime endTime:self.stopTime];
        editor.outputFileType = @"mov";
        if(self.flag==103){
            editor.presetName = _compressType;
        }
        NSString *name = [NSString getCurrentTime];
        NSString *outputPath = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",name]];
        editor.outPutPath = outputPath;
        [editor exportVideo:@"mov" addLogo:@"" AsynchronouslyWithSuccessBlock:^(NSURL *outputURL) {
            [MBProgressHUD hideHUDForView:ws.view animated:YES];
            [editor writeVideoToPhotoLibraryWithSuccess:^{
                [WHToast showMessage:@"Save successful"  duration:1 finishHandler:^{
                }];
                [self.navigationController popViewControllerAnimated:YES];
            } failure:^(NSError *error) {
                 [MBProgressHUD hideHUDForView:ws.view animated:YES];
                [WHToast showMessage:@"Save video failed, please save it again!"  duration:1 finishHandler:^{
                }];
            }];
        } failureBlock:^(NSError *error) {
            [MBProgressHUD hideHUDForView:ws.view animated:YES];
            [WHToast showMessage:@"To deal with failure"  duration:1 finishHandler:^{
            }];
        }];
    }else if (self.flag==101){
       PopUpWindowView *alert = [[PopUpWindowView alloc]initWithShareRegistHeight:@"Select conversion format" selectArr:@[@"mov",@"mp4",@"gif"]];
           WS(ws);
         SNHVideoEditor *editor = [[SNHVideoEditor alloc] init];
          [editor loadAsset:self.videoUrl beginTime:self.startTime endTime:self.stopTime];
        alert.ButtonClick = ^void(NSString*selectString){
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = @"Processing...";
            if(![selectString isEqualToString:@"gif"])
            {
                NSString *name = [NSString getCurrentTime];
                NSString *outputPath = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",name]];
                 editor.outPutPath = outputPath;
             [editor exportVideo:selectString addLogo:@"" AsynchronouslyWithSuccessBlock:^(NSURL *outputURL) {
               [MBProgressHUD hideHUDForView:ws.view animated:YES];
               SNHVideoEditViewController* VC = [[SNHVideoEditViewController alloc]init];
               VC.vedioUrls =outputURL;
              [self.navigationController pushViewController:VC animated:YES];
     } failureBlock:^(NSError *error) {
              [MBProgressHUD hideHUDForView:ws.view animated:YES];
              [WHToast showMessage:@"Conversion failed. Please re convert."  duration:1 finishHandler:^{
              }];
          }];
        }else
        {
            [self pushSelectedVideo];
        }
    };
    }else if (self.flag==104){

        SNHVideoEditor *editor = [[SNHVideoEditor alloc] init];
        if(self.flag==103){
              [editor addLogoInDirection:SNVideoLogoDirectionRightTop];
        }else
        {
            editor.OriginRect = CGRectMake(0, 0, [MyUtility getVideoSize:self.videoUrl].width, [MyUtility getVideoSize:self.videoUrl].height);
            editor.renderRect = self.cutVideoRect;
            editor.angael = 0;
        }
        [editor loadAsset:self.videoUrl beginTime:self.startTime endTime:self.stopTime];
        editor.outputFileType = @"mov";
        NSString *name = [NSString getCurrentTime];
        NSString *outputPath = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",name]];
        editor.outPutPath = outputPath;
        [editor exportVideo:@"mov" addLogo:@"" AsynchronouslyWithSuccessBlock:^(NSURL *outputURL) {
            SNHVideoEditViewController* VC = [[SNHVideoEditViewController alloc]init];
            VC.vedioUrls =outputURL;
            [self.navigationController pushViewController:VC animated:YES];
        } failureBlock:^(NSError *error) {
           
            [WHToast showMessage:@"To deal with failure"  duration:1 finishHandler:^{
            }];
        }];
    }
}



-(void)speedVideo{
     self.player.rate = 1.0;
}
#pragma mark 合并视频
- (void)mergeVideo {

    if (self.videoPartsArr.count == 0) {
        [MBProgressHUD showOnlyText:@"请先裁剪视频" view:self.view delayTime:1.0f];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Processing...";
    
    WS(ws);
    NSString *name = [NSString getCurrentTime];
    
    NSString *videoPath = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",name]];
    
    SNHVideoEditor *editor = [[SNHVideoEditor alloc] init];
    [editor loadAssetModels:self.videoPartsArr];
    editor.videoTransitionType = SNHVideoTransitionTypeFadeInOut;
    editor.outPutPath = videoPath;
    editor.outputFileType = @"mp4";
    
   [editor exportVideo:@"mov" addLogo:@"" AsynchronouslyWithSuccessBlock:^(NSURL *outputURL) {
        NSLog(@"merge success");
        [MBProgressHUD hideHUDForView:ws.view animated:YES];
        
        SNHVideoModel *model = [[SNHVideoModel alloc] init];
        model.assetUrl = outputURL;
        model.beginTime = 0.0;
        model.endTime = CMTimeGetSeconds([[AVAsset assetWithURL:outputURL] duration]);
        NSArray *arr = [NSArray arrayWithObject:model];
        
        WS(ws);
        dispatch_async(dispatch_get_main_queue(), ^{
            SNHVideoEditViewController *vc = [[SNHVideoEditViewController alloc] init];
            vc.urlsArr = arr;
            [ws.navigationController pushViewController:vc animated:NO];
        });
       
        
    } failureBlock:^(NSError *error) {
         NSLog(@"merge failure");
        [MBProgressHUD hideHUDForView:ws.view animated:YES];
        [MBProgressHUD showOnlyText:@"合并失败" view:ws.view];
    }];
}


//ui
- (void)setupUI {
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor blackColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.view.backgroundColor = [UIColor blackColor];
    
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    backBtn.frame = CGRectMake(0, 20, 44, 44);
//    [backBtn setImage:[UIImage imageNamed:@"back12"] forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:backBtn];
//
//    UILabel *titlelable = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 44)];
//    titlelable.textColor = [UIColor whiteColor];
//    titlelable.textAlignment = NSTextAlignmentCenter;
//    titlelable.font = [UIFont systemFontOfSize:15];
//    titlelable.text = @"剪辑视频片段";
//    [self.view addSubview:titlelable];
    
//    self.trimBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.trimBtn.frame = CGRectMake(SCREEN_WIDTH - 10 - 70, 28, 70, 30);
//    self.trimBtn.backgroundColor = [UIColor orangeColor];
//    if(self.flag==100){
//         [self.trimBtn setTitle:@"保存" forState:UIControlStateNormal];
//    }else if(self.flag==101)
//    {
//        [self.trimBtn setTitle:@"转换" forState:UIControlStateNormal];
//    }else if(self.flag==103)
//    {
//        self.trimBtn.hidden = YES;
////         [self.trimBtn setTitle:@"" forState:UIControlStateNormal];
//    }
   
   
//    [self.trimBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.trimBtn addTarget:self action:@selector(saveTrimVideo) forControlEvents:UIControlEventTouchUpInside];
//
//    [self.view addSubview:self.trimBtn];
    
//    self.speedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.speedBtn.frame = CGRectMake(120, SCREEN_HEIGHT - 10 - 30, 70, 30);
//    self.speedBtn.backgroundColor = [UIColor orangeColor];
//    [self.speedBtn setTitle:@"速度" forState:UIControlStateNormal];
//    self.speedBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//    [self.speedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.speedBtn addTarget:self action:@selector(speedVideo) forControlEvents:UIControlEventTouchUpInside];
//    self.speedBtn.layer.cornerRadius = 3;
//    self.speedBtn.layer.masksToBounds = YES;
//    [self.view addSubview:self.speedBtn];
//
//    self.mergeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.mergeBtn.frame = CGRectMake(10, SCREEN_HEIGHT - 10 - 30, 70, 30);
//    self.mergeBtn.backgroundColor = [UIColor orangeColor];
//    [self.mergeBtn setTitle:@"合并" forState:UIControlStateNormal];
//    self.mergeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//    [self.mergeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.mergeBtn addTarget:self action:@selector(mergeVideo) forControlEvents:UIControlEventTouchUpInside];
//    self.mergeBtn.layer.cornerRadius = 3;
//    self.mergeBtn.layer.masksToBounds = YES;
//    [self.view addSubview:self.mergeBtn];
    
    self.videoTrimmerBgView = [[UIView alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT - 10 - 30  - 50 - 60, SCREEN_WIDTH - 20, 60)];
    CGFloat bottomH =SCREEN_HEIGHT-(30 + 40)-200;
     CGFloat scrollCellViewH = (SCREEN_WIDTH - 10*2 - 10*3)/4 + 20;
    if(self.flag==100){
        self.videoTrimmerBgView.hidden = NO;
    }else
    {
         self.videoTrimmerBgView.hidden = YES;
        if(self.flag==105){
               [self addLogal];
            bottomH = self.videoTrimmerBgView.frame.origin.y - 40 - scrollCellViewH - (30 + 20) - 80;
        }else if(self.flag==103){
            [self addCompress:bottomH+30];
        }else if(self.flag==104)
        {
            [self viedoCut:bottomH+30];
        }
    }
    [self.view addSubview:self.videoTrimmerBgView];
//
  
//    self.scrollCellView = [[SNHScrollCellView alloc] initWithFrame:CGRectMake(0, self.videoTrimmerBgView.frame.origin.y - 40 - scrollCellViewH, SCREEN_WIDTH, scrollCellViewH)];
//    self.scrollCellView.collectionView.backgroundColor = [UIColor yellowColor];
//    self.scrollCellView.delegate = self;
//    [self.view addSubview:self.scrollCellView];
    
    self.videoPlayerView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, kScreenWidth-22,400)];
    self.videoPlayerView.backgroundColor = [UIColor blackColor];
   [self.view addSubview:self.videoPlayerView];
//     self.bottomBar.frame = CGRectMake(10,  self.videoPlayerView.bottom+10,SCREEN_WIDTH-20 , 44);
//      [self.view addSubview:self.bottomBar];

}
//视频尺寸裁剪
-(void)viedoCut:(CGFloat)bottom{
    
    UIScrollView *bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(15, bottom+80, kScreenWidth-30, 90)];
    [self.view addSubview:bgScrollView];
    NSArray *titleArray = @[@"Free",@"1:1",@"3:2",@"4:3",@"7:5",@"16:9"];
        for(int i=0;i<titleArray.count;i++){
            UIView *tapView = [[UIView alloc]initWithFrame:CGRectMake(i*(70+15),20, 70, 30)];
            tapView.tag = 101+i;
            tapView.layer.masksToBounds = YES;
            tapView.layer.cornerRadius = 4;
            [tapView setBackgroundColor:[UIColor whiteColor]];
            [bgScrollView addSubview:tapView];
            UILabel *text = [MyUtility createLabelWithFrame:CGRectMake(0 ,0, 70, 30) title:titleArray[i] textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentCenter numberOfLines:0];
           
            [tapView addSubview:text];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectTap:)];
            [tapView addGestureRecognizer:tap];
        }
    bgScrollView.contentSize = CGSizeMake(8*15+titleArray.count*70, 0);
}

-(void)selectTap:(UITapGestureRecognizer*)tap{

    NSInteger flag = tap.view.tag-100;
    if(flag==1){
        self.imageresizerView.resizeWHScale = 0;
    }else if (flag==2){
        self.imageresizerView.resizeWHScale = 1;
    }else if (flag==3){
         self.imageresizerView.resizeWHScale = 3.0 / 2.0;
    }else if (flag==4){
         self.imageresizerView.resizeWHScale = 4.0 / 3.0;
    }else if (flag==5){
        self.imageresizerView.resizeWHScale = 7.0 / 5.0;
    }else
    {
        self.imageresizerView.resizeWHScale = 16.0 / 9.0;
    }
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
//压缩
-(void)addCompress:(CGFloat)top{
    NSString *showSize ;
    if(self.fileSize>1024){
        showSize = [NSString stringWithFormat:@"%d MB",(int)self.fileSize/1024];
    }else
    {
         showSize = [NSString stringWithFormat:@"%d KB",(int)self.fileSize];
    }
    
    _originTitle = [MyUtility createLabelWithFrame:CGRectMake(10, top+15, kScreenWidth-20,30) title:[NSString stringWithFormat:@"Original size: %@",showSize] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    [self.view addSubview:_originTitle];
     NSString *trgateSize ;
    if(self.fileSize*0.5>1024){
        trgateSize = [NSString stringWithFormat:@"%d MB",(int)self.fileSize*1/2/1024];
    }else
    {
        trgateSize = [NSString stringWithFormat:@"%d KB",(int)self.fileSize*1/2];
    }

    _targetTitle = [MyUtility createLabelWithFrame:CGRectMake(10, _originTitle.bottom+5, kScreenWidth-20,30) title:[NSString stringWithFormat:@"Target size: %@(50)%%",trgateSize] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    [self.view addSubview:_targetTitle];
    
    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(10, _targetTitle.bottom+15, kScreenWidth-20, 30)];
    slider.maximumValue = 100;
    slider.value = 50;
    slider.minimumTrackTintColor =RGB(248, 103, 79);
    slider.minimumValue = 0;
    slider.continuous = YES;//默认YES  如果设置为NO，则每次滑块停止移动后才触发事件
    [slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
}
- (void) sliderChange:(id) sender {
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider * slider = sender;
        int value = slider.value;
        if(value<=30){
            _compressType = AVAssetExportPresetLowQuality;
        }else if (value>30&&value<=70){
              _compressType = AVAssetExportPresetMediumQuality;
        }else
        {
               _compressType = AVAssetExportPresetHighestQuality;
        }
        if(self.fileSize*value/100>1024){
             _targetTitle.text = [NSString stringWithFormat:@"Target size: %@(%d)%%",[NSString stringWithFormat:@"%d MB",(int)self.fileSize*value/100/1024],value];
        }else
        {
              _targetTitle.text = [NSString stringWithFormat:@"Target size: %@(%d)%%",[NSString stringWithFormat:@"%d Kb",(int)self.fileSize*value/100],value];
        }
    }
}

//水印模版
-(void)addLogal{
      CGFloat scrollCellViewH = (SCREEN_WIDTH - 10*2 - 10*3)/4 + 20;
    _bgView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, (self.videoTrimmerBgView.frame.origin.y - 40 - scrollCellViewH - (30 + 20) - 50)+15, SCREEN_WIDTH , SCREEN_HEIGHT-(30+ 40+(self.videoTrimmerBgView.frame.origin.y - 40 - scrollCellViewH - (30 + 20) - 50)))];
    _bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bgView];
    NSArray *titleArr = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    for(int i=0;i<titleArr.count;i++){
        NSInteger row = i /3;
        NSInteger col = i %3;
        CGFloat pic_width =(SCREEN_WIDTH-40)/3;
        CGFloat picX = 10 + (pic_width + 10) * col;
        CGFloat picY = 10 + (pic_width + 10) * row;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(picX, picY, pic_width, pic_width)];
        view.layer.masksToBounds = YES;
        view.tag = 100+i;
        view.layer.cornerRadius =5;
        view.backgroundColor = [UIColor lightGrayColor];
        [_bgView addSubview:view];
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
        [view addGestureRecognizer:tapView];
        
        UIImageView *bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, pic_width-16, pic_width-16)];
        bgImage.image = [UIImage imageNamed:titleArr[i]];
        bgImage.contentMode = UIViewContentModeScaleAspectFit;
        bgImage.userInteractionEnabled = YES;
        bgImage.layer.masksToBounds = YES;
        bgImage.layer.cornerRadius =5;
        [view addSubview:bgImage];
        _bgView.contentSize = CGSizeMake(0, 80+pic_width*4);
    }
}
#pragma mark - =================== delegate ===================
#pragma mark  SNHVideoTrimmerDelegate

-(void)tapView:(UITapGestureRecognizer*)tap{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Processing...";
    WS(ws);
     NSArray *titleArr = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    SNHVideoEditor *editor = [[SNHVideoEditor alloc] init];
    [editor addLogoInDirection:SNVideoLogoDirectionRightTop];
    [editor loadAsset:self.videoUrl beginTime:self.startTime endTime:self.stopTime];
    editor.outputFileType = @"mov";
    NSString *name = [NSString getCurrentTime];
    NSString *outputPath = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",name]];
    editor.outPutPath = outputPath;
    [editor exportVideo:@"mov" addLogo:titleArr[tap.view.tag-100] AsynchronouslyWithSuccessBlock:^(NSURL *outputURL) {
          [MBProgressHUD hideHUDForView:ws.view animated:YES];
        SNHVideoEditViewController* VC = [[SNHVideoEditViewController alloc]init];
        VC.vedioUrls =outputURL;
        [self.navigationController pushViewController:VC animated:YES];
    } failureBlock:^(NSError *error) {
          [MBProgressHUD hideHUDForView:ws.view animated:YES];
        [WHToast showMessage:@"裁剪失败"  duration:1 finishHandler:^{
        }];
    }];
}
- (void)trimmerView:(SNHVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime
{
    _restartOnPlay = YES;
    [self.player pause];
    self.isPlaying = NO;
    self.playBtn.hidden = NO;
    [self stopPlaybackTimeChecker];
    
    [self.trimmerView hideTracker:true];
    
    if (startTime != self.startTime) {
        //then it moved the left position, we should rearrange the bar
        [self seekVideoToPos:startTime];
    }
    else{ // right has changed
        [self seekVideoToPos:endTime];
    }
    self.startTime = startTime;
    self.stopTime = endTime;
    
}
- (void)pushSelectedVideo{
    __weak typeof(self) weakSlef = self;
    if (!self.videoManager) {
        self.videoManager = [VideoSelectedManger new];
        
        [self.videoManager PhotosGetVideoData:^(id video) {
            [weakSlef imageAnimation];
        }];
          [self.videoManager creatAvasset:self.changeAsset];
    }
}
//展示gif动画
- (void)imageAnimation{
    if (self.videoManager.totalImageArray.count) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSData *data in self.videoManager.totalImageArray) {
            [array addObject:[UIImage imageWithData:data]];
        }
         WS(ws);
          [MBProgressHUD hideHUDForView:ws.view animated:YES];
        self.videoManager.getGifPath = ^(NSString *path) {
            SNHVideoEditViewController *vc = [[SNHVideoEditViewController alloc] init];
            vc.imagesArr = array;
            vc.gifPath =path;
            [ws.navigationController pushViewController:vc animated:NO];
        };
    }
    
    
}
#pragma mark NCMScrollCellViewDelegate
- (void)SNHScrollCellViewDidDeleteItem:(NSIndexPath *)indexPath {
    [self deleteVideoPart:indexPath];
}

- (void)SNHScrollCellViewDidMoveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //取出源item数据
    SNHVideoModel *objc = [self.videoPartsArr objectAtIndex:sourceIndexPath.item];
    //从资源数组中移除该数据
    [self.videoPartsArr removeObject:objc];
    //将数据插入到资源数组中的目标位置上
    [self.videoPartsArr insertObject:objc atIndex:destinationIndexPath.item];
}

#pragma mark - =================== setter/getter ===================
-(NSMutableArray *)videoPartsArr {
    if (!_videoPartsArr) {
        _videoPartsArr = [NSMutableArray array];
    }
    return _videoPartsArr;
}


@end
