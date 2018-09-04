# Ti.VRView    

It is a Titanium module for realizing of a VRPanoramaView and VRVideoView. Currently only the android version auf PanoramaView and VideoView are realized.


<img src="https://i.ytimg.com/vi/H5F0ggHKZvU/maxresdefault.jpg" width=680 />

## Equirectangular projections

OpenGL has strict texture size requirements acceptable image sizes:

    4096 × 2048
    2048 × 1024
    1024 × 512
    512 × 256
    256 × 128
    … (any smaller power of 2)


## Usage

```javascript
var image = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, "pano.jpg");
image.write(Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, "pano.jpg").read());

var VR = require("ti.vrview");
var win = Ti.UI.createWindow({
});
var panoView = VR.createPanoramaView({
    type : VR.TYPE_MONO,
    image : Ti.Filessystem.getFile(Ti.Filesystem.applicationDataDirectory, "pano.jpg").nativePath,
     onload : function() {},
     onchanged : function(e) {
	 		console.log(e.yaw);
	 		console.log(e.pitch);
	 },
	 fullscreenButtonEnabled : false,
     infoButtonEnabled : false,
     stereoModeButtonEnabled : false,
     touchTrackingEnabled : true,
     transitionViewEnabled : false,
     sensorDelay : VR.SENSOR_DELAY_NORMAL
});
var videoView = VR.createVideoView({
	 onchanged : function(e) {
	 		console.log(e.yaw);
	 		console.log(e.pitch);
	 }
	 onload : function() {},
     type : VR.TYPE_STEREO_OVER_UNDER,
     format : VR.FORMAT_DEFAULT,
     image : Ti.Filessystem.getFile(Ti.Filesystem.applicationDataDirectory, "pano.mp4")).nativePath,
     fullscreenButtonEnabled : false,
     infoButtonEnabled : false,
     stereoModeButtonEnabled : false,
     touchTrackingEnabled : true,
     transitionViewEnabled : false
});
win.add(panoView);
```

##  Constants

### Type of streaming

* FORMAT_DEFAULT
Indicates that the video is in a standard video container format such as mp4, webm, ogg, aac.

* FORMAT_HLS
Indicates that the video uses the HTTP Live Streaming (HLS) format.


### Mono (screen) or stereo (cardbox)
* TYPE_MONO
Each video frame is a monocular equirectangular panorama.

* TYPE\_STEREO\_OVER_UNDER
Each video frame contains two vertically-stacked equirectangular panoramas.

### Sensor dealy for onChange callback
* SENSOR\_DELAY_NORMAL   (2 sec.)
* SENSOR\_DELAY_FASTEST (0)
* SENSOR\_DELAY_GAME (20 ms)
* SENSOR\_DELAY_UI (60 ms)

## Methods

* createPanoramaView()

* createVideoView()

This is [Hyperloop-Version](https://gist.github.com/m1ga/933949ddd1ac7f5e5f75632795bb0420) Thanks to miga.