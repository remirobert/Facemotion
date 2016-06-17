//
//  DetailContactViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 15/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <Realm.h>
#import "DetailContactViewController.h"
#import "FaceCollectionViewCell.h"
#import "FaceContact.h"

@interface DetailContactViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionview;
@property (weak, nonatomic) IBOutlet UILabel *labelFrames;
@property (nonatomic, strong) NSMutableArray *frames;
@property (weak, nonatomic) IBOutlet UILabel *labelNumberProcess;
@property (weak, nonatomic) IBOutlet UIButton *buttonRemoveContact;
@end

@implementation DetailContactViewController

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)removeContact:(id)sender {
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id = %@", self.contact.key];
    RLMResults<FaceContact *> *facesContact = [FaceContact objectsWithPredicate:pred];
    
    [realm deleteObject:self.contact];
    [realm deleteObjects:facesContact];
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttonRemoveContact.layer.cornerRadius = 15;
    self.buttonRemoveContact.layer.masksToBounds = true;
    self.buttonRemoveContact.layer.borderColor = [[UIColor colorWithRed:0.74 green:0.12 blue:0.24 alpha:1.00] CGColor];
    self.buttonRemoveContact.layer.borderWidth = 2;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.frames = [NSMutableArray new];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id = %@", self.contact.key];
    RLMResults<FaceContact *> *facesContact = [FaceContact objectsWithPredicate:pred];
    
    for (FaceContact *currentFace in facesContact) {
        [self.frames addObject:currentFace];
    }
    
    self.labelFrames.text = [NSString stringWithFormat:@"Frames (%lu)", (unsigned long)self.frames.count];

    self.collectionview.showsHorizontalScrollIndicator = false;
    [self.collectionview registerNib:[UINib nibWithNibName:@"FaceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    
    self.labelNumberProcess.text = [NSString stringWithFormat:@"Count process : %ld", (long)self.contact.numberRecogition];
    
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
