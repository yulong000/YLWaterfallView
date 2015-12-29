//
//  YLWaterfallView.h
//  YLWaterfallView
//
//  Created by DreamHand on 15/12/24.
//  Copyright © 2015年 WYL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLWaterfallViewCell : UIView

/**
 *  重用的标识
 */
@property (nonatomic, copy, readonly) NSString              *identrifier;

@property (nonatomic, getter=isHighlighted) BOOL            highlighted;
@property (nonatomic, getter=isSelected) BOOL               selected;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

/**
 *  添加的 view 都添加在 contentView 上
 */
@property (nonatomic, readonly, strong) UIView              *contentView;

// nullable, default nil
@property (nonatomic, strong) UIView                        *backgroundView;
@property (nonatomic, strong) UIView                        *selectedBackgroundView;

// default UIEdgeInsetsZero    contentView top,left,bottom,right inset
@property (nonatomic) UIEdgeInsets                          separatorInset;


@property (nonatomic, copy) NSString                        *title;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end



@interface YLWaterfallViewHeaderFooterView : UIView

@end



@class YLWaterfallView;
@protocol YLWaterfallViewDelegate <NSObject, UIScrollViewDelegate>

@optional

- (UIView *)waterfallView:(YLWaterfallView *)waterfallView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
- (UIView *)waterfallView:(YLWaterfallView *)waterfallView viewForFooterInSection:(NSInteger)section;   // custom view for footer. will be adjusted to default or
// Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.

/**
 *  将要高亮显示
 *
 *  @return NO 取消高亮, YES 高亮
 */
- (BOOL)waterfallView:(YLWaterfallView *)waterfallView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  高亮显示
 */
- (void)waterfallView:(YLWaterfallView *)waterfallView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  取消高亮显示
 */
- (void)waterfallView:(YLWaterfallView *)waterfallView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  选中了某一个cell
 */
- (void)waterfallView:(YLWaterfallView *)waterfallView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  取消选中了某一个cell
 */
- (void)waterfallView:(YLWaterfallView *)waterfallView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
@end
@protocol YLWaterfallViewDataSource <NSObject>

@required

/**
 *  返回每个分组的cell个数
 *
 *  @param section       分组的序列号
 */
- (NSInteger)waterfallView:(YLWaterfallView *)waterfallView numberOfCellsInSection:(NSInteger)section;

/**
 *  返回cell
 *  @param indexPath    某组 某个
 */
- (YLWaterfallViewCell *)waterfallView:(YLWaterfallView *)waterfallView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 *  返回分组个数, 默认为 1
 */
- (NSInteger)numberOfSectionsInWaterfallView:(YLWaterfallView *)waterfallView;

/**
 *  返回每个分组的列数 , 默认为3
 */
- (NSInteger)waterfallView:(YLWaterfallView *)waterfallView numberOfColumsInSection:(NSInteger)section;

/**
 *  返回 cell 的高度, 只初始化一次
 */
- (CGFloat)waterfallView:(YLWaterfallView *)waterfallView heightForCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  分组的头视图的标题
 */
- (NSString *)waterfallView:(YLWaterfallView *)waterfallView titleForHeaderInSection:(NSInteger)section;
/**
 *  分组的尾视图的标题
 */
- (NSString *)waterfallView:(YLWaterfallView *)waterfallView titleForFooterInSection:(NSInteger)section;

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)waterfallView:(YLWaterfallView *)waterfallView canEditRowAtIndexPath:(NSIndexPath *)indexPath;

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -waterfallView:moveRowAtIndexPath:toIndexPath:
- (BOOL)waterfallView:(YLWaterfallView *)waterfallView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray<NSString *> *)sectionIndexTitlesForWaterfallView:(YLWaterfallView *)waterfallView;                                                    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (NSInteger)waterfallView:(YLWaterfallView *)waterfallView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;  // tell table which section corresponds to section title/index (e.g. "B",1))


@end

@interface YLWaterfallView : UIView

@property (nonatomic, weak) id <YLWaterfallViewDelegate> delegate;

@property (nonatomic, weak) id <YLWaterfallViewDataSource> dataSource;

@property (nonatomic, strong, readonly) NSArray <__kindof YLWaterfallViewCell *> *visibleCells;

- (void)reloadData;

/**
 *  cell的重用
 *
 *  @param identifier 标识
 */
- (YLWaterfallViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

//- (YLWaterfallViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath; // newer dequeue method guarantees a cell is returned and resized properly, assuming identifier is registered
//- (YLWaterfallViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifier:(NSString *)identifier;  // like dequeueReusableCellWithIdentifier:, but for headers/footers

@end


