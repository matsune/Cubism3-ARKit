//
//  AppDelegate.m
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/17.
//  Copyright © 2018 matsune. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "LAppAllocator.h"

#import "CubismFramework.hpp"
#import "LAppPal.h"

@interface AppDelegate ()

@property (nonatomic) LAppAllocator cubismAllocator; // Cubism3 Allocator
@property (nonatomic) Csm::CubismFramework::Option cubismOption; // Cubism3 Option

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                           instantiateViewControllerWithIdentifier:@"ViewController"];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    [self initializeCubism];
    [self.viewController setupCubism];
        
    return YES;
}

- (void) initializeCubism {
    _cubismOption.LogFunction = LAppPal::PrintMessage;
    _cubismOption.LoggingLevel = Live2D::Cubism::Framework::CubismFramework::Option::LogLevel_Verbose;
    
    Csm::CubismFramework::StartUp(&_cubismAllocator, &_cubismOption);
    Csm::CubismFramework::Initialize();

    LAppPal::UpdateTime();
}

- (void) releaseCubism {
    Csm::CubismFramework::Dispose();
}

- (void)applicationWillResignActive:(UIApplication *)application {

}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.viewController.mOpenGLRun = false;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    self.viewController.mOpenGLRun = true;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
    self.viewController.mOpenGLRun = false;
    [self releaseCubism];
}


@end
