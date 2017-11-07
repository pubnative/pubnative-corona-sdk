//
//  PNBannerWrapper.h
//  
//
//  Created by Can Soykarafakili on 18.08.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNAdWrapper.h"

@interface PNBannerWrapper : PNAdWrapper

@property(nonatomic, strong) PNBanner *banner;
@property(nonatomic, assign) PNBannerPosition bannerPosition;

- (void)loadWithLuaState:(lua_State *)lua_State withAppToken:(NSString*)appToken withPlacement:(NSString*)placement withListener:(CoronaLuaRef)loadListener;
- (void)show;
- (void)hide;
- (void)setBannerPositionToTop;
- (void)setBannerPositionToBottom;

@end
