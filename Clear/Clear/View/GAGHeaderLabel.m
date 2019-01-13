//
//  GAGHeaderLabel.m
//  Clear
//
//  Created by GMax on 2019/1/5.
//  Copyright © 2019 GAG. All rights reserved.
//

#import "GAGHeaderLabel.h"
#define StatusbarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
@implementation GAGHeaderLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {StatusbarHeight, 5, 0, 5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
