//
//  AGLKContext.m
//  esgl_1
//
//  Created by zhangyun on 2017/11/3.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import "AGLKContext.h"

@implementation AGLKContext


- (void)setClearColor:(GLKVector4)clearColor{
    self.clearColor = clearColor;
    NSAssert(self == [[self class] currentContext], @"right context");
    glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
}

- (void)clear:(GLbitfield)mask{
    glClear(mask);
}
@end
