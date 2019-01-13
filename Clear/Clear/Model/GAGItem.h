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
 init with dictionary

 @param dict <#dict description#>
 @return <#return value description#>
 */
+ (instancetype)itemWithDict:(NSDictionary*)dict;


/**
 <#Description#>

 @param thing <#thing description#>
 @param completed <#completed description#>
 @return <#return value description#>
 */
+ (instancetype)itemWithThing:(NSString*)thing completed:(BOOL)completed;

@end

NS_ASSUME_NONNULL_END
