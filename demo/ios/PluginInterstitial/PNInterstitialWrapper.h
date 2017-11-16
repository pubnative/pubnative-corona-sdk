//
//  PNInterstitialWrapper.h
//
//
//  Created by Can Soykarafakili on 30.08.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Pubnative/Pubnative.h>
#import <CoronaLua.h>

@interface PNInterstitialWrapper : NSObject <PNLayoutLoadDelegate, PNLayoutTrackDelegate, PNLayoutViewDelegate>

@property(nonatomic, strong) PNLargeLayout *interstitial;
@property (nonatomic, assign) lua_State *luaState;
@property (nonatomic, assign) CoronaLuaRef loadListener;
@property (nonatomic, assign) CoronaLuaRef impressionListener;
@property (nonatomic, assign) CoronaLuaRef clickListener;
@property (nonatomic, assign) CoronaLuaRef showListener;
@property (nonatomic, assign) CoronaLuaRef hideListener;

- (void)loadWithLuaState:(lua_State *)lua_State
            withAppToken:(NSString*)appToken
           withPlacement:(NSString*)placement
            withListener:(CoronaLuaRef)loadListener;
- (void)show;
- (void)hide;

@end
