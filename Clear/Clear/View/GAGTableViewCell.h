//
//  GAGTableViewCell.h
//  Clear
//
//  Created by GMax on 2018/12/19.
//  Copyright © 2018 GAG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAGStrikethroughTextField.h"
#import "GAGItem.h"
#import "GAGItems.h"
#import "UIView+Frame.h"

@class GAGTableViewCell;
NS_ASSUME_NONNULL_BEGIN

/**
 GAGTableViewCellDelegate
 */
@protocol GAGTableViewCellDelegate <NSObject>
@optional
/**
 when cell should been deleted

 @param item model
 */
- (void)cellShouldDeleted:(GAGItem*)item;

/**
 when cell should been complete

 @param item model
 */
- (void)cellShouldCompleted:(GAGItem*)item;

/**
 when cell did begin editing

 @param cell which edit
 */
- (void)cellDidBeginEditing:(GAGTableViewCell*)cell item:(GAGItem*)item;

/**
 when cell did end editing
 
 @param cell which edit
 */
- (void)cellDidEndEditing:(GAGTableViewCell*)cell item:(GAGItem*)item;

/**
 when cell did longPress

 @param longPress UILongPressGestureRecognizer
 */
- (void)cellDidLongPress:(GAGTableViewCell*)cell longPress:(UILongPressGestureRecognizer *)longPress;

@end

@interface GAGTableViewCell : UITableViewCell
/**
 渐变层 Gradient Layer for making different from other cell
 */
@property (nonatomic,strong) CAGradientLayer *gradientLayer;


@property (nonatomic,assign) BOOL gestureRecognizerEnable;
/**
 model
 */
@property (nonatomic,strong) GAGItem *item;

@property (nonatomic,strong) GAGStrikethroughTextField *textField;

@property (nonatomic,weak) id<GAGTableViewCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

/**
 cell 是否在长按，长按时不允许接受textField的点击事件
 */
@property (nonatomic,assign) BOOL isLongPress;


@end

NS_ASSUME_NONNULL_END
