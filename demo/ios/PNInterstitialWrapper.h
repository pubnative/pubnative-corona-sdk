//
//  PNInterstitialWrapper.h
//
//
//  Created by Can Soykarafakili on 30.08.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Pubnative/Pubnative.h>
#import "PNAdWrapper.h"

@interface PNInterstitialWrapper : PNAdWrapper <PNLayoutViewDelegate>

@property(nonatomic, strong) PNLargeLayout *interstitial;

- (void)loadWithAppToken:(NSString*)appToken withPlacement:(NSString*)placement;
- (void)show;
- (void)hide;

@end
