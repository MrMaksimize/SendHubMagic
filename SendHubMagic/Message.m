//
//  Message.m
//  SendHubMagic
//
//  Created by Maksim Pecherskiy on 8/31/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "Message.h"
#import "Contact.h"


@implementation Message

@dynamic text;
@dynamic id_str;
@dynamic contacts;

-(id)initWithContacts:(NSSet *)contacts andBodyText:(NSString *)bodyText inManagedObjectContext:(NSManagedObjectContext *)context {
    self = [self initWithEntity:[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context] insertIntoManagedObjectContext:nil];
    if (!self) {
        return nil;
    }
    self.text = bodyText;
    self.id_str = nil;
    [self addContacts:contacts];

    return self;
}

@end
