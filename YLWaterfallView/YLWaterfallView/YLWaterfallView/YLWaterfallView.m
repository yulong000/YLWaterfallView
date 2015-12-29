//
//  YLWaterfallView.m
//  YLWaterfallView
//
//  Created by DreamHand on 15/12/24.
//  Copyright © 2015年 WYL. All rights reserved.
//

#import "YLWaterfallView.h"

#define NSStringFromInt(int) [NSString stringWithFormat:@"%d", int]
#define NSStringFromInteger(integer) [NSString stringWithFormat:@"%ld", integer]
#define NSStringFromDouble(double) [NSString stringWithFormat:@"%lf", double]

// 默认的列数
#define kWaterfallViewColumnNumberDefault 3.0

// 默认的水平间距
#define kWaterfallViewHorizontalGapDefault 5

// 默认的垂直间距
#define kWaterfallViewVerticalGapDefault kWaterfallViewHorizontalGapDefault

// 默认的分组间的间距
#define kWaterfallViewSectionsGapDefault 20

// 默认的 cell 的高度
#define kWaterfallViewCellHeightDefault 50

// cell 动画的时长
#define kWaterfallViewCellAnimatedTimeInterval 0.3

@interface YLWaterfallViewCell ()

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation YLWaterfallViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super init])
    {
        _identrifier = reuseIdentifier;
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
        _separatorInset = UIEdgeInsetsZero;
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat x = self.separatorInset.left;
    CGFloat y = self.separatorInset.top;
    CGFloat w = self.bounds.size.width - self.separatorInset.left - self.separatorInset.right;
    CGFloat h = self.bounds.size.height - self.separatorInset.top - self.separatorInset.bottom;
    _contentView.frame = CGRectMake(x, y, w, h);
    
    if(_backgroundView)
    {
        _backgroundView.frame = _contentView.bounds;
    }
    if(_selectedBackgroundView)
    {
        _selectedBackgroundView.frame = _contentView.bounds;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    
    self.alpha = highlighted ? 0.8 : 1;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [UIView animateWithDuration:(animated ? kWaterfallViewCellAnimatedTimeInterval : 0) animations:^{
        
        [self setHighlighted:highlighted];
    }];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if(selected)
    {
        if(self.selectedBackgroundView)
        {
            if(self.backgroundView.superview)
            {
                [self.backgroundView removeFromSuperview];
            }
            if(self.selectedBackgroundView.superview == nil)
            {
                [_contentView addSubview:self.selectedBackgroundView];
                [_contentView insertSubview:self.selectedBackgroundView atIndex:0];
            }
        }
    }
    else
    {
        if(self.backgroundView)
        {
            if(self.selectedBackgroundView.superview)
            {
                [self.selectedBackgroundView removeFromSuperview];
            }
            if(self.backgroundView.superview == nil)
            {
                [_contentView addSubview:self.backgroundView];
                [_contentView insertSubview:self.backgroundView atIndex:0];
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [UIView animateWithDuration:(animated ? kWaterfallViewCellAnimatedTimeInterval : 0) animations:^{
        
        [self setSelected:selected];
    }];
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    [_backgroundView removeFromSuperview];
    
    if(backgroundView)
    {
        _backgroundView = backgroundView;
        [self setSelected:self.selected];
        [self setNeedsLayout];
    }
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView
{
    [_selectedBackgroundView removeFromSuperview];
    
    if(selectedBackgroundView)
    {
        _selectedBackgroundView = selectedBackgroundView;
        [self setSelected:self.selected];
        [self setNeedsLayout];
    }
}

- (void)addSubview:(UIView *)view
{
    if(view != _contentView)
    {
        [_contentView addSubview:view];
    }
    else
    {
        [super addSubview:view];
    }
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset
{
    _separatorInset = separatorInset;
    
    [self setNeedsLayout];
}

@end

// ------------------------------------------------------------------------------- //

@interface YLScrollView : UIScrollView

@end

@implementation YLScrollView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesCancelled:touches withEvent:event];
}

@end

// ------------------------------------------------------------------------------- //

static CGFloat waterfallScrollVelocity = 0.0;


@interface YLWaterfallView () < UIScrollViewDelegate >

@property (nonatomic, strong) UIScrollView *scrollView;

/**
 *  存放可以重复利用的cell
 */
@property (nonatomic, strong) NSMutableSet <__kindof YLWaterfallViewCell *> *reusableCellsSet;

/**
 *  记录每列的最大高度
 */
@property (nonatomic, strong) NSMutableArray <NSMutableArray *> *columnMaxHeightArr;

/**
 *  存放显示出来的 cell
 */
@property (nonatomic, strong) NSMutableArray <__kindof YLWaterfallViewCell *> *visibleCellsArray;

/**
 *  存放 cell 的 信息
 */
@property (nonatomic, strong) NSMutableArray *cellInfoArr;

/**
 *  选中的cell
 */
@property (nonatomic, strong) NSMutableArray *didSelectedCellsArr;

/**
 *  当前点击的cell
 */
@property (nonatomic, weak) YLWaterfallViewCell *currentSelectedCell;


@end

@implementation YLWaterfallView

- (NSMutableSet<YLWaterfallViewCell *> *)reusableCellsSet
{
    if(_reusableCellsSet == nil)
    {
        _reusableCellsSet = [NSMutableSet set];
    }
    return _reusableCellsSet;
}

- (NSMutableArray<NSMutableArray *> *)columnMaxHeightArr
{
    if(_columnMaxHeightArr == nil)
    {
        _columnMaxHeightArr = [NSMutableArray array];
    }
    return _columnMaxHeightArr;
}

- (NSMutableArray<YLWaterfallViewCell *> *)visibleCellsArray
{
    if(_visibleCellsArray == nil)
    {
        _visibleCellsArray = [NSMutableArray array];
    }
    return _visibleCellsArray;
}

- (NSMutableArray *)cellInfoArr
{
    if(_cellInfoArr == nil)
    {
        _cellInfoArr = [NSMutableArray array];
    }
    return _cellInfoArr;
}

- (NSMutableArray *)didSelectedCellsArr
{
    if(_didSelectedCellsArr == nil)
    {
        _didSelectedCellsArr = [NSMutableArray array];
    }
    return _didSelectedCellsArr;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initialize];
    }
    return self;
}

- (instancetype)init
{
    if(self = [super init])
    {
        [self initialize];
    }
    return self;
}
#pragma mark 初始化
- (void)initialize
{
    self.scrollView = [[YLScrollView alloc] initWithFrame:self.frame];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
}
#pragma mark 重新布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
}

#pragma mark - public method
#pragma mark 刷新数据
-(void)reloadData
{
    [self.reusableCellsSet removeAllObjects];
    [self.visibleCellsArray removeAllObjects];
    [self.cellInfoArr removeAllObjects];
    self.reusableCellsSet = nil;
    self.visibleCellsArray = nil;
    self.cellInfoArr = nil;
    waterfallScrollVelocity = 0.0;
    
    NSInteger sectionsCount = 1;
    if([self.dataSource respondsToSelector:@selector(numberOfSectionsInWaterfallView:)])
    {
        sectionsCount = [self.dataSource numberOfSectionsInWaterfallView:self];
    }
    
    // 存储所有列的最大高度
    for (int i = 0; i < sectionsCount; i++)
    {
        NSMutableArray *columnHeightArr = [NSMutableArray array];
        NSInteger columnNumber = [self columnNumberInSection:i];
        for(int i = (int)columnNumber; i > 0; i--)
        {
            [columnHeightArr addObject:@(0.0)];
        }
        [self.columnMaxHeightArr addObject:columnHeightArr];
    }
    
    // 添加cell
    double maxH = 0.0;
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat height = self.scrollView.frame.size.height;
    for (int i = 0; i < sectionsCount; i++)
    {
        [self updateMinimalHeightOfSection:i byAddHeight:maxH];
        NSUInteger cellsCount = [self.dataSource waterfallView:self numberOfCellsInSection:i];  // cell 的个数
        NSInteger columnNumber = [self columnNumberInSection:i];    // 分组共有多少列
        
        CGFloat w = (width - (columnNumber - 1) * kWaterfallViewHorizontalGapDefault) / columnNumber;
        for (int j = 0; j < cellsCount; j++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            YLWaterfallViewCell *cell = [self.dataSource waterfallView:self cellForRowAtIndexPath:indexPath];
            NSInteger column = [self columnOfminimalHeightInSection:i]; // 所要添加到的列
            CGFloat x = column * (w + kWaterfallViewHorizontalGapDefault);
            CGFloat y = [self minimalHeightInSection:i];
            CGFloat h = [self cellHeightAtIndexPath:indexPath];
            CGRect frame = CGRectMake(x, y, w, h);
            // 记录每个 cell 的 frame
            [self.cellInfoArr addObject:@{indexPath : [NSMutableDictionary dictionaryWithDictionary:
                                                        @{@"frame"      : [NSValue valueWithCGRect:frame],
                                                          @"selected"   : @(NO)
                                                        }]
                                          }];
            // 更新每个分组内的最小的高度
            [self updateMinimalHeightOfSection:i withColumn:column Height:(y + h + kWaterfallViewVerticalGapDefault)];
            if(y <= height)
            {
                cell.frame = frame;
                cell.indexPath = indexPath;
                [self.scrollView addSubview:cell];
                [self.visibleCellsArray addObject:cell];
            }
//            NSLog(@"maxH : %lf  frame : %@", [self maximalHeightInSection:i], NSStringFromCGRect(frame));
        }
        maxH = [self maximalHeightInSection:i];
    }
    self.scrollView.contentSize = CGSizeMake(width, maxH);
//    NSLog(@"dsfsffsf   %@", NSStringFromCGSize(self.scrollView.contentSize));
//    NSLog(@"%@, frames : %@， visibleCells : %@", self.columnMaxHeightArr, self.cellFrameArr, self.visibleCellsArray);
    
}

#pragma mark 获取可以重复利用的cell
- (YLWaterfallViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block YLWaterfallViewCell *cell = nil;
    [self.reusableCellsSet enumerateObjectsUsingBlock:^(YLWaterfallViewCell *reusableCell, BOOL * _Nonnull stop) {
        
        if([reusableCell.identrifier isEqualToString:identifier] && reusableCell != self.currentSelectedCell)
        {
            cell = reusableCell;
            *stop = YES;
        }
    }];
    if(cell)
    {
        [self.reusableCellsSet removeObject:cell];
    }
    return cell;
}

#pragma mark - private method
#pragma mark 滚动过程中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    __block long begin = 0;
    __block long end = 0;
    int count = waterfallScrollVelocity * 5 + 2;
    __block typeof(self) weakSelf = self;
    [self getIndexPathScopeOfVisibleCellsSuccess:^(NSIndexPath *max, NSIndexPath *min) {
        
        if(min.section)
        {
            for (int i = 0; i < min.section; i++)
            {
                begin += [weakSelf.dataSource waterfallView:weakSelf numberOfCellsInSection:i];
                
            }
            begin += min.row;
            begin -= [weakSelf columnNumberInSection:min.section] * count;
        }
        else
        {
            begin = min.row - [weakSelf columnNumberInSection:0] * count;
        }
        if(max.section)
        {
            for (int i = 0; i < max.section; i++)
            {
                end += [weakSelf.dataSource waterfallView:weakSelf numberOfCellsInSection:i];
                
            }
            end += max.row;
            end += [weakSelf columnNumberInSection:max.section] * count;
        }
        else
        {
            end = max.row + [weakSelf columnNumberInSection:0] * count;
        }
    }];
    begin = MAX(begin, 0);
    end = MIN(self.cellInfoArr.count - 1, end);
    
//    NSLog(@"begin : %ld,  end : %ld", begin, end);
    // 截取一定范围的cell 的信息, 防止数据量大时, 影响性能
    NSArray *cellFrameTmp = [self.cellInfoArr subarrayWithRange:NSMakeRange(begin, end - begin + 1)];
    CGRect currentRect = (CGRect){scrollView.contentOffset, self.bounds.size};
    [cellFrameTmp enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSIndexPath *indexPath = dict.allKeys.lastObject;
        NSDictionary *info = dict.allValues.lastObject;
        CGRect frame = [info[@"frame"] CGRectValue];
        BOOL selected = [info[@"selected"] boolValue];
        // 滑出屏幕， 移除
        if(CGRectIntersectsRect(frame, currentRect) == NO)
        {
            [weakSelf.visibleCellsArray enumerateObjectsUsingBlock:^(__kindof YLWaterfallViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(cell.indexPath.row == indexPath.row && cell.indexPath.section == indexPath.section)
                {
                    [weakSelf.reusableCellsSet addObject:cell];
                    [weakSelf.visibleCellsArray removeObject:cell];
                    [cell removeFromSuperview];
                    *stop = YES;
                }
                
            }];
        }
        // 滑进屏幕，如果没有显示，则添加并显示
        else
        {
            __block BOOL cellVisible = NO;
            [self.visibleCellsArray enumerateObjectsUsingBlock:^(__kindof YLWaterfallViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
               
                if(cell.indexPath.row == indexPath.row && cell.indexPath.section == indexPath.section)
                {
                    cellVisible = YES;
                    *stop = YES;
                }
            }];
            if(cellVisible == NO)
            {
                YLWaterfallViewCell *cell = [weakSelf.dataSource waterfallView:weakSelf cellForRowAtIndexPath:indexPath];
                cell.frame = frame;
                cell.selected = selected;
                cell.indexPath = indexPath;
                [weakSelf.scrollView addSubview:cell];
                [weakSelf.visibleCellsArray addObject:cell];
            }
        }
    }];
}
#pragma mark 滚动的速度
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    waterfallScrollVelocity = fabsf((float)velocity.y);
    if(waterfallScrollVelocity < 3)
    {
        waterfallScrollVelocity = 0;
    }
    else
    {
        waterfallScrollVelocity -=3;
    }
}
#pragma mark 获取显示的cell的最大和最小的indexpath
- (void)getIndexPathScopeOfVisibleCellsSuccess:(void(^)(NSIndexPath *max, NSIndexPath *min))success
{
    NSIndexPath *firstI = [(YLWaterfallViewCell *)self.visibleCellsArray.firstObject indexPath];
    NSIndexPath *maxIndexPath = [NSIndexPath indexPathForRow:firstI.row inSection:firstI.section];
    NSIndexPath *minIndexPath = [NSIndexPath indexPathForRow:firstI.row inSection:firstI.section];
    for (YLWaterfallViewCell *cell in self.visibleCellsArray)
    {
        NSIndexPath *indexPath = cell.indexPath;
        if([indexPath compare:maxIndexPath] == NSOrderedDescending)
        {
            maxIndexPath = indexPath;
        }
        if([indexPath compare:minIndexPath] == NSOrderedAscending)
        {
            minIndexPath = indexPath;
        }
    }
    if(success)
    {
        success(maxIndexPath, minIndexPath);
    }
}

