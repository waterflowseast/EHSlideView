//
//  EHSlideView.m
//  WFEDemo
//
//  Created by Eric Huang on 17/1/16.
//  Copyright © 2017年 Eric Huang. All rights reserved.
//

#import "EHSlideView.h"
#import <YYCache/YYMemoryCache.h>

static NSTimeInterval const kAnimationDuration = 0.35;
static CGFloat const kVelocityThreshold = 100.0f;
static NSUInteger const kCacheCountLimit = 5;

@interface EHSlideView ()

@property (nonatomic, assign, readwrite) NSInteger currentIndex;
@property (nonatomic, weak) UIViewController *containerController;

@property (nonatomic, strong) UIView *wrapperView0;
@property (nonatomic, strong) UIView *wrapperView1;
@property (nonatomic, strong) UIViewController *wrapperController0;
@property (nonatomic, strong) UIViewController *wrapperController1;

@property (nonatomic, assign, getter=isWrapperView0Active) BOOL wrapperView0Active;
@property (nonatomic, strong, readonly) UIView *activeWrapperView;
@property (nonatomic, strong, readonly) UIView *inactiveWrapperView;
@property (nonatomic, strong) UIViewController *activeController;
@property (nonatomic, strong) UIViewController *inactiveController;

@property (nonatomic, strong) YYMemoryCache *memoryCache;
@property (nonatomic, assign) NSInteger panningDirectionState;

@end

@implementation EHSlideView

@synthesize activeController = _activeController;
@synthesize inactiveController = _inactiveController;

- (void)commonInit {
    _currentIndex = -1;
    _cacheCountLimit = kCacheCountLimit;
    _wrapperView0Active = YES;
    _panningDirectionState = -1;
}

- (instancetype)initWithContainerController:(UIViewController *)containerController {
    self = [super init];
    if (self) {
        [self commonInit];
        _containerController = containerController;
        
        [self addWrapperViews];
        [self addPanGestureRecognizer];
    }
    
    return self;
}

- (void)showControllerAtIndex:(NSInteger)index {
    if (index < 0 || index >= [self.dataSource numberOfControllersInSlideView:self]) {
        return;
    }
    
    if (index == self.currentIndex) {
        return;
    }
    
    if (self.currentIndex == -1) {
        [self replaceWithControllerAtIndex:index];
    } else if (labs(index - self.currentIndex) == 1) {
        EHSlideViewSlideDirection direction = index > self.currentIndex ? EHSlideViewSlideDirectionNext : EHSlideViewSlideDirectionPrevious;
        [self slideToControllerAtDirection:direction];
    } else {
        [self replaceWithControllerAtIndex:index];
    }
}

#pragma mark - event response

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    CGFloat frameWidth = CGRectGetWidth(self.frame);
    CGFloat offsetX = [sender translationInView:sender.view].x;
    CGFloat ratio = fabs(offsetX) / frameWidth;
    EHSlideViewSlideDirection direction = offsetX > 0 ? EHSlideViewSlideDirectionPrevious : EHSlideViewSlideDirectionNext;

    if ( (self.currentIndex == 0 && direction == EHSlideViewSlideDirectionPrevious) || (self.currentIndex == [self.dataSource numberOfControllersInSlideView:self] - 1 && direction == EHSlideViewSlideDirectionNext) ) {
        
        ratio = ratio * 0.5f;
    }

    if (sender.state == UIGestureRecognizerStateBegan) {
        self.panningDirectionState = -1;
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        if (self.panningDirectionState != direction) {
            self.panningDirectionState = direction;
            
            UIViewController *controller;
            if (direction == EHSlideViewSlideDirectionNext) {
                if (self.currentIndex != [self.dataSource numberOfControllersInSlideView:self] - 1) {
                    controller = [self controllerAtIndex:(self.currentIndex + 1)];
                }
            } else {
                if (self.currentIndex != 0) {
                    controller = [self controllerAtIndex:(self.currentIndex - 1)];
                }
            }
            
            if (self.inactiveController != controller) {
                [self removeViewController:self.inactiveController];
                [self addViewController:controller toView:self.inactiveWrapperView];
                self.inactiveController = controller;
            }
        }

        if (direction == EHSlideViewSlideDirectionNext) {
            self.activeWrapperView.transform = CGAffineTransformMakeTranslation(- frameWidth * ratio, 0);
            self.inactiveWrapperView.transform = CGAffineTransformMakeTranslation(frameWidth * (1 - ratio), 0);
        } else {
            self.activeWrapperView.transform = CGAffineTransformMakeTranslation(frameWidth * ratio, 0);
            self.inactiveWrapperView.transform = CGAffineTransformMakeTranslation(-frameWidth * (1 - ratio), 0);
        }
        
        if ([self.delegate respondsToSelector:@selector(slideView:currentIndex:slidingToDirection:percentage:)]) {
            [self.delegate slideView:self currentIndex:self.currentIndex slidingToDirection:direction percentage:ratio];
        }

        return;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ( (self.currentIndex == 0 && direction == EHSlideViewSlideDirectionPrevious) || (self.currentIndex == [self.dataSource numberOfControllersInSlideView:self] - 1 && direction == EHSlideViewSlideDirectionNext) ) {
            
            [self slideBackFromDirection:direction];
            return;
        }

        CGFloat velocityX = [sender velocityInView:sender.view].x;
        
        if (direction == EHSlideViewSlideDirectionNext) {
            if (velocityX > kVelocityThreshold) {
                [self slideBackFromDirection:direction];
                return;
            } else if (velocityX < -kVelocityThreshold) {
                [self slideToControllerAtDirectionWithAnimation:direction];
                return;
            }
        } else {
            if (velocityX > kVelocityThreshold) {
                [self slideToControllerAtDirectionWithAnimation:direction];
                return;
            } else if (velocityX < -kVelocityThreshold) {
                [self slideBackFromDirection:direction];
                return;
            }
        }
        
        if (ratio > 0.5) {
            [self slideToControllerAtDirectionWithAnimation:direction];
        } else {
            [self slideBackFromDirection:direction];
        }
    }
}

