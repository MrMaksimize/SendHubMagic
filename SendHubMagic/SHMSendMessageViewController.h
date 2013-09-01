//
//  SHMSendMessageViewController.h
//  SendHubMagic
//
//  Created by Maksim Pecherskiy on 8/31/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contact;
@class Message;

@interface SHMSendMessageViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextView *messageBodyTextView;
@property (nonatomic, strong) IBOutlet UILabel *sendToLabel;
@property (nonatomic, strong) IBOutlet UIButton *sendMessageButton;

- (id)initWithContact:(Contact *)initialContact;
- (IBAction)didPressButton:(id)sender;

@end
