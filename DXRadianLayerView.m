//
//  DXRadianLayerView.m
//  UIVIEW弧形边框
//
//  Created by arraybuffer on 2020/4/26.
//  Copyright © 2020 airtim. All rights reserved.
//

#import "DXRadianLayerView.h"

@implementation DXRadianLayerView

- (void)setRadian:(CGFloat) radian
{
   if(radian == 0) return;
    CGFloat t_width = CGRectGetWidth(self.frame); // 宽
    CGFloat t_height = CGRectGetHeight(self.frame); // 高
    CGFloat height = fabs(radian); // 圆弧高度
    CGFloat x = 0;
    CGFloat y = 0;
    
    // 计算圆弧的最大高度
    CGFloat _maxRadian = 0;
    switch (self.direction) {
        case DXRadianDirectionBottom:
        case DXRadianDirectionTop:
            _maxRadian =  MIN(t_height, t_width / 2);
            break;
        case DXRadianDirectionLeft:
        case DXRadianDirectionRight:
            _maxRadian =  MIN(t_height / 2, t_width);
            break;
        default:
            break;
    }
    if(height > _maxRadian){
        NSLog(@"圆弧半径过大, 跳过设置。");
        return;
    }
    
    // 计算半径
    CGFloat radius = 0;
    switch (self.direction) {
        case DXRadianDirectionBottom:
        case DXRadianDirectionTop:
        {
            CGFloat c = sqrt(pow(t_width / 2, 2) + pow(height, 2));
            CGFloat sin_bc = height / c;
            radius = c / ( sin_bc * 2);
        }
            break;
        case DXRadianDirectionLeft:
        case DXRadianDirectionRight:
        {
            CGFloat c = sqrt(pow(t_height / 2, 2) + pow(height, 2));
            CGFloat sin_bc = height / c;
            radius = c / ( sin_bc * 2);
        }
            break;
        default:
            break;
    }
    
    // 画圆
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setFillColor:[[UIColor whiteColor] CGColor]];
    CGMutablePathRef path = CGPathCreateMutable();
    switch (self.direction) {
        case DXRadianDirectionBottom:
        {
            if(radian > 0){
                CGPathMoveToPoint(path,NULL, t_width,t_height - height);
                CGPathAddArc(path,NULL, t_width / 2, t_height - radius, radius, asin((radius - height ) / radius), M_PI - asin((radius - height ) / radius), NO);
            }else{
                CGPathMoveToPoint(path,NULL, t_width,t_height);
                CGPathAddArc(path,NULL, t_width / 2, t_height + radius - height, radius, 2 * M_PI - asin((radius - height ) / radius), M_PI + asin((radius - height ) / radius), YES);
            }
            CGPathAddLineToPoint(path,NULL, x, y);
            CGPathAddLineToPoint(path,NULL, t_width, y);
        }
            break;
        case DXRadianDirectionTop:
        {
            if(radian > 0){
                CGPathMoveToPoint(path,NULL, t_width, height);
                CGPathAddArc(path,NULL, t_width / 2, radius, radius, 2 * M_PI - asin((radius - height ) / radius), M_PI + asin((radius - height ) / radius), YES);
            }else{
                CGPathMoveToPoint(path,NULL, t_width, y);
                CGPathAddArc(path,NULL, t_width / 2, height - radius, radius, asin((radius - height ) / radius), M_PI - asin((radius - height ) / radius), NO);
            }
            CGPathAddLineToPoint(path,NULL, x, t_height);
            CGPathAddLineToPoint(path,NULL, t_width, t_height);
        }
            break;
        case DXRadianDirectionLeft:
        {
            if(radian > 0){
                CGPathMoveToPoint(path,NULL, height, y);
                CGPathAddArc(path,NULL, radius, t_height / 2, radius, M_PI + asin((radius - height ) / radius), M_PI - asin((radius - height ) / radius), YES);
            }else{
                CGPathMoveToPoint(path,NULL, x, y);
                CGPathAddArc(path,NULL, height - radius, t_height / 2, radius, 2 * M_PI - asin((radius - height ) / radius), asin((radius - height ) / radius), NO);
            }
            CGPathAddLineToPoint(path,NULL, t_width, t_height);
            CGPathAddLineToPoint(path,NULL, t_width, y);
        }
            break;
        case DXRadianDirectionRight:
        {
            if(radian > 0){
                CGPathMoveToPoint(path,NULL, t_width - height, y);
                CGPathAddArc(path,NULL, t_width - radius, t_height / 2, radius, 1.5 * M_PI + asin((radius - height ) / radius), M_PI / 2 + asin((radius - height ) / radius), NO);
            }else{
                CGPathMoveToPoint(path,NULL, t_width, y);
                CGPathAddArc(path,NULL, t_width  + radius - height, t_height / 2, radius, M_PI + asin((radius - height ) / radius), M_PI - asin((radius - height ) / radius), YES);
            }
            CGPathAddLineToPoint(path,NULL, x, t_height);
            CGPathAddLineToPoint(path,NULL, x, y);
        }
            break;
        default:
            break;
    }
    
    CGPathCloseSubpath(path);
    [shapeLayer setPath:path];
    CFRelease(path);
    self.layer.mask = shapeLayer;
}
@end
