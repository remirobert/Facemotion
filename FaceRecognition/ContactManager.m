//
//  ContactManager.m
//  FaceRecognition
//
//  Created by Remi Robert on 11/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactManager.h"
#import "ContactModel.h"

@implementation ContactManager

+ (void)fetchContacts:(void (^)(NSArray<ContactModel *> *))completion {
    NSMutableArray<ContactModel *> *contacts = [NSMutableArray new];
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
            NSString *containerId = store.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            if (error) {
                NSLog(@"error fetching contacts %@", error);
                completion(nil);
            }
            else {
                for (CNContact *contact in cnContacts) {
                    [contacts addObject:[[ContactModel alloc] initWithContact:contact]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(contacts);
                });
            }
        }
        else {
            completion(nil);
        }
    }];
}

@end
