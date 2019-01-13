//
//  GAGBaseTableView.m
//  Clear
//
//  Created by GMax on 2018/12/22.
//  Copyright © 2018 GAG. All rights reserved.
//

#import "GAGBaseTableView.h"

#define TableViewCellHeight 60
//static const float TableViewCellHeight = 60;
#define HeaderLabelHeight 20
#define StatusbarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define ScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

typedef NS_ENUM(NSInteger, GAGTableViewGestureType) {
    //下拉添加
    GAGTableViewPullToAdd,
    //捏合添加
    GAGTableViewPinchToAdd,
    //长按移动
    GAGTableViewLongPressToMove,
    //无手势
    GAGTableViewGestureNone
};

typedef NS_ENUM(NSInteger, GAGTableViewScrollType) {
    // TableView顶部
    GAGTableViewTypeTop,
    // TableView底部
    GAGTableViewTypeBottom
};

struct GAGTouchPoint {
    CGPoint upper;
    CGPoint lower;
};
typedef struct GAGTouchPoint GAGTouchPoint;

@interface GAGBaseTableView () <UITableViewDelegate,UITableViewDataSource,GAGTableViewCellDelegate>

@property (nonatomic,assign) GAGTableViewGestureType currentType;
/**
 遮罩层
 */
@property (nonatomic,strong) UIView *coverView;

//property for pull to add
/**
 占位cell
 */
@property (nonatomic,strong) GAGTableViewCell *placeholderCell;

/**
 tableView滚动中真实的偏移量
 */
@property (nonatomic,assign) CGFloat realTableViewOffsetY;

/**
 记录滑动开始时的偏移量，以便判断滑动方向
 */
@property (nonatomic, assign) CGFloat historyTableViewOffsetY;
@property (nonatomic, assign) BOOL pullInProgress;

//property for longpress to move

/// 记录手指所在的位置
@property (nonatomic, assign) CGPoint longLocation;
/// 对被选中的cell的截图
@property (nonatomic, strong) UIImageView *snapshotView;
/// 被选中的cell的原始位置
@property (nonatomic, strong) NSIndexPath *oldIndexPath;
/// 被选中的cell的新位置
@property (nonatomic, strong) NSIndexPath *newestIndexPath;
/// 定时器
@property (nonatomic, strong) CADisplayLink *scrollTimer;

/// 滚动方向
@property (nonatomic, assign) GAGTableViewScrollType scrollType;

//property for pinch to add
@property (nonatomic, assign) GAGTouchPoint startPoint;

@property (nonatomic, strong) NSIndexPath *pinchOneCellIndex;
@property (nonatomic, strong) NSIndexPath *pinchTwoCellIndex;
@property (nonatomic, assign) int newCellIndex;

@end

@implementation GAGBaseTableView

- (void)setItems:(GAGItems *)items {
    _items = items;
    [self reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, TableViewCellHeight * 2)];
        //color
        self.backgroundColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        //hide indicator
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.allowsSelection = NO;

        self.delegate = self;
        self.dataSource = self;
        self.contentInset = UIEdgeInsetsMake(HeaderLabelHeight, 0, 0, 0);
        
        UIGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
        [self addGestureRecognizer:recognizer];
        
        
    }
    return self;
}


#pragma mark - coverView
- (UIView *)coverView {
    if (_coverView == nil) {
        _coverView = [[UIView alloc]init];
        [self.superview addSubview:_coverView];
        _coverView.frame = CGRectMake(0,StatusbarHeight + HeaderLabelHeight + TableViewCellHeight, self.width, self.height);
        _coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    }
    return _coverView;
}

- (void)setCoverViewHidden:(BOOL)coverViewHidden {
    [self bringSubviewToFront:self.coverView];
    self.coverView.hidden = coverViewHidden;
}

