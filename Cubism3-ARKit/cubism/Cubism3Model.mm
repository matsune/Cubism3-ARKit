//
//  Cubism3Model.m
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/18.
//  Copyright © 2018 matsune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Rendering/OpenGL/CubismRenderer_OpenGLES2.hpp>
#import "CubismDefaultParameterId.hpp"
#import "csmString.hpp"
#import "CubismMoc.hpp"
#import "CubismModel.hpp"
#import "CubismModelMatrix.hpp"
#import "CubismIdManager.hpp"
#import "CubismPhysics.hpp"
#import "CubismPose.hpp"
#import "CubismBreath.hpp"
#import "ICubismModelSetting.hpp"
#import "CubismModelSettingJson.hpp"
#import "Cubism3Model.h"
#import "LAppTextureManager.h"
#import "LAppPal.h"

using namespace Live2D::Cubism::Framework;

@interface Cubism3Model()

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
@property (nonatomic) const CubismId *bodyAngleX;
@property (nonatomic) const CubismId *bodyAngleY;
@property (nonatomic) const CubismId *bodyAngleZ;
@property (nonatomic) const CubismId *bustX;
@property (nonatomic) const CubismId *bustY;

@property (nonatomic) CubismMoc* moc;
@property (nonatomic) CubismModel* model;

@property (nonatomic) CubismPhysics* physics;
@property (nonatomic) CubismPose* pose;
@property (nonatomic) CubismBreath* breath;
@property (nonatomic) CubismModelMatrix* modelMatrix;
@property (nonatomic) ICubismModelSetting* modelSetting;

@property (nonatomic) Rendering::CubismRenderer* renderer;

@property (nonatomic) LAppTextureManager* textureManager;
@property (nonatomic) NSString* modelHomeDir;
@property (nonatomic) Csm::csmFloat32 userTimeSeconds;
@property (nonatomic) Csm::CubismMatrix44 *drawMatrix;
@end

@implementation Cubism3Model

- (instancetype)init
{
    self = [super init];
    if (self) {
        _textureManager = [[LAppTextureManager alloc] init];
        _drawMatrix = new Csm::CubismMatrix44();
        
        CubismIdManager *manager = CubismFramework::GetIdManager();
        _mouthOpenId = manager->GetId(DefaultParameterId::ParamMouthOpenY);
        _eyeBallX = manager->GetId(DefaultParameterId::ParamEyeBallX);
        _eyeBallY = manager->GetId(DefaultParameterId::ParamEyeBallY);
        _eyeOpenL = manager->GetId(DefaultParameterId::ParamEyeLOpen);
        _eyeOpenR = manager->GetId(DefaultParameterId::ParamEyeROpen);
        _eyeSmileL = manager->GetId(DefaultParameterId::ParamEyeLSmile);
        _eyeSmileR = manager->GetId(DefaultParameterId::ParamEyeRSmile);
        _browLX = manager->GetId(DefaultParameterId::ParamBrowLX);
        _browLY = manager->GetId(DefaultParameterId::ParamBrowLY);
        _browRX = manager->GetId(DefaultParameterId::ParamBrowRX);
        _browRY = manager->GetId(DefaultParameterId::ParamBrowRY);
        _browLAngle = manager->GetId(DefaultParameterId::ParamBrowLAngle);
        _browRAngle = manager->GetId(DefaultParameterId::ParamBrowRAngle);
        _angleX = manager->GetId(DefaultParameterId::ParamAngleX);
        _angleY = manager->GetId(DefaultParameterId::ParamAngleY);
        _angleZ = manager->GetId(DefaultParameterId::ParamAngleZ);
        _bodyAngleX = manager->GetId(DefaultParameterId::ParamBodyAngleX);
        _bodyAngleY = manager->GetId(DefaultParameterId::ParamBodyAngleY);
        _bodyAngleZ = manager->GetId(DefaultParameterId::ParamBodyAngleZ);
        _bustX = manager->GetId(DefaultParameterId::ParamBustX);
        _bustY = manager->GetId(DefaultParameterId::ParamBustY);
    }
    return self;
}

- (void)dealloc
{
    [self releaseModel];
    [self deleteRenderer];
}

