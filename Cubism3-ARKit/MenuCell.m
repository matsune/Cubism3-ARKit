//
//  MenuCell.m
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/18.
//  Copyright © 2018 matsune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuCell.h"

@interface MenuCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation MenuCell

- (void)bindImage:(UIImage*)image Title:(NSString*)title {
    [self.imageView setImage:image];
    [self.label setText:title];
}

@end
