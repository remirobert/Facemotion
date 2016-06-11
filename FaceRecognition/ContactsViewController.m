//
//  ContactsViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 11/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <Realm.h>
#import <Masonry.h>
#import <Contacts/Contacts.h>
#import "ContactsViewController.h"
#import "ContactModel.h"
#import "ContactCollectionViewCell.h"
#import "ContactManager.h"

@interface ContactsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *layerSubView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) NSArray<ContactModel *> *contacts;
@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.layerSubView.backgroundColor = [UIColor clearColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.layerSubView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[[UIColor blackColor] colorWithAlphaComponent:0.8] CGColor], (id)[[UIColor clearColor] CGColor], nil];

    [self.layerSubView.layer insertSublayer:gradient atIndex:0];

    [self.collectionView registerNib:[UINib nibWithNibName:@"ContactCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    [self.collectionViewLayout setItemSize: CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) / 3, CGRectGetWidth([UIScreen mainScreen].bounds) / 3)];
    self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 55, 0);
    self.collectionViewLayout.minimumLineSpacing = 0;
    self.collectionViewLayout.minimumInteritemSpacing = 0;
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.contacts = [NSMutableArray new];
    
    [ContactManager fetchContacts:^(NSArray<ContactModel *> *contacts) {
        self.contacts = contacts;
        [self.collectionView reloadData];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ContactCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSLog(@"cell : %@", cell);
    [cell configure:[self.contacts objectAtIndex:indexPath.row]];
    return cell;
}

@end
