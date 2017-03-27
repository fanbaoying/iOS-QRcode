//
//  ViewController.m
//  二维码一维码
//
//  Created by 范保莹 on 2017/3/27.
//  Copyright © 2017年 FBY. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SecondViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UITabBarDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * previewLayer;

/*** 专门用于保存描边的图层 ***/
@property (nonatomic,strong) CALayer *containerLayer;

@property(strong,nonatomic)UIView *customContainerView;

@property(strong,nonatomic)UILabel *customLabel;

@property(strong,nonatomic)UILabel *customLab;

@property(strong,nonatomic)UIButton *commodityBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.alpha = 1;

    self.customContainerView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/5, SCREEN_HEIGHT/4, SCREEN_WIDTH*3/5, SCREEN_WIDTH*3/5)];
    [self.customContainerView.layer setBorderWidth:2.0];
    self.customContainerView.layer.borderColor = [UIColor colorWithRed:174/255.0 green:109/255.0 blue:45/255.0 alpha:1].CGColor;
    
    //    self.customContainerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_customContainerView];
    
    self.customLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/5, SCREEN_HEIGHT/4+SCREEN_WIDTH*3/5+10, SCREEN_WIDTH*3/5, 30)];
    self.customLab.text = @"将二维码／条形码放入框内，即可自动扫描";
    self.customLab.font = [UIFont systemFontOfSize:11.0];
    self.customLab.textAlignment = NSTextAlignmentCenter;
    self.customLab.textColor = [UIColor whiteColor];
    
    self.customLab.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_customLab];
    
    self.customLabel = [[UILabel alloc]init];
    
    self.commodityBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-45, SCREEN_HEIGHT*3/4, 90, 30)];
    self.commodityBtn.backgroundColor = [UIColor lightGrayColor];
    [self.commodityBtn addTarget:self action:@selector(commodity:) forControlEvents:UIControlEventTouchUpInside];
    [self.commodityBtn setTitle:@"直接录入" forState:UIControlStateNormal];
    self.commodityBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    
    [self.view addSubview:_commodityBtn];

    
    // 开始扫描二维码
    [self startScan];
}

- (void)commodity:(UIButton *)sender{
    
    SecondViewController *svc = [[SecondViewController alloc]init];
    
    [self presentViewController:svc animated:YES completion:nil];
    
}

//导航栏返回
- (void)backBtn:(UIButton *)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (AVCaptureDevice *)device
{
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureDeviceInput *)input
{
    if (_input == nil) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

- (AVCaptureSession *)session
{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (_previewLayer == nil) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
    return _previewLayer;
}
// 设置输出对象解析数据时感兴趣的范围
// 默认值是 CGRect(x: 0, y: 0, width: 1, height: 1)
// 通过对这个值的观察, 我们发现传入的是比例
// 注意: 参照是以横屏的左上角作为, 而不是以竖屏
//        out.rectOfInterest = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
- (AVCaptureMetadataOutput *)output
{
    if (_output == nil) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        
        //        _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
        
        // 1.获取屏幕的frame
        CGRect viewRect = self.view.frame;
        // 2.获取扫描容器的frame
        CGRect containerRect = self.customContainerView.frame;
        
        CGFloat x = containerRect.origin.y / viewRect.size.height;
        CGFloat y = containerRect.origin.x / viewRect.size.width;
        CGFloat width = containerRect.size.height / viewRect.size.height;
        CGFloat height = containerRect.size.width / viewRect.size.width;
        
        // CGRect outRect = CGRectMake(x, y, width, height);
        // [_output rectForMetadataOutputRectOfInterest:outRect];
        _output.rectOfInterest = CGRectMake(x, y, width, height);
        //        _output.rectOfInterest = CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT/3, SCREEN_WIDTH/2, SCREEN_WIDTH/2);
        
        
    }
    return _output;
}

- (CALayer *)containerLayer
{
    if (_containerLayer == nil) {
        _containerLayer = [[CALayer alloc] init];
        
    }
    return _containerLayer;
}

- (void)startScan
{
    // 1.判断输入能否添加到会话中
    if (![self.session canAddInput:self.input]) return;
    [self.session addInput:self.input];
    
    
    // 2.判断输出能够添加到会话中
    if (![self.session canAddOutput:self.output]) return;
    [self.session addOutput:self.output];
    
    // 4.设置输出能够解析的数据类型
    // 注意点: 设置数据类型一定要在输出对象添加到会话之后才能设置
    self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;
    
    // 5.设置监听监听输出解析到的数据
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 6.添加预览图层
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    self.previewLayer.frame = self.view.bounds;
    
    // 7.添加容器图层
    [self.view.layer addSublayer:self.containerLayer];
    self.containerLayer.frame = self.view.bounds;
    
    // 8.开始扫描
    [self.session startRunning];
}

- (void)stopRunning{
    
    [self.session stopRunning];
    
    NSLog(@"%@",_customLabel.text);
    
    SecondViewController *svc = [[SecondViewController alloc]init];
    
    svc.str = _customLabel.text;
    
    [self presentViewController:svc animated:YES completion:nil];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.session startRunning];
    
}

#pragma mark --------AVCaptureMetadataOutputObjectsDelegate ---------
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    
    // id 类型不能点语法,所以要先去取出数组中对象
    AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
    
    if (object == nil) return;
    
    // 只要扫描到结果就会调用
    self.customLabel.text = object.stringValue;
    
    if (!(_customLabel.text == nil)) {
        
        
        [self stopRunning];
        
    }
    // 清除之前的描边
    [self clearLayers];
    
    // 对扫描到的二维码进行描边
    AVMetadataMachineReadableCodeObject *obj = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:object];
    
    // 绘制描边
    [self drawLine:obj];
    
    
    
}

- (void)drawLine:(AVMetadataMachineReadableCodeObject *)objc
{
    NSArray *array = objc.corners;
    
    // 1.创建形状图层, 用于保存绘制的矩形
    CAShapeLayer *layer = [[CAShapeLayer alloc]init];
    
    // 设置线宽
    layer.lineWidth = 2;
    // 设置描边颜色
    layer.strokeColor = [UIColor colorWithRed:174/255.0 green:109/255.0 blue:45/255.0 alpha:1].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    
    // 2.创建UIBezierPath, 绘制矩形
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGPoint point = CGPointZero;
    int index = 0;
    
    CFDictionaryRef dict = (__bridge CFDictionaryRef)(array[index++]);
    // 把点转换为不可变字典
    // 把字典转换为点，存在point里，成功返回true 其他false
    CGPointMakeWithDictionaryRepresentation(dict, &point);
    
    // 设置起点
    [path moveToPoint:point];
    
    // 2.2连接其它线段
    for (int i = 1; i<array.count; i++) {
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[i], &point);
        [path addLineToPoint:point];
    }
    // 2.3关闭路径
    [path closePath];
    
    layer.path = path.CGPath;
    // 3.将用于保存矩形的图层添加到界面上
    [self.containerLayer addSublayer:layer];
}

- (void)clearLayers
{
    if (self.containerLayer.sublayers)
    {
        for (CALayer *subLayer in self.containerLayer.sublayers)
        {
            [subLayer removeFromSuperlayer];
        }
    }
}

@end
