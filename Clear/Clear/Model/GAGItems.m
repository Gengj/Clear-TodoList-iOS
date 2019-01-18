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

+ (instancetype)itemsWithDict:(NSDictionary*)dict {
    GAGItems *items = [[GAGItems alloc]init];
    [items setValuesForKeysWithDictionary:dict];
    return items;
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

- (void)moveItemToCompletionIndex:(NSUInteger)index{
    GAGItem *item = self.things[index];
    item.completed = YES;
    NSUInteger targetIndex = [self countofUnCompletedThing];
    [self.things insertObject:item atIndex:targetIndex + 1];
    [self.things removeObjectAtIndex:index];
}

- (NSUInteger)countofUnCompletedThing {
    NSUInteger index = 0;
    for (GAGItem *item in self.things) {
        if (item.completed == NO) {
            index++;
        }
    }
    return index;
}

- (void)addItemAtTop:(GAGItem*)item {
    [self.things insertObject:item atIndex:0];
}

- (void)addItemAtIndex:(GAGItem*)item index:(NSUInteger)index{
    [self.things insertObject:item atIndex:index];
}

//- (void)sortByCompletion {
//    for (NSUInteger index = 0; index < self.things.count; index++) {
//        GAGItem *item = self.things[index];
//        if (item.completed == YES) {
//            [self moveItemToCompletionIndex:index];
//        }
//    }
//}

- (void)removeItemAtIndexes:(NSUInteger)index {
    [self.things removeObjectAtIndex:index];
}

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

- (void)resetItems {
     [self.things removeAllObjects];
     [self.things addObject:[GAGItem itemWithThing:@"Feed the cat" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Buy eggs" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Pack bags for WWDC" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Rule the web" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Buy a new iPhone" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Find missing socks" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Write a new tutorial" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Master Objective-C" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Remember your wedding anniversary!" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Drink less beer" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Learn to draw" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Take the car to the garage" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Sell things on eBay" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Learn to juggle" completed:NO]];
     [self.things addObject:[GAGItem itemWithThing:@"Give up" completed:NO]];
}
@end
