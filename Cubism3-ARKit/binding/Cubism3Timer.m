//
//  Cubism3Timer.m
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/18.
//  Copyright © 2018 matsune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cubism3Timer.h"

double s_currentFrame = 0.0;
double s_lastFrame = 0.0;
double s_deltaTime = 0.0;

@interface Cubism3Timer()

@end

@implementation Cubism3Timer

+ (void)update
{
    NSDate *now = [NSDate date];
    double unixtime = [now timeIntervalSince1970];
    s_currentFrame = unixtime;
    s_deltaTime = s_currentFrame - s_lastFrame;
    s_lastFrame = s_currentFrame;
}

+ (double)getDeltaTime
{
    return s_deltaTime;
}

@end
