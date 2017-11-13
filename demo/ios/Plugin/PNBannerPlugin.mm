//
//  PNBannerPlugin.mm
//
//  Created by Can Soykarafakili on 06.11.17.
//  Copyright © 2017 Can Soykarafakili. All rights reserved.
//

#import "PNBannerPlugin.h"
#include <CoronaRuntime.h>
#import <UIKit/UIKit.h>
#import <Pubnative/Pubnative.h>
#import "PNBannerWrapper.h"

// ----------------------------------------------------------------------------

PNBannerWrapper *bannerWrapper;

#pragma mark Class Declaration

class PNBannerPlugin
{
public:
    typedef PNBannerPlugin Self;
    
    static PNBannerPlugin bannerPlugin;

    static const char kName[];
    static const char kEvent[];
    static const int appTokenIndex;
    static const int placementIndex;
    static const int loadListenerIndex;
    static const int impressionListenerIndex;
    static const int clickListenerIndex;
    
    bool Initialize(CoronaLuaRef listener);
    bool InitializeLoadListener(CoronaLuaRef listener);
    bool InitializeImpressionListener(CoronaLuaRef listener);
    bool InitializeClickListener(CoronaLuaRef listener);

    CoronaLuaRef GetListener() const { return fListener; }
    CoronaLuaRef GetLoadListener() const { return loadListener; }
    CoronaLuaRef GetImpressionListener() const { return impressionListener; }
    CoronaLuaRef GetClickListener() const { return clickListener; }

    static int Open(lua_State *L);
    static Self *ToLibrary(lua_State *L);
    static int init(lua_State *L);
    static int load(lua_State *L);
    static int show(lua_State *L);
    static int setImpressionListener(lua_State *L);
    static int setClickListener(lua_State *L);
    static int hide(lua_State *L);
    
protected:
    PNBannerPlugin();
    static int Finalizer(lua_State *L);
    
private:
    CoronaLuaRef fListener;
    CoronaLuaRef loadListener;
    CoronaLuaRef impressionListener;
    CoronaLuaRef clickListener;
    
    void loadBanner(lua_State *L);
    void showBanner(lua_State *L);
    void setBannerImpressionListener(lua_State *L);
    void setBannerClickListener(lua_State *L);
    void hideBanner(lua_State *L);
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.pubnative.banner"
const char PNBannerPlugin::kName[] = "plugin.pubnative.banner";

// This corresponds to the event name, e.g. [Lua] event.name
const char PNBannerPlugin::kEvent[] = "pubnativeBanner";

const int PNBannerPlugin::appTokenIndex = 1;
const int PNBannerPlugin::placementIndex = 2;
const int PNBannerPlugin::loadListenerIndex = 3;
const int PNBannerPlugin::impressionListenerIndex = 1;
const int PNBannerPlugin::clickListenerIndex = 1;

PNBannerPlugin PNBannerPlugin::bannerPlugin;

#pragma mark - Initializers and Corona Methods

PNBannerPlugin::PNBannerPlugin() : fListener(NULL), loadListener(NULL), impressionListener(NULL), clickListener(NULL)
{
    
}

bool PNBannerPlugin::Initialize(CoronaLuaRef listener)
{
    bool result = (NULL == fListener);
    if (result) {
        fListener = listener;
    }
    return result;
}

bool PNBannerPlugin::InitializeLoadListener(CoronaLuaRef listener)
{
    bool result = (NULL == loadListener);
    if (result) {
        loadListener = listener;
    }
    return result;
}

bool PNBannerPlugin::InitializeImpressionListener(CoronaLuaRef listener)
{
    bool result = (NULL == impressionListener);
    if (result) {
        impressionListener = listener;
    }
    return result;
}

bool PNBannerPlugin::InitializeClickListener(CoronaLuaRef listener)
{
    bool result = (NULL == clickListener);
    if (result) {
        clickListener = listener;
    }
    return result;
}

int PNBannerPlugin::Open(lua_State *L)
{
    // Register __gc callback
    const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
    CoronaLuaInitializeGCMetatable(L, kMetatableName, Finalizer);
    
    // Functions in library
    const luaL_Reg kVTable[] = {
        {"init", init},
        {"load", load},
        {"show", show},
        {"setImpressionListener", setImpressionListener},
        {"setClickListener", setClickListener},
        {"hide", hide},
        {NULL, NULL}
    };
    
    // Set library as upvalue for each library function
    Self *library = new Self;
    CoronaLuaPushUserdata(L, library, kMetatableName);
    luaL_openlib(L, kName, kVTable, 1); // leave "library" on top of stack
    return 1;
}

int PNBannerPlugin::Finalizer(lua_State *L)
{
    Self *library = (Self *)CoronaLuaToUserdata(L, 1);
    CoronaLuaDeleteRef(L, library->GetListener());
    CoronaLuaDeleteRef(L, library->GetLoadListener());
    CoronaLuaDeleteRef(L, library->GetImpressionListener());
    CoronaLuaDeleteRef(L, library->GetClickListener());
    delete library;
    return 0;
}

PNBannerPlugin * PNBannerPlugin::ToLibrary(lua_State *L)
{
    // library is pushed as part of the closure
    Self *library = (Self *)CoronaLuaToUserdata(L, lua_upvalueindex(1));
    return library;
}

CORONA_EXPORT int luaopen_plugin_pubnative_banner(lua_State *L)
{
    return PNBannerPlugin::Open(L);
}

#pragma mark - Public Methods

// [Lua] library.init(listener)
int PNBannerPlugin::init(lua_State *L)
{
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, kEvent)) {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        library->Initialize(listener);
    }
    return 0;
}

