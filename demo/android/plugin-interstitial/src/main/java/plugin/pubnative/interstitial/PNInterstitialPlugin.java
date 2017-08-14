package plugin.pubnative.interstitial;

import android.content.Context;

import com.ansca.corona.CoronaRuntime;

import net.pubnative.sdk.core.Pubnative;
import net.pubnative.sdk.layouts.PNLargeLayout;
import net.pubnative.sdk.layouts.PNLayout;

public class PNInterstitialPlugin implements PNLayout.LoadListener, PNLayout.TrackListener, PNLargeLayout.ViewListener {

    private CoronaRuntime mCoronaRuntime;

    private int mLoadListener;
    private int mImpressionListener;
    private int mClickListener;
    private int mShowListener;
    private int mHideListener;

    private PNLargeLayout mInterstitial;

    public void load(CoronaRuntime runtime, Context context, String appToken, String placement, int loadListener) {

        mCoronaRuntime = runtime;
        mLoadListener = loadListener;

        Pubnative.init(context, appToken);

        mInterstitial = new PNLargeLayout();
        mInterstitial.setLoadListener(this);
        mInterstitial.load(context, appToken, placement);
    }

    public void show(int impressionListener, int clickListener, int showListener, int hideListener) {

        mImpressionListener = impressionListener;
        mClickListener = clickListener;
        mShowListener = showListener;
        mHideListener = hideListener;

        mInterstitial.setTrackListener(this);
        mInterstitial.setViewListener(this);
        mInterstitial.show();
    }

    public void hide() {
        mInterstitial.hide();
    }

    private void dispatchEvent(int listener) {
        mCoronaRuntime.getTaskDispatcher().send(new PNEventHandler(listener));
    }

    private void dispatchEvent(final int listener, final Exception exception) {
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

    @Override
    public void onPNLayoutViewShown(PNLayout pnLayout) {
        dispatchEvent(mShowListener);
    }

    @Override
    public void onPNLayoutViewHidden(PNLayout pnLayout) {
        dispatchEvent(mHideListener);
    }
}
