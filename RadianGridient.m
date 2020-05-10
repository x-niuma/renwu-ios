//
//  RadianGridient.m
//  UIVIEW弧形边框
//
//  Created by arraybuffer on 2020/4/26.
//  Copyright © 2020 airtim. All rights reserved.
//

#import "RadianGridient.h"
#import "DXRadianLayerView.h"

@implementation RadianGridient

- (void) setGradient:(UIColor *)startColor and:(UIColor *)endColor WidthSize:(CGFloat) radianSize {
//    UIColor *c1 = [UIColor colorWithRed:51.0/255.0 green:163.0/255.0 blue:220.0/255.0 alpha:1];
//    UIColor *c2 = [UIColor colorWithRed:193.0/255.0 green:222.0/255.0 blue:241.0/255.0 alpha:1];
    
    CGSize size = self.frame.size;
    
    // 创建弧形背景
    DXRadianLayerView *radianView = [[DXRadianLayerView alloc] init];
    radianView.frame = CGRectMake(0, 0, size.width, size.height);
    [radianView setRadian:radianSize];
    [self addSubview:radianView];

    // 创建渐变背景
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1.0);
    gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [radianView.layer addSublayer:gradientLayer];
}

@end
