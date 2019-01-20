//
//  GAGBaseTableView.m
//  Clear
//
//  Created by GMax on 2018/12/22.
//  Copyright © 2018 GAG. All rights reserved.
//

#import "GAGBaseTableView.h"

/**
 枚举类型，记录当前TableView上的手势类型
 GAGTableViewGestureType for current Gesture Type in tableView
 */
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

/**
 枚举类型，记录当前TableView滑动位置
 GAGTableViewGestureType for current scroll Location in tableView
 */
typedef NS_ENUM(NSInteger, GAGTableViewLocationType) {
    // TableView顶部
    GAGTableViewTop,
    // TableView底部
    GAGTableViewBottom
};


/**
 结构体GAGTouchPoint，记录捏合手势的两手指位置
 */
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

//properties for pull to add
/**
 占位cell
 */
@property (nonatomic,strong) GAGTableViewCell *placeholderCell;

/**
 tableView滚动中真实的偏移量
 real offset.y when pulling to add
 */
@property (nonatomic,assign) CGFloat realTableViewOffsetY;

/**
 记录滑动开始时的偏移量，以便判断滑动方向
 record the history offset.y for recognize the direction of pull
 */
@property (nonatomic, assign) CGFloat historyTableViewOffsetY;

//properties for longPress to move cell
/**
 记录手指所在的位置
 record the finger location when longPress
 */
@property (nonatomic, assign) CGPoint longLocation;

/**
 对被选中的cell的截图
 UIImageView which image is snapshot from the cell that longpress
 */
@property (nonatomic, strong) UIImageView *snapshotView;

/**
 被选中的cell的原始位置
 the old indexpath of cell that longpress
 */
@property (nonatomic, strong) NSIndexPath *oldIndexPath;

/**
 被选中的cell的新位置
 the new indexpath of cell that longpress
 */
@property (nonatomic, strong) NSIndexPath *newestIndexPath;


/**
 自动滚动的定时器
 scrollTimer that control the table auto scroll
 */
@property (nonatomic, strong) CADisplayLink *scrollTimer;

/**
 判断长按的cell滚动到底部、顶部
 judge the longpress cell move to the top of tableView or bottom
 */
@property (nonatomic, assign) GAGTableViewLocationType scrollType;

//property for pinch to add
/**
 捏合手势开始时，两个手指的位置
 locationes of two fingers when pinch gesture start
 */
@property (nonatomic, assign) GAGTouchPoint startPoint;

/**
 记录捏合手势的偏移量
 offset of fingers when pinch gesture move
 */
@property (nonatomic, assign) CGFloat pinchOffset;

/**
 即将添加新cell的indexpath
 indexPath of new cell that would add
 */
@property (nonatomic, strong) NSIndexPath *addCellIndex;

/**
 上下两个UIImageView，显示cell上下两张图片的折叠和展开效果
 UIImageViews for folding/unfolding the images of cell
 */
@property (nonatomic, strong) UIImageView *upperCellImageView;
@property (nonatomic, strong) UIImageView *lowerCellImageView;

@end

@implementation GAGBaseTableView

#pragma mark - setter of items
- (void)setItems:(GAGItems *)items {
    _items = items;
    [self reloadData];
}

#pragma mark - override the initWithFrame
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //set backgroudColor
        self.backgroundColor = [UIColor clearColor];
        
        //set separatorStyle of cells
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //hide indicator
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        //cell allow select
        self.allowsSelection = NO;
        
        //set tableViewDelegate & Datasource
        self.delegate = self;
        self.dataSource = self;
        
        //set initial contentInset of tableview
        self.contentInset = UIEdgeInsetsMake(HeaderLabelHeight, 0, 0, 0);
        
        //add pinch recognizer to tableView
        UIGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

#pragma mark - build other views

- (UIView *)coverView {
    if (_coverView == nil) {
        _coverView = [[UIView alloc]init];
        [self.superview addSubview:_coverView];
        _coverView.frame = CGRectMake(0,StatusbarHeight + HeaderLabelHeight + TableViewCellHeight, self.width, self.height);
        _coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    }
    return _coverView;
}

- (void)showCoverViewWithHidden:(BOOL)coverViewHidden {
    [self bringSubviewToFront:self.coverView];
    self.coverView.hidden = coverViewHidden;
}

