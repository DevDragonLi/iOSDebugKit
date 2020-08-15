//
//  ZDDebugKitProtocol.h
//  ZDDebugKit
//
//  Created by DragonLi on 11/8/2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Debug 菜单展示，需要实现的协议
@protocol ZDDebugKitProtocol <NSObject>

/// debug 列表一级菜单文本信息
+ (NSArray <NSString *>*)operationItems;
/// 事件分发
/// NOTE：如果操作完毕后需要消失，可以实现此block即可，否则传nil即可。
+ (void)debugActionWithIndexPath:(NSIndexPath *)indexPath
               completeDissBlock:(void (^)(void))completeDissBlock;

@end

NS_ASSUME_NONNULL_END