- (void) releaseModel
{
    CubismPhysics::Delete(_physics);
    CubismPose::Delete(_pose);
    CubismBreath::Delete(_breath);
    CSM_DELETE(_modelMatrix);
    CSM_DELETE(_modelSetting);
    _moc->DeleteModel(_model);
    CubismMoc::Delete(_moc);
    CSM_DELETE(_drawMatrix);
}

- (void)loadAssets:(NSString *)dir FileName:(NSString *)fileName
{
    _modelHomeDir = dir;
    
    csmSizeInt size;
    NSString *path = [dir stringByAppendingString:fileName];
    csmByte* buffer = LAppPal::LoadFileAsBytes([path UTF8String], &size);
    ICubismModelSetting* setting = new CubismModelSettingJson(buffer, size);
    LAppPal::ReleaseBytes(buffer);
    
    [self setupModel:setting];
    [self createRenderer];
    [self setupTexture];
}

- (void)setupModel:(ICubismModelSetting *)setting
{
    _isInitialized = false;
    _modelSetting = setting;
    
    csmByte* buffer;
    csmSizeInt size;
    
    if (strcmp(_modelSetting->GetModelFileName(), "") != 0) {
        csmString path = [_modelHomeDir UTF8String];
        path += _modelSetting->GetModelFileName();
        
        buffer = LAppPal::LoadFileAsBytes(path.GetRawString(), &size);
        [self loadModelBuffer:buffer Size:size];
        LAppPal::ReleaseBytes(buffer);
    }
    
    //Physics
    if (strcmp(_modelSetting->GetPhysicsFileName(), "") != 0)
    {
        csmString path = [_modelHomeDir UTF8String];
        path += _modelSetting->GetModelFileName();
        
        buffer = LAppPal::LoadFileAsBytes(path.GetRawString(), &size);
        [self loadPhysicsBuffer:buffer Size:size];
        LAppPal::ReleaseBytes(buffer);
    }
    
    //Pose
    if (strcmp(_modelSetting->GetPoseFileName(), "") != 0)
    {
        csmString path = [_modelHomeDir UTF8String];
        path += _modelSetting->GetPoseFileName();
        
        buffer = LAppPal::LoadFileAsBytes(path.GetRawString(), &size);
        [self loadPoseBuffer:buffer Size:size];
        LAppPal::ReleaseBytes(buffer);
    }
    
//    //Breath
//    {
//        _breath = CubismBreath::Create();
//        
//        csmVector<CubismBreath::BreathParameterData> breathParameters;
//        
//        breathParameters.PushBack(CubismBreath::BreathParameterData(_angleX, 0.0f, 15.0f, 6.5345f, 0.1f));
//        breathParameters.PushBack(CubismBreath::BreathParameterData(_angleY, 0.0f, 8.0f, 3.5345f, 0.1f));
//        breathParameters.PushBack(CubismBreath::BreathParameterData(_angleZ, 0.0f, 10.0f, 5.5345f, 0.1f));
//        breathParameters.PushBack(CubismBreath::BreathParameterData(_bodyAngleX, 0.0f, 4.0f, 15.5345f, 0.1f));
//        breathParameters.PushBack(CubismBreath::BreathParameterData(CubismFramework::GetIdManager()->GetId(Live2D::Cubism::Framework::DefaultParameterId::ParamBreath),
//                                                                    0.5f, 0.5f, 3.2345f, 0.1f));
//        
//        _breath->SetParameters(breathParameters);
//    }
//    
    _isInitialized = true;
}

- (void)loadModelBuffer:(const csmByte*)buffer Size:(csmSizeInt) size
{
    _moc = CubismMoc::Create(buffer, size);
    _model = _moc->CreateModel();
    
    if ((_moc == NULL) || (_model == NULL))
    {
        CubismLogError("Failed to CreateModel().");
        return;
    }
    
    _modelMatrix = CSM_NEW CubismModelMatrix(_model->GetCanvasWidth(),
                                             _model->GetCanvasHeight());
}

- (void)loadPhysicsBuffer:(const csmByte*)buffer Size:(csmSizeInt) size
{
    _physics = CubismPhysics::Create(buffer, size);
}

- (void)loadPoseBuffer:(const csmByte*)buffer Size:(csmSizeInt) size
{
    _pose = CubismPose::Create(buffer, size);
}

