//
//  ZYCubeView.m
//  esgl_1
//
//  Created by zhangyun on 2017/10/12.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import "ZYCubeView.h"
#import <OpenGLES/ES2/gl.h>
#import "ZYCubeHeader.h"
#import <GLKit/GLKit.h>
#import "VFRedisplay.h"

#define RubikCubeColor

typedef struct {
    GLfloat postion[3];
    GLfloat color[4];
}Vertex;


@interface ZYCubeView(){
    GLuint  fboId;
    GLuint  colorRboId;
    GLuint  depthRboId;
    GLuint  programId;
    GLuint vboId;
    GLuint vShaderId;
    GLuint fShaderId;
    GLint projUnif;
    GLint modelUnif;
}
@property (nonatomic,strong) VFRedisplay  *display;
@property (nonatomic,strong) EAGLContext  *ctx;
@property (nonatomic,assign) CGSize renderSize;

//--- begin ---
@property (nonatomic,assign) GLKVector3 viewPostion,viewRotate,viewScale;
@property (nonatomic,assign) GLKVector3 modelPostion,modelRotate,modelScale;
@property (assign, nonatomic) GLfloat projectionFov, projectionScaleFix, projectionNearZ, projectionFarZ;
//---end ---

@end

@implementation ZYCubeView

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
        layer.drawableProperties = @{kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8,kEAGLDrawablePropertyRetainedBacking:@(YES)};
        layer.contentsScale = [UIScreen mainScreen].scale;
        layer.opaque = YES;
        
        [self setDefault];
    }
    return self;
}

- (void)setDefault {
    self.modelRotate   = GLKVector3Make(0, 0, 0);
    self.viewRotate    = self.modelRotate;
    
    self.modelScale    = GLKVector3Make(1, 1, 1);
    self.viewScale     = self.modelScale;
    
    self.projectionFov = GLKMathDegreesToRadians(85.0);
    self.projectionScaleFix = 1;
    self.projectionNearZ = 0;
    self.projectionFarZ  = 1500;
}

- (void)prepare{
    // 1. 基本配置
    EAGLContext *ctx =  [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:ctx];
    self.ctx = ctx;
    
    glDeleteFramebuffers(1, &fboId);
    glDeleteBuffers(1, &colorRboId);
    glDeleteBuffers(1, &depthRboId);
    fboId = colorRboId = depthRboId = 0;
    
    glGenFramebuffers(1, &fboId);
    glBindFramebuffer(GL_FRAMEBUFFER, fboId);
    
    glGenRenderbuffers(1, &colorRboId);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRboId);
    [self.ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    GLint w,h;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &w);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &h);
    self.renderSize = CGSizeMake(w, h);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRboId);
    [self chkFBOStatus];
    
    // --- depth render buffer
    glGenRenderbuffers(1, &depthRboId);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRboId);
    //    Once a renderbuffer object is bound, we can specify the dimensions and format of the image stored in the renderbuffer.
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.renderSize.width, self.renderSize.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRboId);
    [self chkFBOStatus];

    // 2.
    glClearColor(0.423, 0.43, 0.87, 1);
    
    // 3. 设置顶点数据，下标数据
    glGenBuffers(1, &vboId);
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    //The vertex array data or element array data storage is created and initialized using the glBufferData command.
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // 3. shader配置
    [self setShader];
    
    projUnif = glGetUniformLocation(programId, "u_Projection");
    modelUnif = glGetUniformLocation(programId, "u_ModelView");
    
    // 5. 给shader 参数设置数据
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(VFVertex), (const GLvoid *)offsetof(VFVertex, position));
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, sizeof(VFVertex), (const GLvoid *)offsetof(VFVertex, color));
    
}