- (GAGTableViewCell *)placeholderCell {
    if (_placeholderCell == nil) {
        //单独创建一个cell
        static NSString *cellID = GAGTableViewCellID;
        _placeholderCell =  [[GAGTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //设置cell的背景色
        _placeholderCell.backgroundColor = [UIColor redColor];
        //设置cell.bounds，不然无法生成UIImage
        //设置cell的内容
        _placeholderCell.gradientLayer.hidden = YES;
    }
    return _placeholderCell;
}

- (UIImageView *)upperCellImageView {
    if (_upperCellImageView == nil) {
        _upperCellImageView = [[UIImageView alloc]init];
        _upperCellImageView.contentMode = UIViewContentModeCenter;
        _upperCellImageView.layer.anchorPoint = CGPointMake(0.5, 0);
        _upperCellImageView.contentMode = UIViewContentModeScaleAspectFill;
        _upperCellImageView.clipsToBounds = YES;

    }
    return _upperCellImageView;
}

- (UIImageView *)lowerCellImageView {
    if (_lowerCellImageView == nil) {
        _lowerCellImageView = [[UIImageView alloc]init];
        _lowerCellImageView.contentMode = UIViewContentModeCenter;
        _lowerCellImageView.layer.anchorPoint = CGPointMake(0.5, 1);
        _lowerCellImageView.contentMode = UIViewContentModeScaleAspectFill;
        _lowerCellImageView.clipsToBounds = YES;
    }
    return _lowerCellImageView;
}

#pragma mark - set backgroundColor of cells

- (UIColor *)colorWithIndexPath:(NSIndexPath*)indexPath {
    NSUInteger count = self.items.things.count - 1;
    CGFloat val = 0.6 *  indexPath.row / count ;
    return [UIColor colorWithRed: 1.0 green:val blue: 0.0 alpha:1.0];
}


- (void)refreshCellsColor{
    for (GAGTableViewCell *cell in self.visibleCells) {
        NSIndexPath *indexPath = [self indexPathForCell:cell];
        cell.backgroundColor = [self colorWithIndexPath:indexPath];
    }
}

#pragma mark - TableView DataSource

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
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}

#pragma mark - GAGTableViewCell Delegate
- (void)cellShouldDeleted:(GAGItem*)item {
    //delete item in model
    NSUInteger index = [self.items.things indexOfObject:item];
    [self.items.things removeObject:item];
    [[GAGFileOperation sharedOperation]save:self.items];
    
    //delete cell
    [self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    [self refreshCellsColor];
    
    [self log];
}

- (void)cellShouldCompleted:(GAGItem*)item{
    
    //move model
    NSUInteger index = [self.items.things indexOfObject:item];
    [self.items moveItemToCompletionWithIndex:index];
    [[GAGFileOperation sharedOperation]save:self.items];
    
    //move cell
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSIndexPath *toIndexPath;
    NSInteger i = [self.items getCountOfUncompletedItem];
    if (item.completed == YES) {
        toIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
    }else {
        toIndexPath = [NSIndexPath indexPathForRow:i - 1 inSection:0];
    }

    [self moveRowAtIndexPath:indexPath toIndexPath:toIndexPath];
    [self refreshCellsColor];

    [self log];
    
}

- (void)cellDidBeginEditing:(GAGTableViewCell*)cell item:(GAGItem*)item{
    //当开始编辑时，cell不允许长按或者滑动
    //cell could not accept pan gesture when begin edit
    cell.gestureRecognizerEnable = NO;
    
    //让controller改变头部标题栏的透明度变为1
    //let controller change alpha of headerLabel to 1
    if ([self.tableViewDelegate respondsToSelector:@selector(tableViewDidBeginEditing)]) {
        [self.tableViewDelegate tableViewDidBeginEditing];
    }
    //显示coverView
    //show coverView
    [self showCoverViewWithHidden:NO];
    
    //将cell向上移动，让点击的cell移动到tableView的顶部
    //move cells and show cell on the top of tableView
    CGFloat selectedCellY = cell.y;
    for (GAGTableViewCell *cell in self.visibleCells) {
        cell.transform = CGAffineTransformMakeTranslation(0,- selectedCellY);
    }
 
    [self log];
}

- (void)cellDidEndEditing:(GAGTableViewCell*)cell item:(GAGItem*)item{
    //编辑事件结束后，恢复cell可以接受滑动事件
    //cell could accept pan gesture when end edit
    cell.gestureRecognizerEnable = YES;
    
    //让controller改变头部标题栏的透明度变为0.7
    //let controller change alpha of headerLabel to 0.7
    if ([self.tableViewDelegate respondsToSelector:@selector(tableViewDidEndEditing)]) {
        [self.tableViewDelegate tableViewDidEndEditing];
    }
    //隐藏coverView
    //hide coverView
    [self showCoverViewWithHidden:YES];
    
    //恢复cells的位置
    //resume cell tranform
    [UIView animateWithDuration:0.5 animations:^{
        for (GAGTableViewCell *cell in self.visibleCells) {
            cell.transform = CGAffineTransformIdentity;
        }
    }];

    
    NSUInteger index = [self.items.things indexOfObject:item];
    //cell内容为空时，需要被删除
    //when cell.textField.text == null,delete cell
    if ([cell.textField.text isEqualToString:[NSString stringWithFormat:@""]]) {
        [self cellShouldDeleted:self.items.things[index]];
    }else {
    //cell内容不为空时，需要保存
    //when cell.textField.text != null,save items
        self.items.things[index].thing = cell.textField.text;
        [[GAGFileOperation sharedOperation]save:self.items];
        [self reloadData];
    }
    
    [self log];
}

#pragma mark - handle pull gesture / UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    //记录下偏移量，以便接下来判断滑动方向
    self.historyTableViewOffsetY = scrollView.contentOffset.y;
    
    //将占位cell添加到superView上x
    [self.superview addSubview:self.placeholderCell];
    [self.superview sendSubviewToBack:self.placeholderCell];

    self.currentType = GAGTableViewPullToAdd;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //由于tableView初始时又偏移量，因此计算下真实的偏移量
    //because of initial contentInset of tableView, should caculate real offset of tableView now
    self.realTableViewOffsetY = scrollView.contentOffset.y + HeaderLabelHeight + StatusbarHeight;
//    NSLog(@"DidScroll ---realTableViewOffsetY    %f",self.realTableViewOffsetY);
    
    //如果向下滑动:
    //if pull down:
    if (scrollView.contentOffset.y < self.historyTableViewOffsetY) {
//    if (scrollView.contentOffset.y < self.historyTableViewOffsetY && self.currentType == GAGTableViewPullToAdd) {
       
        //当实际滑动距离为0到TableViewCellHeight时:
        //when real offset is 0 ~ TableViewCellHeight:
        if (self.realTableViewOffsetY <= 0 && self.realTableViewOffsetY > - TableViewCellHeight) {
            //设置占位cell的frame
            //set placeholderCell.frame
            self.placeholderCell.frame = CGRectMake(0, HeaderLabelHeight+ StatusbarHeight,ScreenWidth,fabs(self.realTableViewOffsetY));
            //设置占位cell的内容
            //set placeholderCell's text
            self.placeholderCell.textField.text = @"pull to create items";

            //计算旋转角度
            //caculate angle of tranform
            CGFloat angle = M_PI_2 - fabs(self.realTableViewOffsetY) * M_PI_2 /  TableViewCellHeight;
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = - 1 / 100.0;
            
            //设置占位cell的锚点
            //set anchorPoint
            self.placeholderCell.layer.anchorPoint = CGPointMake(0.5, 1);
            
            //做CATransform3DRotate变换
            //make CATransform3DRotate
            self.placeholderCell.layer.transform = CATransform3DRotate(transform, angle, 1, 0, 0);
            
        //当实际滑动距离为TableViewCellHeight时:
        //when real offset is TableViewCellHeight:
        }else if (self.realTableViewOffsetY == - TableViewCellHeight){
            //恢复CATransform3DRotate状态
            //resume CATransform3DRotate
            self.placeholderCell.layer.transform = CATransform3DIdentity;
            
            //改变占位cell中的提示内容
            //change text of cell
            self.placeholderCell.textField.text = @"release to add items";
            
        //当实际滑动距离大于TableViewCellHeight时:
        //when real offset > TableViewCellHeight:
        }else {
            //再做一次恢复CATransform3DRotate状态，主要是为了滑动速度非常快时的效果流畅
            //resume CATransform3DRotate again for smooth effect when pulling down very fast
            self.placeholderCell.layer.transform = CATransform3DIdentity;
            
            //改变占位cell中的提示内容
            //change text of cell
            self.placeholderCell.textField.text = @"release to add item";
            
            //placeholderCell跟随tableview第一个cell移动
            //let placeholderCell move by the first cell
            self.placeholderCell.y = HeaderLabelHeight + StatusbarHeight + fabs(self.realTableViewOffsetY) - TableViewCellHeight;
            self.placeholderCell.height = TableViewCellHeight;
        }
        
        
    //向上滑动:
    //move up:
    }else if (scrollView.contentOffset.y >=  self.historyTableViewOffsetY){
        //把placeholderCell移除
        //[self.placeholderCell removeFromSuperview];
    }

}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //设置当前手势状态为无手势
    //set current gesture type
    self.currentType = GAGTableViewGestureNone;
    
    //只有当滑动距离大于等于TableViewCellHeight时，释放才能添加新item
    //add new Item & cell when real offset >= TableViewCellHeight
    if (self.realTableViewOffsetY <= - TableViewCellHeight) {
        //移除占位cell
        //remove placeholder cell
        [self.placeholderCell removeFromSuperview];

        //新增一个item
        //update model by add new items
        GAGItem *newItem = [[GAGItem alloc]init];
        [self.items addItemAtTop:newItem];
        
        //注意：这里必须想加入一个item再增加一行，否则model和view对应不上
        //notice: add new item before new cell
        [self insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        //UITableViewRowAnimationBottom效果也不错，也挺好看的
        //UITableViewRowAnimationBottom is also good effect
        
        //拿到第一个cell，让他成为响应者。并接着用户编辑事件
        //make the new cell becomeFirstResponder,and begin to edit
        GAGTableViewCell *firstCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [firstCell.textField becomeFirstResponder];
    }
    
}

#pragma mark - handle pinch gesture

//控制捏合手势的各个不同状态
//control differt states of pinch gesture
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
    //记录两个手指的位置
    //record points of two fingers
    self.startPoint = [self getRealTouchPoint:recognizer];
    
    //记录两个手指分别对应的indexPath
    //record two IndexPath of two fingers
    NSIndexPath *upperCellIndex = [self indexPathForRowAtPoint:self.startPoint.upper];
    NSIndexPath *downCellIndex = [self indexPathForRowAtPoint:self.startPoint.lower];
    
    //四舍五入计算新cell添加的indexPath
    //caculate new cell IndexPath by rounding off
    int index = (int)(0.5 + (upperCellIndex.row + downCellIndex.row) * 0.5);
    self.addCellIndex = [NSIndexPath indexPathForRow:index inSection:0];
    
    //加入上下两个UIImageView，并放置在最后一层
    //add two UIImageView
    [self addSubview:self.upperCellImageView];
    [self sendSubviewToBack:self.upperCellImageView];
    [self addSubview:self.lowerCellImageView];
    [self sendSubviewToBack:self.lowerCellImageView];
    
    //set frame
    self.upperCellImageView.frame = CGRectMake(0, 0, self.width , TableViewCellHeight * 0.5);
    self.lowerCellImageView.frame = CGRectMake(0, 0, self.width , TableViewCellHeight * 0.5);

    //set image
    NSArray *imgs = [self getHalfTopAndBottomImageFromCache];
    self.upperCellImageView.image = [imgs firstObject];
    self.lowerCellImageView.image = [imgs lastObject];

    //make them hide
    self.upperCellImageView.hidden = NO;
    self.lowerCellImageView.hidden = NO;
}


