//
//  ZDFloatingBall.h
//  ZDFloatingBall
//
//  Created by DragonLi on 2020/07/17
//  Copyright © 2020年 . All rights reserved.
//  悬浮球

#import "ZDBusinessDebugMenuItemVC.h"
/**< 靠边策略(默认所有边框均可停靠) */
typedef NS_ENUM(NSUInteger, ZDFloatingBallEdgePolicy) {
    ZDFloatingBallEdgePolicyAllEdge = 0,    /**< 所有边框都可
                                             (符合正常使用习惯，滑到某一位置时候才上下停靠，参见系统的 assistiveTouch) */
    ZDFloatingBallEdgePolicyLeftRight,      /**< 只能左右停靠 */
    ZDFloatingBallEdgePolicyUpDown,         /**< 只能上下停靠 */
};

typedef struct ZDEdgeRetractConfig {
    CGPoint edgeRetractOffset; /**< 缩进结果偏移量 */
    CGFloat edgeRetractAlpha;  /**< 缩进后的透明度 */
} ZDEdgeRetractConfig;

UIKIT_STATIC_INLINE ZDEdgeRetractConfig ZDEdgeOffsetConfigMake(CGPoint edgeRetractOffset, CGFloat edgeRetractAlpha) {
    ZDEdgeRetractConfig config = {edgeRetractOffset, edgeRetractAlpha};
    return config;
}

#pragma mark - ZDFloatingBall


@class ZDFloatingBall;

@interface ZDFloatingBall : UIView

+ (void)displayWithTitle:(NSString *)title
           autoCloseEdge:(BOOL)autoCloseEdge;
- (void)show;

- (void)hide;

@end

#import "ZDDEBUGMENU.h"
#include <objc/runtime.h>

#pragma mark - ZDFloatingBallWindow

@interface ZDFloatingBallWindow : UIWindow

@end

@implementation ZDFloatingBallWindow

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    __block ZDFloatingBall *floatingBall = nil;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ZDFloatingBall class]]) {
            floatingBall = (ZDFloatingBall *)obj;
            *stop = YES;
        }
    }];
    
    if (CGRectContainsPoint(floatingBall.bounds,
                            [floatingBall convertPoint:point fromView:self])) {
        return [super pointInside:point withEvent:event];
    }
    
    return NO;
}

@end

@interface ZDDEBUGMENU ()

@property (nonatomic,assign) BOOL canRuntime;

@property (nonatomic,weak) UIView * superView;

@property (nonatomic,copy) void (^clickBlock)(void);

@property (nonatomic,copy) NSString * serviceClassString;

+ (instancetype)shareManager;

@end


@implementation ZDDEBUGMENU

+ (void)showDebugMenuWithServiceClass:(Class <ZDDebugKitProtocol>_Nonnull)serviceClass
                                Title:(NSString  * _Nullable )title
                        autoCloseEdge:(BOOL)autoCloseEdge {
    if (serviceClass) {
        [ZDDEBUGMENU shareManager].serviceClassString = NSStringFromClass([serviceClass class]);
    } else {
        [NSException exceptionWithName:@"ZDDeBugKitServiceClassString" reason:@"为传入有效的参数" userInfo:nil];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [ZDFloatingBall displayWithTitle:title autoCloseEdge:autoCloseEdge];
    });
    
}

+ (Class <ZDDebugKitProtocol> _Nonnull )debugProtocolServiceClass {
    Class <ZDDebugKitProtocol> serviceClass = NSClassFromString([ZDDEBUGMENU shareManager].serviceClassString);
    return serviceClass;
}

+ (instancetype)shareManager {
    static ZDDEBUGMENU *ballMgr = nil;
    NSRecursiveLock *lock = [[NSRecursiveLock alloc]init];
    [lock lock];
    if (!ballMgr) {
        ballMgr = [[ZDDEBUGMENU alloc] init];
    }
    [lock unlock];
    return ballMgr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.canRuntime = NO;
    }
    return self;
}

