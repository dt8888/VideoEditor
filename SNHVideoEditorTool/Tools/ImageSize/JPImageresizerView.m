//
//  JPImageresizerView.m
//  DesignSpaceRestructure
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPImageresizerView.h"


#ifdef DEBUG
#define JPLog(...) printf("%s %s 第%d行: %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define JPLog(...)
#endif

@interface JPImageresizerView () <UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSMutableArray *allDirections;
@property (nonatomic, assign) NSInteger directionIndex;
@end

@implementation JPImageresizerView
{
    UIEdgeInsets _contentInsets;
    CGSize _contentSize;
    UIViewAnimationOptions _animationOption;
}

#pragma mark - setter
-(void)setCutVideoRect:(CGRect)cutVideoRect
{
    self.playerLayer.frame = CGRectMake(cutVideoRect.origin.x, cutVideoRect.origin.y, cutVideoRect.size.width, cutVideoRect.size.height);
}

- (void)setFrameType:(JPImageresizerFrameType)frameType {
    [self.frameView updateFrameType:frameType];
}

- (void)setBgColor:(UIColor *)bgColor {
    if (bgColor == [UIColor clearColor]) bgColor =RGB(57, 57, 57);
    self.backgroundColor = bgColor;
    if (_frameView) [_frameView setFillColor:bgColor];
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    if (_frameView) _frameView.maskAlpha = maskAlpha;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    self.frameView.strokeColor = strokeColor;
}

- (void)setResizeImage:(UIImage *)resizeImage {
   self.imageView.image = resizeImage;
    [self updateSubviewLayouts];
}

- (void)setVerBaseMargin:(CGFloat)verBaseMargin {
    _verBaseMargin = verBaseMargin;
    [self updateSubviewLayouts];
}

