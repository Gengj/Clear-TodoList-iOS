//
//  UIView+Frame.m
//  Lottery
//
//  Created by GMax on 2018/12/10.
//  Copyright © 2018 GMax. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)


/*
  getter
 */
- (CGFloat)width {
    return self.frame.size.width;
}
/*
 setter
 */
- (void)setWidth:(CGFloat)width {
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}
/*
 getter
 */
- (CGFloat)height {
    return self.frame.size.height;
}

/*
 setter
 */
- (void)setHeight:(CGFloat)height{
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

/*
 getter
 */
- (CGFloat)x {
    return self.frame.origin.x;
}

/*
 setter
 */
- (void)setX:(CGFloat)x {
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}

/*
 getter
 */
- (CGFloat)y {
    return self.frame.origin.y;
}

/*
 setter
 */
- (void)setY:(CGFloat)y {
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}

@end
