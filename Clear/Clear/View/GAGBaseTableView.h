//
//  GAGBaseTableView.h
//  Clear
//
//  Created by GMax on 2018/12/22.
//  Copyright © 2018 GAG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAGTableViewCell.h"
#import "GAGFileOperation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 GAGTableViewDelegate
 */
@protocol GAGTableViewDelegate <NSObject>

@optional
- (void)tableViewDidBeginEditing;

- (void)tableViewDidEndEditing;

@end

@interface GAGBaseTableView : UITableView

/**
 model
 */
@property (nonatomic,strong) GAGItems* items;


/**
 tableViewDelegate
 */
@property (nonatomic,weak) id<GAGTableViewDelegate> tableViewDelegate;

@end

NS_ASSUME_NONNULL_END