- (void)setHorBaseMargin:(CGFloat)horBaseMargin {
    _horBaseMargin = horBaseMargin;
    [self updateSubviewLayouts];
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale {
    [self.frameView setResizeWHScale:resizeWHScale animated:YES];
}

- (void)setEdgeLineIsEnabled:(BOOL)edgeLineIsEnabled {
    _edgeLineIsEnabled = edgeLineIsEnabled;
    self.frameView.edgeLineIsEnabled = edgeLineIsEnabled;
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale animated:(BOOL)isAnimated {
    [self.frameView setResizeWHScale:resizeWHScale animated:isAnimated];
}

- (void)setIsClockwiseRotation:(BOOL)isClockwiseRotation {
    if (_isClockwiseRotation == isClockwiseRotation) return;
    _isClockwiseRotation = isClockwiseRotation;
    [self.allDirections exchangeObjectAtIndex:1 withObjectAtIndex:3];
    if (self.directionIndex == 1) {
        self.directionIndex = 3;
    } else if (self.directionIndex == 3) {
        self.directionIndex = 1;
    }
}

- (void)setAnimationCurve:(JPAnimationCurve)animationCurve {
    _animationCurve = animationCurve;
    _frameView.animationCurve = animationCurve;
    switch (animationCurve) {
        case JPAnimationCurveEaseInOut:
            _animationOption = UIViewAnimationOptionCurveEaseInOut;
            break;
        case JPAnimationCurveEaseIn:
            _animationOption = UIViewAnimationOptionCurveEaseIn;
            break;
        case JPAnimationCurveEaseOut:
            _animationOption = UIViewAnimationOptionCurveEaseOut;
            break;
        case JPAnimationCurveLinear:
            _animationOption = UIViewAnimationOptionCurveLinear;
            break;
    }
}

- (void)setIsLockResizeFrame:(BOOL)isLockResizeFrame {
    self.frameView.panGR.enabled = !isLockResizeFrame;
}

- (void)setIsRotatedAutoScale:(BOOL)isRotatedAutoScale {
    _isRotatedAutoScale = isRotatedAutoScale;
    self.frameView.isRotatedAutoScale = isRotatedAutoScale;
}

- (void)setVerticalityMirror:(BOOL)verticalityMirror {
    [self setVerticalityMirror:verticalityMirror animated:NO];
}

- (void)setHorizontalMirror:(BOOL)horizontalMirror {
    [self setHorizontalMirror:horizontalMirror animated:NO];
}

#pragma mark - getter

- (JPImageresizerMaskType)maskType {
    return self.frameView.maskType;
}

- (JPImageresizerFrameType)frameType {
    return self.frameView.frameType;
}

- (UIColor *)bgColor {
    return self.backgroundColor;
}

- (UIColor *)strokeColor {
    return _frameView.strokeColor;
}

//- (UIImage *)resizeImage {
//    return _imageView.image;
//}

- (CGFloat)resizeWHScale {
    return _frameView.resizeWHScale;
}

- (CGFloat)maskAlpha {
    return _frameView.maskAlpha;
}

- (BOOL)isLockResizeFrame {
    return !self.frameView.panGR.enabled;
}

#pragma mark - init

+ (instancetype)imageresizerViewWithConfigure:(JPImageresizerConfigure *)configure
                    imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
                 imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale {
    JPImageresizerView *imageresizerView =  [[self alloc] initWithResizeImage:configure.resizeImage
                                                                    palyLayer:nil
                                                                   originSize:CGSizeZero
                                                                        frame:configure.viewFrame
                                    maskType:configure.maskType
                                   frameType:configure.frameType
                              animationCurve:configure.animationCurve
                                 strokeColor:configure.strokeColor
                                     bgColor:configure.bgColor
                                   maskAlpha:configure.maskAlpha
                               verBaseMargin:configure.verBaseMargin
                               horBaseMargin:configure.horBaseMargin
                               resizeWHScale:configure.resizeWHScale
                               contentInsets:configure.contentInsets
                   imageresizerIsCanRecovery:imageresizerIsCanRecovery
                imageresizerIsPrepareToScale:imageresizerIsPrepareToScale];
    imageresizerView.edgeLineIsEnabled = configure.edgeLineIsEnabled;
    return imageresizerView;
}



- (instancetype)initWithResizeImage:(UIView *)resizeImage
                          palyLayer:(AVPlayerLayer *)playerLayer
                         originSize:(CGSize)size
                              frame:(CGRect)frame
                           maskType:(JPImageresizerMaskType)maskType
                          frameType:(JPImageresizerFrameType)frameType
                     animationCurve:(JPAnimationCurve)animationCurve
                        strokeColor:(UIColor *)strokeColor
                            bgColor:(UIColor *)bgColor
                          maskAlpha:(CGFloat)maskAlpha
                      verBaseMargin:(CGFloat)verBaseMargin
                      horBaseMargin:(CGFloat)horBaseMargin
                      resizeWHScale:(CGFloat)resizeWHScale
                      contentInsets:(UIEdgeInsets)contentInsets
          imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
       imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale {

    if (self = [super initWithFrame:frame]) {
        _verBaseMargin = verBaseMargin;
        _horBaseMargin = horBaseMargin;
        _contentInsets = contentInsets;
        CGFloat width = (self.bounds.size.width - _contentInsets.left - _contentInsets.right);
        CGFloat height = (self.bounds.size.height - _contentInsets.top - _contentInsets.bottom);
        _contentSize = CGSizeMake(width, height);
        if (maskType == JPLightBlurMaskType) {
            self.bgColor = [UIColor whiteColor];
        } else if (maskType == JPDarkBlurMaskType) {
            self.bgColor = [UIColor blackColor];
        } else {
            self.bgColor = bgColor;
        }
        self.animationCurve = animationCurve;
        self.playerLayer = playerLayer;
        [self setupBase];
        [self setupScorllView];
        [self setupImageViewWithImage:resizeImage :size];
        [self setupFrameViewWithMaskType:maskType
                               frameType:frameType
                          animationCurve:animationCurve
                             strokeColor:strokeColor
                               maskAlpha:maskAlpha
                           resizeWHScale:resizeWHScale
                      isCanRecoveryBlock:imageresizerIsCanRecovery
                   isPrepareToScaleBlock:imageresizerIsPrepareToScale];

    }
    return self;
}



- (void)setupBase {
    self.clipsToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingNone;
    self.allDirections = [@[@(JPImageresizerVerticalUpDirection),
                            @(JPImageresizerHorizontalLeftDirection),
                            @(JPImageresizerVerticalDownDirection),
                            @(JPImageresizerHorizontalRightDirection)] mutableCopy];
}

#pragma mark - setupSubviews

- (void)setupScorllView {
    CGFloat h = _contentSize.height-200;
//    CGFloat w = h * h / _contentSize.width;
   // CGFloat x = _contentInsets.left + (self.bounds.size.width - w) * 0.5;
     CGFloat w =  _contentSize.width-40;
    CGFloat x = _contentInsets.left+20;
    CGFloat y = _contentInsets.top+20;
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(x, y, w, h);
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = MAXFLOAT;
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.autoresizingMask = UIViewAutoresizingNone;
    scrollView.clipsToBounds = NO;
    if (@available(iOS 11.0, *)) scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)setupImageViewWithImage:(UIView *)imageView :(CGSize)size {
    CGFloat width = (self.frame.size.width - _contentInsets.left - _contentInsets.right);
    CGFloat height = (self.frame.size.height - _contentInsets.top - _contentInsets.bottom);
    CGFloat maxW = width - 2 * self.horBaseMargin;
    CGFloat maxH = height - 2 * self.verBaseMargin;
    CGFloat whScale = size.width /size.height;
    CGFloat w = maxW;
    CGFloat h = w / whScale;
    if (h > maxH) {
        h = maxH;
        w = h * whScale;
    }
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    if(isnan(h)){
        h =maxH;
    }
    if(isnan(w)){
        h =maxW;
    }
 imageView.frame = CGRectMake(0, 0, w, h);
  self.playerLayer.frame = imageView.bounds;
 imageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:imageView];
    self.imageView = imageView;
    self.imageView.backgroundColor = [UIColor blackColor];
    self.isRotatedAutoScale = h > w;

    CGFloat verticalInset = (self.scrollView.bounds.size.height - h) * 0.5;
    CGFloat horizontalInset = (self.scrollView.bounds.size.width - w) * 0.5;
    self.scrollView.backgroundColor = [UIColor redColor];
    self.scrollView.contentSize = imageView.bounds.size;
   self.scrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
    self.scrollView.contentOffset = CGPointMake(-horizontalInset, -verticalInset);
}

- (void)setupFrameViewWithMaskType:(JPImageresizerMaskType)maskType
                         frameType:(JPImageresizerFrameType)frameType
                    animationCurve:(JPAnimationCurve)animationCurve
                       strokeColor:(UIColor *)strokeColor
                         maskAlpha:(CGFloat)maskAlpha
                     resizeWHScale:(CGFloat)resizeWHScale
                isCanRecoveryBlock:(JPImageresizerIsCanRecoveryBlock)isCanRecoveryBlock
             isPrepareToScaleBlock:(JPImageresizerIsPrepareToScaleBlock)isPrepareToScaleBlock {
    
    JPImageresizerFrameView *frameView =
    [[JPImageresizerFrameView alloc] initWithFrame:self.scrollView.frame
                                       contentSize:_contentSize
                                          maskType:maskType
                                         frameType:frameType
                                    animationCurve:animationCurve
                                       strokeColor:strokeColor
                                         fillColor:self.bgColor
                                         maskAlpha:maskAlpha
                                     verBaseMargin:_verBaseMargin
                                     horBaseMargin:_horBaseMargin
                                     resizeWHScale:resizeWHScale
                                        scrollView:self.scrollView
                                         imageView:self.imageView
                         imageresizerIsCanRecovery:isCanRecoveryBlock
                      imageresizerIsPrepareToScale:isPrepareToScaleBlock];
//   frameView.backgroundColor = [UIColor yellowColor];
    frameView.isRotatedAutoScale = self.isRotatedAutoScale;
    
    __weak typeof(self) wSelf = self;
    
    frameView.isVerticalityMirror = ^BOOL{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return NO;
        return sSelf.verticalityMirror;
    };
    
    frameView.isHorizontalMirror = ^BOOL{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return NO;
        return sSelf.horizontalMirror;
    };
    
    [self addSubview:frameView];
    self.frameView = frameView;
}

#pragma mark - private method

- (void)updateSubviewLayouts {
    self.directionIndex = 0;
    
    self.scrollView.layer.transform = CATransform3DIdentity;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    
    CGFloat maxW = self.frame.size.width - 2 * self.horBaseMargin;
    CGFloat maxH = self.frame.size.height - 2 * self.verBaseMargin;
    CGFloat whScale = self.imageView.size.width / self.imageView.size.height;
    CGFloat w = maxW;
    CGFloat h = w / whScale;
    if (h > maxH) {
        h = maxH;
        w = h * whScale;
    }
    self.imageView.frame = CGRectMake(0, 0, w, h);
    
    CGFloat verticalInset = (self.scrollView.bounds.size.height - h) * 0.5;
    CGFloat horizontalInset = (self.scrollView.bounds.size.width - w) * 0.5;
    
   
    self.scrollView.contentSize = self.imageView.bounds.size;
    self.scrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
    self.scrollView.contentOffset = CGPointMake(-horizontalInset, -verticalInset);
    
    [self.frameView updateImageresizerFrameWithVerBaseMargin:_verBaseMargin horBaseMargin:_horBaseMargin];
}

#pragma mark - puild method

- (void)setVerticalityMirror:(BOOL)verticalityMirror animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPLog(@"裁剪区域预备缩放至适合位置，镜像功能暂不可用，此时应该将镜像按钮设为不可点或隐藏");
        return;
    }
    if (_verticalityMirror == verticalityMirror) return;
    _verticalityMirror = verticalityMirror;
    [self setMirror:NO animated:isAnimated];
}

