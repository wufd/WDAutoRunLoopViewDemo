//
//  ViewController.m
//  WDRunLoopProject
//
//  Created by wufd on 10/10/15.
//  Copyright © 2015年 wufd. All rights reserved.
//

#import "ViewController.h"
#import "WDAutoRunLoopView.h"

@interface ViewController ()
@property (nonatomic,strong)WDAutoRunLoopView * loop;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSMutableArray * array = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        NSURL * url = [NSURL URLWithString:@"http://www.baidu.com"];
        [array addObject:url];
    }
    self.loop = [WDAutoRunLoopView viewWithSuperView:self.view Insets:UIEdgeInsetsMake(200, 0, 300, 0) WithDataArray:array];
    [self.loop startAutoAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
