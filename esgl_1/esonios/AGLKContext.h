//
//  AGLKContext.h
//  esgl_1
//
//  Created by zhangyun on 2017/11/3.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface AGLKContext : EAGLContext
@property (nonatomic,assign) GLKVector4  clearColor;

- (void)clear:(GLbitfield)mask;
@end
