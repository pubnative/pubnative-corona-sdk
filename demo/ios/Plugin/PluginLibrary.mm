//
//  PluginLibrary.mm
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PluginLibrary.h"

#include <CoronaRuntime.h>
#import <UIKit/UIKit.h>

#import <Pubnative/Pubnative.h>
#import "PNBannerWrapper.h"

// ----------------------------------------------------------------------------

PNBannerWrapper *bannerWrapper;

class PluginLibrary
{
public:
    typedef PluginLibrary Self;

    static const char kName[];
    static const char kEvent[];
    
    bool Initialize( CoronaLuaRef listener );
    bool InitializeLoadListener( CoronaLuaRef listener );
    bool InitializeImpressionListener( CoronaLuaRef listener );
    bool InitializeClickListener( CoronaLuaRef listener );

    CoronaLuaRef GetListener() const { return fListener; }
    CoronaLuaRef GetLoadListener() const { return loadListener; }
    CoronaLuaRef GetImpressionListener() const { return impressionListener; }
    CoronaLuaRef GetClickListener() const { return clickListener; }

    static int Open( lua_State *L );
    static Self *ToLibrary( lua_State *L );
    static int init( lua_State *L );
    static int load( lua_State *L );
    static int show( lua_State *L );
    static int setBannerPositionTop( lua_State *L );
    static int setBannerPositionBottom( lua_State *L );
    static int setImpressionListener( lua_State *L );
    static int setClickListener( lua_State *L );
    static int hide( lua_State *L );
    
protected:
    PluginLibrary();
    static int Finalizer( lua_State *L );
    
private:
    CoronaLuaRef fListener;
    CoronaLuaRef loadListener;
    CoronaLuaRef impressionListener;
    CoronaLuaRef clickListener;
    
    void loadBanner( lua_State *L );
    void showBanner( lua_State *L );
    void setBannerPositionToTop( lua_State *L );
    void setBannerPositionToBottom( lua_State *L );
    void setBannerImpressionListener( lua_State *L );
    void setBannerClickListener( lua_State *L );
    void hideBanner( lua_State *L );
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.pubnative.banner"
const char PluginLibrary::kName[] = "plugin.pubnative.banner";

// This corresponds to the event name, e.g. [Lua] event.name
const char PluginLibrary::kEvent[] = "pubnativeBanner";

PluginLibrary::PluginLibrary()
:	fListener( NULL )
{
}

bool PluginLibrary::Initialize( CoronaLuaRef listener )
{
    // Can only initialize listener once
    bool result = ( NULL == fListener );
    
    if ( result )
    {
        fListener = listener;
    }
    
    return result;
}

bool PluginLibrary::InitializeLoadListener( CoronaLuaRef listener )
{
    // Can only initialize listener once
    bool result = ( NULL == loadListener );
    
    if ( result )
    {
        loadListener = listener;
    }
    
    return result;
}

bool PluginLibrary::InitializeImpressionListener( CoronaLuaRef listener )
{
    // Can only initialize listener once
    bool result = ( NULL == impressionListener );
    
    if ( result )
    {
        impressionListener = listener;
    }
    
    return result;
}

bool PluginLibrary::InitializeClickListener( CoronaLuaRef listener )
{
    // Can only initialize listener once
    bool result = ( NULL == clickListener );
    
    if ( result )
    {
        clickListener = listener;
    }
    
    return result;
}

int PluginLibrary::Open( lua_State *L )
{
    // Register __gc callback
    const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
    CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );
    
    // Functions in library
    const luaL_Reg kVTable[] =
    {
        { "init", init },
        { "load", load },
        { "show", show },
        { "setBannerPositionTop", setBannerPositionTop },
        { "setBannerPositionBottom", setBannerPositionBottom },
        { "setImpressionListener", setImpressionListener },
        { "setClickListener", setClickListener },
        { "hide", hide },
        { NULL, NULL }
    };
    
    // Set library as upvalue for each library function
    Self *library = new Self;
    CoronaLuaPushUserdata( L, library, kMetatableName );
    