- (void)setHorizontalMirror:(BOOL)horizontalMirror animated:(BOOL)isAnimated {
    if (self.frameView.isPrepareToScale) {
        JPLog(@"裁剪区域预备缩放至适合位置，镜像功能暂不可用，此时应该将镜像按钮设为不可点或隐藏");
        return;
    }
    if (_horizontalMirror == horizontalMirror) return;
    _horizontalMirror = horizontalMirror;
    [self setMirror:YES animated:isAnimated];
}

- (void)setMirror:(BOOL)isHorizontalMirror animated:(BOOL)isAnimated {
    CATransform3D transform = self.layer.transform;
    BOOL mirror;
    if (isHorizontalMirror) {
        transform = CATransform3DRotate(transform, M_PI, 1, 0, 0);
        mirror = _horizontalMirror;
    } else {
        transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
        mirror = _verticalityMirror;
    }
    
    [self.frameView willMirror:isAnimated];
    
    __weak typeof(self) wSelf = self;
    void (^animateBlock)(CATransform3D aTransform) = ^(CATransform3D aTransform){
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        sSelf.layer.transform = aTransform;
        if (isHorizontalMirror) {
            [sSelf.frameView horizontalMirrorWithDiffY:(mirror ? sSelf->_contentInsets.bottom : sSelf->_contentInsets.top)];
        } else {
            [sSelf.frameView verticalityMirrorWithDiffX:(mirror ? sSelf->_contentInsets.right : sSelf->_contentInsets.left)];
        }
    };
    
    if (isAnimated) {
        // 做3d旋转时会遮盖住上层的控件，设置为-400即可
        self.layer.zPosition = -400;
        transform.m34 = 1.0 / 1500.0;
        if (isHorizontalMirror) {
            transform.m34 *= -1.0;
        }
        if (mirror) {
            transform.m34 *= -1.0;
        }
        [UIView animateWithDuration:0.45 delay:0 options:_animationOption animations:^{
            animateBlock(transform);
        } completion:^(BOOL finished) {
            self.layer.zPosition = 0;
            [self.frameView mirrorDone];
        }];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        animateBlock(transform);
        [CATransaction commit];
        [self.frameView mirrorDone];
    }
}

