//
//  UIView+Frame.h
//  Lottery
//
//  Created by GMax on 2018/12/10.
//  Copyright © 2018 GMax. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Frame)

//在分类中，@property 只会生成getter/setter方法，并不会生成下划线的成员属性

@property (assign,nonatomic) CGFloat width;   //宽度
@property (assign,nonatomic) CGFloat height;  //高度
@property (assign,nonatomic) CGFloat x;       // X
@property (assign,nonatomic) CGFloat y;       // Y


@end

NS_ASSUME_NONNULL_END
