//
//  GAGBaseViewController.m
//  Clear
//
//  Created by GMax on 2018/12/19.
//  Copyright © 2018 GAG. All rights reserved.
//

#import "GAGBaseViewController.h"

#import "UIView+Frame.h"

#import "GAGHeaderLabel.h"
#import "GAGTableViewCell.h"
#import "GAGStrikethroughTextField.h"
#import "GAGBaseTableView.h"

#define HeaderLabelHeight 20
#define StatusbarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define TableViewCellHeight 60
#define HeaderLabelAlpha 0.7

@interface GAGBaseViewController () <GAGTableViewDelegate>

/**
 tableView
 */
@property (nonatomic,strong) GAGBaseTableView *tableView;

/**
 header label for theme
 */
@property (nonatomic,strong) GAGHeaderLabel *headerLabel;

@property (nonatomic,strong) GAGItems *items;



@end

@implementation GAGBaseViewController

#pragma mark - cycle of views
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildTableView];
    
    [self buildHeaderLabel];
}

- (void)buildTableView {
    
    self.tableView = [[GAGBaseTableView alloc]init];
    [self.view addSubview:self.tableView];
    
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.height);

    self.tableView.items = self.items;
    self.tableView.tableViewDelegate = self;
}

- (void)buildHeaderLabel {
    self.headerLabel = [[GAGHeaderLabel alloc]init];
    [self.view addSubview:self.headerLabel];
    
    self.headerLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, StatusbarHeight + HeaderLabelHeight);
    self.headerLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:HeaderLabelAlpha];
    self.headerLabel.textColor = [UIColor whiteColor];
    self.headerLabel.font = [UIFont systemFontOfSize:15];
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.text = self.items.theme;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - lazy load

- (GAGItems *)items {
    
    if (_items == nil) {
        _items = [[GAGFileOperation shareOperation]read:@"ios learn.plist"];
        [_items resetItems];
        [[GAGFileOperation shareOperation]save:_items];
    }
    return _items;
}

#pragma mark - GAGTableViewDelegate

- (void)tableViewDidBeginEditing {
     self.headerLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}

- (void)tableViewDidEndEditing {
    self.headerLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:HeaderLabelAlpha];
}

@end
