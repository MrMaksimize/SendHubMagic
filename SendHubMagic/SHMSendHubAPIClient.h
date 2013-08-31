#import "AFRESTClient.h"
#import "AFIncrementalStore.h"

@interface SHMSendHubAPIClient : AFRESTClient
+ (SHMSendHubAPIClient *)sharedClient;

@end
