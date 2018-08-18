//
//  ViewController.m
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/17.
//  Copyright © 2018 matsune. All rights reserved.
//

#import <ARKit/ARKit.h>

#import "ViewController.h"
#import "LAppPal.h"
#import "CubismDefaultParameterId.hpp"
#import "CubismIdManager.hpp"
#import "Cubism3Model.h"

using namespace Csm;

@interface ViewController ()

@property (nonatomic) Cubism3Model *model;
@property (nonatomic) bool showFace;

@property (weak, nonatomic) IBOutlet ARSCNView *sceneView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

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

- (void)setupCubism {
    _model = [[Cubism3Model alloc] init];
    [self.model loadAssets:@"model/Haru/" FileName:@"Haru.model3.json"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _showFace = true;
    
    [self setupUI];
    [self setupGL];
}

- (void)setupUI {
    self.sceneView.delegate = self;
    self.sceneView.session.delegate = self;
    [self.sceneView setAutomaticallyUpdatesLighting:true];
    
    [self.addButton.layer setMasksToBounds:false];
    [self.addButton.layer setShadowColor:[UIColor colorWithWhite:0.2 alpha:1.0].CGColor];
    [self.addButton.layer setShadowOpacity:0.6];
    [self.addButton.layer setShadowOffset:CGSizeMake(0, 3.5f)];
    [self.addButton.layer setShadowRadius:3.5f];
}

- (void)setupGL {
    mOpenGLRun = true;
    
    GLKView *view = (GLKView*)self.view;
    
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
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

- (void)setShowFace:(bool)showFace {
    [self.sceneView setHidden:!showFace];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    LAppPal::UpdateTime();
    
    if (mOpenGLRun) {
        [self.model update];
        
        glClear(GL_COLOR_BUFFER_BIT);
        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        
        CGFloat width = rect.size.width;
        CGFloat height = rect.size.height;
        [self.model scaleX:1.0f Y:width / height];
        [self.model scaleRelativeX:4.0 Y:4.0];
        [self.model translateY:-0.8];
        [self.model draw];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIPopoverPresentationController *popoverController = segue.destinationViewController.popoverPresentationController;
    UIButton *button = (UIButton *)sender;
    popoverController.delegate = self;
    popoverController.sourceRect = button.bounds;
    
    MenuViewController *menuVC = (MenuViewController*)segue.destinationViewController;
    menuVC.showFace = self.showFace;
    menuVC.menuDelegate = self;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)didSelectRestart {
    [self resetTracking];
}

- (void)didChangeShowFace:(bool)showFace {
    [self.sceneView setHidden:!showFace];
    _showFace = showFace;
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

        [self.model setParameter:AngleX Value:-yaw * 40];
        [self.model setParameter:AngleX Value:-yaw * 40];
        [self.model setParameter:AngleY Value:(roll + 0.4) * 2 *30];
        [self.model setParameter:AngleZ Value:pitch * 40];
        
        [self.model setParameter:BodyAngleX Value:-yaw * 10];
        [self.model setParameter:BodyAngleY Value:(roll + 0.4) * 2 * 10];
        [self.model setParameter:BodyAngleZ Value:pitch * 10];
        
        [self.model setParameter:BustX Value:-yaw];
        [self.model setParameter:BustY Value:(roll + 0.4) * 2];
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
        [self.model setParameter:EyeBallX Value:(xEyeL + xEyeR) / 2];
        [self.model setParameter:EyeBallY Value:(yEyeL + yEyeR) / 2];
    }
    
    { // eye blink
        CGFloat eyeBlinkL = [faceAnchor.blendShapes[ARBlendShapeLocationEyeBlinkLeft] floatValue];
        CGFloat eyeBlinkR = [faceAnchor.blendShapes[ARBlendShapeLocationEyeBlinkRight] floatValue];
        // blink invert eyeOpen
        [self.model setParameter:EyeOpenL Value:(eyeBlinkL - 0.5) * -2.0];
        [self.model setParameter:EyeOpenR Value:(eyeBlinkR - 0.5) * -2.0];
        
        CGFloat eyeSquintL = [faceAnchor.blendShapes[ARBlendShapeLocationEyeSquintLeft] floatValue];
        CGFloat eyeSquintR = [faceAnchor.blendShapes[ARBlendShapeLocationEyeSquintRight] floatValue];
        [self.model setParameter:EyeSmileL Value:eyeSquintL * 1.4];
        [self.model setParameter:EyeSmileR Value:eyeSquintR * 1.4];
    }
    
    { // eye brow
        CGFloat innerUp = [faceAnchor.blendShapes[ARBlendShapeLocationBrowInnerUp] floatValue];
        CGFloat outerUpL = [faceAnchor.blendShapes[ARBlendShapeLocationBrowOuterUpLeft] floatValue];
        CGFloat outerUpR = [faceAnchor.blendShapes[ARBlendShapeLocationBrowOuterUpRight] floatValue];
        CGFloat downL = [faceAnchor.blendShapes[ARBlendShapeLocationBrowDownLeft] floatValue];
        CGFloat downR = [faceAnchor.blendShapes[ARBlendShapeLocationBrowDownRight] floatValue];
        [self.model setParameter:BrowLY Value:(innerUp + outerUpL) / 2];
        [self.model setParameter:BrowRY Value:(innerUp + outerUpR) / 2];
        [self.model setParameter:BrowLAngle Value:(innerUp - outerUpL + downL) * (2 / 3) - (1 / 3)];
        [self.model setParameter:BrowRAngle Value:(innerUp - outerUpR + downR) * (2 / 3) - (1 / 3)];
    }
    
    { // mouth
        CGFloat jawOpen = [faceAnchor.blendShapes[ARBlendShapeLocationJawOpen] floatValue];
        [self.model setParameter:MouthOpenId Value:jawOpen];
    }
}

@end
