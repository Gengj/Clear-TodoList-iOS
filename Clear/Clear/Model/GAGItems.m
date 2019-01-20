//
//  GAGItems.m
//  Clear
//
//  Created by GMax on 2018/12/19.
//  Copyright © 2018 GAG. All rights reserved.
//

#import "GAGItems.h"
#import "GAGItem.h"

@implementation GAGItems



/**
 Creates and returns items with dict
 */
+ (instancetype)itemsWithDict:(NSDictionary*)dict {
    GAGItems *items = [[GAGItems alloc]init];
    [items setValuesForKeysWithDictionary:dict];
    return items;
}


/**
 列表中未完成项的总数 count of uncompleted things in list
 */
- (NSUInteger)getCountOfUncompletedItem{
    NSUInteger index = 0;
    for (GAGItem *item in self.things) {
        if (item.completed == NO) {
            index++;
        }
    }
    return index;
}

/**
 移动指定项目到已完成项目的第一个，即未完成项目的末尾
 move index item to the first of completed items (the end of uncompleted items)
 */
- (void)moveItemToCompletionWithIndex:(NSUInteger)index{
    NSUInteger targetIndex;
    GAGItem *item = self.things[index];
    if (item.completed == YES) {
        targetIndex  = [self getCountOfUncompletedItem] + 1;
        [self.things insertObject:item atIndex:targetIndex];
        [self.things removeObjectAtIndex:index];
    }else {
        targetIndex = [self getCountOfUncompletedItem] - 1;
        [self.things insertObject:item atIndex:targetIndex];
        [self.things removeObjectAtIndex:index + 1];
    }
    
//    item.completed = YES;

}

/**
 在顶部添加一个item  add a item at first
 */
- (void)addItemAtTop:(GAGItem*)item {
    [self.things insertObject:item atIndex:0];
}

/**
 在指定index添加一个item  add a item at index
 */
- (void)addItemAtIndex:(GAGItem*)item index:(NSUInteger)index{
    [self.things insertObject:item atIndex:index];
}

/**
 移除指定index的item remove item at index
 */
- (void)removeItemAtIndex:(NSUInteger)index {
    [self.things removeObjectAtIndex:index];
}

/**
 将指定index的item移动到另一个指定index
 move item from index to another index
 */
- (void)moveItemFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex{
    //如果移动起始位置和目的位置的item.completed不相同的话，就把起始位置的item.completed设置为目的位置的item.completed
    if (self.things[fromIndex].completed != self.things[toIndex].completed) {
        self.things[fromIndex].completed = self.things[toIndex].completed;
    }
    
    //比较下位置关系，开始移动吧
    if (fromIndex < toIndex) {
        for (NSUInteger i = fromIndex; i < toIndex; i ++) {
            [self.things exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
        }
    }else{
        for (NSUInteger i = fromIndex; i > toIndex; i --) {
            [self.things exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
        }
    }
}
/**
 按照完成与否排序，把已完成的事件放置在列表末尾
 sort by completion, move completed item to the end of list
 */
- (void)sortByCompletion {
    for (NSUInteger index = 0; index < self.things.count; index++) {
        GAGItem *item = self.things[index];
        if (item.completed == YES) {
            [self moveItemFromIndex:index toIndex:self.things.count];
        }
    }
}

/**
 为调试需要，重置内容
 reset all items of list for debug
 */
- (void)resetItems {
    self.theme = @"Welcome to Clear";
    [self.things removeAllObjects];
    [self.things addObject:[GAGItem itemWithThing:@"0-Feed the cat" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"1-Buy eggs" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"2-Pack bags for WWDC" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"3-Rule the web" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"4-Buy a new iPhone" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"5-Find missing socks" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"6-Write a new tutorial" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"7-Master Objective-C" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"8-Remember your wedding anniversary!" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"9-Drink less beer" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"10-Learn to draw" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"11-Take the car to the garage" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"12-Sell things on eBay" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"13-Learn to juggle" completed:NO]];
    [self.things addObject:[GAGItem itemWithThing:@"14-Give up" completed:NO]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.theme forKey:@"theme"];
    [coder encodeObject:self.things forKey:@"things"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.theme = [coder decodeObjectForKey:@"theme"];
        self.things = [coder decodeObjectForKey:@"things"];
    }
    return self;
}

@end
