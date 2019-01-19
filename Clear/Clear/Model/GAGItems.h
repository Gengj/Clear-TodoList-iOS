//
//  GAGItems.h
//  Clear
//
//  Created by GMax on 2018/12/19.
//  Copyright © 2018 GAG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GAGItem;

NS_ASSUME_NONNULL_BEGIN

@interface GAGItems : NSObject <NSCoding>

/**
 列表主题 theme of list
 */
@property (nonatomic,strong) NSString *theme;

/**
 item列表 list of items
 */
@property (nonatomic,strong) NSMutableArray<GAGItem*> *things;


/**
 Creates and returns items with dict
*/
+ (instancetype)itemsWithDict:(NSDictionary*)dict;

/**
 移动指定项目到已完成项目的第一个，即未完成项目的末尾
 move index item to the first of completed items (the end of uncompleted items)
 */
- (void)moveItemToCompletionWithIndex:(NSUInteger)index;

/**
 在顶部添加一个item  add a item at first
 */
- (void)addItemAtTop:(GAGItem*)item;

/**
 在指定index添加一个item  add a item at index
 */
- (void)addItemAtIndex:(GAGItem*)item index:(NSUInteger)index;

/**
 移除指定index的item remove item at index
 */
- (void)removeItemAtIndex:(NSUInteger)index;

/**
 将指定index的item移动到另一个指定index
 move item from index to another index
 */
- (void)moveItemFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

/**
 按照完成与否排序，把已完成的事件放置在列表末尾
 sort by completion, move completed item to the end of list
 */
- (void)sortByCompletion;

/**
 列表中未完成项的总数 count of uncompleted things in list
 */
- (NSUInteger)getCountOfUncompletedItem;

/**
 为调试需要，重置内容
 reset all items of list for debug
 */
- (void)resetItems;

@end

NS_ASSUME_NONNULL_END
