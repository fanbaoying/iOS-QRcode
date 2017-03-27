//
//  SecondViewController.m
//  二维码一维码
//
//  Created by 范保莹 on 2017/3/27.
//  Copyright © 2017年 FBY. All rights reserved.
//

#import "SecondViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface SecondViewController ()

@property(strong,nonatomic)UILabel *titleLab;
@property(strong,nonatomic)UILabel *contentLab;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self titleLabel];
    [self contentLabel];
    
    //返回按钮
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 100, 50, 35)];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    backBtn.backgroundColor = [UIColor lightGrayColor];
    [backBtn setTitle:@"返回" forState:0];
    [self.view addSubview:backBtn];
    
}

- (void)back{

    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)titleLabel{

    self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 200, SCREEN_WIDTH/2, 30)];
    self.titleLab.text = @"扫描获取的数据";
    [self.view addSubview:_titleLab];
    
}

- (void)contentLabel{
    self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 245, SCREEN_WIDTH-40, 30)];
    self.contentLab.text = _str;
    [self.view addSubview:_contentLab];
}
@end
