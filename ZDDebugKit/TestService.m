//
//  TestService.m
//  ZDDebugKit
//
//  Created by DragonLi on 11/8/2020.
//  Copyright © 2020 zd. All rights reserved.
//

#import <ZDDebugKit/ZDDebugKit.h>

#import <UIKit/NSIndexPath+UIKitAdditions.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestService : NSObject <ZDDebugKitProtocol>

@end

NS_ASSUME_NONNULL_END

@implementation TestService


/// 建议APP入口服务类提供接口，初始化菜单组件
+ (void)load {
    
    [ZDDEBUGMENU showDebugMenuWithServiceClass:self Title:@"Debug菜单中心" autoCloseEdge:YES];
}

+ (NSArray <NSString *>*)operationItems {
    
   return [NSArray arrayWithObjects:
    @"🤡 点击即可切换：展示或隐藏（FLEX工具)",
    @"🤠 一键删除本地所有笔记文件(⚠️会强制退出APP)",
    @"😎 一键删除远端所有笔记 ",
    @"👽 一键删除所有笔记文件（本地和远端 ⚠️会强制退出APP)",
    nil];
}

/// 事件派分 接收处理
+ (void)debugActionWithIndexPath:(nonnull NSIndexPath *)indexPath completeDissBlock:(nonnull void (^)(void))completeDissBlock {
    NSLog(@"%ld",(long)indexPath.row);
    if (completeDissBlock) {
        
        completeDissBlock();
    }
}
/// 执行一些操作，必须杀死APP的，可以执行完行为后，调用次函数
+ (void)forceKillAPP {
    _exit(0);
}



@end
