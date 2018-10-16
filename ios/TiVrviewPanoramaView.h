//
//  PanoramaView.h
//  TiVRView2
//
//  Created by Stefan Gross on 03.09.18.
//
//

#ifndef PanoramaView_h
#define PanoramaView_h

#import "TiUIView.h"
#import <SceneKit/SceneKit.h>

@interface TiVrviewPanoramaView: TiUIView {
   SCNView *sceneView;

}
-(void)startMotionTracking:(id)unused;
-(void)stopMotionTracking:(id)unused;

- (void)setImage_:(id)imagePath;
- (void)setHeading_:(id)heading;

- (void)setMotionUpdateInterval_:(id)value;
- (void)setFov_:(id)value;
- (void)setRadius_:(id)value;
- (void)setSegmentCount_:(id)value;

@end
#endif /* PanoramaView_h */