int PNBannerPlugin::load(lua_State *L)
{
    bannerPlugin.loadBanner(L);
    return 0;
}

int PNBannerPlugin::show(lua_State *L)
{
    bannerPlugin.showBanner(L);
    return 0;
}

int PNBannerPlugin:: hide(lua_State *L)
{
    bannerPlugin.hideBanner(L);
    return 0;
}

int PNBannerPlugin::setImpressionListener(lua_State *L)
{
    bannerPlugin.setBannerImpressionListener(L);
    return 0;
}

int PNBannerPlugin::setClickListener(lua_State *L)
{
    bannerPlugin.setBannerClickListener(L);
    return 0;
}

#pragma mark - Private Methods

void PNBannerPlugin::loadBanner(lua_State *L)
{
    bannerWrapper = [[PNBannerWrapper alloc] init];
    
    if (CoronaLuaIsListener(L, loadListenerIndex, kEvent)) {
        Self *library = ToLibrary(L);
        loadListener = CoronaLuaNewRef(L, loadListenerIndex);
        library->InitializeLoadListener(loadListener);
        [bannerWrapper loadWithLuaState:L
                           withAppToken:[NSString stringWithUTF8String:lua_tostring(L, appTokenIndex)]
                          withPlacement:[NSString stringWithUTF8String:lua_tostring(L, placementIndex)]
                           withListener:library->GetLoadListener()];
    }
}

void PNBannerPlugin::showBanner(lua_State *L)
{
    [bannerWrapper showWithPosition:(NSInteger)lua_tointeger(L, 1)];
}

void PNBannerPlugin::setBannerImpressionListener(lua_State *L)
{
    if (CoronaLuaIsListener(L, impressionListenerIndex, kEvent)) {
        Self *library = ToLibrary(L);
        impressionListener = CoronaLuaNewRef(L, impressionListenerIndex);
        library->InitializeImpressionListener(impressionListener);
        [bannerWrapper setImpressionListener:library->GetImpressionListener()];
    }
}

void PNBannerPlugin::setBannerClickListener(lua_State *L)
{
    if (CoronaLuaIsListener(L, clickListenerIndex, kEvent)) {
        Self *library = ToLibrary(L);
        clickListener = CoronaLuaNewRef(L, clickListenerIndex);
        library->InitializeClickListener(clickListener);
        [bannerWrapper setClickListener:library->GetClickListener()];
    }
}

void PNBannerPlugin::hideBanner(lua_State *L)
{
    [bannerWrapper hide];
}
