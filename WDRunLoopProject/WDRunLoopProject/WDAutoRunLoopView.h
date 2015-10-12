//
//  WDAutoRunLoopView.h
//  WDRunLoopProject
//
//  Created by wufd on 10/10/15.
//  Copyright © 2015年 wufd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDAutoRunLoopView : UIView


/**
 *  点击图片响应方法
 */
@property(nonatomic,copy)void(^tapBlock)(NSInteger pageIndex) ;

/**
 *  内容图片url，NSURL
 */
@property(nonatomic,strong)NSMutableArray * dataArray;

/**
 *  定时动画时间 ，默认3.5
 */
@property(nonatomic)CGFloat animationsTime;

/**
 *  初始化滑动banner组件入口
 *
 *  @param frame     组件大小位置
 *  @param dataArray 内容图片url list，NSURL
 *
 *  @return LoopAdImgView初始化的banner
 */
+(instancetype)viewWithSuperView:(UIView *)SuperView Insets:(UIEdgeInsets)Insets WithDataArray:(NSMutableArray *)dataArray;

/**
 *  定时滑动的动画
 */
-(void)startAutoAnimations;
-(void)stopAnimations;



@end
