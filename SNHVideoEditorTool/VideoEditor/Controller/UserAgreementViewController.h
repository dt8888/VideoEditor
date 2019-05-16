//
//  UserAgreementViewController.h
//  RFApp
//
//  Created by DT on 2019/3/23.
//  Copyright © 2019年 dayukeji. All rights reserved.
//

#import "BaseViewController.h"
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface UserAgreementViewController : BaseViewController<WKNavigationDelegate>
@property(nonatomic,assign)int flag;
@end

NS_ASSUME_NONNULL_END