- (void)updateResizeImage:(UIImage *)resizeImage verBaseMargin:(CGFloat)verBaseMargin horBaseMargin:(CGFloat)horBaseMargin {
   self.imageView.image = resizeImage;
    _verBaseMargin = verBaseMargin;
    _horBaseMargin = horBaseMargin;
    [self updateSubviewLayouts];
}

- (void)rotation {
    if (self.frameView.isPrepareToScale) {
        JPLog(@"裁剪区域预备缩放至适合位置，旋转功能暂不可用，此时应该将旋转按钮设为不可点或隐藏");
        return;
    }
    
    self.directionIndex += 1;
    if (self.directionIndex > self.allDirections.count - 1) self.directionIndex = 0;
    
    JPImageresizerRotationDirection direction = [self.allDirections[self.directionIndex] integerValue];
    
    CGFloat scale = 1;
    if (self.isRotatedAutoScale) {
        if (direction == JPImageresizerHorizontalLeftDirection ||
            direction == JPImageresizerHorizontalRightDirection) {
            scale = self.frame.size.width / self.scrollView.bounds.size.height;
        } else {
            scale = self.scrollView.bounds.size.height / self.frame.size.width;
        }
    }
    
    CGFloat angle = (self.isClockwiseRotation ? 1.0 : -1.0) * M_PI * 0.5;
    switch (self.directionIndex ) {
        case 1:
            if(self.getRotationAngal){
                self.getRotationAngal(90);
            }
            break;
            case 2:
            if(self.getRotationAngal){
                self.getRotationAngal(180);
            }
            break;
        case 3:
            if(self.getRotationAngal){
                self.getRotationAngal(270);
            }
            break;
        default:
            if(self.getRotationAngal){
                self.getRotationAngal(360);
            }
            break;
    }
    
    //    BOOL isNormal = (_verticalityMirror && _horizontalMirror) || (!_verticalityMirror && !_horizontalMirror);
    //    if (!isNormal) {
    //        angle *= -1.0;
    //    }

    CATransform3D svTransform = self.scrollView.layer.transform;
    svTransform = CATransform3DScale(svTransform, scale, scale, 1);
    svTransform = CATransform3DRotate(svTransform, angle, 0, 0, 1);
    
    CATransform3D fvTransform = self.frameView.layer.transform;
    fvTransform = CATransform3DScale(fvTransform, scale, scale, 1);
    fvTransform = CATransform3DRotate(fvTransform, angle, 0, 0, 1);
    
    NSTimeInterval duration = 0.23;
    [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
        self.scrollView.layer.transform = svTransform;
        self.frameView.layer.transform = fvTransform;
        [self.frameView rotationWithDirection:direction rotationDuration:duration];
    } completion:nil];
}

