//
//  SNHVideoTrimmerController.h
//  SNH
//
//  Created by huangshuni on 2017/7/13.
//  Copyright © 2017年 Mirco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BaseViewController.h"
@interface SNHVideoTrimmerController : BaseViewController

@property (nonatomic, strong) NSURL *videoUrl;
@property(nonatomic,assign) int flag;
@property(nonatomic,assign) CGFloat fileSize;
@property (nonatomic, strong) AVAsset * changeAsset;
@end