- (GAGTableViewCell *)placeholderCell {
    if (_placeholderCell == nil) {
        //单独创建一个cell
        static NSString *cellID = @"reuseIdentifier";
        _placeholderCell =  [[GAGTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //设置cell的背景色
        _placeholderCell.backgroundColor = [UIColor redColor];
        //设置cell.bounds，不然无法生成UIImage
        //设置cell的内容
        _placeholderCell.gradientLayer.hidden = YES;
    }
    return _placeholderCell;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.things.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GAGTableViewCell *cell = [GAGTableViewCell cellWithTableView:self];
    cell.delegate = self;
    
    cell.item = self.items.things[indexPath.row];
    cell.backgroundColor = [self colorWithIndexPath:indexPath];
//#pragma warning add longpress in cell
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
//    [cell addGestureRecognizer:longPress];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}

- (UIColor *)colorWithIndexPath:(NSIndexPath*)indexPath {
    NSUInteger count = self.items.things.count - 1;
    CGFloat val = 0.6 *  indexPath.row / count ;
    return [UIColor colorWithRed: 1.0 green:val blue: 0.0 alpha:1.0];
}

#pragma mark - GAGBaseTableViewCellDelegate
- (void)cellShouldDeleted:(GAGItem*)item {
    [self log];
    
    NSUInteger index = [self.items.things indexOfObject:item];
    [self.items.things removeObject:item];
    
    if ([[GAGFileOperation shareOperation]save:self.items]) {
        [UIView animateWithDuration:0.5 animations:^{
            [self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            
        }];
    }
    [self log];
}
#pragma mark - will add new feature
// 已完成的再滑动变未完成
- (void)cellShouldCompleted:(GAGItem*)item{
    [self log];
    
    NSUInteger index = [self.items.things indexOfObject:item];
//    self.items.things[index].completed = !item.completed;
    [self.items moveItemToCompletionIndex:index];

    if ([[GAGFileOperation shareOperation]save:self.items]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        NSIndexPath *toIndexPath;
        toIndexPath = [NSIndexPath indexPathForRow:[self.items countofUnCompletedThing] inSection:0];
    
        [self moveRowAtIndexPath:indexPath toIndexPath:toIndexPath];
    }
    [self log];
    
}

- (void)cellDidBeginEditing:(GAGTableViewCell*)cell{
    cell.gestureRecognizerEnable = NO;
    
    CGFloat selectedCellY = cell.y;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[GAGTableViewCell class]]) {
            [UIView animateWithDuration:0.2 animations:^{
                view.transform = CGAffineTransformMakeTranslation(0,- selectedCellY);
                
                if ([self.tableViewDelegate respondsToSelector:@selector(cellDidBeginEditing)]) {
                    [self.tableViewDelegate cellDidBeginEditing];
                }
            }completion:^(BOOL finished) {
                [self setCoverViewHidden:NO];

            }];
        }
    }

}

- (void)cellDidEndEditing:(GAGTableViewCell*)cell{
    cell.gestureRecognizerEnable = YES;

    [self setCoverViewHidden:YES];
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[GAGTableViewCell class]]) {
            [UIView animateWithDuration:0.5 animations:^{
                view.transform = CGAffineTransformIdentity;
                if ([self.tableViewDelegate respondsToSelector:@selector(cellDidEndEditing)]) {
                    [self.tableViewDelegate cellDidEndEditing];
                }
            }];
        }
    }
    
    //cell内容为空时，需要被删除
    if ([cell.textField.text isEqualToString:[NSString stringWithFormat:@""]]) {
        [self cellShouldDeleted:self.items.things[indexPath.row]];
    }else {    //cell内容不为空时，需要保存
        self.items.things[indexPath.row].thing = cell.textField.text;
        [[GAGFileOperation shareOperation]save:self.items];
        [self reloadData];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    //记录下偏移量，以便接下来判断滑动方向
    self.historyTableViewOffsetY = scrollView.contentOffset.y;
    //将占位cell添加到superView上x
    [self.superview addSubview:self.placeholderCell];
    [self.superview sendSubviewToBack:self.placeholderCell];
//    self.pullInProgress = YES;
    self.currentType = GAGTableViewPullToAdd;
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //由于tableView初始时又偏移量，因此计算下偏移量
    self.realTableViewOffsetY = scrollView.contentOffset.y + HeaderLabelHeight + StatusbarHeight;
    NSLog(@"DidScroll ---realTableViewOffsetY    %f",self.realTableViewOffsetY);
    
    //向下滑动
    if (scrollView.contentOffset.y < self.historyTableViewOffsetY && self.currentType == GAGTableViewPullToAdd) {
        
        
        //当实际滑动距离为0到TableViewCellHeight时：
        if (self.realTableViewOffsetY <= 0 && self.realTableViewOffsetY > - TableViewCellHeight) {
            //设置占位cell的frame
            self.placeholderCell.frame = CGRectMake(0, HeaderLabelHeight+ StatusbarHeight,ScreenWidth,fabs(self.realTableViewOffsetY));
            //设置占位cell的内容
            self.placeholderCell.textField.text = @"pull to create items";
            
            //计算旋转角度
            CGFloat angle = M_PI_2 - fabs(self.realTableViewOffsetY) * M_PI_2 /  TableViewCellHeight;
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = - 1 / 100.0;
            //设置占位cell的锚点
            self.placeholderCell.layer.anchorPoint = CGPointMake(0.5, 1);
            
            //做CATransform3DRotate变换
            self.placeholderCell.layer.transform = CATransform3DRotate(transform,angle, 1, 0, 0);
        }else if (self.realTableViewOffsetY == - TableViewCellHeight){
            //恢复CATransform3DRotate状态
            self.placeholderCell.layer.transform = CATransform3DIdentity;
            //当滑动距离等于cell高度时，改变占位cell中的提示内容
            self.placeholderCell.textField.text = @"release to add items";
        }else {
            self.placeholderCell.layer.transform = CATransform3DIdentity;
            
            //当滑动距离大于cell时，让placeholderCell跟随tableview第一个cell移动
            self.placeholderCell.y = HeaderLabelHeight + StatusbarHeight + fabs(self.realTableViewOffsetY) - TableViewCellHeight;
            self.placeholderCell.height = TableViewCellHeight;
        }
        
        
        //向上滑动
    }else if (scrollView.contentOffset.y >=  self.historyTableViewOffsetY){
        //把placeholderCell移除
        //        [self.placeholderCell removeFromSuperview];
        //        self.placeholderCell = nil;
    }

}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.currentType = GAGTableViewGestureNone;
//只有当滑动距离大于等于TableViewCellHeight时，释放才能添加新item
    if (self.realTableViewOffsetY <= - TableViewCellHeight) {
        //移除占位cell
            [self.placeholderCell removeFromSuperview];
            //新增一个item
            GAGItem *newItem = [[GAGItem alloc]init];
            [self.items addItemAtTop:newItem];
            
            //注意：这里必须想加入一个item再增加一行，否则model和view对应不上
            [self insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft]; //UITableViewRowAnimationBottom效果也不错，也挺好看的
            
            //拿到第一个cell，让他成为响应者。并接着用户编辑事件
            GAGTableViewCell *firstCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [firstCell.textField becomeFirstResponder];
            [self cellDidBeginEditing:firstCell];
            
    }
    
}

