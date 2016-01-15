//
//  YLWaterfallFlowLayout.h
//  YLWaterfallView
//
//  Created by WYL on 16/1/14.
//  Copyright © 2016年 WYL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YLCollectionViewDelegateWaterfallLayout <UICollectionViewDelegate>

@optional

/**
 *  每个分组的列数 ， default = 3
 *
 *  @param index    分组的序列号
 */
- (NSUInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout numberOfColumnsForSectionAtIndex:(NSUInteger)index;

/**
 *  返回 cell 的高度 ，default = 100
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  分组的 inset  default = UIEdgeInsetsMake(10, 10, 10, 10)
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

@end

@interface YLWaterfallLayout : UICollectionViewLayout

@property (nonatomic, assign) NSUInteger columnNumber;  // 列数 default = 3
@property (nonatomic, assign) CGFloat columnSpace;      // 列间距 default= 10
@property (nonatomic, assign) CGFloat lineSpace;        // 行间距 default = 10
@property (nonatomic, assign) CGFloat itemHeight;       // item 高度, default 100, 设置后 代理方法 - (CGFloat)collectionView: layout: heightForItemAtIndexPath: 会失效
@end
