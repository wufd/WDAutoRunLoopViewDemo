//
//  WDAutoRunLoopView.m
//  WDRunLoopProject
//
//  Created by wufd on 10/10/15.
//  Copyright © 2015年 wufd. All rights reserved.
//

#import "WDAutoRunLoopView.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "Masonry.h"

//设置scrollview的frame
#define scrollW (CGRectGetWidth(self.frame))
#define scrollH (CGRectGetHeight(self.frame))
//自动播放时间间隔
#define autoTime 3.5

@interface WDAutoRunLoopView ()<UIScrollViewDelegate>
@property(nonatomic,strong)UIImageView * leftImgV;
@property(nonatomic,strong)UIImageView * centerImgV;
@property(nonatomic,strong)UIImageView * rightImgV;

@property(nonatomic,assign)int currentIndex;
@property(nonatomic,assign)int imgCount;

@property(nonatomic,strong)UITapGestureRecognizer *tap;
@property(nonatomic,strong)NSTimer * timer;

@property(nonatomic,strong)UIView * contentView;
@property(nonatomic,strong)UIScrollView * scrollView;

@end

@implementation WDAutoRunLoopView

+(instancetype)viewWithSuperView:(UIView *)SuperView Insets:(UIEdgeInsets)Insets WithDataArray:(NSMutableArray *)dataArray {
    
    
    WDAutoRunLoopView * view = [WDAutoRunLoopView new];
    [SuperView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(SuperView).insets(Insets);
//        make.width.equalTo(@300);
//        make.height.equalTo(@200);
//        make.centerX.equalTo(SuperView.mas_centerX);
//        make.centerY.equalTo(SuperView.mas_centerY);
    }];
    [view setUpView];
    view.dataArray = dataArray;
    return view;
}

-(void)setUpView{
    _animationsTime = autoTime;
    __weak WDAutoRunLoopView * wself = self;
    _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    [self addSubview:_scrollView];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.pagingEnabled=YES;
    _scrollView.bounces = YES;
    _scrollView.alwaysBounceHorizontal = YES;
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.mas_top);
        make.left.equalTo(wself.mas_left);
        make.bottom.equalTo(wself.mas_bottom);
        make.width.equalTo(wself.mas_width);
    }];
    [_scrollView setContentSize:CGSizeMake(3*scrollW, 0)];
    [_scrollView setContentOffset:CGPointMake(scrollW, 0) animated:NO];
    
    _contentView = [UIView new];
    [_scrollView addSubview:_contentView];
    _contentView.backgroundColor = [UIColor clearColor];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.height.equalTo(_scrollView);
    }];
    
    [self setupImageView];
}

- (void)setupImageView {
    __weak WDAutoRunLoopView * wself = self;
    UIView * lastView = nil;
    for (int i = 0; i < 3; i++) {
        UIImageView * imv = [UIImageView new];
        [_contentView addSubview:imv];
        imv.backgroundColor = [UIColor whiteColor];
        imv.userInteractionEnabled=YES;
        imv.tag = i;
        imv.contentMode = UIViewContentModeScaleToFill ;
        [imv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentView.mas_top);
            make.height.equalTo(wself.scrollView.mas_height);
            make.width.equalTo(wself.scrollView.mas_width);
            if (lastView) {
                make.left.equalTo(lastView.mas_right);
            }else{
                make.left.equalTo(_contentView.mas_left);
            }
        }];
        lastView = imv;
        switch (i) {
            case 0:{
                self.leftImgV = imv;
            }
                break;
            case 1:{
                self.centerImgV = imv;
            }
                break;
            case 2:{
                self.rightImgV = imv;
            }
                break;
        }
    }
    
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(lastView.mas_right);
    }];
    self.tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView)];
    [self.centerImgV addGestureRecognizer:self.tap];
}

-(void)tapImageView{
    if(self.tapBlock){
        self.tapBlock(self.currentIndex);
    }
}

-(void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = dataArray;
    self.currentIndex = 0;
    [self invalTimer];
    self.imgCount = (int)dataArray.count;
    for (NSURL * imgUrl in _dataArray) {
        [[[SDWebImageDownloader alloc] init] downloadImageWithURL:imgUrl
                                                          options:SDWebImageDownloaderUseNSURLCache
                                                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {}];
    }
    [self beginTimer];
    if (self.imgCount == 1) {
        _scrollView.contentSize = CGSizeMake(scrollW, scrollH);
        [_scrollView setContentOffset:CGPointMake(0, 0)];
    }
    [self setMoveToIndex:0];
}

-(void)autoDrag{
    if(!_dataArray || _dataArray.count == 1){
        return;
    }
    [_scrollView setContentOffset:CGPointMake(scrollW*2, 0) animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int contentOffsetX = scrollView.contentOffset.x;
    if(contentOffsetX >= (2 * scrollW)) {
        self.currentIndex = (self.currentIndex+1)%self.imgCount;
        [self change];
    }
    if(contentOffsetX <= 0) {
        self.currentIndex = (self.currentIndex-1+self.imgCount)%self.imgCount;
        [self change];
    }
}

/**
 *  加载图片
 */
-(void)change{
    [self setUpImageViewTagWithIndex];
    [_scrollView setContentOffset:CGPointMake(scrollW, 0)];
}

-(void)setUpImageViewTagWithIndex{
    self.centerImgV.tag = self.currentIndex;
    
    int leftTag = self.currentIndex -1;
    int rightTag = self.currentIndex +1;
    
    if (leftTag<0) {
        leftTag = self.imgCount-1;
    }
    
    if (rightTag>=self.imgCount) {
        rightTag = 0;
    }
    
    self.leftImgV.tag =leftTag;
    self.rightImgV.tag = rightTag;
    
    [self updateImgViewWithImageView:self.centerImgV];
    [self updateImgViewWithImageView:self.leftImgV];
    [self updateImgViewWithImageView:self.rightImgV];
    
}

-(void)updateImgViewWithImageView:(UIImageView *)imgView{
    int tag = (int)imgView.tag;
    NSURL * url = [self.dataArray objectAtIndex:tag];
    [imgView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (imgView.tag == tag) {
            if (image) {
                imgView.image = image;
            }else{
                imgView.image = [UIImage imageNamed:@"img"];
            }
        }
    }];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self invalTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self beginTimer];
}

#pragma mark - timer
-(void)invalTimer{
    
    if (self.timer) {
        [self.timer  invalidate];
        self.timer=nil;
    }
}

-(void)beginTimer{
    if (!self.timer) {
        self.timer=  [NSTimer scheduledTimerWithTimeInterval:_animationsTime target:self selector:@selector(autoDrag) userInfo:nil repeats:YES];
    }
}

-(void)startAutoAnimations {
    [self beginTimer];
}

-(void)stopAnimations {
    [self invalTimer];
}

-(void)setMoveToIndex:(int)currentIndex{
    _currentIndex = currentIndex;
    [self change];
}

- (void)setAnimationsTime:(CGFloat)animationsTime {
    _animationsTime = animationsTime;
    [self invalTimer];
    [self beginTimer];
}

- (void)dealloc {
    [self invalTimer];
}

@end
