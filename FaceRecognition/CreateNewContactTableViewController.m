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
    if (self.textfieldLastName.text == nil || self.textfieldFirstName.text == nil) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please fill the form to add a new contact." message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:true completion:nil];
        return ;
    }
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
