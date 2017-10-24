//
//  ZYTextureView.m
//  esgl_1
//
//  Created by zhangyun on 2017/10/20.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import "ZYTextureView.h"
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>
#import "ZYTextureConstant.h"
#import "VYTransforms.h"

@interface ZYTextureView(){
    GLuint fboId;
    GLuint colorRboId;
    GLuint textureId;
    GLuint vboId;
    
    GLint programId;
    
}
@property (nonatomic,strong) EAGLContext  *ctx;
@property (nonatomic,strong) VYTransforms  *currentTransforms,*oldTransform;
@end

@implementation ZYTextureView

- (void)layoutSubviews{
    
    self.ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.ctx];
    
    //------ 1. 配置帧，渲染缓存 ---------
    // 1.1 帧缓存
    glGenFramebuffers(1, &fboId);
    glBindFramebuffer(GL_FRAMEBUFFER, fboId);
    // 1.2 渲染缓存
    glGenRenderbuffers(1, &colorRboId);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRboId);
    [self.ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    // 1.3 绑定渲染缓存
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRboId);
    
    // 1.4 计算渲染宽高
    GLint renderWidth = 0, renderHeight = 0;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderHeight);
    
    //----- 2. 准备顶点和下标数据 -----
//    glGenBuffers(1, &vboId);
//    glBindBuffer(GL_ARRAY_BUFFER, vboId);
//    const GLvoid *data = NULL;
//    data = text2DSquare;
//    glBufferData(GL_ARRAY_BUFFER, sizeof(text2DSquare), text2DSquare, GL_STATIC_DRAW);
    const GLvoid *indicts = NULL;
    indicts = squareIndicts;
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(squareIndicts), indicts, GL_STATIC_DRAW);
    
    //------- 3. 设置shader program -------
    GLuint vShaderId = [self addShader:GL_VERTEX_SHADER];
    GLuint fShaderId = [self addShader:GL_FRAGMENT_SHADER];
    programId = glCreateProgram();
    glAttachShader(programId, vShaderId);
    glAttachShader(programId, fShaderId);
    glBindAttribLocation(programId, 0, "a_position");
    glBindAttribLocation(programId, 1, "a_texCoord");
    glLinkProgram(programId);
    
    //------ 4.使用shader程序 ------
    // 4.1 设置背景
    glClearColor(0.3,0.3, 0.3, 1);
    // 4.2 清理缓存
    glClear(GL_COLOR_BUFFER_BIT);
    // 4.3 设置视口
    glViewport(0, 0, renderWidth, renderHeight);
    // 4.4 使用shader 程序
    glUseProgram(programId);
    // 4.5 坐标转换 计算变换矩阵
    GLuint modelViewLoc = glGetUniformLocation(programId, "u_modelViewMat4");
    GLuint projectionLoc = glGetUniformLocation(programId, "u_projectionMat4");
    
    VYTransforms *trans = self.currentTransforms;
    trans.modelTransform = VYSTTransformSetPosition(trans.modelTransform, trans.PositionVec3Make(0,-0.5,-3));
    trans.modelTransformMat4 = VYSTTransformMat4Make(trans.modelTransform);
    trans.viewTransformMat4 = VYSTTransformMat4Make(trans.viewTransform);
    trans.lookAtMat4 = VYLookAtMat4Make(trans.lookAt);
    trans.perspectiveProjMat4 = VYPerspectivePerspectiveMat4Make(trans.perspectiveProj);
    trans.baseCamera = VYCameraMake(trans.lookAtMat4, trans.perspectiveProjMat4);
    trans.baseCameraMat4 = VYCameraMat4Make(trans.baseCamera);
    trans.mvpTransfrom = VYMVPTransformMake(trans.modelTransformMat4, trans.viewTransformMat4, trans.baseCameraMat4);
    
    // 4.6 给shader中uniform变量赋值
    VYMVPTransform mvp = trans.mvpTransfrom;
    glUniformMatrix4fv(modelViewLoc, 1, GL_FALSE, VYMVPTransformModelViewMat4Make(mvp).m);
    glUniformMatrix4fv(projectionLoc, 1, GL_FALSE, mvp.cameraProjMat4.m);

    // 4.7 给attribute变量赋值
    glEnableVertexAttribArray(0);
//    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(ZYVextex), (const GLvoid*)offsetof(ZYVextex, postion));
    GLfloat *d = text2DSquare;
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(ZYVextex),d);
    glEnableVertexAttribArray(1);