@end

#pragma mark - UIView (ZDAddSubview)

@interface UIView (ZDAddSubview)

@end

@implementation UIView (ZDAddSubview)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(addSubview:)), class_getInstanceMethod(self, @selector(ZD_addSubview:)));
    });
}

- (void)ZD_addSubview:(UIView *)subview {
    [self ZD_addSubview:subview];
    
    if ([ZDDEBUGMENU shareManager].canRuntime) {
        if ([[ZDDEBUGMENU shareManager].superView isEqual:self]) {
            [self.subviews enumerateObjectsUsingBlock:^(UIView * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[ZDFloatingBall class]]) {
                    [self insertSubview:subview belowSubview:(ZDFloatingBall *)obj];
                }
            }];
        }
    }
}

@end

@interface ZDFloatingBall()
/**
 是否自动靠边
 */
@property (nonatomic, assign, getter=isAutoCloseEdge) BOOL autoCloseEdge;

/**
 靠边策略
 */
@property (nonatomic, assign) ZDFloatingBallEdgePolicy edgePolicy;

@property (nonatomic, assign) CGPoint centerOffset;

@property (nonatomic,   copy) ZDEdgeRetractConfig(^edgeRetractConfigHander)(void);

@property (nonatomic, assign) NSTimeInterval autoEdgeOffsetDuration;

@property (nonatomic, assign, getter=isAutoEdgeRetract) BOOL autoEdgeRetract;

@property (nonatomic, strong) UIView *parentView;

@property (nonatomic, strong) UILabel *ballLabel;

@property (nonatomic, assign) UIEdgeInsets effectiveEdgeInsets;



@end

static const NSInteger minUpDownLimits = 60 * 1.5f;   // ZDFloatingBallEdgePolicyAllEdge 下，悬浮球到达一个界限开始自动靠近上下边缘

@implementation ZDFloatingBall

#pragma mark - Life Cycle

- (void)dealloc {
    [ZDDEBUGMENU shareManager].canRuntime = NO;
    [ZDDEBUGMENU shareManager].superView = nil;
}

+ (void)displayWithTitle:(NSString *)title
           autoCloseEdge:(BOOL)autoCloseEdge {
    ZDFloatingBall *ball = [[ZDFloatingBall alloc] initWithFrame:CGRectMake(10, 250, 100, 50)];
    if (title) {
        ball.ballLabel.text = title;
    } else {
        ball.ballLabel.text = @"Debug 中心";
    }
    ball.autoCloseEdge = autoCloseEdge;
    [ball show];
}


- (instancetype)initWithFrame:(CGRect)frame {
    ZDFloatingBall *ball = [self initWithFrame:frame inSpecifiedView:nil effectiveEdgeInsets:UIEdgeInsetsZero];
    return ball;
}

- (instancetype)initWithFrame:(CGRect)frame inSpecifiedView:(UIView *)specifiedView {
    return [self initWithFrame:frame inSpecifiedView:specifiedView effectiveEdgeInsets:UIEdgeInsetsZero];
}

- (instancetype)initWithFrame:(CGRect)frame inSpecifiedView:(UIView *)specifiedView effectiveEdgeInsets:(UIEdgeInsets)effectiveEdgeInsets {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _autoCloseEdge = NO;
        _autoEdgeRetract = NO;
        _edgePolicy = ZDFloatingBallEdgePolicyAllEdge;
        _effectiveEdgeInsets = effectiveEdgeInsets;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
        
        [self addGestureRecognizer:tapGesture];
        [self addGestureRecognizer:panGesture];
        [self configSpecifiedView:specifiedView];
    }
    return self;
}

