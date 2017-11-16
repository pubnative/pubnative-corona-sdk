//
//  PNInterstitialPlugin.h
//
//  Created by Can Soykarafakili on 14.11.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#ifndef _PNInterstitialPlugin_H__
#define _PNInterstitialPlugin_H__

#include <CoronaLua.h>
#include <CoronaMacros.h>

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
// where the '.' is replaced with '_'
CORONA_EXPORT int luaopen_plugin_pubnative_interstitial(lua_State *L);

#endif // _PNInterstitialPlugin_H__
