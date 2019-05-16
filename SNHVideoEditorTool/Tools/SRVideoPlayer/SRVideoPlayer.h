//
//  SRVideoPlayer.h
//  SRVideoPlayer
//
//  Created by https://github.com/guowilling on 17/1/5.
//  Copyright © 2017年 SR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BarrageRenderer.h"
typedef NS_ENUM(NSInteger, SRVideoPlayerState) {
    SRVedioPlayerStateFailed,
    SRVideoPlayerStateBuffering,
    SRVideoPlayerStatePlaying,
    SRVideoPlayerStatePaused,
    SRVideoPlayerStateFinished,
    SRVideoPlayerStateStopped
};

typedef NS_ENUM(NSInteger, SRVideoPlayerEndAction) {
    SRVideoPlayerEndActionStop,
    SRVideoPlayerEndActionLoop,
    SRVideoPlayerEndActionDestroy
};

@interface SRVideoPlayer : NSObject
@property(nonatomic,strong)NSDictionary *param;
@property(nonatomic,strong)NSString *danMuText;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,assign)BOOL isShowDanMu;
@property(nonatomic,strong)NSTimer *danmuTimer;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)BarrageRenderer *renderer;
@property (nonatomic, assign, readonly) SRVideoPlayerState playerState;

/**
 The action when the video play to end, default is SRVideoPlayerEndActionStop.
 */
@property (nonatomic, assign) SRVideoPlayerEndAction playerEndAction;

/**
 The name of the video which will be displayed in the top center.
 */
@property (nonatomic, copy) NSString *videoName;

/**
 Creates and returns a video player with video's URL, playerView and playerSuperView.

 @param videoURL        The URL of the video.
 @param playerView      The view which you want to display the video.
 @param playerSuperView The playerView's super view.
 @return A newly video player.
 */
+ (instancetype)playerWithVideoURL:(NSURL *)videoURL playerView:(UIView *)playerView playerSuperView:(UIView *)playerSuperView;

- (void)play;

- (void)pause;

- (void)resume;

- (void)destroyPlayer;

@end
