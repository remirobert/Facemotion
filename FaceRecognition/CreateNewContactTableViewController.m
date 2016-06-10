//
//  CreateNewContactTableViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 10/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "CreateNewContactTableViewController.h"
#import "FaceCollectionViewCell.h"

@interface CreateNewContactTableViewController () <UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionviewFrames;
@property (weak, nonatomic) IBOutlet UITextField *textfieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *textfieldLastName;
@end

@implementation CreateNewContactTableViewController

- (IBAction)saveContact:(id)sender {
    
}

- (IBAction)cancelCreateContact:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.clearsSelectionOnViewWillAppear = NO;
    
    [self.collectionviewFrames registerNib:[UINib nibWithNibName:@"FaceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectionviewFrames.dataSource = self;
    self.collectionviewFrames.showsHorizontalScrollIndicator = false;
    NSLog(@"faces = %d", self.face.faces.count);
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