- (void)log {
    for (GAGItem *item in self.items.things) {
        NSLog(@"%@---%d",item.thing,item.completed);
    }
    NSLog(@"++++++++++++++++++++");
}
#pragma mark - handle pinch gesture
- (void)handlePinch:(UIPinchGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self pinchStarted:recognizer];
        self.currentType = GAGTableViewPinchToAdd;
    }
    if (recognizer.state == UIGestureRecognizerStateChanged && recognizer.numberOfTouches == 2 && self.currentType == GAGTableViewPinchToAdd) {
        [self pinchChanged:recognizer];
        self.currentType = GAGTableViewPinchToAdd;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self pinchEnded:recognizer];
        self.currentType = GAGTableViewGestureNone;
    }
    
}


- (void)pinchStarted:(UIPinchGestureRecognizer*)recognizer {
    self.startPoint = [self getRealTouchPoint:recognizer];
    
    self.pinchOneCellIndex = [self indexPathForRowAtPoint:self.startPoint.upper];
    self.pinchTwoCellIndex = [self indexPathForRowAtPoint:self.startPoint.lower];
    self.newCellIndex = (int)(0.5 + (self.pinchOneCellIndex.row + self.pinchTwoCellIndex.row) * 0.5);
    NSLog(@"new index - %d",self.newCellIndex);
    [self addSubview:self.placeholderCell];
    [self sendSubviewToBack:self.placeholderCell];

}
- (void)pinchChanged:(UIPinchGestureRecognizer*)recognizer {
    GAGTouchPoint currentTouchPoint = [self getRealTouchPoint:recognizer];
    CGFloat upperOffsetY = currentTouchPoint.upper.y  -  self.startPoint.upper.y;
    CGFloat lowerOffsetY = self.startPoint.lower.y - currentTouchPoint.lower.y;
    
    float offset = - MIN(0, MIN(upperOffsetY, lowerOffsetY));


    for (int i = 0; i < self.items.things.count; i++) {
        GAGTableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (i < self.newCellIndex) {
            cell.transform = CGAffineTransformMakeTranslation(0, - offset);
        }
        if (i >= self.newCellIndex) {
            cell.transform = CGAffineTransformMakeTranslation(0,  offset);
        }
    }
    
    GAGTableViewCell *upperCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(self.newCellIndex - 1) inSection:0]];
    GAGTableViewCell *lowerCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.newCellIndex inSection:0]];
    NSLog(@"upperCell---- %p",upperCell);
    NSLog(@"lowerCell---- %p",lowerCell);

    self.placeholderCell.center = CGPointMake(self.width * 0.5, CGRectGetMaxY(upperCell.frame) + 0.5 * (lowerCell.y - CGRectGetMaxY(upperCell.frame)));
    NSLog(@"Cell.center%@",NSStringFromCGPoint(self.placeholderCell.center));
    
    NSLog(@"offset----%f",offset);

    self.placeholderCell.height = MIN(offset * 2, TableViewCellHeight);
    NSLog(@"cell.height %f", self.placeholderCell.height);

    //设置占位cell的frame
    //设置占位cell的内容
    self.placeholderCell.textField.text = @"pull to create items";
    self.placeholderCell.layer.anchorPoint = CGPointMake(0.5, 0.5);
