//
//  PNAdWrapper.h
//  
//
//  Created by Can Soykarafakili on 18.08.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Pubnative/Pubnative.h>
#import <CoronaLua.h>

@interface PNAdWrapper : NSObject <PNLayoutLoadDelegate, PNLayoutTrackDelegate>

@property (nonatomic, assign) lua_State *luaState;
@property (nonatomic, assign) CoronaLuaRef loadListener;
@property (nonatomic, assign) CoronaLuaRef impressionListener;
@property (nonatomic, assign) CoronaLuaRef clickListener;


@end
