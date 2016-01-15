//
//  YLViewController.m
//  YLWaterfallView
//
//  Created by WYL on 16/1/14.
//  Copyright © 2016年 WYL. All rights reserved.
//

#import "YLViewController.h"
#import "YLWaterfallLayout.h"
#import "YLCollectionViewCell.h"

@interface YLViewController () < UICollectionViewDataSource, UICollectionViewDelegate, YLCollectionViewDelegateWaterfallLayout >

@end

@implementation YLViewController

static NSString * const identifier = @"CollectionViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    YLWaterfallLayout *layout = [[YLWaterfallLayout alloc] init];
    layout.columnNumber = 4;
    layout.columnSpace = 15;
    layout.lineSpace = 5;
//    layout.itemHeight = 50;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    [collectionView registerClass:[YLCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    [self.view addSubview:collectionView];
}

#pragma mark - collection dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 35;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}


#pragma mark - YLCollectionViewDelegateWaterfallLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return arc4random_uniform(100) + 100;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 10, 10, 10);
}

@end
