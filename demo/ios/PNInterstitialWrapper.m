//
//  PNInterstitialWrapper.m
// 
//
//  Created by Can Soykarafakili on 30.08.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import "PNInterstitialWrapper.h"

@implementation PNInterstitialWrapper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.interstitial = [[PNLargeLayout alloc] init];
    }
    return self;
}

- (void)loadWithAppToken:(NSString *)appToken withPlacement:(NSString *)placement
{
    [self.interstitial loadWithAppToken:appToken placement:placement delegate:self];
}

- (void)show
{
    self.interstitial.viewDelegate = self;
    self.interstitial.trackDelegate = self;
    [self.interstitial show];
}

- (void)hide
{
    [self.interstitial hide];
}

- (void)layoutDidShow:(PNLayout *)layout
{

}

- (void)layoutDidHide:(PNLayout *)layout
{

}

@end
