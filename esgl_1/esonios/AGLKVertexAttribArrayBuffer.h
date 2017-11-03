//
//  AGLKVertexAttribArrayBuffer.h
//  esgl_1
//
//  Created by zhangyun on 2017/11/3.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface AGLKVertexAttribArrayBuffer : NSObject
@property (nonatomic,assign) GLuint glname;
@property (nonatomic,assign) GLsizeiptr stride;
@property (nonatomic,assign) GLsizeiptr buffersize;


- (instancetype)initWithAttribStride:(GLsizeiptr)stride numberOfVertexs:(GLsizei)count data:(const GLvoid*)dataPtr usage:(GLenum)usage;

- (void)prepareToDrawWithAttrib:(GLint)index numberofCoord:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(GLboolean)shouldEnable;

- (void)drawWithMode:(GLenum)mode startVertexIndex:(GLuint)index numberOfVertex:(GLint)count;
@end
