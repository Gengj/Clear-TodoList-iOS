//
//  GAGBaseTableView.m
//  Clear
//
//  Created by GMax on 2018/12/22.
//  Copyright © 2018 GAG. All rights reserved.
//

#import "GAGBaseTableView.h"

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
@property (nonatomic, assign) CGFloat pinchOffset;
@property (nonatomic, strong) NSIndexPath *pinchOneCellIndex;
@property (nonatomic, strong) NSIndexPath *pinchTwoCellIndex;
@property (nonatomic, strong) NSIndexPath *addCellIndex;
@property (nonatomic, strong) UIImageView *cellImageView1;
@property (nonatomic, strong) UIImageView *cellImageView2;
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

- (UIImageView *)cellImageView1 {
    if (_cellImageView1 == nil) {
        _cellImageView1 = [[UIImageView alloc]init];
        _cellImageView1.contentMode = UIViewContentModeCenter;
        _cellImageView1.layer.anchorPoint = CGPointMake(0.5, 0);
    }
    return _cellImageView1;
}

- (UIImageView *)cellImageView2 {
    if (_cellImageView2 == nil) {
        _cellImageView2 = [[UIImageView alloc]init];
        _cellImageView2.contentMode = UIViewContentModeCenter;
        _cellImageView2.layer.anchorPoint = CGPointMake(0.5, 1);
    }
    return _cellImageView2;
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
    
    NSUInteger index = [self.items.things indexOfObject:item];
    [self.items.things removeObject:item];
    [[GAGFileOperation shareOperation]save:self.items];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    }completion:^(BOOL finished) {
        [self reloadData];
    }];
    
    [self log];
}

// 已完成的再滑动变未完成
- (void)cellShouldCompleted:(GAGItem*)item{
    
    NSUInteger index = [self.items.things indexOfObject:item];
//    self.items.things[index].completed = !item.completed;
    [self.items moveItemToCompletionWithIndex:index];
    [[GAGFileOperation shareOperation]save:self.items];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:[self.items getCountOfUncompletedItem] inSection:0];

    [UIView animateWithDuration:0.5 animations:^{
        [self moveRowAtIndexPath:indexPath toIndexPath:toIndexPath];
    } completion:^(BOOL finished) {
        [self reloadData];
    }];

    [self log];
    
}

- (void)cellDidBeginEditing:(GAGTableViewCell*)cell item:(GAGItem*)item{
    cell.gestureRecognizerEnable = NO;
    
    if ([self.tableViewDelegate respondsToSelector:@selector(tableViewDidBeginEditing)]) {
        [self.tableViewDelegate tableViewDidBeginEditing];
    }
    [self setCoverViewHidden:NO];
    
    CGFloat selectedCellY = cell.y;
    
    for (GAGTableViewCell *cell in self.visibleCells) {
        cell.transform = CGAffineTransformMakeTranslation(0,- selectedCellY);
    }
 
    [self log];
}

- (void)cellDidEndEditing:(GAGTableViewCell*)cell item:(GAGItem*)item{
    cell.gestureRecognizerEnable = YES;
    
    if ([self.tableViewDelegate respondsToSelector:@selector(tableViewDidEndEditing)]) {
        [self.tableViewDelegate tableViewDidEndEditing];
    }
    [self setCoverViewHidden:YES];
    
    [UIView animateWithDuration:0.5 animations:^{
        for (GAGTableViewCell *cell in self.visibleCells) {
            cell.transform = CGAffineTransformIdentity;
        }
    }];

    
    NSUInteger index = [self.items.things indexOfObject:item];
        //cell内容为空时，需要被删除
    if ([cell.textField.text isEqualToString:[NSString stringWithFormat:@""]]) {
        [self cellShouldDeleted:self.items.things[index]];
    }else {    //cell内容不为空时，需要保存
        self.items.things[index].thing = cell.textField.text;
        [[GAGFileOperation shareOperation]save:self.items];
        [self reloadData];
    }
    
    [self log];

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
//    NSLog(@"DidScroll ---realTableViewOffsetY    %f",self.realTableViewOffsetY);
    
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
//            [self cellDidBeginEditing:firstCell];
        
    }
    
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
    NSLog(@"%s",__func__);

    self.startPoint = [self getRealTouchPoint:recognizer];
    
    //捏合开始时，上下手指分别对应的indexPath
    self.pinchOneCellIndex = [self indexPathForRowAtPoint:self.startPoint.upper];
    self.pinchTwoCellIndex = [self indexPathForRowAtPoint:self.startPoint.lower];
    //四舍五入计算新cell添加的indexPath
    int index = (int)(0.5 + (self.pinchOneCellIndex.row + self.pinchTwoCellIndex.row) * 0.5);
    self.addCellIndex = [NSIndexPath indexPathForRow:index inSection:0];
    NSLog(@"new index - %ld",self.addCellIndex.row);
    
    /*
    //把placeholder添加上来。准备做截图
    [self addSubview:self.placeholderCell];
    [self sendSubviewToBack:self.placeholderCell];
    //给他设置个frame和标题
    self.placeholderCell.frame = CGRectMake(0, 50, self.width, TableViewCellHeight);
    self.placeholderCell.textField.text = @"pull to add items";

    NSLog(@"%@",NSStringFromCGRect(self.placeholderCell.frame));
*/
//
//    GAGItem *newItem = [[GAGItem alloc]init];
//    [self.items addItemAtIndex:newItem index:self.AddCellIndex.row];
//
//    [self insertRowsAtIndexPaths:@[self.AddCellIndex] withRowAnimation:UITableViewRowAnimationNone];
//    GAGTableViewCell *newCell = [self cellForRowAtIndexPath:self.AddCellIndex];
//    newCell.textField.text = @"pull to add items";
    

