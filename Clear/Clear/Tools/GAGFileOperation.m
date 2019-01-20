//
//  GAGFileOperation.m
//  Clear
//
//  Created by GMax on 2018/12/20.
//  Copyright © 2018 GAG. All rights reserved.
//

#import "GAGFileOperation.h"
#import "GAGItems.h"

@implementation GAGFileOperation

/**
 返回GAGFileOperation单例对象
 Returns the singleton GAGFileOperation instance.
 */
+(GAGFileOperation *) sharedOperation{
    static GAGFileOperation * s_instance_dj_singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance_dj_singleton = [[super allocWithZone:nil] init];
    });
    return s_instance_dj_singleton;
}

+(id)allocWithZone:(NSZone *)zone{
    return [GAGFileOperation sharedOperation];
}

-(id)copyWithZone:(NSZone *)zone{
    return [GAGFileOperation sharedOperation];
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return [GAGFileOperation sharedOperation];
}

/**
 使用GCD开启并发子线程，保存GAGItems对象，文件名是GAGItems.theme
 using GCD open concurrent subthreads for saving items
 */
- (void)save:(GAGItems*)items {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject];
        NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",items.theme]];
        [NSKeyedArchiver archiveRootObject:items toFile:filePath];
    });
}

/**
 从指定文件名读取GAGItems对象
 read GAGItems with fileName in NSDocumentDirectory
 */
- (GAGItems *)read:(NSString*)fileName {
    NSString *path =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"%@",path);
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    GAGItems *items  =  [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return items;
}
@end
