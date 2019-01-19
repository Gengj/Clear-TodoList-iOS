//
//  GAGItem.h
//  Clear
//
//  Created by GMax on 2018/12/19.
//  Copyright © 2018 GAG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GAGItem : NSObject <NSCoding>

@property (nonatomic,strong) NSString *thing;
@property (nonatomic,strong) NSDate *date;
@property (nonatomic,assign) BOOL completed;

/**
 Creates and returns a item with dictionary
 */
+ (instancetype)itemWithDict:(NSDictionary*)dict;

/**
 Creates and returns a item with thing , completed default is NO.
 */
+ (instancetype)itemWithThing:(NSString*)thing;

/**
 Creates and returns a item with thing & completed.
 */
+ (instancetype)itemWithThing:(NSString*)thing completed:(BOOL)completed;



@end

NS_ASSUME_NONNULL_END
