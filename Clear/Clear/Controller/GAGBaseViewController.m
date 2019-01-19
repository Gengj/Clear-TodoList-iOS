//
//  GAGBaseViewController.m
//  Clear
//
//  Created by GMax on 2018/12/19.
//  Copyright © 2018 GAG. All rights reserved.
//

#import "GAGBaseViewController.h"

@interface GAGBaseViewController () <GAGTableViewDelegate>

/**
 tableView
 */
@property (nonatomic,strong) GAGBaseTableView *tableView;

/**
 顶部标题栏 header label like UINavigationBar for show theme of items
 */
@property (nonatomic,strong) GAGHeaderLabel *headerLabel;

@end

@implementation GAGBaseViewController

#pragma mark - cycle of views
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildTableView];
    
    [self buildHeaderLabel];
    
    [self.tableView reloadData];
}

/**
 构建GAGBaseTableView build GAGBaseTableView
 */
- (void)buildTableView {
    self.tableView = [[GAGBaseTableView alloc]init];
    [self.view addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);

    self.tableView.items = self.items;
    self.tableView.tableViewDelegate = self;
}


/**
 构建顶部标题栏 build HeaderLabel
 */
- (void)buildHeaderLabel {
    self.headerLabel = [[GAGHeaderLabel alloc]init];
    [self.view addSubview:self.headerLabel];
    
    //顶部标题栏高度 = StatusbarHeight + HeaderLabelHeight
    //height of HeaderLabel = StatusbarHeight + HeaderLabelHeight
    self.headerLabel.frame = CGRectMake(0, 0, ScreenWidth, StatusbarHeight + HeaderLabelHeight);
    self.headerLabel.text = self.items.theme;
}


/**
 状态栏为暗夜模式 set UIStatusBarStyle = UIStatusBarStyleLightContent
 */
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - lazy loading
- (GAGItems *)items {
    if (_items == nil) {
        _items = [[GAGFileOperation shareOperation]read:@"ios learn.plist"];
       
        //可以使用items的重置方法进行调试
        //using resetItems for debug
        [_items resetItems];
        [[GAGFileOperation shareOperation]save:self.items];
    }
    return _items;
}

#pragma mark - GAGTableViewDelegate

/**
 当cell开始编辑或取消编辑时，改变标题栏透明度
 change alpha of headerLabel when cell begin or end editing
 */
- (void)tableViewDidBeginEditing {
     self.headerLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}

- (void)tableViewDidEndEditing {
    self.headerLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:HeaderLabelAlpha];
}

@end
