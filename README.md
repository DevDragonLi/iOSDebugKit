# ZDDebugKit

> iOS项目Debug调试辅助悬浮球组件

> 务必按照下文的 `Installation` 建议引入项目，不建议引入线上环境。
 
### 组件的通用性设计

> **完全解耦**，菜单和点击行为为宿主工程处理，组件底层只提供响应事件和一级菜单展示的界面维护。

- **一级主菜单**为宿主工程完全自定义并列表展示

	- 工程不同业务方向，拆分不同item可选菜单（账户，视频，分享等）

	- 遵守菜单协议即可自动集成`一级主菜单`
		- 可参考Demo或者下文的`Exapmle`部分

- **一级一级菜单满足不了项目需求怎么办**？
	- 如果项目需要更多的开关或者其他更多菜单，可以在对应ServiceClass的事件派发处理中实现项目需要的视图及事件处理即可。
	- **一级菜单对应项目业务层划分，二级菜单为一级菜单的不同入口**

- **宿主工程的协议实现类细节**
	- 主实现类为一个即可，负责一级菜单及一级实现派分，不建议都写一个类，可采取分类，或者单独为一个桥接组件。
	- 如果项目实现组件化，可中间件解耦派分，实现debug功能业务各有归属。

### 致力于解决的场景

> 业务辅助工具，为QA测试/RD方便调试节省时间，及快捷入口等,多版本迭代后，有些debug功能可以PM评估OK后，引入线上版本。

- 项目的多语言支持
	- 如果去设备设置语言切换，来回较为麻烦，QA测试，只需要关注与APP内文案正确展示，并不关注是否真正真的当前系统为中文，可提供一键切换功能。

- APP引导页
	- 属于非首次安装不再出现，端上可以重置状态，而不需要再次安装（重新安装并无必要）。

- 对于APP本地/远端笔记无法`一键删除`
	- 如果需要测试远端笔记首次安装加载过程，则必须卸载APP，再重新安装，如果端上通过DEBUG Menu 提供，则很快速的处理。

- more 

## Installation

ZDDebugKit is available through CocoaPods To install
it, simply add the following line to your Podfile:

```ruby
// 默认二进制集成
pod 'ZDDebugKit','~>1.0.0',:configurations => ['Debug']

// 源码方式集成 
pod 'ZDDebugKit/source','~>1.0.0',:configurations => ['Debug']

```

## Example 

To run the example project, clone the repo, and run `pod install` from the Example directory first.

- 初始化悬浮球

- 实现扩展菜单协议

```

#ifdef DEBUGMENU

#import <ZDDebugKit/ZDDebugKit.h>

@interface TestService : NSObject <ZDDebugKitProtocol>

@end

NS_ASSUME_NONNULL_END

@implementation TestService

/// 也可以AppDelegate入口设置
/// Title 参数应该为小写，属于已知✍️问题，暂不调整
+ (void)load {
     [ZDDEBUGMENU showDebugMenuWithServiceClass:self Title:@"Debug菜单中心" autoCloseEdge:YES];   
}

+ (NSArray <NSString *>*)operationItems {
    
   return [NSArray arrayWithObjects:
    @"🤡 点击即可切换：展示或隐藏（FLEX工具)",
    @"🤠 一键删除本地所有笔记文件(⚠️会强制退出APP)",
    @"😎 一键删除远端所有笔记 ",
    @"👽 一键删除所有笔记文件（本地和远端 ⚠️会强制退出APP)",
    @"😁 一键切换APP中英文（立即生效）",
    nil];
}

/// 事件派分 接收处理
+ (void)debugActionWithIndexPath:(NSIndexPath *)indexPath
                   completeDissBlock:(void (^)(void))completeDissBlock {
        NSInteger selectRow = indexPath.row;
    // 对应不同下标，处理对应菜单事件即可
    	// 扩展业务，也为此处扩展
}
#endif


```

## Author

DevdragonLi, DragonLi_52171@163.com

## License

ZDDebugKit is available under the MIT license. See the LICENSE file for more info.
