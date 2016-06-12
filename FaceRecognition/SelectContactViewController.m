//
//  SelectContactViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 12/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "SelectContactViewController.h"
#import "ContactManager.h"
#import "FaceContact.h"

@interface SelectContactViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSArray<ContactModel *> *contacts;
@end

@implementation SelectContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.backgroundColor = [UIColor blackColor];
    self.tableview.tableFooterView = [UIView new];
    
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    [ContactManager fetchContacts:^(NSArray<ContactModel *> *contacts) {
        self.contacts = contacts;
        [self.tableview reloadData];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Do you want to assign the detected frames to this contact ?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Assign" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ContactModel *contact = [self.contacts objectAtIndex:indexPath.row];
        NSMutableArray *faces = [NSMutableArray new];
        for (UIImage *imageFace in self.face.faces) {
            FaceContact *newFace = [[FaceContact alloc] initWithImage:imageFace idContact:contact.id];
            [faces addObject:newFace];
        }
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addObjects:faces];
        }];
        [self.navigationController dismissViewControllerAnimated:true completion:nil];
    }]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    ContactModel *contact = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = contact.name;
    cell.textLabel.textColor = [UIColor whiteColor];

    return cell;
}

@end
