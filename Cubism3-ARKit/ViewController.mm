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
#import "ARKit/ContentUpdater.h"

@interface ViewController ()

@property (nonatomic) LAppModel *model;

@property (nonatomic) ARSCNView *sceneView;
@property (nonatomic) ContentUpdater *updater;

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

- (void)initModel {
    self.model = new LAppModel();
    self.model->LoadAssets([@"model/Haru/" UTF8String], [@"Haru.model3.json" UTF8String]);
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
    
    self.updater = [[ContentUpdater alloc] init];
    
    CGFloat w = 100;
    CGFloat h = 100.0 / view.bounds.size.width * view.bounds.size.height;
    self.sceneView = [[ARSCNView alloc] initWithFrame:CGRectMake(view.bounds.size.width - w, view.bounds.size.height - h, w, h)];
    self.sceneView.delegate = self.updater;
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

@end
