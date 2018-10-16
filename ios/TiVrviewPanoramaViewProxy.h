//
//  TiVrviewPanoramaViewProxy.h
//  TiVRView2
//
//  Created by Stefan Gross on 03.09.18.
//
//

#ifndef TiVrviewPanoramaViewProxy_h
#define TiVrviewPanoramaViewProxy_h

#import "TiViewProxy.h"
@interface TiVrviewPanoramaViewProxy: TiViewProxy <UIApplicationDelegate>{
    
}

- (void)stopMotionTracking:(id)unused;
- (void)startMotionTracking:(id)unused;

@end
#endif /* TiVrviewPanoramaViewProxy_h */
