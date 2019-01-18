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

static GAGFileOperation *_instance;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)shareOperation {
    return [[self alloc]init];
}


//存数据
- (BOOL)save:(GAGItems*)items {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",items.theme]];
    return [NSKeyedArchiver archiveRootObject:items toFile:filePath];
}

//读取数据
- (GAGItems *)read:(NSString*)fileName {
   NSString *path =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    GAGItems *items =  [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
//    NSLog(@"%@",path);
    return items;
}
@end
