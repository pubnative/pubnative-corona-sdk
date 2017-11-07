//
//  PNBannerWrapper.m
//  
//
//  Created by Can Soykarafakili on 18.08.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import "PNBannerWrapper.h"

@implementation PNBannerWrapper

- (void)dealloc
{
    self.banner = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.banner = [[PNBanner alloc] init];
        self.bannerPosition = BANNER_POSITION_BOTTOM;
    }
    return self;
}

- (void)loadWithLuaState:(lua_State *)lua_State withAppToken:(NSString *)appToken withPlacement:(NSString *)placement withListener:(CoronaLuaRef)loadListener
{
    self.luaState = lua_State;
    self.loadListener = loadListener;
    [self.banner loadWithAppToken:appToken placement:placement delegate:self];
}

- (void)show
{
    self.banner.trackDelegate = self;
    [self.banner showWithPosition:self.bannerPosition];
}

- (void)setBannerPositionToTop
{
    self.bannerPosition = BANNER_POSITION_TOP;
}

- (void)setBannerPositionToBottom
{
    self.bannerPosition = BANNER_POSITION_BOTTOM;
}

- (void)hide
{
    [self.banner hide];
}

@end
