//
//  Cubism3Allocator.m
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/18.
//  Copyright © 2018 matsune. All rights reserved.
//

#import "Cubism3Allocator.h"

#import <Foundation/Foundation.h>
#import "CubismFramework.hpp"
#import "LAppAllocator.h"
#import "LAppPal.h"
#import "Cubism3Timer.h"

LAppAllocator _cubismAllocator; // Cubism3 Allocator
Csm::CubismFramework::Option _cubismOption; // Cubism3 Option

@interface Cubism3Allocator()

@end

@implementation Cubism3Allocator

+ (void) startUp
{
    _cubismOption.LogFunction = LAppPal::PrintMessage;
    _cubismOption.LoggingLevel = Live2D::Cubism::Framework::CubismFramework::Option::LogLevel_Verbose;
    
    Csm::CubismFramework::StartUp(&_cubismAllocator, &_cubismOption);
    Csm::CubismFramework::Initialize();
    
    [Cubism3Timer update];
}

+ (void) dispose
{
    Csm::CubismFramework::Dispose();
}

@end
