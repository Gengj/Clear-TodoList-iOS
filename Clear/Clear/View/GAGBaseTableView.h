//
//  GAGBaseTableView.h
//  Clear
//
//  Created by GMax on 2018/12/22.
//  Copyright © 2018 GAG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAGStrikethroughTextField.h"
#import "GAGTableViewCell.h"

#import "GAGItem.h"
#import "GAGItems.h"
#import "GAGFileOperation.h"

NS_ASSUME_NONNULL_BEGIN
@protocol GAGTableViewDelegate <NSObject>

@optional
- (void)tableViewDidBeginEditing;
- (void)tableViewDidEndEditing;

@end
@interface GAGBaseTableView : UITableView

@property (nonatomic,assign) BOOL coverViewHidden;

@property (nonatomic,strong) GAGItems* items;

@property (nonatomic,weak) id<GAGTableViewDelegate> tableViewDelegate;
@end

NS_ASSUME_NONNULL_END
