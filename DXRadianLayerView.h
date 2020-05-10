//
//  DXRadianLayerView.h
//  UIVIEW弧形边框
//
//  Created by arraybuffer on 2020/4/26.
//  Copyright © 2020 airtim. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, DXRadianDirection) {
    DXRadianDirectionBottom     = 0,
    DXRadianDirectionTop        = 1,
    DXRadianDirectionLeft       = 2,
    DXRadianDirectionRight      = 3,
};


@interface DXRadianLayerView : UIView

// 圆弧方向, 默认在下方
@property (nonatomic) DXRadianDirection direction;

// 圆弧高/宽, 可为负值。 正值凸, 负值凹
@property (nonatomic) CGFloat radian;

@end
