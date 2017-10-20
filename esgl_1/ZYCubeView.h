//
//  ZYCubeView.h
//  esgl_1
//
//  Created by zhangyun on 2017/10/12.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 可以旋转的立方体
 */
@interface ZYCubeView : UIView

- (void)prepare;
- (void)drawAndRender;
- (void)update;
@end
