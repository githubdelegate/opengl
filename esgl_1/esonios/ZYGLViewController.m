//
//  ZYGLViewController.m
//  esgl_1
//
//  Created by zhangyun on 2017/11/2.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import "ZYGLViewController.h"

typedef struct{
    GLKVector3 positionCoords;
}SceneVertex;

static const SceneVertex vertexs[] = {
    {{-0.5f,-0.5f,0}},
    {{0.5f,-0.5f,0}},
    {{-0.5f,0.5f,0}}
};

@interface ZYGLViewController ()
@property (nonatomic,strong) GLKBaseEffect  *baseeft;
@end

@implementation ZYGLViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    GLKView *view = (GLKView *)self.view;
    
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    self.baseeft = [[GLKBaseEffect alloc] init];
    self.baseeft.useConstantColor = GL_TRUE;
    self.baseeft.constantColor = GLKVector4Make(1, 0.5, 0.3, 1);
    glClearColor(0, 0, 0, 1);
    GLuint bId;
    glGenBuffers(1, &bId);
    glBindBuffer(GL_ARRAY_BUFFER, bId);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_STATIC_DRAW);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    [self.baseeft prepareToDraw];
    
    glClear(GL_COLOR_BUFFER_BIT);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

@end
