package plugin.pubnative.banner;

import com.ansca.corona.CoronaLua;
import com.ansca.corona.CoronaLuaEvent;
import com.ansca.corona.CoronaRuntime;
import com.ansca.corona.CoronaRuntimeTask;
import com.naef.jnlua.LuaState;

import static plugin.pubnative.banner.LuaLoader.EVENT_NAME;

public class PNEventHandler implements CoronaRuntimeTask {

    private int mListener;
    private Exception mException;

    public PNEventHandler(int listener) {
        mListener = listener;
    }

    public PNEventHandler(int listener, Exception exception) {
        this(listener);
        mException = exception;
    }

    @Override
    public void executeUsing(CoronaRuntime coronaRuntime) {
        if (coronaRuntime != null && coronaRuntime.isRunning()) {
            coronaRuntime.getTaskDispatcher().send(new CoronaRuntimeTask() {
                @Override
                public void executeUsing(CoronaRuntime runtime) {
                    LuaState L = runtime.getLuaState();

                    CoronaLua.newEvent( L, EVENT_NAME );

                    if (mException != null) {
                        L.pushString(mException.getLocalizedMessage());
                        L.setField(-2, CoronaLuaEvent.RESPONSE_KEY);

                        L.pushBoolean(true);
                        L.setField(-2, CoronaLuaEvent.ISERROR_KEY);
                    }

                    try {
                        CoronaLua.dispatchEvent( L, mListener, 0 );
                    } catch (Exception ignored) {
                    }
                }
            });
        }
    }
}
