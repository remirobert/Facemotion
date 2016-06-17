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
#import "Contact.h"
#import "DetailContactViewController.h"
#import <ZFModalTransitionAnimator.h>

@interface ContactsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) NSMutableArray<Contact *> *contacts;
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@end

@implementation ContactsViewController

- (void)viewWillAppear:(BOOL)animated {
    RLMResults<Contact *> *localContacts = [Contact allObjects];
    
    NSLog(@"local contacts : %@", localContacts);
    [self.contacts removeAllObjects];
    for (Contact *contact in localContacts) {
        [self.contacts addObject:contact];
    }
    [self.collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ContactCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    [self.collectionViewLayout setItemSize: CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) / 3, CGRectGetWidth([UIScreen mainScreen].bounds) / 3)];
    self.collectionViewLayout.minimumLineSpacing = 0;
    self.collectionViewLayout.minimumInteritemSpacing = 0;
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.contacts = [NSMutableArray new];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detailContactSegue"]) {
        
        UIViewController *controller = segue.destinationViewController;
        
        ((DetailContactViewController *)controller).contact = sender;
        
        self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:controller];
        self.animator.dragable = false;
        self.animator.bounces = true;
        self.animator.behindViewAlpha = 0.5f;
        self.animator.behindViewScale = 0.7f;
        self.animator.transitionDuration = 0.75;
        controller.transitioningDelegate = self.animator;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = [self.contacts objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"detailContactSegue" sender:contact];
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