- (void)recovery {
    if (!self.frameView.isCanRecovery) {
        JPLog(@"已经是初始状态，不需要重置");
        return;
    }
    
    [self.frameView willRecovery];
    
    self.directionIndex = 0;
    
    _horizontalMirror = NO;
    _verticalityMirror = NO;
    
    CGFloat x = (_contentSize.width - self.scrollView.bounds.size.width) * 0.5 + _contentInsets.left;
    CGFloat y = (_contentSize.height - self.scrollView.bounds.size.height) * 0.5 + _contentInsets.top;
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = x;
    frame.origin.y = y;
    
    // 做3d旋转时会遮盖住上层的控件，设置为-400即可
    self.layer.zPosition = -400;
    NSTimeInterval duration = 0.45;
    [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
        
        self.layer.transform = CATransform3DIdentity;
        self.scrollView.layer.transform = CATransform3DIdentity;
        self.frameView.layer.transform = CATransform3DIdentity;
        
        self.scrollView.frame = frame;
        self.frameView.frame = frame;
        
        [self.frameView recoveryWithDuration:duration];
        
    } completion:^(BOOL finished) {
        [self.frameView recoveryDone];
        self.layer.zPosition = 0;
    }];
}


- (void)originImageresizerWithComplete:(void (^)(UIImage *))complete {
    [self imageresizerWithComplete:complete isOriginImageSize:YES referenceWidth:0];
}

- (void)imageresizerWithComplete:(void (^)(UIImage *))complete referenceWidth:(CGFloat)referenceWidth {
    [self imageresizerWithComplete:complete isOriginImageSize:NO referenceWidth:referenceWidth];
}

- (void)imageresizerWithComplete:(void (^)(UIImage *))complete {
    [self imageresizerWithComplete:complete isOriginImageSize:NO referenceWidth:0];
}

- (void)imageresizerWithComplete:(void (^)(UIImage *))complete isOriginImageSize:(BOOL)isOriginImageSize referenceWidth:(CGFloat)referenceWidth {
    if (self.frameView.isPrepareToScale) {
        JPLog(@"裁剪区域预备缩放至适合位置，裁剪功能暂不可用，此时应该将裁剪按钮设为不可点或隐藏");
        !complete ? : complete(nil);
        return;
    }
   [self.frameView imageresizerWithComplete:complete isOriginImageSize:isOriginImageSize referenceWidth:referenceWidth];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.frameView startImageresizer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.frameView endedImageresizer];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [self.frameView startImageresizer];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self.frameView endedImageresizer];
}

@end
