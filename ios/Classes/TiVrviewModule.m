/**
 * TiVRView2
 *
 * Created by Your Name
 * Copyright (c) 2018 Your Company. All rights reserved.
 */

#import "TiVrviewModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiVrviewModule

#pragma mark Internal

// This is generated for your module, please do not change it
- (id)moduleGUID
{
  return @"457c69da-1ac5-4645-bbbd-c479167bb8cb";
}

// This is generated for your module, please do not change it
+ (NSString *)moduleId
{
  return @"ti.vrview";
}

#pragma mark Lifecycle

- (void)startup
{
  // This method is called when the module is first loaded
  // You *must* call the superclass
  [super startup];
  NSLog(@"[DEBUG] %@ loaded", self);
}

- (void) resume:(id)sender
{
    [super resume:sender];
    NSLog(@"[DEBUG] %@ resume", self);
}

- (void) resumed:(id)sender
{
    [super resumed:sender];
    NSLog(@"[DEBUG] %@ resumed", self);
}

- (void) shutdown:(id)sender
{
    NSLog(@"[DEBUG] %@ shutdown", self);
    [super shutdown:sender];
}

-(id)createProxy:(NSArray*)args forName:(NSString*)name context:(id<TiEvaluator>)evaluator {
    NSLog(@"[DEBUG] create Proxy %@ args: %@",name,args);
    return [super createProxy:args forName:name context:evaluator];
}


+ (NSString *)getPathToModuleAsset:(NSString *) fileName
{
    // The module assets are copied to the application bundle into the folder pattern
    // "module/<moduleid>". One way to access these assets is to build a path from the
    // mainBundle of the application.
    
    NSString *pathComponent = [NSString stringWithFormat:@"modules/%@/%@", [self moduleId], fileName];
    NSString *result = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:pathComponent];
    
    return result;
}

- (NSString *)getPathToApplicationAsset:(NSString *) fileName
{
    // The application assets can be accessed by building a path from the mainBundle of the application.
    
    NSString *result = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    
    return result;
}

@end
