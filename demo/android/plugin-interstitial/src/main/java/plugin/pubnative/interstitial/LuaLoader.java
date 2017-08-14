//
//  LuaLoader.java
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// This corresponds to the name of the Lua library,
// e.g. [Lua] require "plugin.library"
package plugin.pubnative.interstitial;

import com.ansca.corona.CoronaActivity;
import com.ansca.corona.CoronaEnvironment;
import com.ansca.corona.CoronaLua;
import com.ansca.corona.CoronaRuntime;
import com.ansca.corona.CoronaRuntimeListener;
import com.ansca.corona.CoronaRuntimeProvider;
import com.naef.jnlua.JavaFunction;
import com.naef.jnlua.LuaState;
import com.naef.jnlua.NamedJavaFunction;


/**
 * Implements the Lua interface for a Corona plugin.
 * <p>
 * Only one instance of this class will be created by Corona for the lifetime of the application.
 * This instance will be re-used for every new Corona activity that gets created.
 */
@SuppressWarnings("WeakerAccess")
public class LuaLoader implements JavaFunction, CoronaRuntimeListener {

    public static final String EVENT_NAME = "pubnativeInterstitial";

    // Listeners
    int loadListener = CoronaLua.REFNIL;
    int impressionListener = CoronaLua.REFNIL;
    int clickListener = CoronaLua.REFNIL;
    int showListener = CoronaLua.REFNIL;
    int hideListener = CoronaLua.REFNIL;

    private CoronaRuntime mRuntime;
    private PNInterstitialPlugin mInterstitial;

    private String mAppToken;
    private String mPlacement;

    /**
     * Creates a new Lua interface to this plugin.
     * <p>
     * Note that a new LuaLoader instance will not be created for every CoronaActivity instance.
     * That is, only one instance of this class will be created for the lifetime of the application process.
     * This gives a plugin the option to do operations in the background while the CoronaActivity is destroyed.
     */
    @SuppressWarnings("unused")
    public LuaLoader() {

        CoronaActivity activity = CoronaEnvironment.getCoronaActivity();

        // Validate.
        if (activity == null) {
            throw new IllegalArgumentException("Activity cannot be null.");
        }

        // Set up this plugin to listen for Corona runtime events to be received by methods
        // onLoaded(), onStarted(), onSuspended(), onResumed(), and onExiting().
        CoronaEnvironment.addRuntimeListener(this);
    }

    /**
     * Called when this plugin is being loaded via the Lua require() function.
     * <p>
     * Note that this method will be called every time a new CoronaActivity has been launched.
     * This means that you'll need to re-initialize this plugin here.
     * <p>
     * Warning! This method is not called on the main UI thread.
     *
     * @param L Reference to the Lua state that the require() function was called from.
     * @return Returns the number of values that the require() function will return.
     * <p>
     * Expected to return 1, the library that the require() function is loading.
     */
    @Override
    public int invoke(LuaState L) {

        mRuntime = CoronaRuntimeProvider.getRuntimeByLuaState(L);

        loadListener = CoronaLua.REFNIL;
        impressionListener = CoronaLua.REFNIL;
        clickListener = CoronaLua.REFNIL;
        showListener = CoronaLua.REFNIL;
        hideListener = CoronaLua.REFNIL;

        // Register this plugin into Lua with the following functions.
        NamedJavaFunction[] luaFunctions = new NamedJavaFunction[]{
                new LoadWrapper(),
                new ShowWrapper(),
                new HideWrapper(),
        };
        String libName = L.toString(1);
        L.register(libName, luaFunctions);

        // Returning 1 indicates that the Lua require() function will return the above Lua library.
        return 1;
    }

    /**
     * Called after the Corona runtime has been created and just before executing the "main.lua" file.
     * <p>
     * Warning! This method is not called on the main thread.
     *
     * @param runtime Reference to the CoronaRuntime object that has just been loaded/initialized.
     *                Provides a LuaState object that allows the application to extend the Lua API.
     */
    @Override
    public void onLoaded(CoronaRuntime runtime) {
        // Note that this method will not be called the first time a Corona activity has been launched.
        // This is because this listener cannot be added to the CoronaEnvironment until after
        // this plugin has been required-in by Lua, which occurs after the onLoaded() event.
        // However, this method will be called when a 2nd Corona activity has been created.

    }

    /**
     * Called just after the Corona runtime has executed the "main.lua" file.
     * <p>
     * Warning! This method is not called on the main thread.
     *
     * @param runtime Reference to the CoronaRuntime object that has just been started.
     */
    @Override
    public void onStarted(CoronaRuntime runtime) {
    }

    /**
     * Called just after the Corona runtime has been suspended which pauses all rendering, audio, timers,
     * and other Corona related operations. This can happen when another Android activity (ie: window) has
     * been displayed, when the screen has been powered off, or when the screen lock is shown.
     * <p>
     * Warning! This method is not called on the main thread.
     *
     * @param runtime Reference to the CoronaRuntime object that has just been suspended.
     */
    @Override
    public void onSuspended(CoronaRuntime runtime) {
    }

    /**
     * Called just after the Corona runtime has been resumed after a suspend.
     * <p>
     * Warning! This method is not called on the main thread.
     *
     * @param runtime Reference to the CoronaRuntime object that has just been resumed.
     */
    @Override
    public void onResumed(CoronaRuntime runtime) {
    }