//    self.placeholderCell.transform = CGAffineTransformMakeScale(1.0f,offset * 2 / TableViewCellHeight);
//    self.placeholderCell.transform = CGAffineTransformMakeScale(1,1);

    NSLog(@"Cell.frame%@",NSStringFromCGRect(self.placeholderCell.frame));
    NSLog(@"Feld.frame%@",NSStringFromCGRect(self.placeholderCell.textField.frame));
    NSLog(@"---------------------------------------------");
    /*
    //计算旋转角度
    CGFloat angle = M_PI_2 - fabs(offset) * M_PI_2 /  TableViewCellHeight;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1 / 100.0;
    //设置占位cell的锚点
    self.placeholderCell.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    //做CATransform3DRotate变换
    self.placeholderCell.layer.transform = CATransform3DRotate(transform,angle, 1, 0, 0);
    */
}
- (void)pinchEnded:(UIPinchGestureRecognizer*)recognizer {
//    NSLog(@"%s",__func__);
    [self.placeholderCell removeFromSuperview];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[GAGTableViewCell class]]) {
            [UIView animateWithDuration:0.5 animations:^{
                view.transform = CGAffineTransformIdentity;
     
            }];
        }
    }
}


/**
 get read two touch points in tableView
 
 @param recognizer UIPinchGestureRecognizer
 @return GAGTouchPoint
 */