/**
 返回上下半张图片的array
 return array that contain half-top & half-bottom images
 */
- (NSArray <UIImage*>*)getHalfTopAndBottomImageFromCache {
    /*
     // 可以在NSCachesDirectory保存placecell的截图
     // can save image by snapshot placeholdercell to NSCachesDirectory
     
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"placeholder.png"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        UIImage *placeholderImage = [UIView snapshotUIImage:self.placeholderCell];
        NSString *imagePath = [path stringByAppendingPathComponent:@"placeholder.png"];
        [UIImagePNGRepresentation(placeholderImage) writeToFile:imagePath atomically:YES];
    }
    UIImage *originalImage = [UIImage imageWithContentsOfFile:filePath];
    */
    
    //也可以直接从assert中读取
    //also can read image form assert
    UIImage *originalImage = [UIImage imageNamed:@"placeholder.png"];
    UIImage *topImage = [originalImage imageByCroppingWithStyle:GAGCropImageStyleTop];
    UIImage *bottomImage = [originalImage imageByCroppingWithStyle:GAGCropImageStyleBottom];
    return @[topImage,bottomImage];

}
/**
 获取上下两根手指的point
 get read two touch points in tableView
  */
- (GAGTouchPoint)getRealTouchPoint : (UIPinchGestureRecognizer*)recognizer {
    CGPoint pointOne = [recognizer locationOfTouch:0 inView:self];
    CGPoint pointTwo = [recognizer locationOfTouch:1 inView:self];

    //change points ,make sure upper and lower
    if (pointOne.y > pointTwo.y) {
        CGPoint temp = pointOne;
        pointOne = pointTwo;
        pointTwo = temp;
    }
    
    GAGTouchPoint point = {pointOne,pointTwo};
    return point;
}


