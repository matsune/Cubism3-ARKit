//
//  MenuViewController.m
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/17.
//  Copyright © 2018 matsune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuViewController.h"
#import "MenuCell.h"

@interface MenuViewController()

@property (nonatomic) NSArray *titles;
@property (nonatomic) NSArray *images;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titles = [[NSArray alloc] initWithObjects:@"Restart", nil];
    self.images = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"restart"], nil];
}

- (void)viewWillLayoutSubviews {
    self.preferredContentSize = CGSizeMake(200, 70);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = (MenuCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MenuCell" forIndexPath:indexPath];
    [cell bindImage:self.images[indexPath.row] Title:self.titles[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if ([self.menuDelegate respondsToSelector:@selector(didSelectRestart)]) {
            [self.menuDelegate didSelectRestart];
        }
    }
}

@end