#pragma mark 获取cell的高度
- (CGFloat)cellHeightAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    if([self.dataSource respondsToSelector:@selector(waterfallView:heightForCellAtIndexPath:)])
    {
        height = [self.dataSource waterfallView:self heightForCellAtIndexPath:indexPath];
    }
    return height < 0 ? 0 : height;
}
#pragma mark 获取某分组的高度最小的列
- (NSUInteger)columnOfminimalHeightInSection:(NSInteger)section
{
    NSMutableArray *columnHeightArr = self.columnMaxHeightArr[section];
    __block double min = MAXFLOAT;
    __block NSUInteger column = 0;
    [columnHeightArr enumerateObjectsUsingBlock:^(NSNumber *height, NSUInteger idx, BOOL * _Nonnull stop) {
        
        double h = height.doubleValue;
        if(h < min)
        {
            min = h;
            column = idx;
        }
    }];
    return column;
}
#pragma mark 分组的最小的高度
- (double)minimalHeightInSection:(NSInteger)section
{
    NSMutableArray *columnHeightArr = self.columnMaxHeightArr[section];
    __block double minH = MAXFLOAT;
    [columnHeightArr enumerateObjectsUsingBlock:^(NSNumber *height, NSUInteger idx, BOOL * _Nonnull stop) {
        
        minH = minH > height.doubleValue ? height.doubleValue : minH;
    }];
    return minH;
}
#pragma mark 分组的最大的高度
- (double)maximalHeightInSection:(NSInteger)section
{
    NSMutableArray *columnHeightArr = self.columnMaxHeightArr[section];
    __block double maxH = 0.0;
    [columnHeightArr enumerateObjectsUsingBlock:^(NSNumber *height, NSUInteger idx, BOOL * _Nonnull stop) {
        
        maxH = maxH < height.doubleValue ? height.doubleValue : maxH;
    }];
    return maxH;
}

