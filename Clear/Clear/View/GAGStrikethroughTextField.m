//
//  GAGStrikethroughTextField.m
//  Clear
//
//  Created by GMax on 2018/12/19.
//  Copyright © 2018 GAG. All rights reserved.
//

#import "GAGStrikethroughTextField.h"

const CGFloat kFONT_SIZE = 20.0;
const CGFloat kSTRIKEOUT_THICKNESS = 2.0f;

@interface GAGStrikethroughTextField() 

@property (nonatomic,strong) CALayer* strikethroughLayer;

@end

@implementation GAGStrikethroughTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //create strikethrouh Layer
        self.strikethroughLayer = [CALayer layer];
        self.strikethroughLayer.backgroundColor = [[UIColor whiteColor]CGColor];
        self.strikethroughLayer.hidden = YES;
        //add strikethrouh Layer to UITextField Layer
        [self.layer addSublayer:self.strikethroughLayer];
        
        //set GAGStrikethroughTextField attr
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:kFONT_SIZE];
        self.backgroundColor = [UIColor clearColor];
    
//        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.returnKeyType = UIReturnKeyDone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resizeStrikeThrough];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self resizeStrikeThrough];
}

// resizes the strikethrough layer to match the current label text
- (void)resizeStrikeThrough
{
    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];

    self.strikethroughLayer.frame = CGRectMake(0, self.bounds.size.height * 0.5, textSize.width, kSTRIKEOUT_THICKNESS);
}

#pragma mark - strikethrough setter
- (void)setStrikethrough:(BOOL)strikethrough {
    _strikethrough = strikethrough;
    self.strikethroughLayer.hidden = !strikethrough;
}

@end
