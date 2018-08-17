//
//  MenuViewController.h
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/17.
//  Copyright © 2018 matsune. All rights reserved.
//

#ifndef MenuViewController_h
#define MenuViewController_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MenuViewControllerDelegate <NSObject>

- (void)didSelectRestart;
- (void)didChangeShowFace:(bool)showFace;

@end

@interface MenuViewController : UICollectionViewController

@property (weak, nonatomic) id <MenuViewControllerDelegate> menuDelegate;
@property (nonatomic) bool showFace;

@end

#endif /* MenuViewController_h */