#pragma mark 每组的分栏数
- (NSInteger)columnNumberInSection:(NSInteger)section
{
    NSInteger columnNumber = kWaterfallViewColumnNumberDefault;
    if([self.dataSource respondsToSelector:@selector(waterfallView:numberOfColumsInSection:)])
    {
        columnNumber = [self.dataSource waterfallView:self numberOfColumsInSection:section];
    }
    return columnNumber;
}

#pragma mark 更新每栏的最小高度
- (void)updateMinimalHeightOfSection:(NSInteger)section withColumn:(NSInteger)column Height:(double)height
{
    NSMutableArray *columnHeightArr = self.columnMaxHeightArr[section];
    [columnHeightArr replaceObjectAtIndex:column withObject:@(height)];
}

#pragma mark 给某个分组各栏的最小高度都增加一定值
- (void)updateMinimalHeightOfSection:(NSInteger)section byAddHeight:(double)height
{
    NSMutableArray *columnHeightArr = self.columnMaxHeightArr[section];
    for (int i = 0; i < columnHeightArr.count; i ++)
    {
        double h = [columnHeightArr[i] doubleValue];
        [columnHeightArr replaceObjectAtIndex:i withObject:@(height + h)];
    }
}

#pragma mark 显示出来的 cell
- (NSArray<YLWaterfallViewCell *> *)visibleCells
{
    return [NSArray arrayWithArray:self.visibleCellsArray];
}

