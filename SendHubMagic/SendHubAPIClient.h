#import "AFHTTPClient.h"

@interface SendHubAPIClient : AFHTTPClient

+ (SendHubAPIClient *)sharedClient;

@end
