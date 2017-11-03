//
//  AGLKView.m
//  esgl_1
//
//  Created by zhangyun on 2017/11/3.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import "AGLKView.h"
#import <OpenGLES/ES2/gl.h>

@interface AGLKView()
@property (nonatomic,strong) EAGLContext  *ctx;
@end

@implementation AGLKView

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configureCtx];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self configureCtx];
    }
    return self;
}

- (void)configureCtx{
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.drawableProperties = @{kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8,kEAGLDrawablePropertyRetainedBacking:@NO};
}

- (void)setCtx:(EAGLContext *)ctx{
    if (ctx != self.ctx) {
        [EAGLContext setCurrentContext:self.ctx];
        if (0 != frameBuffer) {
            glDeleteFramebuffers(1, &frameBuffer);
            frameBuffer = 0;
        }
        
        if (0 != colorRenderBuffer) {
            glDeleteRenderbuffers(1, &colorRenderBuffer);
            colorRenderBuffer = 0;
        }
        
        self.ctx = ctx;
        
        if (nil == ctx) {
            self.ctx = ctx;
            [EAGLContext setCurrentContext:self.ctx];
            glGenFramebuffers(1, &frameBuffer);
            glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
            
            glGenRenderbuffers(1, &colorRenderBuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
            
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
        }
    }
}

- (NSInteger)drawableW{
    GLint backingW = 0;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingW);
    return backingW;
}

- (NSInteger)drawableH{
    NSInteger  backingH = 0;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingH);
    return backingH;
}

- (EAGLContext *)context{
    return self.ctx;
}

- (void)display{
    [EAGLContext setCurrentContext:self.ctx];
    glViewport(0, 0, (GLint)[self drawableW], (GLint)[self drawableH]);
    [self drawRect:[self bounds]];
    [self.ctx presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)drawRect:(CGRect)rect{
    
    if (self.delegate) {
        [self.delegate glkView:self drawInRect:rect];
    }
}

- (void)layoutSubviews{
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    
    [self.ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    GLenum sta = glCheckFramebufferStatus(frameBuffer);
    if (sta != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"frame buffer failed");
    }
}
@end
