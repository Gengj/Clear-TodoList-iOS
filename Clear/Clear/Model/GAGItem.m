//
//  GAGItem.m
//  Clear
//
//  Created by GMax on 2018/12/19.
//  Copyright © 2018 GAG. All rights reserved.
//

#import "GAGItem.h"

@implementation GAGItem 

/**
 Creates and returns a item with dictionary
 */
+ (instancetype)itemWithDict:(NSDictionary*)dict {
    GAGItem *item = [[GAGItem alloc]init];
    [item setValuesForKeysWithDictionary:dict];
    return item;
}

/**
 Creates and returns a item with thing , completed default is NO.
 */
+ (instancetype)itemWithThing:(NSString*)thing {
    return [self itemWithThing:thing completed:NO];
}

/**
 Creates and returns a item with thing & completed.
 */
+ (instancetype)itemWithThing:(NSString*)thing completed:(BOOL)completed {
    GAGItem *item = [[GAGItem alloc]init];
    item.thing = thing;
    item.completed = completed;
    return item;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.thing forKey:@"thing"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeBool:self.completed forKey:@"completed"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.thing = [aDecoder decodeObjectForKey:@"thing"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.completed = [aDecoder decodeBoolForKey:@"completed"];
    }
    return self;
}

@end
