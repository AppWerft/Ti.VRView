//
//  TiVrviewPanoramaView.m
//  TiVRView2
//
//  Created by Stefan Gross on 03.09.18.
//
//  can be created by calling createPanoramaView from JS side
//

// TODO enable/disable motion tracking by methods and background/foreground
// TODO view handling on destroy etc?
// TODO shall module provide means for motion tracking or shall view do?

#import <Foundation/Foundation.h>
#import "TiVrviewModule.h"
#import "TiVrviewPanoramaView.h"
#import "TiUtils.h"

#import <CoreMotion/CoreMotion.h>
#import <GLKit/GLKit.h>


@interface TiVrviewPanoramaView ()
{
    SCNNode *_cameraNode;
    CMMotionManager *_motionManager;
    NSString* _imagePath ;  // TODO initialize with provided dummy image
    NSOperationQueue* _motionQueue;
    CGFloat _initialHeading;
    bool initDone;
    
    double _yFov;
    double _radius;
    int _segmentCount;
}
@end

@implementation TiVrviewPanoramaView




- (instancetype)init {
    _initialHeading = 0.;
    initDone = NO;
    _yFov = 70;
    _radius = 20.0;
    _segmentCount = 300;

    NSLog(@"init in panorama view");
    _imagePath= [TiVrviewModule getPathToModuleAsset:@"default_pano.txt"];
    NSLog(@"Image Path %@",_imagePath);
    return [super init];
}

- (void)dealloc
{
    NSLog(@"dealloc in panorama view")
    if(_motionManager != nil && [_motionManager isDeviceMotionActive]) {
        [_motionManager stopDeviceMotionUpdates];
        _motionManager = nil;
    }
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    NSLog(@"[VIEW LIFECYCLE EVENT] willMoveToSuperview");
}



- (void)initializeState
{
    // This method is called right after all view properties have
    // been initialized from the view proxy. If the view is dependent
    // upon any properties being initialized then this is the method
    // to implement the dependent functionality.
    
    [super initializeState];
    
    NSLog(@"[VIEW LIFECYCLE EVENT] initializeState");
}

- (void)configurationSet
{
    // Creates and keeps a reference to the view upon initialization
    
    [super configurationSet];
    NSLog(@"[VIEW LIFECYCLE EVENT] configurationSet");
    
    // TODO use TiFile here and fetch info from Proxy
    
    NSLog(@"Load Image File %@" ,_imagePath);
    UIImage *image = [UIImage imageWithContentsOfFile:_imagePath];
    if( image.size.width / 2 != image.size.height) {
        NSLog(@"[ERROR] Image format is not 2:1 - will not create scene");
        return;
    }

    sceneView = [[SCNView alloc] initWithFrame:[self frame]];

    NSLog(@"Image File Loaded");
    
    // Set the scene
    self->sceneView.scene = [[SCNScene alloc]init];
    self->sceneView.allowsCameraControl = NO;

    // TODO calculate radius
    
    //Create node, containing a sphere, using the panoramic image as a texture
    SCNSphere *sphere =   [SCNSphere sphereWithRadius:_radius];
    sphere.firstMaterial.doubleSided = YES;
    sphere.segmentCount = _segmentCount;
    sphere.firstMaterial.diffuse.contents = image;
    sphere.firstMaterial.diffuse.mipFilter = SCNFilterModeNearest;
    sphere.firstMaterial.diffuse.magnificationFilter = SCNFilterModeNearest;
    sphere.firstMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(-1, 1, 1);
    sphere.firstMaterial.diffuse.wrapS = SCNWrapModeRepeat;
    sphere.firstMaterial.cullMode = SCNCullModeFront;
    
    SCNNode *sphereNode = [SCNNode nodeWithGeometry:sphere];
    
    sphereNode.position = SCNVector3Make(0,0,0);
    // rotate by heading value if given
    [sphereNode runAction:[SCNAction rotateByX:0 y:_initialHeading z:0 duration:0]];

    [self->sceneView.scene.rootNode addChildNode:sphereNode];
    
    
    // Camera, ...
    _cameraNode = [[SCNNode alloc]init];
    _cameraNode.camera = [[SCNCamera alloc]init];
    _cameraNode.position = SCNVector3Make(0, 0, 0);
    _cameraNode.camera.yFov = _yFov; // we do not need to set xFov for spherical case
    
    [self->sceneView.scene.rootNode addChildNode:_cameraNode];
    
    
    // TODO externalize Motion handling
    _motionManager = [[CMMotionManager alloc]init];
    
    if (_motionManager.isDeviceMotionAvailable) {
        NSLog(@"[DEBUG] Motion Data is available");
        _motionQueue = [[NSOperationQueue alloc]init ];
        [_motionQueue setQualityOfService:NSQualityOfServiceUserInteractive];
        
        // TODO shall we emit an event in case no motion sensing is allowed?

        _motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
        [self startMotionTracking :nil];
    }
// TODO     [sceneView backgroundColor: [UIColor.Black] ];
    [self addSubview: sceneView];
    initDone = YES;

}

