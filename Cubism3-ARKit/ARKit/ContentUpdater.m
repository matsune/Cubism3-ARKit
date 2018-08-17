//
//  ContentUpdater.m
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/17.
//  Copyright © 2018 matsune. All rights reserved.
//

#import "ContentUpdater.h"

@interface ContentUpdater()

@end

@implementation ContentUpdater

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    NSLog(@"didUpdateNode");
}

@end
