//
//  ViewController.m
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/17.
//  Copyright © 2018 matsune. All rights reserved.
//

#import <ARKit/ARKit.h>

#import "ViewController.h"
#import "LAppModel.h"
#import "LAppPal.h"
#import "CubismDefaultParameterId.hpp"
#import "CubismIdManager.hpp"

using namespace Csm;

@interface ViewController ()

@property (nonatomic) LAppModel *model;

@property (nonatomic) ARSCNView *sceneView;

@property (nonatomic) const CubismId *mouthOpenId;
@property (nonatomic) const CubismId *eyeBallX;
@property (nonatomic) const CubismId *eyeBallY;
@property (nonatomic) const CubismId *eyeOpenL;
@property (nonatomic) const CubismId *eyeOpenR;
@property (nonatomic) const CubismId *eyeSmileL;
@property (nonatomic) const CubismId *eyeSmileR;
@property (nonatomic) const CubismId *browLX;
@property (nonatomic) const CubismId *browLY;
@property (nonatomic) const CubismId *browRX;
@property (nonatomic) const CubismId *browRY;
@property (nonatomic) const CubismId *browLAngle;
@property (nonatomic) const CubismId *browRAngle;

@property (nonatomic) const CubismId *angleX;
@property (nonatomic) const CubismId *angleY;
@property (nonatomic) const CubismId *angleZ;

@end

@implementation ViewController
@synthesize mOpenGLRun;

static const GLfloat uv[] =
{
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f,
};

- (void)dealloc
{
    delete self.model;
}

- (void)setupCubism {
    self.model = new LAppModel();
    self.model->LoadAssets([@"model/Haru/" UTF8String], [@"Haru.model3.json" UTF8String]);
    
    CubismIdManager *manager = CubismFramework::GetIdManager();
    self.mouthOpenId = manager->GetId(DefaultParameterId::ParamMouthOpenY);
    self.eyeBallX = manager->GetId(DefaultParameterId::ParamEyeBallX);
    self.eyeBallY = manager->GetId(DefaultParameterId::ParamEyeBallY);
    self.eyeOpenL = manager->GetId(DefaultParameterId::ParamEyeLOpen);
    self.eyeOpenR = manager->GetId(DefaultParameterId::ParamEyeROpen);
    self.eyeSmileL = manager->GetId(DefaultParameterId::ParamEyeLSmile);
    self.eyeSmileR = manager->GetId(DefaultParameterId::ParamEyeRSmile);
    self.browLX = manager->GetId(DefaultParameterId::ParamBrowLX);
    self.browLY = manager->GetId(DefaultParameterId::ParamBrowLY);
    self.browRX = manager->GetId(DefaultParameterId::ParamBrowRX);
    self.browRY = manager->GetId(DefaultParameterId::ParamBrowRY);
    self.browLAngle = manager->GetId(DefaultParameterId::ParamBrowLAngle);
    self.browRAngle = manager->GetId(DefaultParameterId::ParamBrowRAngle);
    self.angleX = manager->GetId(DefaultParameterId::ParamAngleX);
    self.angleY = manager->GetId(DefaultParameterId::ParamAngleY);
    self.angleZ = manager->GetId(DefaultParameterId::ParamAngleZ);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mOpenGLRun = true;
    
    GLKView *view = (GLKView*)self.view;
    
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    // set context
    [EAGLContext setCurrentContext:view.context];
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glGenBuffers(1, &_vertexBufferId);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferId);
    
    glGenBuffers(1, &_fragmentBufferId);
    glBindBuffer(GL_ARRAY_BUFFER, _fragmentBufferId);
    glBufferData(GL_ARRAY_BUFFER, sizeof(uv), uv, GL_STATIC_DRAW);
    
    CGFloat w = 100;
    CGFloat h = 100.0 / view.bounds.size.width * view.bounds.size.height;
    self.sceneView = [[ARSCNView alloc] initWithFrame:CGRectMake(view.bounds.size.width - w, view.bounds.size.height - h, w, h)];
    self.sceneView.delegate = self;
    self.sceneView.session.delegate = self;
    [self.sceneView setAutomaticallyUpdatesLighting:true];
    [self.view addSubview:self.sceneView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:true];
    
    [self resetTracking];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.sceneView.session pause];
}