/**
 计算捏合手势中的偏移量
 caculate offset of pinch recognizer
 */
- (CGFloat)pinchOffsetWith:(UIPinchGestureRecognizer*)recognizer {
    GAGTouchPoint currentTouchPoint = [self getRealTouchPoint:recognizer];
    CGFloat upperOffsetY = currentTouchPoint.upper.y  -  self.startPoint.upper.y;
    CGFloat lowerOffsetY = self.startPoint.lower.y - currentTouchPoint.lower.y;

    return  - MIN(0, MIN(upperOffsetY, lowerOffsetY));
}

/**
 当捏合手势变化时，移动cell上下移动
 move cells up or down when pinch gesture Changed
 */
- (void)moveCellsWithOffset:(CGFloat)offset {
    
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
 
    self.pinchOffset = [self pinchOffsetWith:recognizer];
    
    //上下移动其他cell
    //move cells up and down
    [self moveCellsWithOffset:self.pinchOffset];
    
    [self moveUpperAndLowerImageView];
    
    if (self.pinchOffset > 0 && self.pinchOffset < TableViewCellHeight * 0.5){
        
        [self makeCATransform3DConcatWithOffset:self.pinchOffset];
        
    }else {
        //恢复两个UIImageView的tranform
        //resume two UIImageView transform
        self.upperCellImageView.layer.transform = CATransform3DIdentity;
        self.lowerCellImageView.layer.transform = CATransform3DIdentity;

        //调整两个imageView的center,调整好两者的位置关系
        //change two location of two UIImageView
        CGPoint center1 = self.upperCellImageView.center;
        self.lowerCellImageView.center = CGPointMake(center1.x, center1.y + self.upperCellImageView.height );
        self.upperCellImageView.center = CGPointMake(center1.x, center1.y - self.upperCellImageView.height);
    }
 
}

