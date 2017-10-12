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

// vertex attribute struct
typedef struct {
    GLfloat Position[3];
    GLfloat Color[4];
    
}VFVertex;

// 白色
static const GLfloat whiteColor[] = {1,1,1,1};
static const RGBAColor kDefaultColor = {0.4,0.7,0.9,1.f};

// 4个顶点的数据
static const VFVertex crossLinesVertices[] = {
  // line one
    {0.5f,0.5f,0.f},
    {-0.5f,-0.5f,0.f},
    
    // line two
    {-0.53f,0.48f,0.f},
    {0.55f,-0.4f,0.f}
};

// 折线（山丘）
static const VFVertex mountainLinesVertices[] = {
    // Point one
    {-0.9f, -0.8f, 0.0f},
    
    // Point Two
    {-0.6f, -0.4f, 0.0f},
    
    // Point Three
    {-0.4f, -0.6f, 0.0f},
    
    // Point Four
    { 0.05f, -0.05f, 0.0f},
    
    // Point Five
    {0.45f, -0.65f, 0.0f},
    
    // Point Six
    { 0.55f,  -0.345f, 0.0f},
    
    // Point Seven
    { 0.95f, -0.95f, 0.0f},
};
@interface ZYGLView(){
    GLint programID;
}
@property (nonatomic,strong) EAGLContext *ctx;
@property (nonatomic,assign) GLfloat windowScale;
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
    
    // 1.设置上下文环境
    EAGLContext *ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:ctx];
    self.ctx = ctx;
    
    // 2. 设置背景颜色
    glClearColor(kDefaultColor.red, kDefaultColor.green, kDefaultColor.blue, kDefaultColor.alpha);
    
    // 3. 配置rbo
    GLuint rboId;
    glGenRenderbuffers(1, &rboId);
    glBindRenderbuffer(GL_RENDERBUFFER, rboId);
    
    // 4. 配置fbo
    GLuint fboId;
    glGenFramebuffers(1, &fboId);
    glBindFramebuffer(GL_FRAMEBUFFER, fboId);
    
    // 5. 绑定fbo rbo
   glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, rboId);
    
    // 6. 绑定renderbuffer到绘制表面
    [ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    // 7. 下面的shader的内容
    GLuint vertexId = [self addShader:GL_VERTEX_SHADER];
    GLuint fragmentId = [self addShader:GL_FRAGMENT_SHADER];
    if (vertexId ==0 || fragmentId == 0) {
        return;
    }

    // 8. 创建program
    GLuint programId = glCreateProgram();
    
    // 9. 添加shader 到program
    glAttachShader(programId, vertexId);
    glAttachShader(programId, fragmentId);
    
    // 10. 设置attribute 的index
    glBindAttribLocation(programId, 0, "v_Position");
    glBindAttribLocation(programId, 1, "v_Color");
    
    // 11. link program
    glLinkProgram(programId);
    GLint linkSuccess;
    // 检查是否链接成功
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
    // 获取当前设备窗口的宽高
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderbufW);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderbufH);
    glViewport(0, 0, renderbufW, renderbufH);
    
    // 获取宽高比,用来做坐标系转换
    self.windowScale = ((GLfloat)renderbufW / (GLfloat)renderbufH);
    
    // 14. 加载顶点数据
    GLuint vboId;
    glGenBuffers(1, &vboId);
    
    const GLvoid *dataPtr;
    GLsizeiptr dataSize;
    GLsizei verticesIndicesCount;
    
    dataSize = sizeof(mountainLinesVertices);
    dataPtr = mountainLinesVertices;
    verticesIndicesCount = (GLsizei)(sizeof(mountainLinesVertices) / sizeof(mountainLinesVertices[0]));
    
    // vbo
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glBufferData(GL_ARRAY_BUFFER, dataSize, dataPtr, GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    // 设置shader中postion数据
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(VFVertex), (const GLvoid *)offsetof(VFVertex,Position));
    // 设置shader 中color数据
    glDisableVertexAttribArray(1);
    glVertexAttrib4fv(1, whiteColor);
}

- (void)display{
    // 1. 使用program
    glUseProgram(programID);
    
    // 2. 坐标系转换，这块好复杂，没搞懂，直接使用了
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

    glLineWidth(10);
    // 2. 绘制
    glDrawArrays(GL_LINE_STRIP, 0, 7);
    
    // 3. 展示renderbuffer内容
    [self.ctx presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)addShader:(GLenum)type{
    NSString *fileName;
    if (type == GL_VERTEX_SHADER) {
        fileName = @"vertex.glsl";
    }else{
        fileName = @"fragment.glsl";
    }
    // 1. 从文件中加载shader代码
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString *shaderSource = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar *stringDatas = [shaderSource UTF8String];
    GLint stringLen = (GLint)shaderSource.length;
    
    // 2. 创建shader
    GLuint shaderId = glCreateShader(type);
    
    // 3. 加载代码
    glShaderSource(shaderId, 1, &stringDatas, &stringLen);
    
    // 4. 编译
    glCompileShader(shaderId);
    GLint compileSuccess;
    
    // 5. 检查是否编译成功
    glGetShaderiv(shaderId, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLint infoLen;
        glGetShaderiv(shaderId, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 0) {
            GLchar *msg = malloc(sizeof(GLchar *) * infoLen);
            glGetShaderInfoLog(shaderId, infoLen, NULL, msg);
            NSString *msgS = [NSString stringWithUTF8String:msg];
            NSLog(@"&&&-->shader erro: %@",msgS);
            free(msg);
        }
        return 0;
    }
    return shaderId;
}
@end
