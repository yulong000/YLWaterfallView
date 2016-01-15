//
//  WaterfallViewCell.m
//  YLWaterfallView
//
//  Created by WYL on 15/12/28.
//  Copyright © 2015年 WYL. All rights reserved.
//

#import "WaterfallViewCell.h"

@implementation WaterfallViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithReuseIdentifier:reuseIdentifier])
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.contentView.bounds;//CGRectMake(0, 0, self.frame.size.width * 0.8, self.frame.size.height * 0.8);
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.imageView.image = selected ? [UIImage imageNamed:@"1"] : [UIImage imageNamed:@"2"];
}

@end
