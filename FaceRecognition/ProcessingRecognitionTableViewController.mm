//
//  ProcessingRecognitionTableViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 12/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "ProcessingRecognitionTableViewController.h"
#import "FaceCollectionViewCell.h"
#import "FaceRecognition.h"
#import "FaceContact.h"
#import "ContactManager.h"
#import "SelectContactViewController.h"

@interface ProcessingRecognitionTableViewController () <UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelConfidence;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionviewFrames;
@property (weak, nonatomic) IBOutlet UILabel *nameResult;
@property (weak, nonatomic) IBOutlet UIImageView *imageviewResult;
@end

@implementation ProcessingRecognitionTableViewController

- (IBAction)cancelRecognition:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;

    [self.collectionviewFrames registerNib:[UINib nibWithNibName:@"FaceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectionviewFrames.delegate = self;
    self.collectionviewFrames.dataSource = self;

    RLMResults<FaceContact *> *contactsFace = [FaceContact allObjects];
    NSMutableArray<FaceContact *> *contacts = [NSMutableArray new];
    for (NSInteger index = 0; index < contactsFace.count; index++) {
        [contacts addObject:[contactsFace objectAtIndex:index]];
    }
    if (contactsFace.count > 0) {
        RecognitionResult *result = [FaceRecognition recognitionFace:contacts face:[self.face.faces firstObject]];
        FaceContact *contact = result.contact;

        self.labelConfidence.text = [NSString stringWithFormat:@"confidence : %f", result.confidence];
        [ContactManager fetchWithId:contact.id completion:^(ContactModel *contact) {
            self.nameResult.text = contact.name;
            
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"id = %@", contact.id];
            RLMResults<FaceContact *> *facesContact = [FaceContact objectsWithPredicate:pred];
            
            if (facesContact.count > 0) {
                FaceContact *firstFace = [facesContact objectAtIndex:0];
                UIImage *image = [UIImage imageWithData:firstFace.imageData];
                self.imageviewResult.image = image;
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectContactSegue"]) {
        ((SelectContactViewController *)segue.destinationViewController).face = self.face;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        [self performSegueWithIdentifier:@"selectContactSegue" sender:nil];
    }
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
