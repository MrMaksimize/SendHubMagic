#import "SHMSendHubAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "SHMSendHubAPIConstants.h"

#import "Message.h"
#import "Contact.h"

@implementation SHMSendHubAPIClient


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


- (NSMutableURLRequest *)requestForFetchRequest:(NSFetchRequest *)fetchRequest
                                    withContext:(NSManagedObjectContext *)context
{
    NSMutableURLRequest *request = [super requestForFetchRequest:fetchRequest withContext:context];
    
    NSString *newURLPath = [NSString stringWithFormat:@"%@/?username=%@&api_key=%@", [request.URL absoluteString], kSendHubAPIPhoneNumber, kSendHubAPIKey];
    [request setURL:[NSURL URLWithString:newURLPath]];

    return request;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                       pathForObjectWithID:(NSManagedObjectID *)objectID
                               withContext:(NSManagedObjectContext *)context {

    NSMutableURLRequest *request = [super requestWithMethod:method pathForObjectWithID:objectID withContext:context];

    return request;

}

- (NSMutableURLRequest *)requestForInsertedObject:(NSManagedObject *)insertedObject {
    NSMutableURLRequest *request = [super requestForInsertedObject:insertedObject];

    NSString *newURLPath = [NSString stringWithFormat:@"%@/?username=%@&api_key=%@", [request.URL absoluteString], kSendHubAPIPhoneNumber, kSendHubAPIKey];
    [request setURL:[NSURL URLWithString:newURLPath]];

    return request;
}

- (NSDictionary *)representationOfAttributes:(NSDictionary *)attributes
                             ofManagedObject:(NSManagedObject *)managedObject
{
    NSMutableDictionary *representation = [NSMutableDictionary dictionaryWithDictionary:
                                           [super representationOfAttributes:attributes ofManagedObject:managedObject]];
    if ([managedObject.entity.name isEqualToString:@"Message"]) {
       // TODO - idk if it's good practice to use the Core Data model here.
        Message *message = (Message *)managedObject;
        NSArray *contactsArray = [message.contacts allObjects];
        NSMutableArray *contactsToSend = [[NSMutableArray alloc] init];
        for (Contact* contact in contactsArray) {
            //TODO see if I can use object_id instead of storing the id string directly.
            [contactsToSend addObject:contact.id_str];
        }
        [representation setObject:contactsToSend forKey:@"contacts"];
    }

    return representation;
}

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
    //return [[[objectID entity] name] isEqualToString:@"Contact"];
    return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
                               forObjectWithID:(NSManagedObjectID *)objectID
                        inManagedObjectContext:(NSManagedObjectContext *)context
{
    // We're not fetching remote relationships yet.
    //return [[[objectID entity] name] isEqualToString:@"Contact"];
    return NO;
}


@end
