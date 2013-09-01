//
//  SHMSendMessageViewController.m
//  SendHubMagic
//
//  Created by Maksim Pecherskiy on 8/31/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "SHMSendMessageViewController.h"

#import "Contact.h"
#import "Message.h"

@interface SHMSendMessageViewController ()

@end

@implementation SHMSendMessageViewController {
    Contact *contact;

    NSManagedObjectContext *_managedObjectContext;
}

- (id)initWithContact:(Contact *)initialContact
{
    // We can initialize with no contact in the use case of being able to create one.
    self = [super init];
    if (!self) {
        return nil;
    }
    
    contact = initialContact;
    self.title = @"Compose";

    _managedObjectContext = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];

    // We already have phone number and name of the contact which is all we need for this screen.
    // However, if we wanted to get the full contact record, say at contacts/123, we can do a core data
    // fetch here as well..
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.sendToLabel setText:contact.name];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressButton:(id)sender
{
    // Using button to send a message rather than Done on keyboard since it's more natural.
    if (sender == self.sendMessageButton) {
        [self.messageBodyTextView resignFirstResponder];
        [self saveAndSendMessage];
    }
}

- (void)saveAndSendMessage
{
    Message *messageToSend = [[Message alloc]
                              initWithContacts:[NSSet setWithObject:contact]
                              andBodyText:self.messageBodyTextView.text
                              inManagedObjectContext:_managedObjectContext];
    
    [_managedObjectContext insertObject:messageToSend];
    
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
    }

}

#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == self.messageBodyTextView && [textView.text isEqualToString:@"Send Message"]) {
        [self.messageBodyTextView setText:@""];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    // TODO for some reason this method never gets called. Come back and fix.  Text View does not resign first responder.
    NSLog(@"TEST");
    return YES;
}

@end
