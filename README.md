# EHSlideView

[![CI Status](http://img.shields.io/travis/Eric Huang/EHSlideView.svg?style=flat)](https://travis-ci.org/Eric Huang/EHSlideView)
[![Version](https://img.shields.io/cocoapods/v/EHSlideView.svg?style=flat)](http://cocoapods.org/pods/EHSlideView)
[![License](https://img.shields.io/cocoapods/l/EHSlideView.svg?style=flat)](http://cocoapods.org/pods/EHSlideView)
[![Platform](https://img.shields.io/cocoapods/p/EHSlideView.svg?style=flat)](http://cocoapods.org/pods/EHSlideView)

## Summary

a view you can slide between controllers' view.

dataSource:

```ObjectiveC
- (NSUInteger)numberOfControllersInSlideView:(EHSlideView *)slideView;
- (UIViewController *)slideView:(EHSlideView *)slideView controllerAtIndex:(NSInteger)index;
```

delegate:

```ObjectiveC
- (void)slideView:(EHSlideView *)slideView currentIndex:(NSInteger)currentIndex slidingToDirection:(EHSlideViewSlideDirection)direction percentage:(CGFloat)percentage;
- (void)slideView:(EHSlideView *)slideView currentIndex:(NSInteger)currentIndex willAutomaticallySlideToDirection:(EHSlideViewSlideDirection)direction;
- (void)slideView:(EHSlideView *)slideView currentIndex:(NSInteger)currentIndex willAutomaticallySlideBackFromDirection:(EHSlideViewSlideDirection)direction;
- (void)slideView:(EHSlideView *)slideView didSlideToIndex:(NSInteger)index;
```

## Screenshots

![](https://github.com/waterflowseast/EHSlideView/raw/master/screenshots/1.png)
![](https://github.com/waterflowseast/EHSlideView/raw/master/screenshots/2.png)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 7.0+

## Installation

EHSlideView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "EHSlideView"
```

## Author

Eric Huang, WaterFlowsEast@gmail.com

## License

EHSlideView is available under the MIT license. See the LICENSE file for more info.