#pragma mark - private methods

- (void)addWrapperViews {
    UIView *inactiveView = self.inactiveWrapperView;
    inactiveView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:inactiveView];
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:inactiveView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                           [NSLayoutConstraint constraintWithItem:inactiveView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
                           [NSLayoutConstraint constraintWithItem:inactiveView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
                           [NSLayoutConstraint constraintWithItem:inactiveView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]
                           ]];
    
    UIView *activeView = self.activeWrapperView;
    activeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:activeView];
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:activeView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                           [NSLayoutConstraint constraintWithItem:activeView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
                           [NSLayoutConstraint constraintWithItem:activeView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
                           [NSLayoutConstraint constraintWithItem:activeView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]
                           ]];
}

- (void)addPanGestureRecognizer {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [self addGestureRecognizer:pan];
}

- (void)slideToControllerAtDirection:(EHSlideViewSlideDirection)direction {
    UIViewController *controller;
    CGFloat inactiveWrapperViewBeganTranslationX = 0;
    
    if (direction == EHSlideViewSlideDirectionNext) {
        controller = [self controllerAtIndex:(self.currentIndex + 1)];
        inactiveWrapperViewBeganTranslationX = CGRectGetWidth(self.frame);
    } else {
        controller = [self controllerAtIndex:(self.currentIndex - 1)];
        inactiveWrapperViewBeganTranslationX = - CGRectGetWidth(self.frame);
    }
    
    if (self.inactiveController != controller) {
        [self removeViewController:self.inactiveController];
        [self addViewController:controller toView:self.inactiveWrapperView];
        self.inactiveController = controller;
    }
    
    self.activeWrapperView.transform = CGAffineTransformMakeTranslation(0, 0);
    self.inactiveWrapperView.transform = CGAffineTransformMakeTranslation(inactiveWrapperViewBeganTranslationX, 0);
    
    [self slideToControllerAtDirectionWithAnimation:direction];
}

- (void)slideToControllerAtDirectionWithAnimation:(EHSlideViewSlideDirection)direction {
    if (self.panningDirectionState != -1) {
        if ([self.delegate respondsToSelector:@selector(slideView:currentIndex:willAutomaticallySlideToDirection:)]) {
            [self.delegate slideView:self currentIndex:self.currentIndex willAutomaticallySlideToDirection:direction];
        }
    }

    NSInteger index = 0;
    CGFloat activeWrapperViewEndedTranslationX = 0;
    
    if (direction == EHSlideViewSlideDirectionNext) {
        index = self.currentIndex + 1;
        activeWrapperViewEndedTranslationX = - CGRectGetWidth(self.frame);
    } else {
        index = self.currentIndex - 1;
        activeWrapperViewEndedTranslationX = CGRectGetWidth(self.frame);
    }

    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.activeWrapperView.transform = CGAffineTransformMakeTranslation(activeWrapperViewEndedTranslationX, 0);
        self.inactiveWrapperView.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        self.wrapperView0Active = !self.isWrapperView0Active;
        self.currentIndex = index;
        
        [self bringSubviewToFront:self.activeWrapperView];
        self.activeWrapperView.transform = CGAffineTransformIdentity;
        self.inactiveWrapperView.transform = CGAffineTransformIdentity;
        
        if (self.panningDirectionState != -1) {
            self.panningDirectionState = -1;
            
            if ([self.delegate respondsToSelector:@selector(slideView:didSlideToIndex:)]) {
                [self.delegate slideView:self didSlideToIndex:index];
            }
        }
    }];
}

