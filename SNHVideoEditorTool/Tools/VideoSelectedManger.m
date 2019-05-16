//
//  VideoSelectedManger.m
//  VideoToGif
//
//  Created by du zhou on 2017/11/29.
//  Copyright © 2017年 du zhou. All rights reserved.
//

#import "VideoSelectedManger.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
//帧率15/s
static NSInteger const FTPNumber = 15;

//gif最长时长
static NSInteger const Maxsconds = 6;

//在documnet下的gif文件名称
static NSString  *gifName = @"test.gif";

@interface VideoSelectedManger ()

//承载回调的block
@property (nonatomic, copy) videoModelBlock blockVideo;


@end

@implementation VideoSelectedManger

-(PHFetchResult *)assets{
    if (!_assets) {
        _assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:self.fetchOptions];
        
    }
   
    
    return _assets;
}

-(PHFetchOptions *)fetchOptions{
    if (!_fetchOptions) {
        _fetchOptions = [[PHFetchOptions alloc]init];
        _fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
    }
    return _fetchOptions;
}


-(PHVideoRequestOptions *)imageOptions{
    if (!_imageOptions) {
       _imageOptions = [[PHVideoRequestOptions alloc]init];//请求选项配置
//        _imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;//
//        _imageOptions.synchronous = YES;
        
        _imageOptions.version = PHImageRequestOptionsVersionCurrent;//当前图片
        //    options.networkAccessAllowed = YES //到iclould中下载
        _imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        
    }
    return _imageOptions;
}

-(NSMutableArray *)totalImageArray{
    if (!_totalImageArray) {
        
        _totalImageArray = [NSMutableArray array];
    }
    return _totalImageArray;
}


//- (NSInteger)animationTimer{
//
//    return Maxsconds;
//
//}

/**
 回调处理

 @param videoBloc block
 */
- (void)PhotosGetVideoData:(videoModelBlock)videoBloc{
    
    self.blockVideo = videoBloc;
    
}
-(void)creatVideoComeToGifCurrentNumber:(NSInteger)number{
   
    __weak typeof(self) weakSelf = self;
    [[PHImageManager defaultManager]requestAVAssetForVideo:self.assets[number] options:self.imageOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        [weakSelf creatAvasset:asset];
        
    }];
    
    
}

- (void)setGifPath:(NSString *)gifPath{
    if (gifPath) {
        _gifPath = [NSString stringWithFormat:@"%@", gifPath];
        

    }
    
}
//把视频转换成图片数组
- (void)creatAvasset:(AVAsset *)asset{
   AVAssetImageGenerator *imagegenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    CMTime time = asset.duration;
    
    NSInteger totalTimer = (NSInteger)CMTimeGetSeconds(time);
    //总共要取的张数
    NSInteger totalCount = 0;
    //最多取的时常
    if (totalTimer > Maxsconds) {
        self.animationTimer = Maxsconds;
        totalCount = Maxsconds * FTPNumber;
    }else{
        self.animationTimer = totalTimer;
        totalCount = totalTimer * FTPNumber;
        
    }
    
    NSMutableArray *timeArray = [NSMutableArray array];
    for (NSInteger i = 0; i < totalCount; i++) {
        CMTime timeFrame = CMTimeMake(i, FTPNumber);
        NSValue *timeValue = [NSValue valueWithCMTime:timeFrame];
        [timeArray addObject:timeValue];
    }
    //防止出现偏差
    imagegenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imagegenerator.requestedTimeToleranceAfter = kCMTimeZero;
    
    [self.totalImageArray removeAllObjects];
    
    //转换成图片
    
    [imagegenerator generateCGImagesAsynchronouslyForTimes:timeArray completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        
        switch (result) {
            case AVAssetImageGeneratorFailed:
            {
                //获取失败
                NSLog(@"获取失败");
            }
            break;
              case AVAssetImageGeneratorCancelled:
            {
//                获取已取消
                NSLog(@"获取已经取消");
            }
                break;
                case AVAssetImageGeneratorSucceeded:
            {
//                获取成功

                    NSData *data = UIImageJPEGRepresentation([UIImage imageWithCGImage:image], 0.6);
                    [self.totalImageArray addObject:data];

                if ( requestedTime.value >= totalCount -1) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.blockVideo) {
                            
                            self.blockVideo(@"成功处理");
                            //随便处理生产一个gif
                            [self ImageArrayToGif];
                        }
                      
                    });
                    
                }
               
            }
                break;
            default:
                break;
        }
        
        
    }];
    

}