- (void)configSpecifiedView:(UIView *)specifiedView {
    if (specifiedView) {
        _parentView = specifiedView;
    }
    else {
        ZDFloatingBallWindow *window = [[ZDFloatingBallWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.windowLevel = CGFLOAT_MAX; //UIWindowLevelStatusBar - 1;
        window.rootViewController = [UIViewController new];
        window.rootViewController.view.backgroundColor = [UIColor clearColor];
        window.rootViewController.view.userInteractionEnabled = NO;
        [window makeKeyAndVisible];
        
        _parentView = window;
    }
    
    _parentView.hidden = YES;
    _centerOffset = CGPointMake(_parentView.bounds.size.width * 0.6, _parentView.bounds.size.height * 0.6);
    
    // setup ball manager
    [ZDDEBUGMENU shareManager].canRuntime = YES;
    [ZDDEBUGMENU shareManager].superView = specifiedView;
}

#pragma mark - Private Methods

// 靠边
- (void)autoCloseEdge {
    [UIView animateWithDuration:0.5f animations:^{
        // center
        self.center = [self calculatePoisitionWithEndOffset:CGPointZero];//center;
    } completion:^(BOOL finished) {
        // 靠边之后自动缩进边缘处
        if (self.isAutoEdgeRetract) {
            [self performSelector:@selector(autoEdgeOffset) withObject:nil afterDelay:self.autoEdgeOffsetDuration];
        }
    }];
}

- (void)autoEdgeOffset {
    ZDEdgeRetractConfig config = self.edgeRetractConfigHander ? self.edgeRetractConfigHander() : ZDEdgeOffsetConfigMake(CGPointMake(self.bounds.size.width * 0.3, self.bounds.size.height * 0.3), 0.8);
    
    [UIView animateWithDuration:0.5f animations:^{
        self.center = [self calculatePoisitionWithEndOffset:config.edgeRetractOffset];
        self.alpha = config.edgeRetractAlpha;
    }];
}

- (CGPoint)calculatePoisitionWithEndOffset:(CGPoint)offset {
    CGFloat ballHalfW   = self.bounds.size.width * 0.5;
    CGFloat ballHalfH   = self.bounds.size.height * 0.5;
    CGFloat parentViewW = self.parentView.bounds.size.width;
    CGFloat parentViewH = self.parentView.bounds.size.height;
    CGPoint center = self.center;
    
    if (ZDFloatingBallEdgePolicyLeftRight == self.edgePolicy) {
        // 左右
        center.x = (center.x < self.parentView.bounds.size.width * 0.5) ? (ballHalfW - offset.x + self.effectiveEdgeInsets.left) : (parentViewW + offset.x - ballHalfW + self.effectiveEdgeInsets.right);
    }
    else if (ZDFloatingBallEdgePolicyUpDown == self.edgePolicy) {
        center.y = (center.y < self.parentView.bounds.size.height * 0.5) ? (ballHalfH - offset.y + self.effectiveEdgeInsets.top) : (parentViewH + offset.y - ballHalfH + self.effectiveEdgeInsets.bottom);
    }
    else if (ZDFloatingBallEdgePolicyAllEdge == self.edgePolicy) {
        if (center.y < minUpDownLimits) {
            center.y = ballHalfH - offset.y + self.effectiveEdgeInsets.top;
        }
        else if (center.y > parentViewH - minUpDownLimits) {
            center.y = parentViewH + offset.y - ballHalfH + self.effectiveEdgeInsets.bottom;
        }
        else {
            center.x = (center.x < self.parentView.bounds.size.width  * 0.5) ? (ballHalfW - offset.x + self.effectiveEdgeInsets.left) : (parentViewW + offset.x - ballHalfW + self.effectiveEdgeInsets.right);
        }
    }
    return center;
}

#pragma mark - Public Methods

- (void)show {
    self.parentView.hidden = NO;
    [self.parentView addSubview:self];
}

- (void)hide {
    self.parentView.hidden = YES;
    [self removeFromSuperview];
}

/**
 当悬浮球靠近边缘的时候，自动像边缘缩进一段间距 (只有 autoCloseEdge 为YES时候才会生效)
 
 @param duration 缩进间隔
 @param edgeRetractConfigHander 缩进后参数的配置(如果为 NULL，则使用默认的配置)
 */
- (void)autoEdgeRetractDuration:(NSTimeInterval)duration edgeRetractConfigHander:(ZDEdgeRetractConfig (^)(void))edgeRetractConfigHander {
    if (self.isAutoCloseEdge) {
        // 只有自动靠近边缘的时候才生效
        self.edgeRetractConfigHander = edgeRetractConfigHander;
        self.autoEdgeOffsetDuration = duration;
        self.autoEdgeRetract = YES;
    }
}

#pragma mark - GestureRecognizer

// 手势处理
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGesture {
    if (UIGestureRecognizerStateBegan == panGesture.state) {
        [self setAlpha:1.0f];
        
        // cancel
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoEdgeOffset) object:nil];
    }
    else if (UIGestureRecognizerStateChanged == panGesture.state) {
        CGPoint translation = [panGesture translationInView:self];
        
        CGPoint center = self.center;
        center.x += translation.x;
        center.y += translation.y;
        self.center = center;
        
        CGFloat   leftMinX = 0.0f + self.effectiveEdgeInsets.left;
        CGFloat    topMinY = 0.0f + self.effectiveEdgeInsets.top;
        CGFloat  rightMaxX = self.parentView.bounds.size.width - self.bounds.size.width + self.effectiveEdgeInsets.right;
        CGFloat bottomMaxY = self.parentView.bounds.size.height - self.bounds.size.height + self.effectiveEdgeInsets.bottom;
        
        CGRect frame = self.frame;
        frame.origin.x = frame.origin.x > rightMaxX ? rightMaxX : frame.origin.x;
        frame.origin.x = frame.origin.x < leftMinX ? leftMinX : frame.origin.x;
        frame.origin.y = frame.origin.y > bottomMaxY ? bottomMaxY : frame.origin.y;
        frame.origin.y = frame.origin.y < topMinY ? topMinY : frame.origin.y;
        self.frame = frame;
        
        // zero
        [panGesture setTranslation:CGPointZero inView:self];
    }
    else if (UIGestureRecognizerStateEnded == panGesture.state) {
        if (self.isAutoCloseEdge) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 0.2s 之后靠边
                [self autoCloseEdge];
            });
        }
    }
}