    /**
     * Called just before the Corona runtime terminates.
     * <p>
     * This happens when the Corona activity is being destroyed which happens when the user presses the Back button
     * on the activity, when the native.requestExit() method is called in Lua, or when the activity's finish()
     * method is called. This does not mean that the application is exiting.
     * <p>
     * Warning! This method is not called on the main thread.
     *
     * @param runtime Reference to the CoronaRuntime object that is being terminated.
     */
    @Override
    public void onExiting(CoronaRuntime runtime) {

        // We should clean all references on app exit
        loadListener = CoronaLua.REFNIL;
        impressionListener = CoronaLua.REFNIL;
        clickListener = CoronaLua.REFNIL;
        showListener = CoronaLua.REFNIL;
        hideListener = CoronaLua.REFNIL;

        mRuntime = null;
        mInterstitial = null;

    }

    //===========================================================================================
    // Plugin API
    //===========================================================================================

    /**
     * The following Lua function has been called:  pubnative.init( { parameters } )
     * <p>
     * Warning! This method is not called on the main thread.
     *
     * @return Returns the number of values to be returned by the library.init() function.
     */
    public int load() {

        // Fetch a reference to the Corona activity.
        // Note: Will be null if the end-user has just backed out of the activity.
        CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
        if (activity == null) {
            return 0;
        }

        if (mInterstitial == null) {
            mInterstitial = new PNInterstitialPlugin();
        }

        mInterstitial.load(mRuntime, activity, mAppToken, mPlacement, loadListener);

        return 0;
    }

    /**
     * The following Lua function has been called:  pubnative.show()
     * <p>
     * Warning! This method is not called on the main thread.
     *
     * @return Returns the number of values to be returned by the library.show() function.
     */
    public int show() {

        // Fetch a reference to the Corona activity.
        // Note: Will be null if the end-user has just backed out of the activity.
        CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
        if (activity == null) {
            return 0;
        }

        try {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    // Fetch a reference to the Corona activity.
                    // Note: Will be null if the end-user has just backed out of the activity.
                    CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
                    if (activity == null) {
                        return;
                    }
                    if (mInterstitial != null) {
                        mInterstitial.show(impressionListener, clickListener, showListener, hideListener);
                    }

                }
            });
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0;
    }

    public int hide() {

        // Fetch a reference to the Corona activity.
        // Note: Will be null if the end-user has just backed out of the activity.
        CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
        if (activity == null) {
            return 0;
        }

        try {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    // Fetch a reference to the Corona activity.
                    // Note: Will be null if the end-user has just backed out of the activity.
                    CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
                    if (activity == null) {
                        return;
                    }

                    if (mInterstitial != null) {
                        mInterstitial.hide();
                    }

                }
            });
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0;
    }

    /**
     * Implements the pubnative.init() Lua function.
     */
    private class LoadWrapper implements NamedJavaFunction {
        /**
         * Gets the name of the Lua function as it would appear in the Lua script.
         *
         * @return Returns the name of the custom Lua function.
         */
        @Override
        public String getName() {
            return "load";
        }

        /**
         * This method is called when the Lua function is called.
         * <p>
         * Warning! This method is not called on the main UI thread.
         *
         * @param L Reference to the Lua state.
         *          Needed to retrieve the Lua function's parameters and to return values back to Lua.
         * @return Returns the number of values to be returned by the Lua function.
         */
        @Override
        public int invoke(LuaState L) {

            int index = 1;

            mAppToken = L.checkString(index);
            index++;

            mPlacement = L.checkString(index);
            index++;

            if (CoronaLua.isListener(L, index, EVENT_NAME)) {
                loadListener = CoronaLua.newRef(L, index);
            }
            index++;

            return load();
        }
    }

    /**
     * Implements the pubnative.show() Lua function.
     */
    private class ShowWrapper implements NamedJavaFunction {
        /**
         * Gets the name of the Lua function as it would appear in the Lua script.
         *
         * @return Returns the name of the custom Lua function.
         */
        @Override
        public String getName() {
            return "show";
        }

        /**
         * This method is called when the Lua function is called.
         * <p>
         * Warning! This method is not called on the main UI thread.
         *
         * @param L Reference to the Lua state.
         *          Needed to retrieve the Lua function's parameters and to return values back to Lua.
         * @return Returns the number of values to be returned by the Lua function.
         */
        @Override
        public int invoke(LuaState L) {

            int index = 1;

            if (CoronaLua.isListener(L, index, EVENT_NAME)) {
                impressionListener = CoronaLua.newRef(L, index);
            }
            index++;

            if (CoronaLua.isListener(L, index, EVENT_NAME)) {
                clickListener = CoronaLua.newRef(L, index);
            }
            index++;

            if (CoronaLua.isListener(L, index, EVENT_NAME)) {
                showListener = CoronaLua.newRef(L, index);
            }
            index++;

            if (CoronaLua.isListener(L, index, EVENT_NAME)) {
                hideListener = CoronaLua.newRef(L, index);
            }
            index++;

            return show();
        }
    }

    /**
     * Implements the pubnative.hide() Lua function.
     */
    private class HideWrapper implements NamedJavaFunction {
        /**
         * Gets the name of the Lua function as it would appear in the Lua script.
         *
         * @return Returns the name of the custom Lua function.
         */
        @Override
        public String getName() {
            return "hide";
        }

        @Override
        public int invoke(LuaState L) {
            return hide();
        }
    }
}