//把图片转成gif
-(void)ImageArrayToGif{
    
    NSMutableArray * images= [NSMutableArray array];
    
    for (NSData *dataImage in self.totalImageArray) {
        [images addObject:[UIImage imageWithData:dataImage]];
        
    }
//生成载gif的文件在Document中
    NSString *path = [self creatPathGif];
    self.gifPath = path;
    //配置gif属性
    CGImageDestinationRef destion;
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, false);
    destion = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, NULL);
    NSDictionary *frameDic = [NSDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.3],(NSString*)kCGImagePropertyGIFDelayTime, nil] forKey:(NSString*)kCGImagePropertyGIFDelayTime];
    
    NSMutableDictionary *gifParmdict = [NSMutableDictionary dictionaryWithCapacity:2];
    //颜色
    [gifParmdict setObject:[NSNumber numberWithBool:YES] forKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap];
//    颜色类型
    [gifParmdict setObject:(NSString*)kCGImagePropertyColorModelRGB forKey:(NSString*)kCGImagePropertyColorModel];
//   颜色深度
    [gifParmdict setObject:[NSNumber numberWithInt:8] forKey:(NSString*)kCGImagePropertyDepth];
//   是否重复
    [gifParmdict setObject:[NSNumber numberWithInt:0] forKey:(NSString*)kCGImagePropertyGIFLoopCount];
    
    NSDictionary *gifProperty = [NSDictionary dictionaryWithObject:gifParmdict forKey:(NSString*)kCGImagePropertyGIFDictionary];
//    合成gif
    for (UIImage *dimage in images) {
        
        //可以在这里对图片进行压缩
        
        CGImageDestinationAddImage(destion, dimage.CGImage, (__bridge CFDictionaryRef)frameDic);
    }
    
    CGImageDestinationSetProperties(destion,(__bridge CFDictionaryRef)gifProperty);
    CGImageDestinationFinalize(destion);
    CFRelease(destion);
    if(self.getGifPath){
            self.getGifPath(path);
    }
}

//获取到保存在documnet文件中的gif数据
-(NSData *)getFileIntoSaveGif{
    
    NSData *imageData = [NSData dataWithContentsOfFile:self.gifPath];
    
    return imageData;
    
}

- (NSString *)creatPathGif{
    //创建你的gif文件
        NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *doucmentStr =[document objectAtIndex:0];
        NSFileManager *filemanager = [NSFileManager defaultManager];
        NSString *textDic = [doucmentStr stringByAppendingString:@"/gif"];
        [filemanager createDirectoryAtPath:textDic withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *path = [textDic stringByAppendingString:gifName];
    NSLog(@"-----%@",path);
    return path;
}
//保存到自己的相册中
- (void)saveGifToPhoto:(NSString *)photoName{
    
    if ([self getFileIntoSaveGif]) {
        NSLog(@"我获取到了文件里面的gif");
        NSDictionary *metadata = @{@"UTI":(__bridge NSString *)kUTTypeGIF};
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
        [library writeImageDataToSavedPhotosAlbum:[self getFileIntoSaveGif] metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"写数据失败：%@",error);
            }else{
                
                NSLog(@"保存成功");
                
            }
        }];
        
    }
}

- (void)getVideoPhotosFromAlbum{
    
//    [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:nil];

    
}
@end
