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
#import "ZYCubeView.h"

@interface ViewController ()
@property (nonatomic,strong)  ZYGLView *glView;
@property (nonatomic,strong) ZYCubeView  *cubeView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.glView = [[ZYGLView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:self.glView];
//    [self.glView prepare];
//    [self.glView display];    
    
    self.cubeView = [[ZYCubeView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.cubeView];
    [self.cubeView prepare];
    [self.cubeView drawAndRender];

    
//    UIPickerView *pickV = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
//    [self.view addSubview:pickV];
//
//    pickV.delegate = self;
}

// returns the number of 'columns' to display.
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
//    return 1;
//}
//
//// returns the # of rows in each component..
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
//    return 3;
//}
//
//- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//
//}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"***>%s-%d",__FUNCTION__,__LINE__);
    
    [self.cubeView update];
}
@end
