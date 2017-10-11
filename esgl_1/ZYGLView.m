//
//  ZYGLView.m
//  esgl_1
//
//  Created by zhangyun on 2017/10/9.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import "ZYGLView.h"
#import <GLKit/GLKit.h>
#import "VFMatrix.h"

typedef struct{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
}RGBAColor;

typedef struct {
    GLfloat Position[3];
    GLfloat Color[4];
    
}VFVertex;


static const GLfloat whiteColor[] = {1,1,1,1};
static const RGBAColor kDefaultColor = {0.4,0.7,0.9,1.f};
static const VFVertex crossLinesVertices[] = {
  // line one
    {0.5f,0.5f,0.f},
    {-0.5f,-0.5f,0.f},
    
    // line two
    {-0.53f,0.48f,0.f},
    {0.55f,-0.4f,0.f}
};

@interface ZYGLView(){
    GLint programID;
}
@property (nonatomic,strong) EAGLContext *ctx;
@property (nonatomic,assign) CGFloat windowScale;
@end

@implementation ZYGLView

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
        layer.drawableProperties = @{kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8,kEAGLDrawablePropertyRetainedBacking:@(YES)};
        layer.contentsScale = [UIScreen mainScreen].scale;
        layer.opaque = YES;
    }
    return self;
}

- (void)prepare{
    
    // 1.
    EAGLContext *ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:ctx];
    self.ctx = ctx;
    
    // 2.
    glClearColor(kDefaultColor.red, kDefaultColor.green, kDefaultColor.blue, kDefaultColor.alpha);
    
    // 3.
    GLuint rboId;
    glGenRenderbuffers(1, &rboId);
    glBindRenderbuffer(GL_RENDERBUFFER, rboId);
    
    // 4.
    GLuint fboId;
    glGenFramebuffers(1, &fboId);
    glBindFramebuffer(GL_FRAMEBUFFER, fboId);
    
    // 5.
   glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, rboId);
    
    // 6.
    [ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    // 7.
    GLuint vertexId = [self addShader:GL_VERTEX_SHADER];
    GLuint fragmentId = [self addShader:GL_FRAGMENT_SHADER];
    if (vertexId ==0 || fragmentId == 0) {
        return;
    }

    // 8.
    GLuint programId = glCreateProgram();
    
    // 9.
    glAttachShader(programId, vertexId);
    glAttachShader(programId, fragmentId);
    
    // 10.
    glBindAttribLocation(programId, 0, "v_Position");
    glBindAttribLocation(programId, 1, "v_Color");
    
    // 11. link program
    glLinkProgram(programId);
    GLint linkSuccess;
    glGetProgramiv(programId, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLint infoLen;
        glGetProgramiv(programId, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 0) {
            GLchar *msg = malloc(sizeof(GLchar *) * infoLen);
            glGetProgramInfoLog(programId, infoLen,NULL, msg);
            NSString *str = [NSString stringWithUTF8String:msg];
            NSLog(@"**---->shader link error:%@",str);
            free(msg);
        }
        NSLog(@"**---->shader link error return");
        return;
    }
    programID = programId;
    
    // 12. 重置渲染内存
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 13. 设置视窗
    GLint renderbufW,renderbufH;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderbufW);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderbufH);
    glViewport(0, 0, renderbufW, renderbufH);
    
    self.windowScale = renderbufW / renderbufH;
    
    // 14. 加载数据
    GLuint vboId;
    glGenBuffers(1, &vboId);
    
    const GLvoid *dataPtr;
    GLsizeiptr dataSize;
    GLsizei verticesIndicesCount;
    
    dataSize = sizeof(crossLinesVertices);
    dataPtr = crossLinesVertices;
    verticesIndicesCount = (GLsizei)(sizeof(crossLinesVertices) / sizeof(crossLinesVertices[0]));
    
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glBufferData(GL_ARRAY_BUFFER, dataSize, dataPtr, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    // 给shader attribute 提供数据
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(VFVertex), (const GLvoid *)offsetof(VFVertex,Position));
    
    glDisableVertexAttribArray(1);
    glVertexAttrib4fv(1, whiteColor);
}

- (void)display{
    
    // 1.
    glUseProgram(programID);
    
    // scale
    VFMatrix4 scaleMat4 = VFMatrix4MakeScaleY(self.windowScale);
    VFMatrix4 transMat4 = VFMatrix4Identity;
    glUniformMatrix4fv(0,   // 定义的 uniform 变量的内存标识符
                       1,                                           // 不是 uniform 数组，只是一个 uniform -> 1
                       GL_FALSE,                                    // ES 下 只能是 False
                       (const GLfloat *)scaleMat4.m1D);             // 数据的首指针
    
    glUniformMatrix4fv(1,   // 定义的 uniform 变量的内存标识符
                       1,                                           // 不是 uniform 数组，只是一个 uniform -> 1
                       GL_FALSE,                                    // ES 下 只能是 False
                       (const GLfloat *)transMat4.m1D);             // 数据的首指针

    
    // 2. 绘制
    glLineWidth(10);
    glDrawArrays(GL_LINES, 0, 4);
    
    // 3. 渲染
    [self.ctx presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)addShader:(GLenum)type{
    NSString *fileName;
    if (type == GL_VERTEX_SHADER) {
        fileName = @"vertex.glsl";
    }else{
        fileName = @"fragment.glsl";
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString *vertex = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar *stringDatas = [vertex UTF8String];
    GLint stringLen = (GLint)vertex.length;
    GLuint vertexId = glCreateShader(type);
    glShaderSource(vertexId, 1, &stringDatas, &stringLen);
    glCompileShader(vertexId);
    GLint compileSuccess;
    glGetShaderiv(vertexId, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLint infoLen;
        glGetShaderiv(vertexId, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 0) {
            GLchar *msg = malloc(sizeof(GLchar *) * infoLen);
            glGetShaderInfoLog(vertexId, infoLen, NULL, msg);
            NSString *msgS = [NSString stringWithUTF8String:msg];
            NSLog(@"&&&-->shader erro: %@",msgS);
            free(msg);
        }
        return 0;
    }
    return vertexId;
}
@end
