package plugin.pubnative.banner;

import android.content.Context;

import com.ansca.corona.CoronaRuntime;

import net.pubnative.sdk.core.Pubnative;
import net.pubnative.sdk.layouts.PNBanner;
import net.pubnative.sdk.layouts.PNLayout;

public class PNBannerPlugin implements PNLayout.LoadListener, PNLayout.TrackListener {

    private PNBanner mBanner;
    private PNBanner.Position mPosition = PNBanner.Position.BOTTOM;
    private CoronaRuntime mCoronaRuntime;

    private int mLoadListener;
    private int mImpressionListener;
    private int mClickListener;

    public void load(CoronaRuntime runtime, Context context, String appToken, String placement, int loadListener) {

        mCoronaRuntime = runtime;
        mLoadListener = loadListener;

        Pubnative.init(context, appToken);

        mBanner = new PNBanner();
        mBanner.setLoadListener(this);
        mBanner.load(context, appToken, placement);

    }

    public void show(int impressionListener, int clickListener) {

        mImpressionListener = impressionListener;
        mClickListener = clickListener;

        mBanner.setTrackListener(this);
        mBanner.show(mPosition);
    }

    public void hide() {
        mBanner.hide();
    }

    public void setPositionTop() {
        mPosition = PNBanner.Position.TOP;
    }

    public void setPositionBottom() {
        mPosition = PNBanner.Position.BOTTOM;
    }


    private void dispatchEvent(int listener) {
        mCoronaRuntime.getTaskDispatcher().send(new PNEventHandler(listener));
    }

    private void dispatchEvent(int listener, Exception exception) {
        mCoronaRuntime.getTaskDispatcher().send(new PNEventHandler(listener, exception));
    }

    @Override
    public void onPNLayoutLoadFinish(PNLayout pnLayout) {
        dispatchEvent(mLoadListener);
    }

    @Override
    public void onPNLayoutLoadFail(PNLayout pnLayout, Exception e) {
        dispatchEvent(mLoadListener, e);
    }

    @Override
    public void onPNLayoutTrackImpression(PNLayout pnLayout) {
        dispatchEvent(mImpressionListener);
    }

    @Override
    public void onPNLayoutTrackClick(PNLayout pnLayout) {
        dispatchEvent(mClickListener);
    }
}
