//
//  AGLKVertexAttribArrayBuffer.m
//  esgl_1
//
//  Created by zhangyun on 2017/11/3.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import "AGLKVertexAttribArrayBuffer.h"

@implementation AGLKVertexAttribArrayBuffer

- (instancetype)initWithAttribStride:(GLsizeiptr)stride numberOfVertexs:(GLsizei)count data:(const GLvoid *)dataPtr usage:(GLenum)usage{
    NSParameterAssert(0 < stride);
    NSParameterAssert(0 < count);
    NSParameterAssert( nil != dataPtr);
    
    if (self = [super init]) {
        self.stride = stride;
        glGenBuffers(1, &_glname);
        glBindBuffer(GL_ARRAY_BUFFER, self.glname);
        glBufferData(GL_ARRAY_BUFFER, count * stride, dataPtr, usage);
        NSAssert(0 != _glname,@"faild gen buffer ");
    }
    return self;
}


- (void)prepareToDrawWithAttrib:(GLint)index numberofCoord:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(GLboolean)shouldEnable{
    
    glBindBuffer(GL_ARRAY_BUFFER, self.glname);
    if (shouldEnable) {
        glEnableVertexAttribArray(index);
    }
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, self.stride,NULL + offset);
}

- (void)drawWithMode:(GLenum)mode startVertexIndex:(GLuint)index numberOfVertex:(GLint)count{
    glDrawArrays(mode, index, count);
}

- (void)dealloc{
    if (0 != self.glname) {
        glDeleteBuffers(1, &_glname);
        self.glname = 0;
    }
}
@end
