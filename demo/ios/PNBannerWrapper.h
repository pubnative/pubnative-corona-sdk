//
//  PNBannerWrapper.h
//  
//
//  Created by Can Soykarafakili on 18.08.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Pubnative/Pubnative.h>
#import <CoronaLua.h>

@interface PNBannerWrapper : NSObject <PNLayoutLoadDelegate, PNLayoutTrackDelegate>

@property(nonatomic, strong) PNBanner *banner;
@property (nonatomic, assign) lua_State *luaState;
@property (nonatomic, assign) CoronaLuaRef loadListener;
@property (nonatomic, assign) CoronaLuaRef impressionListener;
@property (nonatomic, assign) CoronaLuaRef clickListener;

- (void)loadWithLuaState:(lua_State *)lua_State
            withAppToken:(NSString*)appToken
           withPlacement:(NSString*)placement
            withListener:(CoronaLuaRef)loadListener;
- (void)showWithPosition:(NSInteger)position;
- (void)hide;
- (NSInteger)topPosition;
- (NSInteger)bottomPosition;

@end
