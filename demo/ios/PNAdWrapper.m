//
//  PNAdWrapper.m
//  
//
//  Created by Can Soykarafakili on 18.08.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import "PNAdWrapper.h"

@implementation PNAdWrapper

- (void)layoutDidFinishLoading:(PNLayout *)layout
{
    CoronaLuaNewEvent(self.luaState, [@"pubnativeBanner" UTF8String]);
    CoronaLuaDispatchEvent(self.luaState, self.loadListener, 0);
}

- (void)layout:(PNLayout *)layout didFailLoading:(NSError *)error
{
    CoronaLuaNewEvent(self.luaState, [@"pubnativeBanner" UTF8String]);
    CoronaLuaDispatchEvent(self.luaState, self.loadListener, 0);
}

- (void)layoutTrackImpression:(PNLayout *)layout
{
    CoronaLuaNewEvent(self.luaState, [@"pubnativeBanner" UTF8String]);
   // CoronaLuaDispatchEvent(self.luaState, self.impressionListener, 0);
}

- (void)layoutTrackClick:(PNLayout *)layout
{
    CoronaLuaNewEvent(self.luaState, [@"pubnativeBanner" UTF8String]);
   // CoronaLuaDispatchEvent(self.luaState, self.clickListener, 0);

}

@end
