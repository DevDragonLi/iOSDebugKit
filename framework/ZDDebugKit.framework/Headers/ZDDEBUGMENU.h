//
//  ZDFloatingBall.h
//  ZDFloatingBall
//
//  Created by DragonLi on 2020/07/17
//  Copyright © 2020年 . All rights reserved.
//  悬浮球


#import <UIKit/UIKit.h>
#import "ZDDebugKitProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ZDDEBUGMENU

@interface ZDDEBUGMENU : NSObject

/// Debug 菜单悬浮中心
/// @param title 浮球标题
/// @param autoCloseEdge 是否自动靠边
/// @param serviceClass : 协议实现的Class 类
+ (void)showDebugMenuWithServiceClass:(Class <ZDDebugKitProtocol>_Nonnull)serviceClass
                                Title:(NSString  * _Nullable )title
                        autoCloseEdge:(BOOL)autoCloseEdge;

+ (Class <ZDDebugKitProtocol> _Nonnull )debugProtocolServiceClass;

@end

NS_ASSUME_NONNULL_END

