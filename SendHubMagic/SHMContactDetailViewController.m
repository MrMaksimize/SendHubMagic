//
//  SHMContactDetailViewController.m
//  SendHubMagic
//
//  Created by Maksim Pecherskiy on 8/31/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SHMContactDetailViewController.h"
#import "SHMSendMessageViewController.h"

#import "Contact.h"

@interface SHMContactDetailViewController ()

@end

@implementation SHMContactDetailViewController {
    Contact *contact;
    BOOL createMode;

    NSManagedObjectContext *_managedObjectContext;
}

- (id)initWithContactOrNil:(Contact *)contactOrNil
{
    // We can initialize with no contact in the use case of being able to create one.
    self = [super init];
    if (!self) {
        return nil;
    }

    // Set up MOC.
    _managedObjectContext = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];

    if (!contactOrNil) {
        createMode = YES;
        self.title = @"Add A New Contact";
    }
    else {
        createMode = NO;
        contact = contactOrNil;
        self.title = contact.name;
    }
    // We already have phone number and name of the contact which is all we need for this screen.
    // However, if we wanted to get the full contact record, say at contacts/123, we can do a core data
    // fetch here.

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!createMode) {
        [self.nameTextField setText:contact.name];
        [self.phoneTextField setText:contact.phoneNumber];
        [self.messageButton setHidden:NO];
    }
    // Add save button to Navbar programmatically.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveContactEntry:)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressButton:(id)sender
{
    if (sender == self.messageButton) {
        SHMSendMessageViewController *sendMessageViewController = [[SHMSendMessageViewController alloc] initWithContact:contact];
        [self.navigationController pushViewController:sendMessageViewController animated:YES];
    }
}

- (void)saveContactEntry:(id)sender
{
    if (contact && !createMode) {
        [contact setName:self.nameTextField.text];
        [contact setPhoneNumber:self.phoneTextField.text];
        if ([contact hasChanges]) {
            NSError *error = nil;
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Error: %@", error);
            }
        }
    }
}

@end
