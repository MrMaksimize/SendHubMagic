#import "SHMSendHubAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "SHMSendHubAPIConstants.h"

#import "Message.h"
#import "Contact.h"

@implementation SHMSendHubAPIClient

#pragma mark - Initialization

// Creates a single instance
+ (instancetype)sharedClient {
    static SHMSendHubAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kSendHubAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"Content-Type" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    return self;
}

#pragma mark - Request Modifiers

- (NSMutableURLRequest *)requestForFetchRequest:(NSFetchRequest *)fetchRequest
                                    withContext:(NSManagedObjectContext *)context
{
    NSMutableURLRequest *request = [super requestForFetchRequest:fetchRequest withContext:context];

    [request setURL:[self modifiedURLForRequest:request]];

    return request;
}


- (NSMutableURLRequest *)requestForInsertedObject:(NSManagedObject *)insertedObject
{
    NSMutableURLRequest *request = [super requestForInsertedObject:insertedObject];
    [request setURL:[self modifiedURLForRequest:request]];

    return request;
}


- (NSMutableURLRequest *)requestForUpdatedObject:(NSManagedObject *)updatedObject
{
    NSMutableURLRequest *request = [super requestForUpdatedObject:updatedObject];

    [request setURL:[self modifiedURLForRequest:request]];

    return request;
}

- (NSURL *)modifiedURLForRequest:(NSMutableURLRequest *)request
{
    NSString *newURLPath = [NSString stringWithFormat:@"%@/?username=%@&api_key=%@", [request.URL absoluteString], kSendHubAPIPhoneNumber, kSendHubAPIKey];

    return [NSURL URLWithString:newURLPath];
}

- (NSDictionary *)representationOfAttributes:(NSDictionary *)attributes
                             ofManagedObject:(NSManagedObject *)managedObject
{
    NSMutableDictionary *representation = [NSMutableDictionary dictionaryWithDictionary:
                                           [super representationOfAttributes:attributes ofManagedObject:managedObject]];

    // Messages.
    if ([managedObject.entity.name isEqualToString:@"Message"]) {
       // TODO - idk if it's good practice to use the Core Data model here.
        Message *message = (Message *)managedObject;
        NSArray *contactsArray = [message.contacts allObjects];
        NSMutableArray *contactsToSend = [[NSMutableArray alloc] init];
        for (Contact* contact in contactsArray) {
            //TODO see if I can use AFIS's id instead of storing the id string directly.
            [contactsToSend addObject:contact.id_str];
        }
        [representation setObject:contactsToSend forKey:@"contacts"];
    }
    // Contacts
    if ([managedObject.entity.name isEqualToString:@"Contact"]) {
        // Transform Phone Number to Number.
        // Also looks like AFIS likes to send update entries only.  For Sendhub, we need all.
        Contact *contact = (Contact *)managedObject;
        [representation setObject:contact.phoneNumber forKey:@"number"];
        [representation setObject:contact.name forKey:@"name"];
        [representation setObject:contact.id_str forKey:@"id"];
    }

    return representation;
}

#pragma mark - Respone Modifiers

- (id)representationOrArrayOfRepresentationsOfEntity:(NSEntityDescription *)entity
                                  fromResponseObject:(id)responseObject {
    // SendHub seems pretty consistent in following the model of nesting the actual response in Objects at least in lists.
    // Let's let AFIS know about that.
    if ([(NSDictionary *)responseObject objectForKey:@"objects"]) {
        return [(NSDictionary *)responseObject objectForKey:@"objects"];
    }
    else {
        return [super representationOrArrayOfRepresentationsOfEntity:entity fromResponseObject:responseObject];
    }
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
                                     ofEntity:(NSEntityDescription *)entity
                                 fromResponse:(NSHTTPURLResponse *)response
{
    NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];
    if ([entity.name isEqualToString:@"Contact"]) {
        NSString *phoneNumber = [representation valueForKey:@"number"];
        [mutablePropertyValues setValue:phoneNumber forKey:@"phoneNumber"];
    }


    return mutablePropertyValues;
}

- (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID
                                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    // We're not fetching remote attributes per contact just yet.
    return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
                               forObjectWithID:(NSManagedObjectID *)objectID
                        inManagedObjectContext:(NSManagedObjectContext *)context
{
    // We're not fetching remote relationships yet.
    return NO;
}


@end
