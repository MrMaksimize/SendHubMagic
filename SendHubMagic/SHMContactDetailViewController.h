//
//  SHMContactDetailViewController.h
//  SendHubMagic
//
//  Created by Maksim Pecherskiy on 8/31/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contact;

@interface SHMContactDetailViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *phoneTextField;
@property (nonatomic, strong) IBOutlet UIButton *messageButton;

- (id)initWithContactOrNil:(Contact *)contactOrNil;
- (IBAction)didPressButton:(id)sender;
@end
