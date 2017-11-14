//
//  PNBannerWrapper.m
//  
//
//  Created by Can Soykarafakili on 18.08.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import "PNBannerWrapper.h"

NSString * const kCoronaBannerEventName = @"pubnativeBanner";
NSString * const kCoronaBannerResponseKey = @"response";
NSString * const kCoronaBannerErrorKey = @"isError";

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
    }
    return self;
}

- (void)loadWithLuaState:(lua_State *)lua_State withAppToken:(NSString *)appToken withPlacement:(NSString *)placement withListener:(CoronaLuaRef)loadListener
{
    self.luaState = lua_State;
    self.loadListener = loadListener;
    [self.banner loadWithAppToken:appToken placement:placement delegate:self];
}

- (void)showWithPosition:(NSInteger)position
{
    self.banner.trackDelegate = self;
    if (position == [self topPosition]) {
        [self.banner showWithPosition:BANNER_POSITION_TOP];
    } else if (position == [self bottomPosition]) {
        [self.banner showWithPosition:BANNER_POSITION_BOTTOM];
    }
}

- (NSInteger)topPosition
{
    return 1;
}

- (NSInteger)bottomPosition
{
    return 2;
}

- (void)hide
{
    [self.banner hide];
}

#pragma mark - PNLayoutLoadDelegate Methods

- (void)layoutDidFinishLoading:(PNLayout *)layout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CoronaLuaNewEvent(self.luaState, [kCoronaBannerEventName UTF8String]);
        CoronaLuaDispatchEvent(self.luaState, self.loadListener, 0);
    });
}

- (void)layout:(PNLayout *)layout didFailLoading:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        lua_State *error_luaState = self.luaState;
        CoronaLuaNewEvent(error_luaState, [kCoronaBannerEventName UTF8String]);
        lua_pushstring(error_luaState, [error.localizedDescription UTF8String]);
        lua_setfield(error_luaState, -2, [kCoronaBannerResponseKey UTF8String]);
        lua_pushboolean(error_luaState, 1);
        lua_setfield(error_luaState, -2, [kCoronaBannerErrorKey UTF8String]);
        CoronaLuaDispatchEvent(error_luaState, self.loadListener, 0);
    });
    
}

#pragma mark - PNLayoutTrackDelegate Methods

- (void)layoutTrackImpression:(PNLayout *)layout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CoronaLuaNewEvent(self.luaState, [kCoronaBannerEventName UTF8String]);
        CoronaLuaDispatchEvent(self.luaState, self.impressionListener, 0);
    });
}

- (void)layoutTrackClick:(PNLayout *)layout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CoronaLuaNewEvent(self.luaState, [kCoronaBannerEventName UTF8String]);
        CoronaLuaDispatchEvent(self.luaState, self.clickListener, 0);
    });
}

@end