    luaL_openlib( L, kName, kVTable, 1 ); // leave "library" on top of stack
    
    return 1;
}

int PluginLibrary::Finalizer( lua_State *L )
{
    Self *library = (Self *)CoronaLuaToUserdata( L, 1 );
    
    CoronaLuaDeleteRef( L, library->GetListener() );
    
    delete library;
    
    return 0;
}

PluginLibrary * PluginLibrary::ToLibrary( lua_State *L )
{
    // library is pushed as part of the closure
    Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
    return library;
}

// [Lua] library.init( listener )
int PluginLibrary::init( lua_State *L )
{
    int listenerIndex = 1;
    
    if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
    {
        Self *library = ToLibrary( L );
        
        CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
        library->Initialize( listener );
    }
    
    return 0;
}

int PluginLibrary::load( lua_State *L )
{
    PluginLibrary bannerPlugin;
    bannerPlugin.loadBanner(L);
    return 0;
}

int PluginLibrary::show( lua_State *L )
{
    PluginLibrary bannerPlugin;
    bannerPlugin.showBanner(L);
    return 0;
}

int PluginLibrary::setBannerPositionTop( lua_State *L )
{
    PluginLibrary bannerPlugin;
    bannerPlugin.setBannerPositionToTop(L);
    return 0;
}

int PluginLibrary::setBannerPositionBottom( lua_State *L )
{
    PluginLibrary bannerPlugin;
    bannerPlugin.setBannerPositionToBottom(L);
    return 0;
}

int PluginLibrary:: hide( lua_State *L )
{
    PluginLibrary bannerPlugin;
    bannerPlugin.hideBanner(L);
    return 0;
}

int PluginLibrary::setImpressionListener( lua_State *L )
{
    PluginLibrary bannerPlugin;
    bannerPlugin.setBannerImpressionListener(L);
    return 0;
}

int PluginLibrary::setClickListener( lua_State *L )
{
    PluginLibrary bannerPlugin;
    bannerPlugin.setBannerClickListener(L);
    return 0;
}

void PluginLibrary::loadBanner( lua_State *L )
{
    bannerWrapper = [[PNBannerWrapper alloc] init];
    
    if ( CoronaLuaIsListener( L, 3, kEvent ) )
    {
        Self *library = ToLibrary( L );
        
        loadListener = CoronaLuaNewRef( L, 3 );
        library->InitializeLoadListener( loadListener );
        
        [bannerWrapper loadWithLuaState:L
                           withAppToken:[NSString stringWithUTF8String:lua_tostring(L, 1)]
                          withPlacement:[NSString stringWithUTF8String:lua_tostring(L, 2)]
                           withListener:library->GetLoadListener()];
    }
}

void PluginLibrary::showBanner( lua_State *L )
{
    [bannerWrapper show];
}

void PluginLibrary::setBannerPositionToTop( lua_State *L)
{
    [bannerWrapper setBannerPositionToTop];
}

void PluginLibrary::setBannerPositionToBottom( lua_State *L )
{
    [bannerWrapper setBannerPositionToBottom];
}

void PluginLibrary::setBannerImpressionListener( lua_State *L)
{
    if ( CoronaLuaIsListener( L, 1, kEvent ) )
    {
        Self *library = ToLibrary( L );
        
        impressionListener = CoronaLuaNewRef( L, 1 );
        library->InitializeImpressionListener( impressionListener );
        
        [bannerWrapper setImpressionListener:library->GetImpressionListener()];
    }
}

void PluginLibrary::setBannerClickListener( lua_State *L )
{
    if ( CoronaLuaIsListener( L, 1, kEvent ) )
    {
        Self *library = ToLibrary( L );
        
        clickListener = CoronaLuaNewRef( L, 1 );
        library->InitializeClickListener( clickListener );
        
        [bannerWrapper setClickListener:library->GetClickListener()];
    }
}

void PluginLibrary::hideBanner( lua_State *L )
{
    [bannerWrapper hide];
}

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_pubnative_banner( lua_State *L )
{
    return PluginLibrary::Open( L );
}