- (void)drawAndRender{
    // 1. use program
    glUseProgram(programId);
    // 2. transform
    //FIXME: 这个不懂参数什么意思，如何取到的？
    self.modelPostion = GLKVector3Make(0, -0.5, -5);
    [self tansform];
    
    glViewport(0, 0, self.renderSize.width, self.renderSize.height);
    
    //FIXME: 这个不懂为什么设置？
    glDepthRangef(0, 1);
    // 3. clear old cached
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // 4. open depth test
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    // 5. draw
    glBindRenderbuffer(GL_RENDERBUFFER, colorRboId);
    //The glBindBuffer command is used to make a buffer object the current array buffer object or the current element array buffer object.
//    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, indices);
    
    // 6. render
    [self.ctx presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)update{
    VFRedisplay *display = [[VFRedisplay alloc] init];
    self.display = display;
    
    self.display.delegate = self;
    self.display.preferredFramesPerSecond = 15;
    self.display.updateContentTimes = arc4random_uniform(650) / 10000.0;
    [self.display startUpdate];
}

- (void)chkFBOStatus{
    GLenum s = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (s != GL_FRAMEBUFFER_COMPLETE) {
//        NSLog(@"failed setup framebuffer");
    }
}


- (void)preferTransformsWithTimes:(NSTimeInterval)time {
    
    GLfloat rotateX = self.modelRotate.x;
        rotateX += M_PI_2 * time;
    
    GLfloat rotateY = self.modelRotate.y;
    rotateY += M_PI_2 * time;
    
    GLfloat rotateZ = self.modelRotate.z;
    rotateZ += M_PI * time;
    self.modelRotate = GLKVector3Make(rotateX, rotateY, rotateZ);
}

// <VFRedisplayDelegate>
- (void)updateContentsWithTimes:(NSTimeInterval)times {
    
    [self preferTransformsWithTimes:times];
    [self drawAndRender];
    
}


#pragma mark - shader

- (void)setShader{
    vShaderId = [self addShader:GL_VERTEX_SHADER];
    fShaderId = [self addShader:GL_FRAGMENT_SHADER];
    programId = glCreateProgram();
    
    glAttachShader(programId, vShaderId);
    glAttachShader(programId, fShaderId);
    
    glBindAttribLocation(programId, 0, "a_Position");
    glBindAttribLocation(programId, 1, "a_Color");
    
    glLinkProgram(programId);
    
    GLint sts;
    glGetProgramiv(programId, GL_LINK_STATUS, &sts);
    if (sts == GL_FALSE) {
        GLint infoLen;
        glGetProgramiv(programId, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 0) {
            GLchar *info = malloc(sizeof(GLchar) * infoLen);
            glGetProgramInfoLog(programId, infoLen, NULL, info);
            NSLog(@" program link erro info %s",info);
            free(info);
        }
    }
}

- (GLuint)addShader:(GLenum)type{
    NSString *fileName;
    if (type == GL_VERTEX_SHADER) {
        fileName = @"cubuVextex.glsl";
    }else{
        fileName = @"cubeFragment.glsl";
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


#pragma mark - transform

- (void)tansform{
    GLKMatrix4 modelMat4 = [self model2world];
    GLKMatrix4 viewMat4 = [self world2camera];
    GLKMatrix4 modelviewMat4 = GLKMatrix4Multiply(modelMat4, viewMat4);
    glUniformMatrix4fv(modelUnif, 1, GL_FALSE, modelviewMat4.m);
    
    GLKMatrix4 projectMat4 = [self camera2clip];
    glUniformMatrix4fv(projUnif, 1, GL_FALSE, projectMat4.m);
}

- (GLKMatrix4)camera2clip{
    GLKMatrix4 projectMat4 = GLKMatrix4Identity;
    
    self.projectionScaleFix = self.bounds.size.width / self.bounds.size.height;
    self.projectionNearZ = 1;
    self.projectionFarZ = 150;
    projectMat4 = GLKMatrix4MakePerspective(self.projectionFov, self.projectionScaleFix, self.projectionNearZ, self.projectionFarZ);
    return projectMat4;
    
}

- (GLKMatrix4)world2camera{
    GLKMatrix4 viewMat4 = GLKMatrix4Identity;
    viewMat4 = GLKMatrix4Translate(viewMat4, self.viewPostion.x, self.viewPostion.y, self.viewPostion.z);
    viewMat4 = GLKMatrix4Rotate(viewMat4, self.viewRotate.x, 1, 0, 0);
    viewMat4 = GLKMatrix4Rotate(viewMat4, self.viewRotate.y, 0, 1, 0);
    viewMat4 = GLKMatrix4Rotate(viewMat4, self.viewRotate.z, 0, 0, 1);
    viewMat4 = GLKMatrix4Scale(viewMat4, self.viewScale.x, self.viewScale.y, self.viewScale.z);
    return viewMat4;
}

- (GLKMatrix4)model2world{
    
    GLKMatrix4 modelMat4 = GLKMatrix4Identity;
    modelMat4 = GLKMatrix4Translate(modelMat4, self.modelPostion.x, self.modelPostion.y, self.modelPostion.z);
    modelMat4 = GLKMatrix4Rotate(modelMat4, self.modelRotate.x, 1, 0, 0);
    modelMat4 = GLKMatrix4Rotate(modelMat4, self.modelRotate.y, 0, 1, 0);
    modelMat4 = GLKMatrix4Rotate(modelMat4, self.modelRotate.z, 0, 0, 1);
    modelMat4 = GLKMatrix4Scale(modelMat4, self.modelScale.x, self.modelScale.y, self.modelScale.z);
    return modelMat4;
}

@end