-(void)stopMotionTracking :(id)unused{
    if(_motionManager==nil) return;
    
    NSLog(@"[DEBUG] Stop motion tracking and scene playing");
    [_motionManager stopDeviceMotionUpdates];
    //sceneView.playing = NO;// due to lack of animations we do not have to set playing
    
}

-(void)startMotionTracking :(id)unused{
    if(_motionManager==nil) return;

    NSLog(@"[DEBUG] Start motion tracking and scene playing");

    //sceneView.playing = YES; // due to lack of animations we do not have to set playing

    [_motionManager startDeviceMotionUpdatesToQueue:_motionQueue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        CMAttitude *attitude = motion.attitude;
        _cameraNode.orientation = [self orientation:attitude];
        /*
           Code for cylindrical projection where no gimbal lock can occure
           _cameraNode.eulerAngles = SCNVector3Make(attitude.roll - M_PI/2.0, attitude.yaw, attitude.pitch);
          */
        // TODO shall we emit a heading info here as well? Currently not a requirement
    }];
}

-(SCNVector4) orientation:(CMAttitude*)attitude {
    SCNVector4 result;
    CMQuaternion quaternion1 = attitude.quaternion;
    GLKQuaternion attitudeQuanternion = GLKQuaternionMake(quaternion1.x, quaternion1.y, quaternion1.z, quaternion1.w);

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication ] statusBarOrientation];
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            ;{
            GLKQuaternion cq1 = GLKQuaternionMakeWithAngleAndAxis(-(M_PI/2), 1, 0, 0);
            GLKQuaternion qm = GLKQuaternionMultiply(cq1, attitudeQuanternion);
            result = SCNVector4Make(qm.q[0],qm.q[1],qm.q[2],qm.q[3]);
            }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            ;{
            GLKQuaternion cq1 = GLKQuaternionMakeWithAngleAndAxis(-(M_PI/2), 1, 0, 0);
            GLKQuaternion cq2 = GLKQuaternionMakeWithAngleAndAxis(M_PI, 0, 0, 1);
            GLKQuaternion qm = GLKQuaternionMultiply(cq1, attitudeQuanternion);
            qm = GLKQuaternionMultiply(cq2, qm);
            result = SCNVector4Make(-qm.q[0],qm.q[1],qm.q[2],qm.q[3]);
            }
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            ;{
            GLKQuaternion cq1 = GLKQuaternionMakeWithAngleAndAxis(-(M_PI/2), 0, 1, 0);
            GLKQuaternion cq2 = GLKQuaternionMakeWithAngleAndAxis(-(M_PI/2), 1, 0, 0);
            GLKQuaternion qm = GLKQuaternionMultiply(cq1, attitudeQuanternion);
            qm = GLKQuaternionMultiply(cq2, qm);
            result = SCNVector4Make(qm.q[1],-qm.q[0],qm.q[2],qm.q[3]);
            }
            break;
        case UIInterfaceOrientationLandscapeRight:
        default:
            ;{
            GLKQuaternion cq1 = GLKQuaternionMakeWithAngleAndAxis(M_PI/2, 0, 1, 0);
            GLKQuaternion cq2 = GLKQuaternionMakeWithAngleAndAxis(-(M_PI/2), 1, 0, 0);
            GLKQuaternion qm = GLKQuaternionMultiply(cq1, attitudeQuanternion);
            qm = GLKQuaternionMultiply(cq2, qm);
            // strict ANSI (for whatever reason used in module project) does not allow union with x,y,z,w
            result = SCNVector4Make(-qm.q[1],qm.q[0],qm.q[2],qm.q[3]);
            }
            break;
    }
    return result;
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    // Sets the size and position of the view
    [TiUtils setView:sceneView positionRect:bounds];
}

#pragma Public API - only for initialization by map

- (void)setImage_:(id)pathToImage
{
    NSLog(@"[DEBUG] Set Image");
    if(initDone == YES) return; // accept setter only in init phase
    
    ENSURE_SINGLE_ARG(pathToImage, NSString)
    _imagePath = [TiUtils stringValue:pathToImage];
    NSLog(@"[DEBUG] ImagePath in setter %@",_imagePath);
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDir;
    if ([fileManager fileExistsAtPath:_imagePath isDirectory:&isDir] == NO) {
        NSLog(@"File Not found - throw exception");
        [self throwException:TiExceptionInternalInconsistency subreason:[NSString stringWithFormat:@"File not found: %@",_imagePath] location:CODELOCATION];
    }

}


- (void)setHeading_:(id)heading
{
    if(initDone == YES) return; // accept setter only in init phase

    ENSURE_SINGLE_ARG(heading, NSNumber)
    // TODO shall we accept degrees here or radian?
    _initialHeading = degreesToRadians([TiUtils floatValue:heading]);
}


- (void)setMotionUpdateInterval_:(id)value{
  // TODO
}

- (void)setFov_:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber)
    _yFov = [TiUtils floatValue:value];
}

- (void)setRadius_:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber)
    _radius = [TiUtils floatValue:value];
}

- (void)setSegmentCount_:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber)
    _segmentCount = [TiUtils intValue:value];
}


@end
