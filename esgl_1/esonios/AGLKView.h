//
//  AGLKView.h
//  esgl_1
//
//  Created by zhangyun on 2017/11/3.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AGLKView;

@protocol AGLKViewDelegate <NSObject>
@required
- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect;
@end

@interface AGLKView : UIView
{
    EAGLContext *ctx;
    GLuint frameBuffer;
    GLuint colorRenderBuffer;
    GLint drawableW;
    GLint drawableH;
}
@property (nonatomic,strong) id<AGLKViewDelegate>  delegate;
- (void)display;
@end
