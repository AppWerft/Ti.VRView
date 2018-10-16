//
//  TiVrviewPanoramaViewProxy.m
//  TiVRView2
//
//  Created by Stefan Gross on 03.09.18.
//
//

#import <Foundation/Foundation.h>
#import "TiVrviewPanoramaViewProxy.h"
#import <TiUtils.h>
#import <TiApp.h>

#ifndef USE_VIEW_FOR_UI_METHOD
#define USE_VIEW_FOR_UI_METHOD(methodname)\
-(void)methodname:(id)args\
{\
  NSLog(@"UI Method forwarded to View methodname");\
  [self makeViewPerformSelector:@selector(methodname:) withObject:args createIfNeeded:YES waitUntilDone:NO];\
}
#endif

@implementation TiVrviewPanoramaViewProxy


// TODO shall we implement a AppDelegate to disable tracking in background mode

- (id)init
{
    // This is the designated initializer method and will always be called
    // when the view proxy is created.
    
    NSLog(@"[VIEWPROXY LIFECYCLE EVENT] init");
    
    
    return [super init];
}

- (void)_destroy
{
    // This method is called from the dealloc method and is good place to
    // release any objects and memory that have been allocated for the view proxy.
    
    NSLog(@"[VIEWPROXY LIFECYCLE EVENT] _destroy");
    
    [super _destroy];
}

- (id)_initWithPageContext:(id<TiEvaluator>)context
{
    // This method is one of the initializers for the view proxy class. If the
    // proxy is created without arguments then this initializer will be called.
    // This method is also called from the other _initWithPageContext method.
    // The superclass method calls the init and _configure methods.
    
    NSLog(@"[VIEWPROXY LIFECYCLE EVENT] _initWithPageContext (no arguments)");
    
    return [super _initWithPageContext:context];
}

- (id)_initWithPageContext:(id<TiEvaluator>)context_ args:(NSArray *)args
{
    // This method is one of the initializers for the view proxy class. If the
    // proxy is created with arguments then this initializer will be called.
    // The superclass method calls the _initWithPageContext method without
    // arguments.
    
    NSLog(@"[VIEWPROXY LIFECYCLE EVENT] _initWithPageContext %@", args);
    
    return [super _initWithPageContext:context_ args:args];
}

- (void)_configure
{
    // This method is called from _initWithPageContext to allow for
    // custom configuration of the module before startup. The superclass
    // method calls the startup method.
    
    NSLog(@"[VIEWPROXY LIFECYCLE EVENT] _configure");
    
    [super _configure];
  // as of Titanium 7.x onward  [[TiApp app] registerApplicationDelegate:self];

}

- (void)_initWithProperties:(NSDictionary *)properties
{
    // This method is called from _initWithPageContext if arguments have been
    // used to create the view proxy. It is called after the initializers have completed
    // and is a good point to process arguments that have been passed to the
    // view proxy create method since most of the initialization has been completed
    // at this point.
    
    NSLog(@"[VIEWPROXY LIFECYCLE EVENT] _initWithProperties %@", properties);
    
    [super _initWithProperties:properties];
}


// Delegate declaration - the Proxy exposes the API for the view to the JS Bridge

USE_VIEW_FOR_UI_METHOD(startMotionTracking)
USE_VIEW_FOR_UI_METHOD(stopMotionTracking)


- (void)viewWillAttach
{
    // This method is called right before the view is attached to the proxy
    
    NSLog(@"[VIEWPROXY LIFECYCLE EVENT] viewWillAttach");
}

- (void)viewDidAttach
{
    // This method is called right after the view has attached to the proxy
    
    NSLog(@"[VIEWPROXY LIFECYCLE EVENT] viewDidAttach");
}

- (void)viewDidDetach
{
    // This method is called right before the view is detached from the proxy
    
    NSLog(@"[VIEWPROXY LIFECYCLE EVENT] viewDidDetach");
}

- (void)viewWillDetach
{
    // This method is called right after the view has detached from the proxy
    [self stopMotionTracking :nil];
    NSLog(@"[VIEWPROXY LIFECYCLE EVENT] viewWillDetach");
}





// Property setter methods defined this way will dispatched to the corresponding method in View as well TBC by logging...
- (void)setFoo:(id)value
{
    ENSURE_SINGLE_ARG_OR_NIL(value, NSDictionary);

    // Handle the value
    NSString *sVal = [TiUtils stringValue:@"key" properties:value def:@"default"];
}

// creation handled with parameter initialisation shall be automatically converted to setter calls
// according module development documentation - TBC!


#pragma mark Helper

USE_VIEW_FOR_CONTENT_WIDTH

USE_VIEW_FOR_CONTENT_HEIGHT

- (TiDimension)defaultAutoWidthBehavior:(id)unused
{
    return TiDimensionAutoFill;
}

- (TiDimension)defaultAutoHeightBehavior:(id)unused
{
    return TiDimensionAutoFill;
}

@end
