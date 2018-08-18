//
//  Cubism3Model.h
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/18.
//  Copyright © 2018 matsune. All rights reserved.
//

#ifndef Cubism3Model_h
#define Cubism3Model_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DefaultParamId) {
    MouthOpenId,
    EyeBallX,
    EyeBallY,
    EyeOpenL,
    EyeOpenR,
    EyeSmileL,
    EyeSmileR,
    BrowLX,
    BrowLY,
    BrowRX,
    BrowRY,
    BrowLAngle,
    BrowRAngle,
    AngleX,
    AngleY,
    AngleZ,
    BodyAngleX,
    BodyAngleY,
    BodyAngleZ,
    BustX,
    BustY
};

@interface Cubism3Model : NSObject

@property (nonatomic) BOOL isInitialized;

- (void)releaseModel;
- (void)loadAssets:(NSString *)dir FileName:(NSString *)fileName;
- (void)setParameter:(DefaultParamId)paramId Value:(float)value;
- (void)scaleX:(CGFloat)x Y:(CGFloat)y;
- (void)scaleRelativeX:(CGFloat)x Y:(CGFloat)y;
- (void)translateX:(CGFloat)x Y:(CGFloat)y;
- (void)translateX:(CGFloat)x;
- (void)translateY:(CGFloat)y;
- (void)update;
- (void)draw;

@end

#endif /* Cubism3Model_h */
