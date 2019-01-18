//
//  GAGTableViewCell.m
//  Clear
//
//  Created by GMax on 2018/12/19.
//  Copyright © 2018 GAG. All rights reserved.
//


#import "GAGTableViewCell.h"
#import "GAGStrikethroughTextField.h"
#import "GAGItem.h"
#import "UIView+Frame.h"

const CGFloat kLABEL_LEFT_MARGIN = 15.0f;
const CGFloat kUI_CUES_MARGIN = 10.0f;
const CGFloat kUI_CUES_WIDTH = 50.0f;

@interface GAGTableViewCell () <UITextFieldDelegate>


/**
 完成层
 */
@property (nonatomic,strong) CALayer *completeLayer;

/**
 左侧标签
 */
@property (nonatomic,strong) UILabel *leftLabel;

/**
 右侧标签
 */
@property (nonatomic,strong) UILabel *rightLabel;

@property (nonatomic,assign) CGPoint originalCenter;
@property (nonatomic,assign) BOOL shouldCompleted;
@property (nonatomic,assign) BOOL shouldDeleted;
@property (nonatomic,strong) UIPanGestureRecognizer* panRecognizer;
@property (nonatomic,strong) UILongPressGestureRecognizer* longPressRecognizer;

@end

@implementation GAGTableViewCell

#pragma mark - dequeue ReusableCell
+ (instancetype)cellWithTableView:(UITableView*)tableView {
    static NSString *cellID = @"reuseIdentifier";

    GAGTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[GAGTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // build textField for render text
        self.textField = [[GAGStrikethroughTextField alloc]initWithFrame:CGRectNull];
        [self.contentView addSubview:self.textField];
        self.textField.delegate = self;
        
        
        // add a layer that overlays the cell adding a subtle gradient effect
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.colors = @[(id)[[UIColor colorWithWhite:1.0f alpha:0.2f] CGColor], (id)[[UIColor colorWithWhite:1.0f alpha:0.1f] CGColor], (id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0.0f alpha:0.1f] CGColor]];
        self.gradientLayer.locations = @[@0.00f, @0.01f, @0.95f, @1.00f];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];

        
        // add a pan recognizer
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.panRecognizer.delegate = self;
        [self addGestureRecognizer:self.panRecognizer];
        
        //add longPress Gest to self.textField & self.contentView
        self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        self.longPressRecognizer.delegate = self;
        [self addGestureRecognizer:self.longPressRecognizer];
        
        [self.panRecognizer requireGestureRecognizerToFail:self.longPressRecognizer];

        self.gestureRecognizerEnable = YES;
        
#warning add completeLayer after gestureRecognizerShouldBegin ?????
        // add a layer that renders a green background when an item is complete
        self.completeLayer = [CALayer layer];
        self.completeLayer.backgroundColor = [[[UIColor alloc] initWithRed:0.0 green:0.6 blue:0.0 alpha:1.0] CGColor];
        self.completeLayer.hidden = YES;
        [self.layer insertSublayer:self.completeLayer atIndex:0];
    }
    return self;
}

#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    self.textField.frame = CGRectMake(kLABEL_LEFT_MARGIN,
                                      0,
                                      self.width - kLABEL_LEFT_MARGIN,
                                      self.height);
    
    self.leftLabel.frame = CGRectMake(-kUI_CUES_WIDTH - kUI_CUES_MARGIN,
                                      0,
                                      kUI_CUES_WIDTH,
                                      self.height);
    
    self.rightLabel.frame = CGRectMake(self.width + kUI_CUES_MARGIN,
                                       0,
                                       kUI_CUES_WIDTH,
                                       self.height);
    
    self.gradientLayer.frame = self.bounds;
    self.completeLayer.frame = self.bounds;
}

