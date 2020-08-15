//
//  ZDBusiness DebugVC.m
//  ZDFloatingDebugKit
//
//  Created by DragonLi on 17/7/2020.
//

#import "ZDBusinessDebugMenuItemVC.h"
#import "ZDDEBUGMENU.h"
#import "ZDDebugKitProtocol.h"

static NSString *_Nonnull const ZDBusinessDebugCellReuseIdentifier = @"ZDBusinessDebugCellReuseIdentifier";

@interface ZDBusinessDebugMenuItemVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray *operationItems;

@end

@implementation ZDBusinessDebugMenuItemVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.operationItems = [[ZDDEBUGMENU debugProtocolServiceClass] operationItems];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self tipInfoLabelConfig];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableView.bounces = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ZDBusinessDebugCellReuseIdentifier];
    [self.tableView reloadData];
}

- (void)tipInfoLabelConfig {
    CGFloat labelHeight = 60;
    UILabel *tipInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 350, labelHeight)];
    tipInfoLabel.text = @"温馨提示：真机下滑界面即可隐藏菜单界面(模拟器点此消失)";
    tipInfoLabel.textAlignment = NSTextAlignmentCenter;
    tipInfoLabel.textColor = [UIColor blueColor];
    tipInfoLabel.backgroundColor = [UIColor greenColor];
    tipInfoLabel.font = [UIFont boldSystemFontOfSize:18];
    tipInfoLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissViewControllerAnimated)];
    [tipInfoLabel addGestureRecognizer:tapGestureRecognizer];
    self.tableView.tableHeaderView = tipInfoLabel;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.operationItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ZDBusinessDebugCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.operationItems[indexPath.row];
    cell.backgroundColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor greenColor];
    return cell;
}

#pragma mark --- DEBUG Action Handles

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[ZDDEBUGMENU debugProtocolServiceClass] debugActionWithIndexPath:indexPath completeDissBlock:^{
        [self dismissViewControllerAnimated];
    }];
}

- (void)dismissViewControllerAnimated {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
