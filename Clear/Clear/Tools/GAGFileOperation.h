//
//  GAGFileOperation.h
//  Clear
//
//  Created by GMax on 2018/12/20.
//  Copyright © 2018 GAG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GAGItems;
NS_ASSUME_NONNULL_BEGIN

@interface GAGFileOperation : NSObject

/**
 <#Description#>

 @return <#return value description#>
 */
+ (instancetype)shareOperation;

/**
 <#Description#>

 @param items <#items description#>
 @return <#return value description#>
 */
- (BOOL)save:(GAGItems*)items;

/**
 <#Description#>

 @param fileName <#fileName description#>
 @return <#return value description#>
 */
- (GAGItems *)read:(NSString*)fileName;
@end

NS_ASSUME_NONNULL_END
