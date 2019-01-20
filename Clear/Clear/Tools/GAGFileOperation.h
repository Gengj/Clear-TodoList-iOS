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
 返回GAGFileOperation单例对象
 Returns the singleton GAGFileOperation instance.
 */
+ (instancetype)sharedOperation;

/**
 保存GAGItems对象，文件名是GAGItems.theme
 save items
 */
- (void)save:(GAGItems*)items;

/**
 从指定文件名读取GAGItems对象
 read GAGItems with fileName in NSDocumentDirectory
 */
- (GAGItems *)read:(NSString*)fileName;
@end

NS_ASSUME_NONNULL_END
