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
@property (nonatomic,strong) NSString *theme;
@property (nonatomic,strong) NSMutableArray<GAGItem*> *things;

+ (instancetype)itemsWithDict:(NSDictionary*)dict;

- (void)moveItemToCompletionIndex:(NSUInteger)index;

- (NSUInteger)countofUnCompletedThing;

- (void)addItemAtTop:(GAGItem*)item;

- (void)removeItemAtIndexes:(NSUInteger)index;

- (void)moveItemFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (void)resetItems;

@end

NS_ASSUME_NONNULL_END