- (void)createRenderer {
    [self deleteRenderer];
    _renderer = Rendering::CubismRenderer::Create();
    _renderer->Initialize(_model);
}

- (void)deleteRenderer {
    if (_renderer) {
        Rendering::CubismRenderer::Delete(_renderer);
        _renderer = NULL;
    }
}

- (void)setupTexture {
    for (csmInt32 modelTextureNumber = 0; modelTextureNumber < _modelSetting->GetTextureCount(); modelTextureNumber++) {
        if (strcmp(_modelSetting->GetTextureFileName(modelTextureNumber), "") == 0) {
            continue;
        }
        
        csmString path = [_modelHomeDir UTF8String];
        path += _modelSetting->GetTextureFileName(modelTextureNumber);
        
        TextureInfo* texture = [_textureManager createTextureFromPngFile:path.GetRawString()];
        csmInt32 glTextueNumber = texture->id;
        
        [self getRender]->BindTexture(modelTextureNumber, glTextueNumber);
    }
    [self getRender]->IsPremultipliedAlpha(true);
}

- (Rendering::CubismRenderer_OpenGLES2*)getRender
{
    return dynamic_cast<Rendering::CubismRenderer_OpenGLES2*>(_renderer);
}

- (void)scaleX:(CGFloat)x Y:(CGFloat)y
{
    _drawMatrix->Scale(x, y);
}

- (void)scaleRelativeX:(CGFloat)x Y:(CGFloat)y
{
    _drawMatrix->ScaleRelative(x, y);
}

- (void)translateX:(CGFloat)x Y:(CGFloat)y
{
    _drawMatrix->Translate(x, y);
}

- (void)translateX:(CGFloat)x
{
    _drawMatrix->TranslateX(x);
}

- (void)translateY:(CGFloat)y
{
    _drawMatrix->TranslateY(y);
}

- (void)update
{
    const csmFloat32 deltaTimeSeconds = LAppPal::GetDeltaTime();
    _userTimeSeconds += deltaTimeSeconds;
    
    if (_breath != NULL) {
        _breath->UpdateParameters(_model, deltaTimeSeconds);
    }
    
    if (_physics != NULL) {
        _physics->Evaluate(_model, deltaTimeSeconds);
    }
    
    if (_pose != NULL)
    {
        _pose->UpdateParameters(_model, deltaTimeSeconds);
    }
    
    _model->Update();
    
    _drawMatrix->LoadIdentity();
}

- (void)draw
{
    if (_model == NULL) {
        return;
    }
    
    [self getRender]->SetMvpMatrix(_drawMatrix);
    [self getRender]->DrawModel();
}


- (void)setParameter:(DefaultParamId)paramId Value:(float)value
{
    const CubismId *pId;
    switch (paramId) {
        case MouthOpenId:
            pId = _mouthOpenId;
            break;
            
        case EyeBallX:
            pId = _eyeBallX;
            break;
            
        case EyeBallY:
            pId = _eyeBallY;
            break;
            
        case EyeOpenL:
            pId = _eyeOpenL;
            break;
            
        case EyeOpenR:
            pId = _eyeOpenR;
            break;
            
        case EyeSmileL:
            pId = _eyeSmileL;
            break;
            
        case EyeSmileR:
            pId = _eyeSmileR;
            break;
            
        case BrowLX:
            pId = _browLX;
            break;
            
        case BrowLY:
            pId = _browLY;
            break;
            
        case BrowRX:
            pId = _browRX;
            break;
            
        case BrowRY:
            pId = _browRY;
            break;
            
        case BrowLAngle:
            pId = _browLAngle;
            break;
            
        case BrowRAngle:
            pId = _browRAngle;
            break;
            
        case AngleX:
            pId = _angleX;
            break;
            
        case AngleY:
            pId = _angleY;
            break;
            
        case AngleZ:
            pId = _angleZ;
            break;
            
        case BodyAngleX:
            pId = _bodyAngleX;
            break;
            
        case BodyAngleY:
            pId = _bodyAngleY;
            break;
            
        case BodyAngleZ:
            pId = _bodyAngleZ;
            break;
            
        case BustX:
            pId = _bustX;
            break;
            
        case BustY:
            pId = _bustY;
            break;
            
    }
    _model->SetParameterValue(pId, value);
}

@end
