//
//  VideoSelectedManger.h
//  VideoToGif
//
//  Created by du zhou on 2017/11/29.
//  Copyright © 2017年 du zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
typedef void(^videoModelBlock)(id video);
@interface VideoSelectedManger : NSObject

@property(copy,nonatomic)void (^getGifPath)(NSString*);
/**
 装载gif
 */
@property (nonatomic, strong) NSString *gifPath;
/**
 获取的资源结果
 */
@property (nonatomic, strong) PHFetchResult *assets;

/**
 要获取的资源结果的筛选条件
 */
@property (nonatomic, strong) PHFetchOptions * fetchOptions;

/**
 获取图片的筛选类型
 */
@property (nonatomic, strong) PHVideoRequestOptions *imageOptions;

- (void)PhotosGetVideoData:(videoModelBlock)videoBlock;

/**
 选择要生成的图

 @param number 点击的数据
 */
-(void)creatVideoComeToGifCurrentNumber:(NSInteger)number;

@property (nonatomic, strong) NSMutableArray  *totalImageArray;

@property (nonatomic, assign) NSInteger animationTimer;


- (void)creatAvasset:(AVAsset *)asset;
/**
 保存gif到相册中

 @param photoName 自定义的相册的名字
 */
- (void)saveGifToPhoto:(NSString *)photoName;


@end