#pragma mark 更新cell的信息
- (void)updateCellInfoWithDict:(NSDictionary *)info atIndexPath:(NSIndexPath *)indexPath
{
    if(info == nil || indexPath == nil) return;
    
    NSUInteger index = 0;
    if(indexPath.section)
    {
        for (int i = 0; i < indexPath.section; i++)
        {
            index += [self.dataSource waterfallView:self numberOfCellsInSection:i];
        }
    }
    index += indexPath.row;
    if(index < self.cellInfoArr.count)
    {
        NSIndexPath *indexP = [self.cellInfoArr[index] allKeys].lastObject;
        if(indexP.section == indexPath.section && indexP.row == indexPath.row)
        {
            NSMutableDictionary *oldInfo = [self.cellInfoArr[index] allValues].lastObject;
            [info enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
                
                [oldInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull oldKey, id  _Nonnull oldValue, BOOL * _Nonnull stop) {
                    
                    if([oldKey isEqualToString:key])
                    {
                        [oldInfo setObject:value forKey:oldKey];
                    }
                }];
            }];
        }
    }
}

#pragma mark - 点击操作
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch began");
    CGPoint p = [[touches anyObject] locationInView:self];
    CGPoint localPoint = [self convertPoint:p toView:self.scrollView];
    __block YLWaterfallViewCell *weakCell = nil;
    [self.visibleCellsArray enumerateObjectsUsingBlock:^(__kindof YLWaterfallViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(CGRectContainsPoint(cell.frame, localPoint))
        {
            weakCell = cell;
            *stop = YES;
        }
    }];
    
    if(weakCell && [self.delegate respondsToSelector:@selector(waterfallView:shouldHighlightRowAtIndexPath:)])
    {
        NSIndexPath *indexPath = weakCell.indexPath;
        __strong typeof(weakCell) cell = weakCell;
        BOOL highlight = [self.delegate waterfallView:self shouldHighlightRowAtIndexPath:indexPath];
        if(highlight)
        {
            if([self.delegate respondsToSelector:@selector(waterfallView:didHighlightRowAtIndexPath:)])
            {
                cell.highlighted = YES;
                [self.delegate waterfallView:self didHighlightRowAtIndexPath:indexPath];
                self.currentSelectedCell = cell;
            }
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch move");
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch end");
    if(self.currentSelectedCell == nil) return;
    
    CGPoint p = [[touches anyObject] locationInView:self];
    CGPoint localPoint = [self convertPoint:p toView:self.scrollView];
    if(CGRectContainsPoint(self.currentSelectedCell.frame, localPoint))
    {
        if(self.didSelectedCellsArr.count)
        {
            // 取消选中上一个
            YLWaterfallViewCell *preSelectedCell = self.didSelectedCellsArr.lastObject;
            preSelectedCell.selected = NO;
            [self updateCellInfoWithDict:@{@"selected" : @(NO)} atIndexPath:preSelectedCell.indexPath];
            [self.didSelectedCellsArr removeObject:preSelectedCell];
            if([self.delegate respondsToSelector:@selector(waterfallView:didDeselectRowAtIndexPath:)])
            {
                [self.delegate waterfallView:self didDeselectRowAtIndexPath:preSelectedCell.indexPath];
            }
        }
        
        // 取消高亮当前
        self.currentSelectedCell.highlighted = NO;
        if([self.delegate respondsToSelector:@selector(waterfallView:didUnhighlightRowAtIndexPath:)])
        {
            [self.delegate waterfallView:self didUnhighlightRowAtIndexPath:self.currentSelectedCell.indexPath];
        }
        
        // 选中当前
        self.currentSelectedCell.selected = YES;
        [self updateCellInfoWithDict:@{@"selected" : @(YES)} atIndexPath:self.currentSelectedCell.indexPath];
        if([self.delegate respondsToSelector:@selector(waterfallView:didSelectRowAtIndexPath:)])
        {
            [self.delegate waterfallView:self didSelectRowAtIndexPath:self.currentSelectedCell.indexPath];
        }
        
        // 添加
        [self.didSelectedCellsArr addObject:self.currentSelectedCell];
        NSLog(@"add selected  : %@", self.currentSelectedCell.indexPath);
    }
    else
    {
        [self touchesCancelled:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch cancle");
    if(self.currentSelectedCell)
    {
        self.currentSelectedCell.highlighted = NO;
        if(self.didSelectedCellsArr.count)
        {
            YLWaterfallViewCell *preSelectedCell = self.didSelectedCellsArr.lastObject;
            preSelectedCell.selected = YES;
            [self updateCellInfoWithDict:@{@"selected" : @(YES)} atIndexPath:preSelectedCell.indexPath];
            self.currentSelectedCell = preSelectedCell;
        }
    }
}


@end


