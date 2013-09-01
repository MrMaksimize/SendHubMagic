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

//Regex validates US #'s with leading 1

static NSString * const kPhoneNumberRegexString = @"^(?:\\+?1[-. ]?)?\\(?([2-9][0-8][0-9])\\)?[-. ]?([2-9][0-9]{2})[-. ]?([0-9]{4})$";

@interface SHMContactDetailViewController ()

@end

@implementation SHMContactDetailViewController {
    Contact *contact;
    BOOL createMode;

    NSManagedObjectContext *_managedObjectContext;
}

#pragma mark - View LifeCycle

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
    // TODO - deal with the + in the phone number.  People dont want to enter that by themselves.
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

#pragma mark - UI Ops

// Resign first responder when user touches somewhere else.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.phoneTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
}

- (IBAction)didPressButton:(id)sender
{
    if (sender == self.messageButton) {
        SHMSendMessageViewController *sendMessageViewController = [[SHMSendMessageViewController alloc] initWithContact:contact];
        [self.navigationController pushViewController:sendMessageViewController animated:YES];
    }
}


- (void)showMessageLabelWithMessage:(NSString *)message andColor:(UIColor *)color
{
    // Hide first in case it was displayed before.
    [self.messageLabel setHidden:YES];
    [self.messageLabel setText:message];
    [self.messageLabel setTextColor:color];
    [self.messageLabel setHidden:NO];
}

- (void)hideMessageLabelAndClearState
{
    // TODO DRY
    // Bring back the form to clean state.
    [self.phoneTextField setBackgroundColor:[UIColor whiteColor]];
    [self.nameTextField setBackgroundColor:[UIColor whiteColor]];
    [self.messageLabel setText:@""];
    [self.messageLabel setHidden:YES];

}

#pragma mark - Contact Saving

- (void)saveContactEntry:(id)sender
{
    if (contact && !createMode) {
        [contact setName:self.nameTextField.text];
        [contact setPhoneNumber:self.phoneTextField.text];
        if ([contact hasChanges]) {
            NSError *error = nil;
            // TODO - this does not reflect AFIS errors, need to reflect those.
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Error: %@", error);
                [self showMessageLabelWithMessage:@"Error Saving" andColor:[UIColor redColor]];
            }
            else {
                [self showMessageLabelWithMessage:@"Successfully Saved" andColor:[UIColor blueColor]];
            }
        }
    }
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self hideMessageLabelAndClearState];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (![self textFieldHasValidatedInput:textField]) {
        [textField setBackgroundColor:[UIColor redColor]];
        [self showMessageLabelWithMessage:@"Please Fix The Fields In Red" andColor:[UIColor redColor]];
    }
}


#pragma mark - UITextField Delegate Helpers.

-(BOOL)textFieldHasValidatedInput:(UITextField *)textField
{
    // Empty text fields are a no go either way.
    if (textField.text == nil || [textField.text isEqualToString:@""]) {
        return NO;
    }
    // Check phone #
    if (textField == self.phoneTextField) {
        NSError *error = NULL;

        // TODO review this
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:kPhoneNumberRegexString options:0 error:&error];

        NSArray *matches = [regex matchesInString:self.phoneTextField.text options:0 range:NSMakeRange(0, [self.phoneTextField.text length])];

        if (!matches || [matches count] == 0) {
            return NO;
        }
    }

    // Always assume good things about people.
    return YES;
}

@end
