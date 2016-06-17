//
//  SelectContactViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 15/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <Realm.h>
#import "SelectContactViewController.h"
#import "FaceContact.h"
#import "Contact.h"
#import "ContactCollectionViewCell.h"

@interface SelectContactViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlow;
@property (nonatomic, strong) NSMutableArray<Contact *> *contacts;
@end

@implementation SelectContactViewController

- (void)viewWillAppear:(BOOL)animated {
    RLMResults<Contact *> *localContacts = [Contact allObjects];
    
    [self.contacts removeAllObjects];
    for (Contact *contact in localContacts) {
        [self.contacts addObject:contact];
    }
    [self.collectionView reloadData];
}

- (NSInteger)idFace:(Contact *)contact {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id = %@", contact.key];
    RLMResults<FaceContact *> *facesContact = [FaceContact objectsWithPredicate:pred];
    
    if (facesContact.count > 0) {
        FaceContact *firstFace = [facesContact objectAtIndex:0];
        return firstFace.idRecognition;
    }
    return [(NSNumber *)[[FaceContact allObjects] maxOfProperty:@"idRecognition"] integerValue] + 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Select a contact";
    
    self.contacts = [NSMutableArray new];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ContactCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionViewFlow setItemSize: CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) / 3, CGRectGetWidth([UIScreen mainScreen].bounds) / 3)];
    self.collectionViewFlow.minimumLineSpacing = 0;
    self.collectionViewFlow.minimumInteritemSpacing = 0;
    self.collectionViewFlow.scrollDirection = UICollectionViewScrollDirectionVertical;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    Contact *selectedContact = [self.contacts objectAtIndex:indexPath.row];
    NSInteger idFace = [self idFace:selectedContact];
    
    NSMutableArray *faces = [NSMutableArray new];
    for (UIImage *imageFace in self.face.faces) {
        FaceContact *newFace = [[FaceContact alloc] initWithImage:imageFace idContact:selectedContact.key];
        newFace.idRecognition = idFace;
        [faces addObject:newFace];
    }
    [realm transactionWithBlock:^{
        [realm addObjects:faces];
    }];
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ContactCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    Contact *contact = [self.contacts objectAtIndex:indexPath.row];
    [cell configure:contact];
    return cell;
}

@end
