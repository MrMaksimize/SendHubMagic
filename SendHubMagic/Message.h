//
//  Message.h
//  SendHubMagic
//
//  Created by Maksim Pecherskiy on 8/31/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * id_str;
@property (nonatomic, retain) NSSet *contacts;

-(id)initWithContacts:(NSSet *)contacts andBodyText:(NSString *)bodyText inManagedObjectContext:(NSManagedObjectContext *)context;
@end

@interface Message (CoreDataGeneratedAccessors)

- (void)addContactsObject:(Contact *)value;
- (void)removeContactsObject:(Contact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

@end
