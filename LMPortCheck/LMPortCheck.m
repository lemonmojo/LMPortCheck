#import "LMPortCheck.h"
#import "GCDAsyncSocket.h"

@interface LMPortCheck () <GCDAsyncSocketDelegate>

@property (nonatomic, copy) NSString* host;
@property (nonatomic, readwrite) uint16_t port;
@property (nonatomic, readwrite) NSTimeInterval timeout;
@property (nonatomic, copy) LMPortCheckCompletionHandler completionHandler;

@property (nonatomic, strong) GCDAsyncSocket* sock;

@end

@implementation LMPortCheck

+ (NSMutableArray<LMPortCheck*>*)currentPortChecks
{
    static NSMutableArray* _currentPortChecks;
    static dispatch_once_t onceToken;
	
    dispatch_once(&onceToken, ^{
		_currentPortChecks = NSMutableArray.array;
    });
	
    return _currentPortChecks;
}

+ (void)connectToHost:(NSString*)host port:(uint16_t)port timeout:(NSTimeInterval)timeout completionHandler:(LMPortCheckCompletionHandler)completionHandler
{
	LMPortCheck* portCheck = [LMPortCheck new];
	portCheck.host = host;
	portCheck.port = port;
	portCheck.timeout = timeout;
	portCheck.completionHandler = completionHandler;
	
	[self.class.currentPortChecks addObject:portCheck];
	
	[portCheck connect];
}

- (void)connect
{
	self.sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
	
	NSError* err;
	
	BOOL success = [self.sock connectToHost:self.host
									 onPort:self.port
								withTimeout:self.timeout
									  error:&err];
	
	if (!success) {
		if (self.completionHandler) {
			self.completionHandler(NO, err);
		}
		
		[self.class.currentPortChecks removeObject:self];
	}
}

- (void)socket:(GCDAsyncSocket*)sock didConnectToHost:(NSString*)host port:(UInt16)port
{
	if (self.completionHandler) {
		self.completionHandler(YES, nil);
	}
	
	[sock disconnect];
}

- (void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError*)err
{
	if (err) {
		if (self.completionHandler) {
			self.completionHandler(NO, err);
		}
	}
	
	[self.class.currentPortChecks removeObject:self];
}

@end
