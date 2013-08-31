#import "AFHTTPClient.h"

@interface SHMSendHubAPIClient : AFHTTPClient
+ (SHMSendHubAPIClient *)sharedClient;

@end
