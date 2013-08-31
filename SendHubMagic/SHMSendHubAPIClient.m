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

@end
