#import "SHMSendHubAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "SHMSendHubAPIConstants.h"

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
    
    return self;
}

- (void)sendAuthedRequestWithPath:(NSString*)path
                            method:(NSString*)method
                            params:(NSDictionary*)params
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    
    NSString *requestPath = [NSString stringWithFormat:
                             @"%@/%@?username=%@&api_key=%@",
                             kSendHubAPIBaseURLString,
                             path,
                             kSendHubAPIPhoneNumber,
                             kSendHubAPIKey];

    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:requestPath]];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}


- (NSMutableURLRequest *)requestForFetchRequest:(NSFetchRequest *)fetchRequest
                                    withContext:(NSManagedObjectContext *)context
{
    NSMutableURLRequest *request = [super requestForFetchRequest:fetchRequest withContext:context];

    NSLog(@"stop");
    // Whatever AFIS decides our request should look like, we know we have to append the ?username and ?api_key params to the url.
    NSString *newURLPath = [NSString stringWithFormat:@"%@/?username=%@&api_key=%@", [request.URL absoluteString], kSendHubAPIPhoneNumber, kSendHubAPIKey];
    [request setURL:[NSURL URLWithString:newURLPath]];

    return request;
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
