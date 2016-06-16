//
//  DetailContactViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 15/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "DetailContactViewController.h"
#import "FaceCollectionViewCell.h"
#import "FaceContact.h"

@interface DetailContactViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionview;
@property (nonatomic, strong) NSMutableArray *frames;
@end

@implementation DetailContactViewController

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.frames = [NSMutableArray new];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id = %@", self.contact.key];
    RLMResults<FaceContact *> *facesContact = [FaceContact objectsWithPredicate:pred];
    
    for (FaceContact *currentFace in facesContact) {
        [self.frames addObject:currentFace];
    }

    self.collectionview.showsHorizontalScrollIndicator = false;
    [self.collectionview registerNib:[UINib nibWithNibName:@"FaceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    self.collectionview.dataSource = self;
    self.collectionview.delegate = self;
    self.labelName.text = self.contact.name;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.frames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FaceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    FaceContact *face = [self.frames objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithData:face.imageData];
    [cell configureWithImage:image];
    return cell;
}

@end
