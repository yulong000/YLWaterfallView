//
//  ViewController.m
//  YLWaterfallView
//
//  Created by DreamHand on 15/12/24.
//  Copyright © 2015年 WYL. All rights reserved.
//

#import "ViewController.h"
#import "YLWaterfallView.h"
#import "WaterfallViewCell.h"

@interface ViewController () <YLWaterfallViewDataSource, YLWaterfallViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YLWaterfallView *waterfallView = [[YLWaterfallView alloc] initWithFrame:self.view.bounds];
    waterfallView.delegate = self;
    waterfallView.dataSource = self;
    [self.view addSubview:waterfallView];
    [waterfallView reloadData];

}

- (NSInteger)numberOfSectionsInWaterfallView:(YLWaterfallView *)waterfallView
{
    return 2;
}

- (NSInteger)waterfallView:(YLWaterfallView *)waterfallView numberOfCellsInSection:(NSInteger)section
{
    if(section == 1)
    {
        return 60;
    }
    return 50;
}


- (YLWaterfallViewCell *)waterfallView:(YLWaterfallView *)waterfallView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    WaterfallViewCell * cell = (WaterfallViewCell *)[waterfallView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[WaterfallViewCell alloc] initWithReuseIdentifier:identifier];
    }
    
//    cell.imageView.image = [UIImage imageNamed:@"1"];
//    if(indexPath.row % 2)
//    {
//        cell.imageView.image = [UIImage imageNamed:@"2"];
//    }
    cell.backgroundView = [[UIView alloc] init];
    cell.backgroundView.backgroundColor = [UIColor colorWithRed:(indexPath.row + 50) % 255 / 255. green:(indexPath.row + 50) * 20 % 255 / 255. blue:indexPath.row * 32 % 255 / 255. alpha:1];
    
    cell.selectedBackgroundView = [[UIView alloc] init];
    cell.selectedBackgroundView.backgroundColor = [UIColor greenColor];
//    cell.separatorInset = UIEdgeInsetsMake(20, 20, 20, 20);
    
    cell.title = [NSString stringWithFormat:@"%ld  -   %d", indexPath.section ,indexPath.row];
//    cell.backgroundColor = [UIColor colorWithRed:(indexPath.row + 50) % 255 / 255. green:(indexPath.row + 50) * 20 % 255 / 255. blue:indexPath.row * 32 % 255 / 255. alpha:1];
    return cell;
}

- (NSInteger)waterfallView:(YLWaterfallView *)waterfallView numberOfColumsInSection:(NSInteger)section
{
    NSInteger n = 3;
    if(section == 1)
    {
        n = 5;
    }
    return n;
}

- (CGFloat)waterfallView:(YLWaterfallView *)waterfallView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return 52 *indexPath.row % 100 + 170 + arc4random() % 30;
}


//- (UIView *)waterfallView:(YLWaterfallView *)waterfallView viewForHeaderInSection:(NSInteger)section
//{
//    
//}
//- (UIView *)waterfallView:(YLWaterfallView *)waterfallView viewForFooterInSection:(NSInteger)section
//{
//    
//}
/**
 *  将要高亮显示
 *
 *  @return NO 取消高亮, YES 高亮
 */
- (BOOL)waterfallView:(YLWaterfallView *)waterfallView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"shouldHighlightRowAtIndexPath : %@", indexPath);
    return YES;
}
/**
 *  高亮显示
 */
- (void)waterfallView:(YLWaterfallView *)waterfallView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didHighlightRowAtIndexPath : %@", indexPath);
}
/**
 *  取消高亮显示
 */
- (void)waterfallView:(YLWaterfallView *)waterfallView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didUnhighlightRowAtIndexPath : %@", indexPath);
}


/**
 *  选中了某一个cell
 */
- (void)waterfallView:(YLWaterfallView *)waterfallView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath : %@", indexPath);
}
/**
 *  取消选中了某一个cell
 */
- (void)waterfallView:(YLWaterfallView *)waterfallView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectRowAtIndexPath : %@", indexPath);
}



@end
