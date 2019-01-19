//
//  GAGHeaderLabel.m
//  Clear
//
//  Created by GMax on 2019/1/5.
//  Copyright © 2019 GAG. All rights reserved.
//

#import "GAGHeaderLabel.h"

@implementation GAGHeaderLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:HeaderLabelAlpha];
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:15];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

//设置GAGHeaderLabel的text在底部居中 set GAGHeaderLabel.text at the center of bottom
- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {StatusbarHeight, 5, 0, 5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