/**
 根据偏移量做3D混合变换
 make CATransform3DConcat with offset
 */
- (void)makeCATransform3DConcatWithOffset:(CGFloat)offset {
    //做CATransform3DConcat变换
    //make CATransform3DConcat
    CGFloat angle1 = - M_PI_2 + offset * 11 * M_PI_4 / (60 * 3);
    CGFloat angle2 = M_PI_2 - offset * 11 * M_PI_4 / (60 * 3);
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1 / 200.0;
    
    CATransform3D transRotate1 = CATransform3DRotate(transform,angle1, 1, 0, 0);
    CATransform3D transTranslate1 = CATransform3DMakeTranslation(0, - offset * 11 * 15/ (60 * 3), 0);
    
    self.upperCellImageView.layer.transform = CATransform3DConcat (transRotate1,transTranslate1);
    CATransform3D transRotate2 = CATransform3DRotate(transform,angle2, 1, 0, 0);
    CATransform3D transTranslate2 = CATransform3DMakeTranslation(0, offset * 11 * 15/ (60 * 3), 0);
    self.lowerCellImageView.layer.transform = CATransform3DConcat (transRotate2,transTranslate2);
}

/**
 在捏合过程中改变两个UIImageView的位置
 change center of two UIImageView when pinch changed
 */
