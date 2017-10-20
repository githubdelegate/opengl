//
//  ZYCubeHeader.h
//  esgl_1
//
//  Created by zhangyun on 2017/10/19.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>


#define PositionCoordinateCount         (3)
#define ColorCoordinateCount            (4)

typedef struct {
    GLfloat position[PositionCoordinateCount];
    GLfloat color[ColorCoordinateCount];
} VFVertex;

#define RubikCubeColor

static const VFVertex vertices[] = {
    
#ifdef RubikCubeColor
    // Front
    // [UIColor colorWithRed:0.000 green:0.586 blue:1.000 alpha:1.000] // 湖蓝
    {{ 1.0, -1.0,  1.0}, {0.000, 0.586, 1.000, 1.000}}, // -- 0
    {{ 1.0,  1.0,  1.0}, {0.000, 0.586, 1.000, 1.000}}, // -- 1
    {{-1.0,  1.0,  1.0}, {0.000, 0.586, 1.000, 1.000}}, // -- 2
    {{-1.0, -1.0,  1.0}, {0.000, 0.586, 1.000, 1.000}}, // -- 3
    
    // Back
    // [UIColor colorWithRed:0.119 green:0.519 blue:0.142 alpha:1.000] // 暗绿
    {{-1.0, -1.0, -1.0}, {0.119, 0.519, 0.142, 1.000}}, // -- 4
    {{-1.0,  1.0, -1.0}, {0.119, 0.519, 0.142, 1.000}}, // -- 5
    {{ 1.0,  1.0, -1.0}, {0.119, 0.519, 0.142, 1.000}}, // -- 6
    {{ 1.0, -1.0, -1.0}, {0.119, 0.519, 0.142, 1.000}}, // -- 7
    
    // Left
    // [UIColor colorWithRed:1.000 green:0.652 blue:0.000 alpha:1.000] // 橙
    {{-1.0, -1.0,  1.0}, {1.000, 0.652, 0.000, 1.000}}, // -- 8
    {{-1.0,  1.0,  1.0}, {1.000, 0.652, 0.000, 1.000}}, // -- 9
    {{-1.0,  1.0, -1.0}, {1.000, 0.652, 0.000, 1.000}}, // -- 10
    {{-1.0, -1.0, -1.0}, {1.000, 0.652, 0.000, 1.000}}, // -- 11
    
    // Right
    // [UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:1.000] // 红色
    {{ 1.0, -1.0, -1.0}, {1.000, 0.000, 0.000, 1.000}}, // -- 12
    {{ 1.0,  1.0, -1.0}, {1.000, 0.000, 0.000, 1.000}}, // -- 13
    {{ 1.0,  1.0,  1.0}, {1.000, 0.000, 0.000, 1.000}}, // -- 14
    {{ 1.0, -1.0,  1.0}, {1.000, 0.000, 0.000, 1.000}}, // -- 15
    
    // Top
    // [UIColor colorWithRed:1.000 green:1.000 blue:0.000 alpha:1.000] // 黄色
    {{ 1.0,  1.0,  1.0}, {1.000, 1.000, 0.000, 1.000}}, // -- 16
    {{ 1.0,  1.0, -1.0}, {1.000, 1.000, 0.000, 1.000}}, // -- 17
    {{-1.0,  1.0, -1.0}, {1.000, 1.000, 0.000, 1.000}}, // -- 18
    {{-1.0,  1.0,  1.0}, {1.000, 1.000, 0.000, 1.000}}, // -- 19
    
    // Bottom
    // [UIColor colorWithWhite:1.000 alpha:1.000]                      // 白色
    {{ 1.0, -1.0, -1.0}, {1.000, 1.000, 1.000, 1.000}}, // -- 20
    {{ 1.0, -1.0,  1.0}, {1.000, 1.000, 1.000, 1.000}}, // -- 21
    {{-1.0, -1.0,  1.0}, {1.000, 1.000, 1.000, 1.000}}, // -- 22
    {{-1.0, -1.0, -1.0}, {1.000, 1.000, 1.000, 1.000}}, // -- 23
#else
    // Front
    // 0 [UIColor colorWithRed:0.438 green:0.786 blue:1.000 alpha:1.000]
    {{ 1.0, -1.0,  1.0}, {0.438, 0.786, 1.000, 1.000}}, // 淡（蓝） -- 0
    
    // 1 [UIColor colorWithRed:1.000 green:0.557 blue:0.246 alpha:1.000]
    {{ 1.0,  1.0,  1.0}, {1.000, 0.557, 0.246, 1.000}}, // 淡（橙） -- 1
    
    // 2 [UIColor colorWithRed:0.357 green:0.927 blue:0.690 alpha:1.000]
    {{-1.0,  1.0,  1.0}, {0.357, 0.927, 0.690, 1.000}}, // 蓝（绿） -- 2
    
    // 3 [UIColor colorWithRed:0.860 green:0.890 blue:0.897 alpha:1.000]
    {{-1.0, -1.0,  1.0}, {0.860, 0.890, 0.897, 1.000}}, // 超淡蓝 偏（白） -- 3
    
    // Back
    // 4 [UIColor colorWithRed:0.860 green:0.890 blue:0.897 alpha:1.000]
    {{-1.0, -1.0, -1.0}, {0.860, 0.890, 0.897, 1.000}}, // 超淡蓝 偏（白） -- 4
    
    // 5 [UIColor colorWithRed:0.357 green:0.927 blue:0.690 alpha:1.000]
    {{-1.0,  1.0, -1.0}, {0.357, 0.927, 0.690, 1.000}}, // 蓝（绿） -- 5
    
    // 6 [UIColor colorWithRed:1.000 green:0.557 blue:0.246 alpha:1.000]
    {{ 1.0,  1.0, -1.0}, {1.000, 0.557, 0.246, 1.000}}, // 淡（橙） -- 6
    
    // 7 [UIColor colorWithRed:0.438 green:0.786 blue:1.000 alpha:1.000]
    {{ 1.0, -1.0, -1.0}, {0.438, 0.786, 1.000, 1.000}}, // 淡（蓝） -- 7
#endif
};

static const GLubyte indices[] = {
    
#ifdef RubikCubeColor
    // Front
    0, 1, 2,
    2, 3, 0,
    // Right
    4, 5, 6,
    6, 7, 4,
    // Back
    8 , 9 , 10,
    10, 11, 8 ,
    // Left
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20,
#else
    // Front  ------------- 蓝橙绿白 中间线（蓝绿）
    0, 1, 2, // 蓝橙绿
    2, 3, 0, // 绿白蓝
    // Back   ------------- 蓝橙绿白 中间线（白橙）
    4, 5, 6, // 白绿橙
    6, 7, 4, // 橙蓝白
    // Left   ------------- 白绿
    3, 2, 5, // 白绿绿
    5, 4, 3, // 绿白白
    // Right  ------------- 蓝橙
    7, 6, 1, // 蓝橙橙
    1, 0, 7, // 橙蓝蓝
    // Top    ------------- 橙绿
    1, 6, 5, // 橙橙绿
    5, 2, 1, // 绿绿橙
    // Bottom ------------- 白蓝
    3, 4, 7, // 白白蓝
    7, 0, 3  // 蓝蓝白
#endif
};


@interface ZYCubeHeader : NSObject

@end