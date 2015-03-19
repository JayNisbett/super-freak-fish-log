//
//  CMAAdBanner.h
//  TheAnglersLog
//
//  Created by Cohen Adair on 2015-03-19.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import <iAd/iAd.h>
#import <Foundation/Foundation.h>

@interface CMAAdBanner : NSObject

@property (strong, nonatomic)ADBannerView *adBanner;
@property (strong, nonatomic)UIView *mySuperview;
@property (strong, nonatomic)NSLayoutConstraint *constraint;
@property (nonatomic)BOOL bannerIsOnBottom;
@property (nonatomic)BOOL bannerIsVisible;
@property (nonatomic)CGFloat showTime;
@property (nonatomic)CGFloat hideTime;

+ (CMAAdBanner *)withFrame:(CGRect)aFrame delegate:(id<ADBannerViewDelegate>)aDelegate superView:(UIView *)aSuperview;
- (id)initWithFrame:(CGRect)aFrame delegate:(id<ADBannerViewDelegate>)aDelegate superView:(UIView *)aSuperview;

- (void)showWithCompletion:(void (^)())completionBlock;
- (void)hideWithCompletion:(void (^)())completionBlock;

@end