- (void)replaceWithControllerAtIndex:(NSInteger)index {
    UIViewController *controller = [self controllerAtIndex:index];
    
    [self.containerController addChildViewController:controller];
    controller.view.alpha = 0;
    controller.view.frame = self.activeWrapperView.bounds;
    [self.activeWrapperView addSubview:controller.view];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        controller.view.alpha = 1;
    } completion:^(BOOL finished) {
        [controller didMoveToParentViewController:self.containerController];
        
        [self removeViewController:self.activeController];
        self.activeController = controller;
        self.currentIndex = index;
    }];
}

- (void)slideBackFromDirection:(EHSlideViewSlideDirection)direction {
    if (self.panningDirectionState != -1) {
        if ([self.delegate respondsToSelector:@selector(slideView:currentIndex:willAutomaticallySlideBackFromDirection:)]) {
            [self.delegate slideView:self currentIndex:self.currentIndex willAutomaticallySlideBackFromDirection:direction];
        }
    }

    CGFloat inactiveWrapperViewEndedTranslationX = 0;
    
    if (direction == EHSlideViewSlideDirectionNext) {
        inactiveWrapperViewEndedTranslationX = CGRectGetWidth(self.frame);
    } else {
        inactiveWrapperViewEndedTranslationX = - CGRectGetWidth(self.frame);
    }

    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.activeWrapperView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.inactiveWrapperView.transform = CGAffineTransformMakeTranslation(inactiveWrapperViewEndedTranslationX, 0);
    } completion:^(BOOL finished) {
        [self bringSubviewToFront:self.activeWrapperView];
        self.activeWrapperView.transform = CGAffineTransformIdentity;
        self.inactiveWrapperView.transform = CGAffineTransformIdentity;

        if (self.panningDirectionState != -1) {
            self.panningDirectionState = -1;
            
            if ([self.delegate respondsToSelector:@selector(slideView:didSlideToIndex:)]) {
                [self.delegate slideView:self didSlideToIndex:self.currentIndex];
            }
        }
    }];
}
     
- (void)addViewController:(UIViewController *)controller toView:(UIView *)view {
    if (!controller) {
        return;
    }

    [self.containerController addChildViewController:controller];
    controller.view.frame = view.bounds;
    [view addSubview:controller.view];
    [controller didMoveToParentViewController:self.containerController];
}

- (void)removeViewController:(UIViewController *)controller {
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}

- (UIViewController *)controllerAtIndex:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
    UIViewController *controller = [self.memoryCache objectForKey:key];
    
    if (!controller) {
        controller = [self.dataSource slideView:self controllerAtIndex:index];
        [self.memoryCache setObject:controller forKey:key];
    }

    return controller;
}

#pragma mark - getters & setters

- (UIView *)wrapperView0 {
    if (!_wrapperView0) {
        _wrapperView0 = [[UIView alloc] init];
        _wrapperView0.backgroundColor = [UIColor whiteColor];
    }
    
    return _wrapperView0;
}

- (UIView *)wrapperView1 {
    if (!_wrapperView1) {
        _wrapperView1 = [[UIView alloc] init];
        _wrapperView1.backgroundColor = [UIColor whiteColor];
    }
    
    return _wrapperView1;
}

- (UIView *)activeWrapperView {
    return self.isWrapperView0Active ? self.wrapperView0 : self.wrapperView1;
}

- (UIView *)inactiveWrapperView {
    return self.isWrapperView0Active ? self.wrapperView1 : self.wrapperView0;
}

- (UIViewController *)activeController {
    return self.isWrapperView0Active ? self.wrapperController0 : self.wrapperController1;
}

- (void)setActiveController:(UIViewController *)activeController {
    if (_wrapperView0Active) {
        _wrapperController0 = activeController;
    } else {
        _wrapperController1 = activeController;
    }
}

- (UIViewController *)inactiveController {
    return self.isWrapperView0Active ? self.wrapperController1 : self.wrapperController0;
}

- (void)setInactiveController:(UIViewController *)inactiveController {
    if (_wrapperView0Active) {
        _wrapperController1 = inactiveController;
    } else {
        _wrapperController0 = inactiveController;
    }
}

- (YYMemoryCache *)memoryCache {
    if (!_memoryCache) {
        _memoryCache = [[YYMemoryCache alloc] init];
        _memoryCache.countLimit = _cacheCountLimit;
    }
    
    return _memoryCache;
}

- (void)setCacheCountLimit:(NSUInteger)cacheCountLimit {
    _cacheCountLimit = cacheCountLimit;
    self.memoryCache.countLimit = _cacheCountLimit;
}

@end