#pragma mark - set alpha of left & right Label
- (void)setAlphaForLabel:(CGFloat)alpha {
    self.leftLabel.alpha = alpha;
    self.rightLabel.alpha = alpha;
}
#pragma mark - horizontal pan gesture methods
//接受多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer  {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    if (self.gestureRecognizerEnable == YES) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            NSLog(@"GgestureRecognizerShouldBegin longPress");
            return YES;
        }
        
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            CGPoint translation = [gestureRecognizer translationInView:[self superview]];
            //        CGPoint translation = [gestureRecognizer locationInView:[self superview]];
            
            // Check for horizontal gesture
            if (fabs(translation.x) > fabs(translation.y)) {
                
#warning creating leftLabel & rightLabel after gestureRecognizerShouldBegin
                
                //leftLabel
                self.leftLabel = [[UILabel alloc] init];
                self.leftLabel.textColor = [UIColor whiteColor];
                self.leftLabel.font = [UIFont boldSystemFontOfSize:32.0];
                self.leftLabel.backgroundColor = [UIColor clearColor];
                self.leftLabel.text = @"\u2713";//tick
                self.leftLabel.textAlignment = NSTextAlignmentRight;
                [self addSubview:self.leftLabel];
                
                //rightLabel
                self.rightLabel = [[UILabel alloc] init];
                self.rightLabel.textColor = [UIColor redColor];
                self.rightLabel.font = [UIFont boldSystemFontOfSize:32.0];
                self.rightLabel.backgroundColor = [UIColor clearColor];
                self.rightLabel.text = @"\u2717";//cross
                self.rightLabel.textAlignment = NSTextAlignmentLeft;
                [self addSubview:self.rightLabel];
                
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - handlePan

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"pan");

    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.originalCenter = self.center;
        }
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint offset = [recognizer translationInView:self];

            self.center = CGPointMake(self.originalCenter.x+ offset.x, self.originalCenter.y);
        
        /*
        self.shouldCompleted = self.x > self.width * 0.5;
        self.shouldDeleted = self.x < - self.width * 0.5;

        CGFloat alpha = fabs(self.x) / kUI_CUES_WIDTH;
        [self setAlphaForLabel:alpha];
        self.leftLabel.textColor = self.shouldCompleted ? [UIColor greenColor] :[UIColor whiteColor];
        self.rightLabel.textColor = self.shouldDeleted ? [UIColor redColor] : [UIColor whiteColor];
        */
        
        //滑动到1.5倍kUI_CUES_WIDTH大小时，代表删除，这里可以自定义长度
        self.shouldCompleted = self.x > kUI_CUES_WIDTH * 1.5;
        self.shouldDeleted = self.x < - kUI_CUES_WIDTH * 1.5;
        CGFloat alpha = fabs(self.x) / kUI_CUES_WIDTH;
        [self setAlphaForLabel:alpha];
        self.completeLayer.hidden = !self.shouldCompleted;
        }
        if (recognizer.state == UIGestureRecognizerStateEnded) {

            if (self.shouldCompleted) {
                self.item.completed = YES;
                self.completeLayer.hidden = NO;
                self.textField.strikethrough = YES;
                if ([self.delegate respondsToSelector:@selector(cellShouldCompleted:)]) {
                    [self.delegate cellShouldCompleted:self.item];
                }
            }else if (self.shouldDeleted) {
                if ([self.delegate respondsToSelector:@selector(cellShouldDeleted:)]) {
                    [self.delegate cellShouldDeleted:self.item];
                }
            }else {
                [UIView animateWithDuration:0.2 animations:^{
                    self.x = 0;
                }];
            }

        }
    }
}

#pragma mark - handleLongPress

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer {
    NSLog(@"longPress");
    if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        
        if ([self.delegate respondsToSelector:@selector(cellDidLongPress:longPress:)]) {
            [self.delegate cellDidLongPress:self longPress:recognizer];
        }
    }
}
#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    长按时不允许接受点击事件，不然会既响应点击事件，又响应长按拖动
    if (self.isLongPress == YES) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    if (self.longPressRecognizer) {
        if ([self.delegate respondsToSelector:@selector(cellDidBeginEditing:)]) {
            [self.delegate cellDidBeginEditing:self];
        }
//    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.textField.text = textField.text;
    if ([self.delegate respondsToSelector:@selector(cellDidEndEditing:)]) {
        [self.delegate cellDidEndEditing:self];
    }
}

#pragma mark - item setter
- (void)setItem:(GAGItem *)item {
    _item = item;
    self.textField.text = [item.thing copy];
    self.textField.strikethrough = item.completed;
    self.completeLayer.hidden = !item.completed;
}



@end
