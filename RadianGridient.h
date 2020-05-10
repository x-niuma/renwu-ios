//
//  RadianGridient.h
//  UIVIEW弧形边框
//
//  Created by arraybuffer on 2020/4/26.
//  Copyright © 2020 airtim. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RadianGridient : UIView

- (void) setGradient:(UIColor *)startColor and:(UIColor *)endColor WidthSize:(CGFloat) radianSize;

@end

NS_ASSUME_NONNULL_END
