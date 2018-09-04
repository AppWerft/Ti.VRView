package ti.vrview;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.AsyncResult;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.common.TiMessenger;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiC;
import org.appcelerator.titanium.io.TiBaseFile;
import org.appcelerator.titanium.io.TiFile;
import org.appcelerator.titanium.io.TiFileFactory;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiUIView;
import org.appcelerator.titanium.util.TiSensorHelper;

import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import ti.modules.titanium.filesystem.FileProxy;
import ti.vrview.VrviewModule;
import android.app.Activity;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Message;
import android.util.Pair;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;

import com.google.vr.sdk.widgets.pano.*;
import com.google.vr.sdk.widgets.pano.VrPanoramaView.Options;

@Kroll.proxy(creatableInModule = VrviewModule.class)
public class PanoramaViewProxy extends TiViewProxy implements
		SensorEventListener {

	TiUIView view;
	KrollProxy proxy;
	public boolean loadImageSuccessful;
	private int type = VrviewModule.TYPE_MONO;
	private static final int MSG_FIRST_ID = TiViewProxy.MSG_LAST_ID + 1;
	private static final int MSG_RESUME = MSG_FIRST_ID + 500;
	private static final int MSG_PAUSE = MSG_FIRST_ID + 501;
	private static final int MSG_DESTROY = MSG_FIRST_ID + 502;
	private static final String LCAT = "TiVR";

	private ImageLoaderTask backgroundImageLoaderTask;
	private Uri fileUriOfPanoImage;
	public VrPanoramaView vrPanoramaView;
	KrollFunction headRotationCallback = null;
	KrollFunction onLoadCallback = null;

	private static Context ctx = TiApplication.getInstance()
			.getApplicationContext();
	private static SensorManager sensorManager = TiSensorHelper
			.getSensorManager();
	private Sensor sensor = sensorManager
			.getDefaultSensor(Sensor.TYPE_ORIENTATION);
	private float[] headRotation = new float[2];
	private boolean fullscreenButtonEnabled = false;
	private boolean infoButtonEnabled = false;
	private boolean stereoModeButtonEnabled = false;
	private boolean touchTrackingEnabled = false;
	private boolean transitionViewEnabled = false;
	private int sensorDelay = SensorManager.SENSOR_DELAY_UI;
	private boolean running = false;

	private class PanoramaView extends TiUIView {
		private Options panoOptions = new Options();

		public PanoramaView(final TiViewProxy proxy) {
			super(proxy);
			this.proxy = proxy;

			Activity ctx = proxy.getActivity();
			Log.d(LCAT,
					"Start PanoramaView with " + fileUriOfPanoImage.toString());

			LinearLayout container = new LinearLayout(ctx);
			container.setLayoutParams(new LayoutParams(
					LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
			vrPanoramaView = new VrPanoramaView(ctx);
			// setting all params:
			vrPanoramaView.setInfoButtonEnabled(infoButtonEnabled);
			vrPanoramaView.setStereoModeButtonEnabled(stereoModeButtonEnabled);
			vrPanoramaView.setFullscreenButtonEnabled(fullscreenButtonEnabled);
			vrPanoramaView.setTouchTrackingEnabled(touchTrackingEnabled);
			vrPanoramaView.setTransitionViewEnabled(transitionViewEnabled);
			sensorManager.registerListener(PanoramaViewProxy.this, sensor,
					sensorDelay);
			vrPanoramaView.setEventListener(new ActivityEventListener());
			vrPanoramaView
					.setOnFocusChangeListener(new OnFocusChangeListener() {
						@Override
						public void onFocusChange(View view, boolean hasFocus) {
							if (hasFocus) {
								sensorManager.registerListener(
										PanoramaViewProxy.this, sensor,
										sensorDelay);
							} else {
								sensorManager
										.unregisterListener(PanoramaViewProxy.this);
							}
						}
					});
			panoOptions.inputType = type;
			if (backgroundImageLoaderTask != null) {
				backgroundImageLoaderTask.cancel(true);
			}
			backgroundImageLoaderTask = new ImageLoaderTask();
			Log.d(LCAT, "Starting backgroundLoader");
			backgroundImageLoaderTask.execute(Pair.create(fileUriOfPanoImage,
					panoOptions));
			container.addView(vrPanoramaView);
			setNativeView(container);
		}
	}

	// Constructor
	public PanoramaViewProxy() {
		super();
	}

	@Override
	public boolean handleMessage(Message msg) {
		AsyncResult result = null;
		switch (msg.what) {
		case MSG_RESUME: {
			result = (AsyncResult) msg.obj;
			handleResume();
			result.setResult(null);
			return true;
		}
		case MSG_DESTROY: {
			result = (AsyncResult) msg.obj;
			handleDestroy();
			result.setResult(null);
			return true;
		}
		case MSG_PAUSE: {
			result = (AsyncResult) msg.obj;
			handlePause();
			result.setResult(null);
			return true;
		}
		default: {
			return super.handleMessage(msg);
		}
		}
	}

	// Exposed methods:
	@Kroll.method
	public void pause() {
		if (TiApplication.isUIThread()) {
			handlePause();
		} else {
			TiMessenger.sendBlockingMainMessage(getMainHandler().obtainMessage(
					MSG_PAUSE));

		}
	}

	@Kroll.method
	public void resume() {
		if (TiApplication.isUIThread()) {
			handleResume();
		} else {
			TiMessenger.sendBlockingMainMessage(getMainHandler().obtainMessage(
					MSG_RESUME));

		}
	}

	@Kroll.method
	public void destroy() {
		if (TiApplication.isUIThread()) {
			handleDestroy();
		} else {
			TiMessenger.sendBlockingMainMessage(getMainHandler().obtainMessage(
					MSG_DESTROY));
		}
	}

	private void handlePause() {
		running = false;
		Log.d(LCAT, "PAUSE PanoView");
		sensorManager.unregisterListener(PanoramaViewProxy.this);
		vrPanoramaView.pauseRendering();
	}

	private void handleDestroy() {
		running = false;
		Log.d(LCAT, "DESTROY PanoView");
		vrPanoramaView.shutdown();
		sensorManager.unregisterListener(PanoramaViewProxy.this);

	}

	private void handleResume() {
		Log.d(LCAT, "RESUME PanoView");
		vrPanoramaView.resumeRendering();
		sensorManager.registerListener(PanoramaViewProxy.this, sensor,
				sensorDelay);
		running = true;
	}

	@Override
	public TiUIView createView(Activity activity) {
		Log.d(LCAT, "TiUIView createView");
		view = new PanoramaView(this);
		view.getLayoutParams().autoFillsHeight = true;
		view.getLayoutParams().autoFillsWidth = true;
		return view;
	}

	// Handle creation options
	@Override
	public void handleCreationDict(KrollDict opts) {
		super.handleCreationDict(opts);
		if (opts.containsKeyAndNotNull(TiC.PROPERTY_TYPE)) {
			type = opts.getInt(TiC.PROPERTY_TYPE);
		}
		if (opts.containsKeyAndNotNull(VrviewModule.ONCHANGED)) {
			headRotationCallback = (KrollFunction) opts
					.get(VrviewModule.ONCHANGED);
		}
		if (opts.containsKeyAndNotNull(VrviewModule.ONLOAD)) {
			onLoadCallback = (KrollFunction) opts.get(VrviewModule.ONLOAD);
		}
		if (opts.containsKeyAndNotNull("fullscreenButtonEnabled")) {
			fullscreenButtonEnabled = opts
					.getBoolean("fullscreenButtonEnabled");
		}
		if (opts.containsKeyAndNotNull("infoButtonEnabled")) {
			infoButtonEnabled = opts.getBoolean("infoButtonEnabled");
		}
		if (opts.containsKeyAndNotNull("stereoModeButtonEnabled")) {
			stereoModeButtonEnabled = opts
					.getBoolean("stereoModeButtonEnabled");
		}
		if (opts.containsKeyAndNotNull("touchTrackingEnabled")) {
			touchTrackingEnabled = opts.getBoolean("touchTrackingEnabled");
		}
		if (opts.containsKeyAndNotNull("transitionViewEnabled")) {
			transitionViewEnabled = opts.getBoolean("transitionViewEnabled");
		}

		if (opts.containsKeyAndNotNull(TiC.PROPERTY_IMAGE)) {
			Log.d(LCAT, TiC.PROPERTY_IMAGE + " found");
			Object inputValue = opts.get(TiC.PROPERTY_IMAGE);
			TiBaseFile inputFile = null;
			if (inputValue instanceof TiFile) {
				Log.d(LCAT, "image  TiFile");
				inputFile = TiFileFactory.createTitaniumFile(
						((TiFile) inputValue).getFile().getAbsolutePath(),
						false);
			} else {
				if (inputValue instanceof FileProxy) {
					Log.d(LCAT, "image  FileProxy");
					inputFile = ((FileProxy) inputValue).getBaseFile();
				} else {
					if (inputValue instanceof TiBaseFile) {
						Log.d(LCAT, "image  TiBaseFile");
						inputFile = (TiBaseFile) inputValue;
					} else {
						Log.d(LCAT, "image  String " + inputValue.toString());
						inputFile = TiFileFactory.createTitaniumFile(
								inputValue.toString(), false);
					}
				}
			}
			if (inputFile.exists()) {
				fileUriOfPanoImage = Uri.fromFile(inputFile.getNativeFile());
				Log.d(LCAT, "Uri=" + fileUriOfPanoImage.toString());

			} else
				Log.e(LCAT, "(pano) file not exists");

		} else
			Log.w(LCAT, "image missing");

	}

	/**
	 * Helper class to manage threading.
	 */
	class ImageLoaderTask extends AsyncTask<Pair<Uri, Options>, Void, Boolean> {
		/**
		 * Reads the bitmap from disk in the background and waits until it's
		 * loaded by pano widget.
		 */
		@SuppressWarnings("unchecked")
		@Override
		protected Boolean doInBackground(Pair<Uri, Options>... fileInformation) {
			Options panoOptions = null; // It's safe to use null
			// VrPanoramaView.Options.
			InputStream istr = null;
			try {
				istr = new FileInputStream(new File(
						fileInformation[0].first.getPath()));
				panoOptions = fileInformation[0].second;
			} catch (IOException e) {
				return false;
			}
			Log.d(LCAT, "Start loadingImageFromBitmap");
			vrPanoramaView.loadImageFromBitmap(
					BitmapFactory.decodeStream(istr), panoOptions);
			try {
				istr.close();
				Log.d(LCAT, "stream closed");
			} catch (IOException e) {
				Log.e(LCAT, "Error closing stream");
			}
			return true;
		}
	}

	private class ActivityEventListener extends VrPanoramaEventListener {
		/**
		 * Called by pano widget on the UI thread when it's done loading the
		 * image.
		 */
		@Override
		public void onLoadSuccess() {
			running = true;
			Log.d(LCAT, "VrPanoramaEventListener: success");
			loadImageSuccessful = true;
			if (onLoadCallback != null) {
				onLoadCallback.call(getKrollObject(), new KrollDict());
			}
		}

		/**
		 * Called by pano widget on the UI thread on any asynchronous error.
		 */
		@Override
		public void onLoadError(String errorMessage) {
			Log.e(LCAT, "VrPanoramaEventListener: error");
			loadImageSuccessful = false;

		}

	}

	@Override
	public void onSensorChanged(SensorEvent sensorEvent) {
		if (running) {
			vrPanoramaView.getHeadRotation(headRotation);
			if (headRotationCallback != null
					&& headRotationCallback instanceof KrollFunction) {
				KrollDict dict = new KrollDict();
				dict.put("yaw", headRotation[0]);
				dict.put("pitch", headRotation[1]);
				headRotationCallback.call(getKrollObject(), dict);
			}
		}
    }

	@Override
	public void onAccuracyChanged(Sensor arg0, int arg1) {
		// TODO Auto-generated method stub
	}
}