- (void)moveUpperAndLowerImageView {
    //得到插入新位置的上下各一个cell
    //get the first upper and lower cell addCellIndex
    GAGTableViewCell *upperCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(self.addCellIndex.row - 1) inSection:0]];
    GAGTableViewCell *lowerCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.addCellIndex.row inSection:0]];
    
    //改变上下两个UIImageView.center
    //change center of two UIImageView
    self.upperCellImageView.center = CGPointMake(self.width * 0.5, CGRectGetMaxY(upperCell.frame) + 0.5 * (lowerCell.y - CGRectGetMaxY(upperCell.frame)));
    self.lowerCellImageView.center = self.upperCellImageView.center;
}

- (void)pinchEnded:(UIPinchGestureRecognizer*)recognizer {
    self.pinchOffset = [self pinchOffsetWith:recognizer];

    //恢复所有cell的位置
    //resume all cells tranform
    [UIView animateWithDuration:0.3 animations:^{
        for (GAGTableViewCell *cell in self.visibleCells) {
            cell.transform = CGAffineTransformIdentity;
        }
    }];
    
    //如果松手时捏合手势偏移量大于高度的一半
    //if offset > TableViewCellHeight * 0.5 :
    if (self.pinchOffset >= TableViewCellHeight * 0.5) {
        //remove UIImageViews
        [self.upperCellImageView removeFromSuperview];
        [self.lowerCellImageView removeFromSuperview];
        
        //加入新cell，让他成为响应者。并接着用户编辑事件
        //insert new cell and make it becomeFirstResponder
        [UIView animateWithDuration:0.5 animations:^{
            GAGItem *newItem = [[GAGItem alloc]init];
            [self.items addItemAtIndex:newItem index:self.addCellIndex.row];
            [self insertRowsAtIndexPaths:@[self.addCellIndex] withRowAnimation:UITableViewRowAnimationNone];
        } completion:^(BOOL finished) {
           NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.addCellIndex.row  inSection:0];
            GAGTableViewCell *newCell = [self cellForRowAtIndexPath:newIndexPath];
            [newCell.textField becomeFirstResponder];
        }];
     
    }
#warning have bugs
    else if (self.pinchOffset < TableViewCellHeight * 0.5 && self.pinchOffset > 0) {
        [self moveUpperAndLowerImageView];
        [self makeCATransform3DConcatWithOffset:self.pinchOffset];
    }else if (self.pinchOffset == 0) {
        [self.upperCellImageView removeFromSuperview];
        [self.lowerCellImageView removeFromSuperview];
    }
}

#pragma mark - handle pull gesture / LongPress delegate
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
 */
- (BOOL)checkIfSnapshotMeetsEdge{
    CGFloat minY = CGRectGetMinY(self.snapshotView.frame);
    CGFloat maxY = CGRectGetMaxY(self.snapshotView.frame);
    if (minY < self.contentOffset.y) {
        self.scrollType = GAGTableViewTop;
        return YES;
    }
    if (maxY > self.bounds.size.height + self.contentOffset.y) {
        self.scrollType = GAGTableViewBottom;
        return YES;
    }
    return NO;
}


/**
 当截图到了新的位置，先改变数据源，然后将cell移动过去
 */
- (void)cellRelocatedToNewIndexPath:(NSIndexPath *)indexPath{
    //更新数据源并返回给外部
    [self.items moveItemFromIndex:self.oldIndexPath.row toIndex:self.newestIndexPath.row];
    [[GAGFileOperation sharedOperation]save:self.items];
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
    if (self.scrollType == GAGTableViewTop) {     //向下滚动
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
        
        //[self reloadData];
        [self refreshCellsColor];
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

#pragma mark - debug 
- (void)log {
    for (GAGItem *item in self.items.things) {
        NSLog(@"%@---%d",item.thing,item.completed);
    }
    NSLog(@"+++++++++++++++++++++++++++++++++++++++++++++++++++");
}

@end

