//
//  ViewController.m
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/17.
//  Copyright © 2018 matsune. All rights reserved.
//

#import "ViewController.h"
#import "LAppModel.h"
#import "LAppPal.h"

@interface ViewController ()

@property (nonatomic) LAppModel *model;

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
    
}

- (void)initModel {
    self.model = new LAppModel();
    self.model->LoadAssets([@"model/Haru/" UTF8String], [@"Haru.model3.json" UTF8String]);
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

@end