- (void)tapGestureRecognizer:(UIPanGestureRecognizer *)tapGesture {
    ZDBusinessDebugMenuItemVC *vc = [ZDBusinessDebugMenuItemVC new];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:^{
    }];
    if ([ZDDEBUGMENU shareManager].clickBlock) {
        [ZDDEBUGMENU shareManager].clickBlock();
    }
}

#pragma mark - Setter / Getter

- (void)setAutoCloseEdge:(BOOL)autoCloseEdge {
    _autoCloseEdge = autoCloseEdge;
    
    if (autoCloseEdge) {
        [self autoCloseEdge];
    }
}

- (UILabel *)ballLabel {
    if (!_ballLabel) {
        _ballLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _ballLabel.textAlignment = NSTextAlignmentCenter;
        _ballLabel.numberOfLines = 1.0f;
        _ballLabel.minimumScaleFactor = 0.0f;
        _ballLabel.adjustsFontSizeToFitWidth = YES;
        _ballLabel.textColor = [UIColor greenColor];
        _ballLabel.backgroundColor = [UIColor grayColor];
        _ballLabel.layer.masksToBounds = YES;
        _ballLabel.layer.cornerRadius = 10.0f;
        _ballLabel.font = [UIFont boldSystemFontOfSize:20];
        _ballLabel.numberOfLines = 2;
        [self addSubview:_ballLabel];
    }
    return _ballLabel;
}

@end

