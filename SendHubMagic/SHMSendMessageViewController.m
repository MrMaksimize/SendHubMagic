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


#pragma mark - View LifeCycle

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

#pragma mark - UI Ops

- (IBAction)didPressButton:(id)sender
{
    // Using button to send a message rather than Done on keyboard since it's more natural.
    if (sender == self.sendMessageButton) {
        [self.messageBodyTextView resignFirstResponder];

        if (self.messageBodyTextView.text == nil || [self.messageBodyTextView.text isEqualToString:@""]) {
            // Yeah we could've totally done w/o the abstraction,
            // but this is a view that might have more than 1 thing happening.
            [self.messageBodyTextView setBackgroundColor:[UIColor redColor]];
            [self showMessageLabelWithMessage:@"Hey, I'm not sending a blank message!" andColor:[UIColor redColor]];
        }
        else {
            [self saveAndSendMessage];
        }

    }
}

// Resign first responder when user touches somewhere else.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.messageBodyTextView resignFirstResponder];
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
    [self.messageBodyTextView setBackgroundColor:[UIColor cyanColor]];
    [self.messageLabel setText:@""];
    [self.messageLabel setHidden:YES];
}

#pragma mark - Message Saving and Sending

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
        [self showMessageLabelWithMessage:@"Error Sending Message" andColor:[UIColor redColor]];
    }
    else {
        [self showMessageLabelWithMessage:@"Message is on the way!" andColor:[UIColor blueColor]];
    }

}

#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == self.messageBodyTextView && [textView.text isEqualToString:@"Send Message"]) {
        [self.messageBodyTextView setText:@""];
    }
    // Could live without abstraction here, but better to have it.
    [self hideMessageLabelAndClearState];
}


@end
