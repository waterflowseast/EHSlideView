//
//  EHSlideView.h
//  WFEDemo
//
//  Created by Eric Huang on 17/1/16.
//  Copyright © 2017年 Eric Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef EHSlideView_H
#define EHSlideView_H

typedef NS_ENUM(NSInteger, EHSlideViewSlideDirection) {
    EHSlideViewSlideDirectionNext,
    EHSlideViewSlideDirectionPrevious
};

#endif

@class EHSlideView;

@protocol EHSlideViewDataSource <NSObject>

@required
- (NSUInteger)numberOfControllersInSlideView:(EHSlideView *)slideView;
- (UIViewController *)slideView:(EHSlideView *)slideView controllerAtIndex:(NSInteger)index;

@end

@protocol EHSlideViewDelegate <NSObject>

@optional
- (void)slideView:(EHSlideView *)slideView currentIndex:(NSInteger)currentIndex slidingToDirection:(EHSlideViewSlideDirection)direction percentage:(CGFloat)percentage;
- (void)slideView:(EHSlideView *)slideView currentIndex:(NSInteger)currentIndex willAutomaticallySlideToDirection:(EHSlideViewSlideDirection)direction;
- (void)slideView:(EHSlideView *)slideView currentIndex:(NSInteger)currentIndex willAutomaticallySlideBackFromDirection:(EHSlideViewSlideDirection)direction;
- (void)slideView:(EHSlideView *)slideView didSlideToIndex:(NSInteger)index;

@end

@interface EHSlideView : UIView

@property (nonatomic, assign) id<EHSlideViewDataSource> dataSource;
@property (nonatomic, assign) id<EHSlideViewDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger currentIndex;
@property (nonatomic, assign) NSUInteger cacheCountLimit;

- (instancetype)initWithContainerController:(UIViewController *)containerController;
- (void)showControllerAtIndex:(NSInteger)index;

@end