- (GAGTouchPoint)getRealTouchPoint : (UIPinchGestureRecognizer*)recognizer {
    CGPoint pointOne = [recognizer locationOfTouch:0 inView:self];
    CGPoint pointTwo = [recognizer locationOfTouch:1 inView:self];

    
//    pointOne.y += self.contentOffset.y;
//    pointTwo.y += self.contentOffset.y;
    
    if (pointOne.y > pointTwo.y) {
        CGPoint temp = pointOne;
        pointOne = pointTwo;
        pointTwo = temp;
    }
    
    GAGTouchPoint point = {pointOne,pointTwo};
    return point;
}
#pragma mark - LongPress delegate
- (void)cellDidLongPress:(GAGTableViewCell*)cell longPress:(UILongPressGestureRecognizer *)longPress {
    
        UIGestureRecognizerState longPressState = longPress.state;
        //长按的cell在tableView中的位置
        self.longLocation = [longPress locationInView:self];
        
        //手指按住位置对应的indexPath，可能为nil
        self.newestIndexPath = [self indexPathForRowAtPoint:self.longLocation];
        switch (longPressState) {
            case UIGestureRecognizerStateBegan:{
                self.currentType = GAGTableViewLongPressToMove;
                //cell长按状态开启，此时cell中的textField不接受点击事件
                cell.isLongPress = YES;
                //手势开始，对被选中cell截图，隐藏原cell
                self.oldIndexPath = [self indexPathForRowAtPoint:self.longLocation];
                if (self.oldIndexPath) {
                    [self snapshotCellAtIndexPath:self.oldIndexPath];
                }
                break;
            }
            case UIGestureRecognizerStateChanged:{//点击位置移动，判断手指按住位置是否进入其它indexPath范围，若进入则更新数据源并移动cell
               if (self.currentType == GAGTableViewLongPressToMove) {
                    //截图跟随手指移动
                    CGPoint center = _snapshotView.center;
                    center.y = self.longLocation.y;
                    self.snapshotView.center = center;
                    if ([self checkIfSnapshotMeetsEdge]) {
                        [self startAutoScrollTimer];
                    }else{
                        [self stopAutoScrollTimer];
                    }
                    //手指按住位置对应的indexPath，可能为nil
                    self.newestIndexPath = [self indexPathForRowAtPoint:self.longLocation];
                    if (self.newestIndexPath && ![self.newestIndexPath isEqual:self.oldIndexPath]) {
                        [self cellRelocatedToNewIndexPath:self.newestIndexPath];
                    }
                }
                break;
              
            }
            default: {
                //cell的长按状态结束
                cell.isLongPress = NO;
                self.currentType = GAGTableViewGestureNone;
                //长按手势结束或被取消，移除截图，显示cell
                [self stopAutoScrollTimer];
                [self didEndDraging];
                break;
            }
        }
}

/**
 对选中的cell进行截图，并且隐藏cell
 
 @param indexPath of UITableView
 */
-(void)snapshotCellAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    /// 截图
    UIImageView *snapshot = [UIView snapshotUIImageView:cell];
    /// 添加在UITableView上
    [self addSubview:snapshot];
    self.snapshotView = snapshot;
    
    /// 隐藏cell
    cell.hidden = YES;
    
    CGPoint center = self.snapshotView.center;
    center.y = self.longLocation.y;
    /// 移动截图
    [UIView animateWithDuration:0.2 animations:^{
        self.snapshotView.transform = CGAffineTransformMakeScale(1.03, 1.03);
        self.snapshotView.alpha = 0.98;
        self.snapshotView.center = center;
    }];
}

