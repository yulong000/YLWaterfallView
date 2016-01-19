YLWaterfallView 瀑布流 使用方法
=======

## #import "YLWaterfallLayout.h"
``` objective-c
 YLWaterfallLayout *layout = [[YLWaterfallLayout alloc] init];
 layout.columnNumber = 3;    // 分组的列数 default = 3
 layout.columnSpace = 15;    // 列间距 default = 10
 layout.lineSpace = 5;       // 行间距 default = 10
 layout.itemHeight = 50;     // item 高度 default = 100 ，优先级高
```

#### 遵守协议 < YLCollectionViewDelegateWaterfallLayout >
    协议方法  @optional
``` objective-c
 // 返回每个分组的列数 ， default = 3
- (NSUInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout numberOfColumnsForSectionAtIndex:(NSUInteger)index;

// 返回 item 的高度 ，default = 100
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath;

// 分组的 inset , default = UIEdgeInsetsMake(10, 10, 10, 10)
 - (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
```
