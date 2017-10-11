//
//  ViewController.m
//  esgl_1
//
//  Created by zhangyun on 2017/10/9.
//  Copyright © 2017年 zhangyun. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/EAGL.h>
#import "ZYGLView.h"


@interface ViewController ()
@property (nonatomic,strong)  ZYGLView *glView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.glView = [[ZYGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
  
    [self.glView prepare];
    [self.glView display];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"***>%s-%d",__FUNCTION__,__LINE__);
}
@end