//    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(ZYVextex), (const GLvoid *)offsetof(ZYVextex, texCoord));
    d = d + 3;
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(ZYVextex),d);
    
    //------ 5. 创建texture -----
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureId);
    // 5.1给sample变量赋值
    GLuint textureSourceLoc = glGetUniformLocation(programId, "us2d_texture");
    glUniform1i(textureSourceLoc, 0);
    
    // 5.2 加载纹理数据
    [self p_loadTextureImg:@"512_512" completion:^(NSMutableData *data, size_t newWidth, size_t newHeight) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, newWidth, newHeight, GL_FALSE, GL_RGBA, GL_UNSIGNED_BYTE, data.bytes);
    }];
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    //----- 6.绘制------
    glBindRenderbuffer(GL_RENDERBUFFER, colorRboId);
    glDrawElements(GL_TRIANGLES, sizeof(indicts)/sizeof(indicts[0]), GL_UNSIGNED_BYTE, indicts);
//    glDrawArrays(GL_TRIANGLES, 0, 4);
    [self.ctx presentRenderbuffer:GL_RENDERBUFFER];
 
    // delete source
    glDeleteTextures(1, &textureId);
    glDeleteProgram(programId);
    glDeleteShader(vShaderId);
    glDeleteShader(fShaderId);
    glDeleteBuffers(1, &vboId);
    glDeleteFramebuffers(1, &fboId);
    glDeleteRenderbuffers(1, &colorRboId);
    [EAGLContext setCurrentContext:nil];
}
- (GLuint)addShader:(GLenum)type{
    NSString *fileName;
    if (type == GL_VERTEX_SHADER) {
        fileName = @"textureVertex.glsl";
    }else{
        fileName = @"textureFragment.glsl";
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

- (size_t)aspectSizeWithDimension:(size_t)dimension{
    
    size_t failure = 0;
    if (dimension  <= 0 || (dimension % 2) != 0) {
        return failure;
    }
    
    GLint _2dTextureSzie;
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &_2dTextureSzie);
    
    if (dimension > _2dTextureSzie) {
        return failure;
    }
    
    if (dimension == _2dTextureSzie) {
        return  _2dTextureSzie;
    }
    
    GLint min = 1;
    size_t aspectSize = min;
    GLuint index = 1;
    
    while (_2dTextureSzie / pow(2,index) != min) {
        if (dimension > (_2dTextureSzie / pow(2, index))) {
            aspectSize = (_2dTextureSzie / pow(2,index -1));
            break;
        }
        index++;
    }
    return aspectSize;
}

- (void)p_loadTextureImg:(NSString *)imgName completion:(void(^)(NSMutableData *data,size_t newWidth,size_t newHeight))block{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"512_512.png" ofType:nil];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    CGImageRef cimg = img.CGImage;
    size_t originalW = CGImageGetWidth(cimg);
    size_t originalH = CGImageGetHeight(cimg);
    
    size_t width = [self aspectSizeWithDimension:originalW];
    size_t height = [self aspectSizeWithDimension:originalH];
    
    NSMutableData *imageData = [NSMutableData dataWithLength:(height * width * 4)];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate([imageData mutableBytes], width, height, 8, (width * 4), colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    CGContextTranslateCTM(cgContext, 0, height);
    CGContextScaleCTM(cgContext, 1.0, -1.0);
    CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height), cimg);
    CGContextRelease(cgContext);
    
    if (block) {
        block(imageData,width,height);
    }
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self settingDrawable];
        [self settingDefault];
    }
    return self;
}


- (void)settingDrawable {
    
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.drawableProperties = @{kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8,
                                 kEAGLDrawablePropertyRetainedBacking : @(YES)};
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.opaque = YES;
}

- (void)settingDefault {
    self.currentTransforms = self.oldTransform = [[VYTransforms alloc] init];
    [self setDefaultTransforms];
}

- (void)setDefaultTransforms {
    VYTransforms *trans = self.currentTransforms;
    // Model Transform
    trans.modelTransform = VYSTTransformMake(trans.PositionVec3Make(0, 0, 0),
                                             trans.RotationVec3Make(0, 0, 0),
                                             trans.ScalingVec3Make(1, 1, 1));
    // View Transform
    trans.viewTransform = VYSTTransformMake(trans.PositionVec3Make(0, 0, 0),
                                            trans.RotationVec3Make(0, 0, 0),
                                            trans.ScalingVec3Make(1, 1, 1));
    // Projection Transform
    // LookAt
    trans.lookAt = VYLookAtMake(trans.EyeVec3Make(0, 0, 0),
                                trans.CenterVec3Make(0, 0, -1),
                                trans.UpVec3Make(0, 1, 0));
    trans.aspectRadio = (self.bounds.size.width / self.bounds.size.height);
    trans.perspectiveProj = VYPerspectivePerspectiveMake(GLKMathDegreesToRadians(85.0),
                                                         trans.aspectRadio,
                                                         1, 150);
    
}

@end
