//
//  EHDemo2ViewController.m
//  EHSlideView
//
//  Created by Eric Huang on 17/1/17.
//  Copyright © 2017年 Eric Huang. All rights reserved.
//

#import "EHDemo2ViewController.h"
#import <Masonry/Masonry.h>
#import <EHHorizontalFixedWidthItemsView/EHHorizontalFixedWidthItemsTrackView.h>
#import <EHSlideView/EHSlideView.h>
#import "EHDemoTableViewController.h"
#import "WFEPercentageLabel.h"

static CGFloat const kLabelWidth = 68.0f;
static CGFloat const kLabelHeight = 24.0f;
static CGFloat const kMinimumInteritemSpacing = 20.0f;
static CGFloat const kTrackHeight = 4.0f;
static CGFloat const kTrackWidthPercent = 0.3f;

@interface EHDemo2ViewController () <EHHorizontalFixedWidthItemsTrackViewDelegate, EHSlideViewDataSource, EHSlideViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *words;
@property (nonatomic, strong) NSArray *trackLabels;
@property (nonatomic, strong) EHHorizontalFixedWidthItemsTrackView *trackView;
@property (nonatomic, strong) EHSlideView *slideView;

@property (nonatomic, weak) id<UIGestureRecognizerDelegate> originalDelegate;

@end

@implementation EHDemo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self configureForNavigationBar];
    [self configureForViews];
    
    [self.view addSubview:self.slideView];
    [self.slideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.slideView showControllerAtIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.originalDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    for (UIGestureRecognizer *gestureRecognizer in self.slideView.gestureRecognizers) {
        [gestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self.originalDelegate;
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

#pragma mark - EHHorizontalFixedWidthItemsTrackViewDelegate

- (void)didTapItemAtIndex:(NSInteger)index inView:(EHHorizontalFixedWidthItemsTrackView *)view {
    [self.slideView showControllerAtIndex:index];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.trackView scrollToMiddleOfFrameForItemViewAtIndex:index];
    });
}

#pragma mark - EHSlideViewDataSource

- (NSUInteger)numberOfControllersInSlideView:(EHSlideView *)slideView {
    return self.words.count;
}

- (UIViewController *)slideView:(EHSlideView *)slideView controllerAtIndex:(NSInteger)index {
    EHDemoTableViewController *controller = [[EHDemoTableViewController alloc] init];
    controller.controllerIndex = index;
    return controller;
}

#pragma mark - EHSlideViewDelegate

- (void)slideView:(EHSlideView *)slideView currentIndex:(NSInteger)currentIndex slidingToDirection:(EHSlideViewSlideDirection)direction percentage:(CGFloat)percentage {
    EHHorizontalFixedWidthItemsTrackViewSlideDirection trackDirection = (int)direction;
    [self.trackView slidingToDirection:trackDirection percentage:percentage];
}

- (void)slideView:(EHSlideView *)slideView currentIndex:(NSInteger)currentIndex willAutomaticallySlideToDirection:(EHSlideViewSlideDirection)direction {
    EHHorizontalFixedWidthItemsTrackViewSlideDirection trackDirection = (int)direction;
    [self.trackView slideToDirection:trackDirection];
}

- (void)slideView:(EHSlideView *)slideView currentIndex:(NSInteger)currentIndex willAutomaticallySlideBackFromDirection:(EHSlideViewSlideDirection)direction {
    EHHorizontalFixedWidthItemsTrackViewSlideDirection trackDirection = (int)direction;
    [self.trackView slideBackFromDirection:trackDirection];
}

- (void)slideView:(EHSlideView *)slideView didSlideToIndex:(NSInteger)index {
    [self.trackView scrollToMiddleOfFrameForItemViewAtIndex:self.trackView.selectedIndex];
}

#pragma mark - event response

#pragma mark - private methods

- (void)configureForNavigationBar {
    self.navigationItem.title = @"";
    self.trackView.frame = CGRectMake(0,
                                      0,
                                      CGRectGetWidth([UIScreen mainScreen].bounds),
                                      [self.trackView totalHeight]);
    self.navigationItem.titleView = self.trackView;
    self.navigationItem.hidesBackButton = YES;
}

- (void)configureForViews {
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - getters & setters

- (NSArray *)words {
    if (!_words) {
        _words = @[
                   @"照片", @"拍摄", @"小视频", @"视频聊天",
                   @"红包", @"转账", @"位置", @"收藏",
                   @"个人名片", @"语音输入", @"卡券"
                   ];
    }
    
    return _words;
}

- (NSArray *)trackLabels {
    if (!_trackLabels) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        for (int i = 0; i < self.words.count; i++) {
            WFEPercentageLabel *label = [[WFEPercentageLabel alloc] initWithText:self.words[i]];
            
            [mutableArray addObject:label];
        }
        
        _trackLabels = [mutableArray copy];
    }
    
    return _trackLabels;
}

- (EHHorizontalFixedWidthItemsTrackView *)trackView {
    if (!_trackView) {
        _trackView = [[EHHorizontalFixedWidthItemsTrackView alloc] initWithItems:self.trackLabels itemSize:CGSizeMake(kLabelWidth, kLabelHeight) insets:UIEdgeInsetsMake(8, 8, 8, 8) interitemSpacing:kMinimumInteritemSpacing trackHeight:kTrackHeight];
        
        _trackView.tapDelegate = self;
        _trackView.trackWidthPercent = kTrackWidthPercent;
        _trackView.trackCornerRadius = kTrackHeight / 2.0f;
        _trackView.trackColor = [UIColor blueColor];
    }
    
    return _trackView;
}

- (EHSlideView *)slideView {
    if (!_slideView) {
        _slideView = [[EHSlideView alloc] initWithContainerController:self];
        _slideView.dataSource = self;
        _slideView.delegate = self;
    }
    
    return _slideView;
}

@end
