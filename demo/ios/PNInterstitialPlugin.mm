//
//  PNInterstitialPlugin.mm
//  
//  Created by Can Soykarafakili on 14.11.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import "PNInterstitialPlugin.h"
#include <CoronaRuntime.h>
#import <UIKit/UIKit.h>
#import <Pubnative/Pubnative.h>
#import "PNInterstitialWrapper.h"

// ----------------------------------------------------------------------------

#pragma mark Class Declaration

class PNInterstitialPlugin
{
	public:
		typedef PNInterstitialPlugin Self;

		static const char kName[];
		static const char kEvent[];
    
        bool Initialize(CoronaLuaRef listener);
    
        CoronaLuaRef GetListener() const { return fListener; }
    
        static int Open(lua_State *L);
        static Self *ToLibrary(lua_State *L);
        static int init(lua_State *L);
        static int show(lua_State *L);

	protected:
		PNInterstitialPlugin();
        static int Finalizer(lua_State *L);

	private:
		CoronaLuaRef fListener;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
const char PNInterstitialPlugin::kName[] = "plugin.library";

// This corresponds to the event name, e.g. [Lua] event.name
const char PNInterstitialPlugin::kEvent[] = "PNInterstitialPluginevent";

#pragma mark - Initializers and Corona Methods

PNInterstitialPlugin::PNInterstitialPlugin() :	fListener(NULL)
{
    
}

bool PNInterstitialPlugin::Initialize(CoronaLuaRef listener)
{
	bool result = (NULL == fListener);
	if (result) {
		fListener = listener;
	}
	return result;
}

int PNInterstitialPlugin::Open(lua_State *L)
{
	// Register __gc callback
	const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
	CoronaLuaInitializeGCMetatable(L, kMetatableName, Finalizer);

	// Functions in library
	const luaL_Reg kVTable[] =
	{
		{ "init", init },
		{ "show", show },
		{ NULL, NULL }
	};

	// Set library as upvalue for each library function
	Self *library = new Self;
	CoronaLuaPushUserdata(L, library, kMetatableName);
	luaL_openlib(L, kName, kVTable, 1); // leave "library" on top of stack
	return 1;
}

int PNInterstitialPlugin::Finalizer(lua_State *L)
{
	Self *library = (Self *)CoronaLuaToUserdata(L, 1);
	CoronaLuaDeleteRef(L, library->GetListener());
	delete library;
	return 0;
}

PNInterstitialPlugin * PNInterstitialPlugin::ToLibrary(lua_State *L)
{
	// library is pushed as part of the closure
	Self *library = (Self *)CoronaLuaToUserdata(L, lua_upvalueindex(1));
	return library;
}

CORONA_EXPORT int luaopen_plugin_library(lua_State *L)
{
    return PNInterstitialPlugin::Open(L);
}

#pragma mark - Public Methods

// [Lua] library.init(listener)
int PNInterstitialPlugin::init(lua_State *L)
{
	int listenerIndex = 1;

	if (CoronaLuaIsListener(L, listenerIndex, kEvent)) {
		Self *library = ToLibrary(L);
		CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
		library->Initialize(listener);
	}
	return 0;
}

int PNInterstitialPlugin::show(lua_State *L)
{
	return 0;
}

#pragma mark - Private Methods


