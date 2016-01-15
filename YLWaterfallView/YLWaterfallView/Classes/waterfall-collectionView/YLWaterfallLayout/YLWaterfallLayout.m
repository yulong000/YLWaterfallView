//
//  YLWaterfallFlowLayout.m
//  YLWaterfallView
//
//  Created by WYL on 16/1/14.
//  Copyright © 2016年 WYL. All rights reserved.
//

#import "YLWaterfallLayout.h"

#define kWaterfallViewColumnNumberDefault 3         // 默认的每个分组的列数

#define kWaterfallViewColumnSpaceDefault 10         // 默认的列距
#define kWaterfallViewLineSpaceDefault   10         // 默认的行距
#define kWaterfallViewHeightForItemDefault 100      // 默认的 cell 高度

#define kWaterfallViewSectionInsetDefault UIEdgeInsetsMake(10, 10, 10, 10)  // 默认的分组的 inset


@interface YLWaterfallLayout ()

/**
 *  每组每列的最大 Y 值
 */
@property (nonatomic, strong) NSMutableArray *columnMaxYArr;

/**
 *  属性列表
 */
@property (nonatomic, strong) NSMutableArray *attrArr;

@property (nonatomic, weak, readonly) id <YLCollectionViewDelegateWaterfallLayout> delegate;

@end


@implementation YLWaterfallLayout

#pragma mark - private method
#pragma mark 获取某个分组的 insets
- (UIEdgeInsets)edgeInsetOfSectionAtIndex:(NSUInteger)index
{
    UIEdgeInsets insets = kWaterfallViewSectionInsetDefault;
    if(self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)])
    {
        insets = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:index];
    }
    return insets;
}

#pragma mark 获取某个分组的列数
- (NSUInteger)columnNumberOfSectionAtIndex:(NSUInteger)index
{
    NSUInteger columnNumber = kWaterfallViewColumnNumberDefault;
    if(self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:numberOfColumnsForSectionAtIndex:)])
    {
        columnNumber = [self.delegate collectionView:self.collectionView layout:self numberOfColumnsForSectionAtIndex:index];
    }
    columnNumber = self.columnNumber > 0 ? self.columnNumber : columnNumber;
    return columnNumber;
}

#pragma mark 获取某个 item 的高度
- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = kWaterfallViewHeightForItemDefault;
    if(self.delegate && [self.delegate respondsToSelector:@selector(collectionView:layout:heightForItemAtIndexPath:)])
    {
        height = [self.delegate collectionView:self.collectionView layout:self heightForItemAtIndexPath:indexPath];
    }
    height = self.itemHeight > 0.0 ? self.itemHeight : height;
    return height;
}

#pragma mark 列间距
- (CGFloat)columnSpace
{
    return _columnSpace > 0.0 ? _columnSpace : kWaterfallViewColumnSpaceDefault;
}
#pragma mark 行间距
- (CGFloat)lineSpace
{
    return _lineSpace > 0.0 ? _lineSpace : kWaterfallViewLineSpaceDefault;
}
#pragma mark 获取某个分组的最小 y 值
- (void)getMinYOfSectionAtIndex:(NSUInteger)index success:(void(^)(CGFloat minY, NSUInteger columnIndex))success
{
    NSUInteger minYIndex = 0;
    NSMutableArray *arr = self.columnMaxYArr[index];
    CGFloat minY = [arr.firstObject doubleValue];
    for(int i = 1; i < arr.count; i++)
    {
        CGFloat tmpY = [arr[i] doubleValue];
        if(minY > tmpY)
        {
            minY = tmpY;
            minYIndex = i;
        }
    }
    if(success)
    {
        success(minY, minYIndex);
    }
}
#pragma mark 获取某个分组的最大 y 值
- (CGFloat)maxYOfSectionAtIndex:(NSUInteger)index
{
    UIEdgeInsets insetPre = [self edgeInsetOfSectionAtIndex:index];
    NSMutableArray *arr = self.columnMaxYArr[index];
    CGFloat maxY = [arr.firstObject doubleValue];
    for(int i = 1; i < arr.count; i++)
    {
        CGFloat tmpY = [arr[i] doubleValue];
        if(maxY < tmpY)
        {
            maxY = tmpY;
        }
    }
    return maxY + insetPre.bottom;
}
#pragma mark - 懒加载
#pragma mark 初始化 每组每列的最大 Y 值
- (NSMutableArray *)columnMaxYArr
{
    if(_columnMaxYArr == nil)
    {
        NSUInteger sectionCount = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
        _columnMaxYArr = [NSMutableArray arrayWithCapacity:sectionCount];
        for(int i = 0; i < sectionCount; i++)
        {
            UIEdgeInsets insets = [self edgeInsetOfSectionAtIndex:i];
            NSUInteger columnNumber = [self columnNumberOfSectionAtIndex:i];
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:columnNumber];
            for(int j = 0; j < columnNumber; j++)
            {
                [arr addObject:@(insets.top)];
            }
            [_columnMaxYArr addObject:arr];
        }
    }
    return _columnMaxYArr;
}