//
    [self addSubview:self.cellImageView1];
    [self sendSubviewToBack:self.cellImageView1];
    [self addSubview:self.cellImageView2];
    [self sendSubviewToBack:self.cellImageView2];
    

    self.cellImageView1.frame = CGRectMake(0, 0, self.width , TableViewCellHeight * 0.5);
    self.cellImageView2.frame = CGRectMake(0, 0, self.width , TableViewCellHeight * 0.5);

    NSArray *imgs = [self getPlaceholderTopAndBottomImageFromCache];
    self.cellImageView1.image = [imgs firstObject];
    self.cellImageView2.image = [imgs lastObject];
    self.cellImageView1.contentMode = UIViewContentModeScaleAspectFill;
    self.cellImageView2.contentMode = UIViewContentModeScaleAspectFill;
    self.cellImageView1.clipsToBounds = YES;
    self.cellImageView2.clipsToBounds = YES;

    self.cellImageView1.hidden = NO;
    self.cellImageView2.hidden = NO;
    
    NSLog(@"%s",__func__);

}

- (NSArray <UIImage*>*)getPlaceholderTopAndBottomImageFromCache {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"placeholder.png"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        UIImage *placeholderImage = [UIView snapshotUIImage:self.placeholderCell];
        NSString *imagePath = [path stringByAppendingPathComponent:@"placeholder.png"];
        [UIImagePNGRepresentation(placeholderImage) writeToFile:imagePath atomically:YES];
    }
    UIImage *originalImage = [UIImage imageWithContentsOfFile:filePath];
    UIImage *topImage = [originalImage imageByCroppingWithStyle:GAGCropImageStyleTop];
    UIImage *bottomImage = [originalImage imageByCroppingWithStyle:GAGCropImageStyleBottom];
    return @[topImage,bottomImage];

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


/**
 caculate offset of pinch recognizer

 @param recognizer UIPinchGestureRecognizer
 @return CGFloat offset
 */
- (CGFloat)pinchOffsetWith:(UIPinchGestureRecognizer*)recognizer {
    GAGTouchPoint currentTouchPoint = [self getRealTouchPoint:recognizer];
    CGFloat upperOffsetY = currentTouchPoint.upper.y  -  self.startPoint.upper.y;
    CGFloat lowerOffsetY = self.startPoint.lower.y - currentTouchPoint.lower.y;
    
    //偏移量
    return  - MIN(0, MIN(upperOffsetY, lowerOffsetY));
}


/**
 move cells up or down when pinchChanged

 @param offset <#offset description#>
 */
