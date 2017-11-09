//
//  PNBannerPlugin.h
//  
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef _PNBannerPlugin_H__
#define _PNBannerPlugin_H__

#include <CoronaLua.h>
#include <CoronaMacros.h>

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
// where the '.' is replaced with '_'
CORONA_EXPORT int luaopen_plugin_pubnative_banner( lua_State *L );

#endif // _PNBannerPlugin_H__
