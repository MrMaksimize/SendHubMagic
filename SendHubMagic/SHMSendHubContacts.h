//
//  SHMSendHubContacts.h
//  SendHubMagic
//
//  Created by Maksim Pecherskiy on 8/31/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHMSendHubAPIClient.h"

@interface SHMSendHubContacts : NSObject
+ (void)getContactsListWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

@end
