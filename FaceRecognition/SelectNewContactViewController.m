//
//  SelectContactViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 12/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "SelectNewContactViewController.h"
#import "ContactManager.h"
#import "FaceContact.h"
#import "Contact.h"

@interface SelectNewContactViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray<ContactModel *> *contacts;
@end

@implementation SelectNewContactViewController

- (void)viewWillAppear:(BOOL)animated {
    RLMResults<Contact *> *localContacts = [Contact allObjects];
    
    [ContactManager fetchContacts:^(NSArray<ContactModel *> *contacts) {
        [self.contacts removeAllObjects];
        
        for (ContactModel *contact in contacts) {
            BOOL exist = false;
            for (Contact *localContact in localContacts) {
                if ([localContact.key isEqualToString:contact.id]) {
                    exist = true;
                    break;
                }
            }
            if (!exist) {
                [self.contacts addObject:contact];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.backgroundColor = [UIColor blackColor];
    self.tableview.tableFooterView = [UIView new];
    
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.contacts = [NSMutableArray new];
}

- (NSInteger)idFace:(ContactModel *)contact {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id = %@", contact.id];
    RLMResults<FaceContact *> *facesContact = [FaceContact objectsWithPredicate:pred];
    
    if (facesContact.count > 0) {
        FaceContact *firstFace = [facesContact objectAtIndex:0];
        return firstFace.idRecognition;
    }
    return [(NSNumber *)[[FaceContact allObjects] maxOfProperty:@"idRecognition"] integerValue] + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Do you want to assign the detected frames to this contact ?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Assign" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ContactModel *contact = [self.contacts objectAtIndex:indexPath.row];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        NSInteger idFace = [self idFace:contact];
        
        Contact *newContact = [Contact new];
        newContact.key = contact.id;
        newContact.name = contact.name;
        newContact.dataImage = UIImageJPEGRepresentation(self.face.faces.firstObject, 1);
    
        NSMutableArray *faces = [NSMutableArray new];
    
        for (UIImage *imageFace in self.face.faces) {
            FaceContact *newFace = [[FaceContact alloc] initWithImage:imageFace idContact:contact.id];
            newFace.idRecognition = idFace;
            [faces addObject:newFace];
        }
        [realm transactionWithBlock:^{
            [realm addObject:newContact];
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