/**
 检查截图是否到达边缘，并作出响应

 @return <#return value description#>
 */
- (BOOL)checkIfSnapshotMeetsEdge{
    CGFloat minY = CGRectGetMinY(self.snapshotView.frame);
    CGFloat maxY = CGRectGetMaxY(self.snapshotView.frame);
    if (minY < self.contentOffset.y) {
        self.scrollType = GAGTableViewTypeTop;
        return YES;
    }
    if (maxY > self.bounds.size.height + self.contentOffset.y) {
        self.scrollType = GAGTableViewTypeBottom;
        return YES;
    }
    return NO;
}


/**
 当截图到了新的位置，先改变数据源，然后将cell移动过去

 @param indexPath <#indexPath description#>
 */
- (void)cellRelocatedToNewIndexPath:(NSIndexPath *)indexPath{
    //更新数据源并返回给外部
    [self.items moveItemFromIndex:self.oldIndexPath.row toIndex:self.newestIndexPath.row];
    [[GAGFileOperation shareOperation]save:self.items];
    [self log];

    //交换移动cell位置
    [self moveRowAtIndexPath:self.oldIndexPath toIndexPath:indexPath];
    //更新cell的原始indexPath为当前indexPath
    self.oldIndexPath = indexPath;
    
    GAGTableViewCell *cell = [self cellForRowAtIndexPath:_oldIndexPath];
    cell.hidden = YES;
}


/**
 开始自动滚动
 */
- (void)startAutoScroll {
    CGFloat pixelSpeed = 4;
    if (self.scrollType == GAGTableViewTypeTop) {     //向下滚动
        if (self.contentOffset.y > 0) {//向下滚动最大范围限制
            [self setContentOffset:CGPointMake(0, self.contentOffset.y - pixelSpeed)];
            self.snapshotView.center = CGPointMake(self.snapshotView.center.x, self.snapshotView.center.y - pixelSpeed);
        }
    }else{                                            //向上滚动
        if (self.contentOffset.y + self.bounds.size.height < self.contentSize.height) {//向下滚动最大范围限制
            [self setContentOffset:CGPointMake(0, self.contentOffset.y + pixelSpeed)];
            self.snapshotView.center = CGPointMake(self.snapshotView.center.x, self.snapshotView.center.y + pixelSpeed);
        }
    }
    
    ///  当把截图拖动到边缘，开始自动滚动，如果这时手指完全不动，则不会触发‘UIGestureRecognizerStateChanged’，对应的代码就不会执行，导致虽然截图在tableView中的位置变了，但并没有移动那个隐藏的cell，用下面代码可解决此问题，cell会随着截图的移动而移动
    self.newestIndexPath = [self indexPathForRowAtPoint:self.snapshotView.center];
    if (self.newestIndexPath && ![self.newestIndexPath isEqual:self.oldIndexPath]) {
        [self cellRelocatedToNewIndexPath:self.newestIndexPath];
    }
}


/**
 拖拽结束，显示cell，并移除截图
 */
- (void)didEndDraging{
    UITableViewCell *cell = [self cellForRowAtIndexPath:self.oldIndexPath];
    cell.hidden = NO;
    cell.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.snapshotView.center = cell.center;
        self.snapshotView.alpha = 0;
        self.snapshotView.transform = CGAffineTransformIdentity;
        cell.alpha = 1;
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
        self.oldIndexPath = nil;
        self.newestIndexPath = nil;
        
        [self reloadData];
    }];
}


/**
 创建定时器
 */
- (void)startAutoScrollTimer {
    if (!self.scrollTimer) {
        self.scrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(startAutoScroll)];
        [self.scrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}


/**
 销毁定时器
 */
- (void)stopAutoScrollTimer {
    if (self.scrollTimer) {
        [self.scrollTimer invalidate];
        self.scrollTimer = nil;
    }
}



@end

