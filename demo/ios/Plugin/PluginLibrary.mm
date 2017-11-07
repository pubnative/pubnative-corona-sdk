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

class PluginLibrary
{
public:
    typedef PluginLibrary Self;
    
    static const char kName[];
    static const char kEvent[];
    
    bool Initialize( CoronaLuaRef listener );
    
    CoronaLuaRef GetListener() const { return fListener; }
    
    static int Open( lua_State *L );
    static Self *ToLibrary( lua_State *L );
    static int init( lua_State *L );
    static int load( lua_State *L );
    static int show( lua_State *L );
    static int hide( lua_State *L );
    static int remove( lua_State *L );
    
protected:
    PluginLibrary();
    static int Finalizer( lua_State *L );
    
private:
    CoronaLuaRef fListener;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.pubnative.banner"
const char PluginLibrary::kName[] = "plugin.pubnative.banner";

// This corresponds to the event name, e.g. [Lua] event.name
const char PluginLibrary::kEvent[] = "Banner";

PluginLibrary::PluginLibrary()
:	fListener( NULL )
{
}

bool
PluginLibrary::Initialize( CoronaLuaRef listener )
{
    // Can only initialize listener once
    bool result = ( NULL == fListener );
    
    if ( result )
    {
        fListener = listener;
    }
    
    return result;
}

int
PluginLibrary::Open( lua_State *L )
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
        { "hide", hide },
        { "remove", remove },
        { NULL, NULL }
    };
    
    // Set library as upvalue for each library function
    Self *library = new Self;
    CoronaLuaPushUserdata( L, library, kMetatableName );
    
    luaL_openlib( L, kName, kVTable, 1 ); // leave "library" on top of stack
    
    return 1;
}

int
PluginLibrary::Finalizer( lua_State *L )
{
    Self *library = (Self *)CoronaLuaToUserdata( L, 1 );
    
    CoronaLuaDeleteRef( L, library->GetListener() );
    
    delete library;
    
    return 0;
}

PluginLibrary *
PluginLibrary::ToLibrary( lua_State *L )
{
    // library is pushed as part of the closure
    Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
    return library;
}

// [Lua] library.init( listener )
int
PluginLibrary::init( lua_State *L )
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
    PNBannerWrapper *bannerWrapper = [[PNBannerWrapper alloc] init];
    [bannerWrapper loadWithLuaState:L withAppToken:[NSString stringWithUTF8String:lua_tostring(L, 1)] withPlacement:[NSString stringWithUTF8String:lua_tostring(L, 2)]];
    return 0;
}

int PluginLibrary::show( lua_State *L )
{
    return 0;
}

int PluginLibrary:: hide( lua_State *L )
{
    return 0;
}

int PluginLibrary:: remove( lua_State *L )
{
    return 0;
}

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_pubnative_banner( lua_State *L )
{
    return PluginLibrary::Open( L );
}
