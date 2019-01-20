//
//  GAGTableViewCell.m
//  Clear
//
//  Created by GMax on 2018/12/19.
//  Copyright © 2018 GAG. All rights reserved.
//


#import "GAGTableViewCell.h"

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

/**
 滑动手势
 */
@property (nonatomic,strong) UIPanGestureRecognizer* panRecognizer;

/**
 长按手势
 */
@property (nonatomic,strong) UILongPressGestureRecognizer* longPressRecognizer;
/**
 初始位置的中心点
 */
@property (nonatomic,assign) CGPoint originalCenter;

/**
 是否完成
 */
@property (nonatomic,assign) BOOL shouldCompleted;

/**
 是否删除
 */
@property (nonatomic,assign) BOOL shouldDeleted;
@end

@implementation GAGTableViewCell

#pragma mark - dequeue ReusableCell

/**
 返回GAGTableViewCell实例对象 return GAGTableViewCell instance with UITabelView
 */
+ (instancetype)cellWithTableView:(UITableView*)tableView {
    
    static NSString *cellID = GAGTableViewCellID;
    GAGTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[GAGTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}


/**
 覆写initWithStyle方法 override initWithStyle
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //离屏渲染 - 异步绘制  耗电
        self.layer.drawsAsynchronously = YES;
        //栅格化
        self.layer.shouldRasterize = YES;
        //使用 “栅格化” 必须指定分辨率
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
               
        // 生成textField build textField
        self.textField = [[GAGStrikethroughTextField alloc]initWithFrame:CGRectNull];
        [self.contentView addSubview:self.textField];
        self.textField.delegate = self;
        
        // 添加一个渐变层，让每个cell的颜色更有区分度
        //add a layer that overlays the cell adding a subtle gradient effect
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.colors = @[(id)[[UIColor colorWithWhite:1.0f alpha:0.2f] CGColor], (id)[[UIColor colorWithWhite:1.0f alpha:0.1f] CGColor], (id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0.0f alpha:0.1f] CGColor]];
        self.gradientLayer.locations = @[@0.00f, @0.01f, @0.95f, @1.00f];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];

        // 添加绿色的完成层，当item是完成时显示
        // add a layer that renders a green background when an item is complete
        self.completeLayer = [CALayer layer];
        self.completeLayer.backgroundColor = [[[UIColor alloc] initWithRed:0.0 green:0.6 blue:0.0 alpha:1.0] CGColor];
        self.completeLayer.hidden = YES;
        [self.layer insertSublayer:self.completeLayer atIndex:0];
        
        // 添加滑动手势 add a pan recognizer
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.panRecognizer.delegate = self;
        [self addGestureRecognizer:self.panRecognizer];
        
        // 添加长按手势 add longPress Gest
        self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        self.longPressRecognizer.delegate = self;
        [self addGestureRecognizer:self.longPressRecognizer];
        
        // 滑动手势级别低于长按手势
        [self.panRecognizer requireGestureRecognizerToFail:self.longPressRecognizer];

        // 设置可以接受手势事件 cell can recognize gestures
        self.gestureRecognizerEnable = YES;
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

/**
 设置左右两侧label的透明度 set alpha of left & right Label
 */
- (void)setAlphaForLabel:(CGFloat)alpha {
    self.leftLabel.alpha = alpha;
    self.rightLabel.alpha = alpha;
}
#pragma mark - horizontal pan gesture methods
//可以接受多个手势 allowed to recognize two gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer  {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    //当cell允许接受手势事件时：
    //when cell could recognize gestures
    if (self.gestureRecognizerEnable == YES) {
        
        //允许接收长按手势
        //could recognize long press gesture
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            return YES;
        }
        
        //允许接收滑动手势
        //could recognize pan gesture
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            CGPoint translation = [gestureRecognizer translationInView:[self superview]];
            
            // 确定是左右滑动，而非上下滑动
            // Check for horizontal gesture
            if (fabs(translation.x) > fabs(translation.y)) {
                
                //创建左右两侧的label
                //creating leftLabel & rightLabel after gestureRecognizerShouldBegin
                
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

#pragma mark - handle Pan Recognizer

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        // UIGestureRecognizerStateBegan
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.originalCenter = self.center;
        }
        
        // UIGestureRecognizerStateChanged
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint offset = [recognizer translationInView:self];

            self.center = CGPointMake(self.originalCenter.x + offset.x, self.originalCenter.y);
        
            //滑动到1倍kUI_CUES_WIDTH长度时，意味着完成或删除，这里可以自定义长度
            //when pan offset longer than kUI_CUES_WIDTH ,means completed/delete
            self.shouldCompleted = self.x > kUI_CUES_WIDTH;
            self.shouldDeleted = self.x < - kUI_CUES_WIDTH ;
            
            CGFloat alpha = fabs(self.x) / kUI_CUES_WIDTH;
            [self setAlphaForLabel:alpha];
            
            /* 也可以设置左右Label的颜色
             self.leftLabel.textColor = self.shouldCompleted ? [UIColor greenColor] :[UIColor whiteColor];
             self.rightLabel.textColor = self.shouldDeleted ? [UIColor redColor] : [UIColor whiteColor];
             */
            self.completeLayer.hidden = !self.shouldCompleted;
        }
        
        //UIGestureRecognizerStateEnded
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            if (self.shouldCompleted) {
                self.item.completed = !self.item.completed;
                self.completeLayer.hidden = !self.item.completed;
                self.textField.strikethrough = self.item.completed;
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
    //长按时不允许接受点击事件，不然会既响应点击事件，又响应长按拖动
    //textField should not begin edit when longPress
    if (self.isLongPress == YES) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(cellDidBeginEditing:item:)]) {
            [self.delegate cellDidBeginEditing:self item:self.item];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.textField.text = textField.text;
    if ([self.delegate respondsToSelector:@selector(cellDidEndEditing:item:)]) {
        [self.delegate cellDidEndEditing:self item:self.item];
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
