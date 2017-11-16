//
//  PNInterstitialPlugin.mm
//  
//  Created by Can Soykarafakili on 14.11.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#include <CoronaRuntime.h>
#import <UIKit/UIKit.h>
#import <Pubnative/Pubnative.h>
#import "PNInterstitialWrapper.h"
#import "PNInterstitialPlugin.h"

// ----------------------------------------------------------------------------

PNInterstitialWrapper *interstitalWrapper;

#pragma mark Class Declaration

class PNInterstitialPlugin
{
	public:
		typedef PNInterstitialPlugin Self;
    
        static PNInterstitialPlugin interstitalPlugin;

		static const char kName[];
		static const char kEvent[];
        static const int appTokenIndex;
        static const int placementIndex;
        static const int loadListenerIndex;
        static const int impressionListenerIndex;
        static const int clickListenerIndex;
        static const int showListenerIndex;
        static const int hideListenerIndex;

        bool Initialize(CoronaLuaRef listener);
        bool InitializeLoadListener(CoronaLuaRef listener);
        bool InitializeImpressionListener(CoronaLuaRef listener);
        bool InitializeClickListener(CoronaLuaRef listener);
        bool InitializeShowListener(CoronaLuaRef listener);
        bool InitializeHideListener(CoronaLuaRef listener);

        CoronaLuaRef GetListener() const { return fListener; }
        CoronaLuaRef GetLoadListener() const { return loadListener; }
        CoronaLuaRef GetImpressionListener() const { return impressionListener; }
        CoronaLuaRef GetClickListener() const { return clickListener; }
        CoronaLuaRef GetShowListener() const { return showListener; }
        CoronaLuaRef GetHideListener() const { return hideListener; }
    
        static int Open(lua_State *L);
        static Self *ToLibrary(lua_State *L);
        static int init(lua_State *L);
        static int load(lua_State *L);
        static int show(lua_State *L);
        static int setImpressionListener(lua_State *L);
        static int setClickListener(lua_State *L);
        static int setShowListener(lua_State *L);
        static int setHideListener(lua_State *L);
        static int hide(lua_State *L);

	protected:
		PNInterstitialPlugin();
        static int Finalizer(lua_State *L);

	private:
		CoronaLuaRef fListener;
        CoronaLuaRef loadListener;
        CoronaLuaRef impressionListener;
        CoronaLuaRef clickListener;
        CoronaLuaRef showListener;
        CoronaLuaRef hideListener;
    
        void loadInterstitial(lua_State *L);
        void showInterstitial(lua_State *L);
        void setInterstitialImpressionListener(lua_State *L);
        void setInterstitialClickListener(lua_State *L);
        void setInterstitialShowListener(lua_State *L);
        void setInterstitialHideListener(lua_State *L);
        void hideInterstitial(lua_State *L);

};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.pubnative.interstitial"
const char PNInterstitialPlugin::kName[] = "plugin.pubnative.interstitial";

// This corresponds to the event name, e.g. [Lua] event.name
const char PNInterstitialPlugin::kEvent[] = "pubnativeInterstitial";

const int PNInterstitialPlugin::appTokenIndex = 1;
const int PNInterstitialPlugin::placementIndex = 2;
const int PNInterstitialPlugin::loadListenerIndex = 3;
const int PNInterstitialPlugin::impressionListenerIndex = 1;
const int PNInterstitialPlugin::clickListenerIndex = 1;
const int PNInterstitialPlugin::showListenerIndex = 1;
const int PNInterstitialPlugin::hideListenerIndex = 1;

PNInterstitialPlugin PNInterstitialPlugin::interstitalPlugin;

#pragma mark - Initializers and Corona Methods

PNInterstitialPlugin::PNInterstitialPlugin() :	fListener(NULL), loadListener(NULL), impressionListener(NULL), clickListener(NULL), showListener(NULL), hideListener(NULL)
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

bool PNInterstitialPlugin::InitializeLoadListener(CoronaLuaRef listener)
{
    bool result = (NULL == loadListener);
    if (result) {
        loadListener = listener;
    }
    return result;
}

bool PNInterstitialPlugin::InitializeImpressionListener(CoronaLuaRef listener)
{
    bool result = (NULL == impressionListener);
    if (result) {
        impressionListener = listener;
    }
    return result;
}

bool PNInterstitialPlugin::InitializeClickListener(CoronaLuaRef listener)
{
    bool result = (NULL == clickListener);
    if (result) {
        clickListener = listener;
    }
    return result;
}

bool PNInterstitialPlugin::InitializeShowListener(CoronaLuaRef listener)
{
    bool result = (NULL == showListener);
    if (result) {
        showListener = listener;
    }
    return result;
}