- (void)moveOtherCellsWithOffset:(CGFloat)offset {
    
    for (int i = 0; i < self.items.things.count; i++) {
        GAGTableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (i < self.addCellIndex.row) {
            cell.transform = CGAffineTransformMakeTranslation(0, - offset);
        }
        if (i >= self.addCellIndex.row) {
            cell.transform = CGAffineTransformMakeTranslation(0,  offset);
        }
    }
}
- (void)pinchChanged:(UIPinchGestureRecognizer*)recognizer {
    NSLog(@"%s",__func__);

    //得到手指指向的位置
    self.pinchOffset = [self pinchOffsetWith:recognizer];
    NSLog(@"offset----%f",self.pinchOffset);

    //上下移动其他cell
    [self moveOtherCellsWithOffset:self.pinchOffset];
    
    //得到插入新位置的上下cell
    GAGTableViewCell *upperCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(self.addCellIndex.row - 1) inSection:0]];
    GAGTableViewCell *lowerCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.addCellIndex.row inSection:0]];

    self.cellImageView1.center = CGPointMake(self.width * 0.5, CGRectGetMaxY(upperCell.frame) + 0.5 * (lowerCell.y - CGRectGetMaxY(upperCell.frame)));
    self.cellImageView2.center = self.cellImageView1.center;
    
    if (self.pinchOffset > 0 && self.pinchOffset < TableViewCellHeight * 0.5){
    
//  center
//        self.cellImageView1.center = CGPointMake(self.width * 0.5, CGRectGetMaxY(upperCell.frame) + 0.25 * (lowerCell.y - CGRectGetMaxY(upperCell.frame)));
//        self.cellImageView2.center = CGPointMake(self.width * 0.5, CGRectGetMaxY(upperCell.frame) + 0.75 * (lowerCell.y - CGRectGetMaxY(upperCell.frame)));
        
//    offset = offset * ;
//    CGFloat angle1 = - M_PI_2 + offset * 11 * M_PI_4 / (60 * 3);
//    CGFloat angle2 = M_PI_2 - offset * 11 * M_PI_4 / (60 * 3);
        
    CGFloat angle1 = - M_PI_2 + self.pinchOffset * 11 * M_PI_4 / (60 * 3);
    CGFloat angle2 = M_PI_2 - self.pinchOffset * 11 * M_PI_4 / (60 * 3);
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1 / 200.0;
    
    CATransform3D transRotate1 = CATransform3DRotate(transform,angle1, 1, 0, 0);
    CATransform3D transTranslate1 = CATransform3DMakeTranslation(0, -  self.pinchOffset * 11 * 15/ (60 * 3), 0);
    
    self.cellImageView1.layer.transform = CATransform3DConcat (transRotate1,transTranslate1);
    CATransform3D transRotate2 = CATransform3DRotate(transform,angle2, 1, 0, 0);
    CATransform3D transTranslate2 = CATransform3DMakeTranslation(0, self.pinchOffset * 11 * 15/ (60 * 3), 0);
    self.cellImageView2.layer.transform = CATransform3DConcat (transRotate2,transTranslate2);

        
        
 }else {
     self.cellImageView1.layer.transform = CATransform3DIdentity;
     self.cellImageView2.layer.transform = CATransform3DIdentity;
     
     //调整两个imageView的center,调整好两者的位置关系
     CGPoint center1 = self.cellImageView1.center;
     self.cellImageView2.center = CGPointMake(center1.x, center1.y + self.cellImageView1.height );
     self.cellImageView1.center = CGPointMake(center1.x, center1.y - self.cellImageView1.height);
    }
 
}
- (void)pinchEnded:(UIPinchGestureRecognizer*)recognizer {
        NSLog(@"%s",__func__);

    
        [UIView animateWithDuration:0.3 animations:^{
            for (int i = 0; i < self.items.things.count; i++) {
                GAGTableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                
                cell.transform = CGAffineTransformIdentity;
            }
        }];
    

 if (self.pinchOffset > 30) {
    [self.cellImageView1 removeFromSuperview];
    [self.cellImageView2 removeFromSuperview];
    //拿到第一个cell，让他成为响应者。并接着用户编辑事件
    [UIView animateWithDuration:0.5 animations:^{
        GAGItem *newItem = [[GAGItem alloc]init];
        [self.items addItemAtIndex:newItem index:self.addCellIndex.row];
        [self insertRowsAtIndexPaths:@[self.addCellIndex] withRowAnimation:UITableViewRowAnimationNone];
   } completion:^(BOOL finished) {
       NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.addCellIndex.row  inSection:0];
        GAGTableViewCell *newCell = [self cellForRowAtIndexPath:newIndexPath];
       
       

        [newCell.textField becomeFirstResponder];
//        [self cellDidBeginEditing:firstCell];
    }];
     
}
}

- (void)logCellAddr{
    for (NSInteger i = 0; i < self.items.things.count; i++) {
        GAGTableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSLog(@"%p",cell);
    }
    NSLog(@"------------");
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
               if (self.currentType == GAGTableViewLongPressToMove && self.currentType != GAGTableViewPinchToAdd) {
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


- (void)log {
    for (GAGItem *item in self.items.things) {
        NSLog(@"%@---%d",item.thing,item.completed);
    }
    NSLog(@"++++++++++++++++++++");
}

@end

