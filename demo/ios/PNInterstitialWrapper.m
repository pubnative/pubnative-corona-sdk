//
//  PNInterstitialWrapper.m
// 
//
//  Created by Can Soykarafakili on 30.08.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import "PNInterstitialWrapper.h"

NSString * const kCoronaInterstitialEventName = @"pubnativeInterstitial";
NSString * const kCoronaInterstitialResponseKey = @"response";
NSString * const kCoronaInterstitialErrorKey = @"isError";

@implementation PNInterstitialWrapper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.interstitial = [[PNLargeLayout alloc] init];
    }
    return self;
}
- (void)loadWithLuaState:(lua_State *)lua_State withAppToken:(NSString *)appToken withPlacement:(NSString *)placement withListener:(CoronaLuaRef)loadListener
{
    self.luaState = lua_State;
    self.loadListener = loadListener;
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

#pragma mark - PNLayoutLoadDelegate Methods

- (void)layoutDidFinishLoading:(PNLayout *)layout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CoronaLuaNewEvent(self.luaState, [kCoronaInterstitialEventName UTF8String]);
        CoronaLuaDispatchEvent(self.luaState, self.loadListener, 0);
    });
}

- (void)layout:(PNLayout *)layout didFailLoading:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        lua_State *error_luaState = self.luaState;
        CoronaLuaNewEvent(error_luaState, [kCoronaInterstitialEventName UTF8String]);
        lua_pushstring(error_luaState, [error.localizedDescription UTF8String]);
        lua_setfield(error_luaState, -2, [kCoronaInterstitialResponseKey UTF8String]);
        lua_pushboolean(error_luaState, 1);
        lua_setfield(error_luaState, -2, [kCoronaInterstitialErrorKey UTF8String]);
        CoronaLuaDispatchEvent(error_luaState, self.loadListener, 0);
    });
}

#pragma mark - PNLayoutTrackDelegate Methods

- (void)layoutTrackImpression:(PNLayout *)layout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CoronaLuaNewEvent(self.luaState, [kCoronaInterstitialEventName UTF8String]);
        CoronaLuaDispatchEvent(self.luaState, self.impressionListener, 0);
    });
}

- (void)layoutTrackClick:(PNLayout *)layout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CoronaLuaNewEvent(self.luaState, [kCoronaInterstitialEventName UTF8String]);
        CoronaLuaDispatchEvent(self.luaState, self.clickListener, 0);
    });
}

#pragma mark - PNLayoutViewDelegate Methods

- (void)layoutDidShow:(PNLayout *)layout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CoronaLuaNewEvent(self.luaState, [kCoronaInterstitialEventName UTF8String]);
        CoronaLuaDispatchEvent(self.luaState, self.showListener, 0);
    });
}

- (void)layoutDidHide:(PNLayout *)layout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CoronaLuaNewEvent(self.luaState, [kCoronaInterstitialEventName UTF8String]);
        CoronaLuaDispatchEvent(self.luaState, self.hideListener, 0);
    });
}

@end
