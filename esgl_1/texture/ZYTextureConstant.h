//
//  ZYTextureConstant.h
//  esgl_1
//
//  Created by zhangyun on 2017/10/23.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#ifndef ZYTextureConstant_h
#define ZYTextureConstant_h

#import <OpenGLES/gltypes.h>

typedef struct {
    GLfloat postion[3];
    GLfloat texCoord[2];
    GLfloat normalCoord[3];
}ZYVextex;

static const ZYVextex text2DSquare[] = {
    {{-1,-1,0},{0,0}},
    {{1,-1,0},{1,0}},
    {{1,1,0},{1,1}},
    {{-1,1,0},{0,1}}
};

static const GLubyte squareIndicts[] = {
    0,1,2,
    2,3,0
};


#endif /* ZYTextureConstant_h */
