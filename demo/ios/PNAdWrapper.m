//
//  PNAdWrapper.m
//  
//
//  Created by Can Soykarafakili on 18.08.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import "PNAdWrapper.h"

NSString * const kCoronaEventName = @"pubnativeBanner";

@implementation PNAdWrapper

- (void)layoutDidFinishLoading:(PNLayout *)layout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CoronaLuaNewEvent(self.luaState, [kCoronaEventName UTF8String]);
        CoronaLuaDispatchEvent(self.luaState, self.loadListener, 0);
    });
}

- (void)layout:(PNLayout *)layout didFailLoading:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CoronaLuaNewEvent(self.luaState, [kCoronaEventName UTF8String]);
        CoronaLuaDispatchEvent(self.luaState, self.loadListener, 0);
    });}

- (void)layoutTrackImpression:(PNLayout *)layout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CoronaLuaNewEvent(self.luaState, [kCoronaEventName UTF8String]);
        CoronaLuaDispatchEvent(self.luaState, self.impressionListener, 0);
    });
}

- (void)layoutTrackClick:(PNLayout *)layout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CoronaLuaNewEvent(self.luaState, [kCoronaEventName UTF8String]);
        CoronaLuaDispatchEvent(self.luaState, self.clickListener, 0);
    });

}

@end