- (void)resetTracking {
    if (!ARFaceTrackingConfiguration.isSupported) {
        return;
    }
    ARFaceTrackingConfiguration *conf = [[ARFaceTrackingConfiguration alloc] init];
    [conf setLightEstimationEnabled:true];
    [self.sceneView.session runWithConfiguration:conf options:ARSessionRunOptionResetTracking|ARSessionRunOptionRemoveExistingAnchors];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //時間更新
    LAppPal::UpdateTime();
    
    if(mOpenGLRun)
    {
        // 画面クリア
        glClear(GL_COLOR_BUFFER_BIT);
        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        
        self.model->Update();
        
        int width = rect.size.width;
        int height = rect.size.height;
        Csm::CubismMatrix44 projection;
        projection.Scale(1.0f, static_cast<float>(width) / static_cast<float>(height));
        projection.ScaleRelative(4.0, 4.0);
        self.model->Draw(projection);
    }
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self resetTracking];
    });
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    ARFaceAnchor *faceAnchor = (ARFaceAnchor*)anchor;
    
    { // face angle
        float yaw = atan2(-faceAnchor.transform.columns[2][0], faceAnchor.transform.columns[0][0]);
        float roll = atan2(-faceAnchor.transform.columns[1][2], faceAnchor.transform.columns[1][1]);
        float pitch = asin(faceAnchor.transform.columns[1][0]);
        
        self.model->GetModel()->SetParameterValue(self.angleX, -yaw * 40);
        self.model->GetModel()->SetParameterValue(self.angleY, (roll + 0.4) * 2 *30);
        self.model->GetModel()->SetParameterValue(self.angleZ, pitch * 40);
    }
    
    { // eyeball
        CGFloat lookUpL = [faceAnchor.blendShapes[ARBlendShapeLocationEyeLookUpLeft] floatValue];
        CGFloat lookDownL = [faceAnchor.blendShapes[ARBlendShapeLocationEyeLookDownLeft] floatValue];
        CGFloat lookInL = [faceAnchor.blendShapes[ARBlendShapeLocationEyeLookInLeft] floatValue];
        CGFloat lookOutL = [faceAnchor.blendShapes[ARBlendShapeLocationEyeLookOutLeft] floatValue];
        CGFloat lookUpR = [faceAnchor.blendShapes[ARBlendShapeLocationEyeLookUpRight] floatValue];
        CGFloat lookDownR = [faceAnchor.blendShapes[ARBlendShapeLocationEyeLookDownRight] floatValue];
        CGFloat lookInR = [faceAnchor.blendShapes[ARBlendShapeLocationEyeLookInRight] floatValue];
        CGFloat lookOutR = [faceAnchor.blendShapes[ARBlendShapeLocationEyeLookOutRight] floatValue];
        CGFloat xEyeL = lookOutL - lookInL;
        CGFloat xEyeR = lookInR - lookOutR;
        CGFloat yEyeL = lookUpL - lookDownL;
        CGFloat yEyeR = lookUpR - lookDownR;
        self.model->GetModel()->SetParameterValue(self.eyeBallX, (xEyeL + xEyeR) / 2);
        self.model->GetModel()->SetParameterValue(self.eyeBallY, (yEyeL + yEyeR) / 2);
    }
    
    { // eye blink
        CGFloat eyeBlinkL = [faceAnchor.blendShapes[ARBlendShapeLocationEyeBlinkLeft] floatValue];
        CGFloat eyeBlinkR = [faceAnchor.blendShapes[ARBlendShapeLocationEyeBlinkRight] floatValue];
        // blink invert eyeOpen
        self.model->GetModel()->SetParameterValue(self.eyeOpenL, (eyeBlinkL - 0.5) * -2.0);
        self.model->GetModel()->SetParameterValue(self.eyeOpenR, (eyeBlinkR - 0.5) * -2.0);
        
        CGFloat eyeSquintL = [faceAnchor.blendShapes[ARBlendShapeLocationEyeSquintLeft] floatValue];
        CGFloat eyeSquintR = [faceAnchor.blendShapes[ARBlendShapeLocationEyeSquintRight] floatValue];
        self.model->GetModel()->SetParameterValue(self.eyeSmileL, eyeSquintL * 1.4);
        self.model->GetModel()->SetParameterValue(self.eyeSmileR, eyeSquintR * 1.4);
    }
    
    { // eye brow
        CGFloat innerUp = [faceAnchor.blendShapes[ARBlendShapeLocationBrowInnerUp] floatValue];
        CGFloat outerUpL = [faceAnchor.blendShapes[ARBlendShapeLocationBrowOuterUpLeft] floatValue];
        CGFloat outerUpR = [faceAnchor.blendShapes[ARBlendShapeLocationBrowOuterUpRight] floatValue];
        CGFloat downL = [faceAnchor.blendShapes[ARBlendShapeLocationBrowDownLeft] floatValue];
        CGFloat downR = [faceAnchor.blendShapes[ARBlendShapeLocationBrowDownRight] floatValue];
        self.model->GetModel()->SetParameterValue(self.browLY, (innerUp + outerUpL) / 2);
        self.model->GetModel()->SetParameterValue(self.browRY, (innerUp + outerUpR) / 2);
        self.model->GetModel()->SetParameterValue(self.browLAngle, (innerUp - outerUpL + downL) * (2 / 3) - (1 / 3));
        self.model->GetModel()->SetParameterValue(self.browRAngle, (innerUp - outerUpR + downR) * (2 / 3) - (1 / 3));
    }
    
    { // mouth
        CGFloat jawOpen = [faceAnchor.blendShapes[ARBlendShapeLocationJawOpen] floatValue];
        self.model->GetModel()->SetParameterValue(self.mouthOpenId, jawOpen);
    }
}

@end
