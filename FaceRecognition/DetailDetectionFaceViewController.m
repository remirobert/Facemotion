//
//  DetailDetectionFaceViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 06/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "DetailDetectionFaceViewController.h"
#import "FaceCollectionViewCell.h"

@interface DetailDetectionFaceViewController () <UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;
@end

@implementation DetailDetectionFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"FaceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectionViewFlowLayout.itemSize = CGSizeMake(128, 128);
    self.collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.dataSource = self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.face.faces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FaceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell configureWithImage:[self.face.faces objectAtIndex:indexPath.row]];
    return cell;
}

@end