#pragma mark 属性列表
- (NSMutableArray *)attrArr
{
    if(_attrArr == nil)
    {
        _attrArr = [NSMutableArray array];
    }
    return _attrArr;
}
#pragma mark 代理
- (id<YLCollectionViewDelegateWaterfallLayout>)delegate
{
    if([self.collectionView.delegate conformsToProtocol:@protocol(YLCollectionViewDelegateWaterfallLayout)])
    {
        id delegateWaterfall = self.collectionView.delegate;
        return delegateWaterfall;
    }
    return nil;
}

#pragma mark 返回 collectionView 的 contentsize
- (CGSize)collectionViewContentSize
{
    if(self.columnMaxYArr.count == 0)   return CGSizeMake(0, 0);
    CGFloat totalHeight = [self maxYOfSectionAtIndex:(self.columnMaxYArr.count - 1)];
    CGFloat contentSizeHeight = MAX(self.collectionView.frame.size.height + 0.2 ,totalHeight);
    return CGSizeMake(0, contentSizeHeight);
}
#pragma mark - 布局
- (void)prepareLayout
{
    [super prepareLayout];
    
    [self.columnMaxYArr removeAllObjects];
    self.columnMaxYArr = nil;
    
    [self.attrArr removeAllObjects];
    for(int i = 0; i < self.columnMaxYArr.count; i++)
    {
        NSUInteger itemsCount = [self.collectionView numberOfItemsInSection:i];
        for(int j = 0; j < itemsCount; j++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.attrArr addObject:attr];
        }
    }
}

#pragma mark 获取单个 item 的属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    __block NSUInteger minYIndex = 0;
    __block CGFloat minY = 0.0;
    [self getMinYOfSectionAtIndex:indexPath.section success:^(CGFloat min, NSUInteger columnIndex) {
        
        minY = min;
        minYIndex = columnIndex;
    }];
    UIEdgeInsets insets = [self edgeInsetOfSectionAtIndex:indexPath.section];
    NSUInteger columnNumber = [self columnNumberOfSectionAtIndex:indexPath.section];
    
    // 每个 item 的宽度
    CGFloat width = (self.collectionView.frame.size.width - self.columnSpace * (columnNumber - 1) - insets.left - insets.right) / columnNumber;
    
    // 每个 item 的高度
    CGFloat height = [self heightForItemAtIndexPath:indexPath];
    
    // x 值
    CGFloat x = minYIndex * (self.columnSpace + width) + insets.left;
    
    // y 值
    CGFloat maxYPre = 0.0;
    if(indexPath.section > 0)
    {
        maxYPre = [self maxYOfSectionAtIndex:indexPath.section - 1];
    }
    CGFloat y = minY;
    if(indexPath.item >= columnNumber)
    {
        // 每组的非第一行加上行间距
        y += self.lineSpace;
    }
    else
    {
        // 每组的第一行加上上个分组的最大 y 值
        y += maxYPre;
    }
    
    attr.frame = CGRectMake(x, y, width, height);
    self.columnMaxYArr[indexPath.section][minYIndex] = @(CGRectGetMaxY(attr.frame));
    return attr;
}

#pragma mark 获取所有属性
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attrArr;
}
@end