bool PNInterstitialPlugin::InitializeHideListener(CoronaLuaRef listener)
{
    bool result = (NULL == hideListener);
    if (result) {
        hideListener = listener;
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
        {"init", init},
        {"load", load},
        {"show", show},
        {"setImpressionListener", setImpressionListener},
        {"setClickListener", setClickListener},
        {"setShowListener",setShowListener},
        {"setHideListener",setHideListener},
        {"hide", hide},
		{NULL, NULL}
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
    CoronaLuaDeleteRef(L, library->GetLoadListener());
    CoronaLuaDeleteRef(L, library->GetImpressionListener());
    CoronaLuaDeleteRef(L, library->GetClickListener());
    CoronaLuaDeleteRef(L, library->GetShowListener());
    CoronaLuaDeleteRef(L, library->GetHideListener());
    delete library;
	return 0;
}

PNInterstitialPlugin * PNInterstitialPlugin::ToLibrary(lua_State *L)
{
	// library is pushed as part of the closure
	Self *library = (Self *)CoronaLuaToUserdata(L, lua_upvalueindex(1));
	return library;
}

CORONA_EXPORT int luaopen_plugin_pubnative_interstitial(lua_State *L)
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

int PNInterstitialPlugin::load(lua_State *L)
{
    interstitalPlugin.loadInterstitial(L);
    return 0;
}

int PNInterstitialPlugin::show(lua_State *L)
{
    interstitalPlugin.showInterstitial(L);
	return 0;
}

int PNInterstitialPlugin::hide(lua_State *L)
{
    interstitalPlugin.hideInterstitial(L);
    return 0;
}

int PNInterstitialPlugin::setImpressionListener(lua_State *L)
{
    interstitalPlugin.setInterstitialImpressionListener(L);
    return 0;
}

int PNInterstitialPlugin::setClickListener(lua_State *L)
{
    interstitalPlugin.setInterstitialClickListener(L);
    return 0;
}

int PNInterstitialPlugin::setShowListener(lua_State *L)
{
    interstitalPlugin.setInterstitialShowListener(L);
    return 0;
}

int PNInterstitialPlugin::setHideListener(lua_State *L)
{
    interstitalPlugin.setInterstitialHideListener(L);
    return 0;
}

#pragma mark - Private Methods

void PNInterstitialPlugin::loadInterstitial(lua_State *L)
{
    interstitalWrapper = [[PNInterstitialWrapper alloc] init];
    
    if (CoronaLuaIsListener(L, loadListenerIndex, kEvent)) {
        Self *library = ToLibrary(L);
        loadListener = CoronaLuaNewRef(L, loadListenerIndex);
        library->InitializeLoadListener(loadListener);
        [interstitalWrapper loadWithLuaState:L
                                withAppToken:[NSString stringWithUTF8String:lua_tostring(L, appTokenIndex)]
                               withPlacement:[NSString stringWithUTF8String:lua_tostring(L, placementIndex)]
                                withListener:library->GetLoadListener()];
    }
    
}

void PNInterstitialPlugin::showInterstitial(lua_State *L)
{
    [interstitalWrapper show];
}

void PNInterstitialPlugin::setInterstitialImpressionListener(lua_State *L)
{
    if (CoronaLuaIsListener(L, impressionListenerIndex, kEvent)) {
        Self *library = ToLibrary(L);
        impressionListener = CoronaLuaNewRef(L, impressionListenerIndex);
        library->InitializeImpressionListener(impressionListener);
        [interstitalWrapper setImpressionListener:library->GetImpressionListener()];
    }
}

void PNInterstitialPlugin::setInterstitialClickListener(lua_State *L)
{
    if (CoronaLuaIsListener(L, clickListenerIndex, kEvent)) {
        Self *library = ToLibrary(L);
        clickListener = CoronaLuaNewRef(L, clickListenerIndex);
        library->InitializeClickListener(clickListener);
        [interstitalWrapper setClickListener:library->GetClickListener()];
    }
}

void PNInterstitialPlugin::setInterstitialShowListener(lua_State *L)
{
    if (CoronaLuaIsListener(L, showListenerIndex, kEvent)) {
        Self *library = ToLibrary(L);
        showListener = CoronaLuaNewRef(L, showListenerIndex);
        library->InitializeShowListener(showListener);
        [interstitalWrapper setShowListener:library->GetShowListener()];
    }
}

void PNInterstitialPlugin::setInterstitialHideListener(lua_State *L)
{
    if (CoronaLuaIsListener(L, hideListenerIndex, kEvent)) {
        Self *library = ToLibrary(L);
        hideListener = CoronaLuaNewRef(L, hideListenerIndex);
        library->InitializeHideListener(hideListener);
        [interstitalWrapper setHideListener:library->GetHideListener()];
    }
}

void PNInterstitialPlugin::hideInterstitial(lua_State *L)
{
    [interstitalWrapper hide];
}
