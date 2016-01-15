//
//  YLCollectionViewCell.m
//  YLWaterfallView
//
//  Created by WYL on 16/1/15.
//  Copyright © 2016年 WYL. All rights reserved.
//

#import "YLCollectionViewCell.h"

@interface YLCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation YLCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.image = [UIImage imageNamed:@"2"];
        [self addSubview:self.imageView];
    }
    return  self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.imageView.image = selected ? [UIImage imageNamed:@"1"] : [UIImage imageNamed:@"2"];
}

@end
