//
//  SNHVideoEditViewController.h
//  SNHVideoEditorTool
//
//  Created by huangshuni on 2017/7/27.
//  Copyright © 2017年 huangshuni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface SNHVideoEditViewController : BaseViewController

@property (nonatomic, strong) NSArray *urlsArr;
@property (nonatomic, strong) NSArray *imagesArr;
@property (nonatomic, strong) NSURL *vedioUrls;

@property (nonatomic, strong) NSString *gifPath;
@end
