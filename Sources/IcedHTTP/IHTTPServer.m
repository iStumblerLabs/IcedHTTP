#import "IHTTPServer.h"

#import "IHTTPConstants.h"
#import "IHTTPHandler.h"
#import "IHTTPRequest.h"
#import "IHTTPResponse.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <Network/Network.h>


@class IHTTPServerTask;

NSString * const IHTTPServerStateChangedNotification = @"IHTTPServerStateChangedNotification";

// MARK: -

@interface IHTTPServer () <IHTTPRequestDelegate, IHTTPResponseDelegate>
@property(nonatomic, assign) IHHTPServerState serverStateStorage;
@property(nonatomic, assign) nw_endpoint_t networkListener;
@property(nonatomic, retain) NSMutableArray* handlerPrototypesStorage;
@property(nonatomic, retain) NSMutableSet* serverRequestsStorage;
@property(nonatomic, retain) NSError* serverErrorStorage;

- (void)setServerError:(NSError*) anError;

// TODO remove
@property(nonatomic, retain) NSFileHandle* listeningHandle;
@property(nonatomic, assign) CFSocketRef serverSocket;

@end

// MARK: -

@implementation IHTTPServer

+ (IHTTPServer *)sharedIHTTPServer {
    static IHTTPServer* sharedIHTTPServer = nil;
	@synchronized(self) {
		if (sharedIHTTPServer == nil) {
			sharedIHTTPServer = [IHTTPServer new];
		}
	}
	
	return sharedIHTTPServer;
}

+ (IHTTPServer*) serverOnPort:(NSUInteger)serverPort {
    IHTTPServer* server = IHTTPServer.new;
    server.serverPort = serverPort;
    return server;  
}

// MARK: -

- (id)init {
	if ((self = super.init)) {
        self.serverPort = IHTTPDefaultPort;
		self.serverStateStorage = IHTTPServerStateIdle;
        self.loggingLevel = IHTTPServerLoggingErrors;
        [self resetPrototypes];
	}
	return self;
}

// MARK: - Properties

- (NSArray*) handlerPrototypes {
    return [NSArray arrayWithArray:self.handlerPrototypesStorage];
}

- (IHHTPServerState) serverState {
    return self.serverStateStorage;
}

- (void)setServerState:(IHHTPServerState)newState {
	if (self.serverStateStorage == newState) {
		return;
	}

	self.serverStateStorage = newState;
	
	[NSNotificationCenter.defaultCenter postNotificationName:IHTTPServerStateChangedNotification object:self];
}

- (NSError*)serverError {
    return self.serverErrorStorage;
}

- (void)setServerError:(NSError*) anError {
	self.serverErrorStorage = anError;
	
	if (self.serverErrorStorage) {
        [self stopServer];
        
        self.serverState = IHTTPServerStateIdle;
        
        if (self.loggingLevel >= IHTTPServerLoggingErrors) {
            NSLog(@"%@ error: %@", NSStringFromClass([self class]), self.serverErrorStorage);
        }
	}
}

- (NSURL*) rootURL {
    // TODO get the .local hostname
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%lu/", (unsigned long)self.serverPort]];
}

// MARK: - Prototype Registry

- (void)registerHandler:(IHTTPHandler *)prototype {
	[self.handlerPrototypesStorage insertObject:prototype atIndex:0];

    if (self.loggingLevel >= IHTTPServerLoggingDebug) {
        NSLog(@"%@ registerPrototype: %@", NSStringFromClass([self class]), prototype);
    }
}

- (IHTTPHandler *)prototypeForRequest:(IHTTPRequest *)request {
    for (IHTTPHandler* prototype in self.handlerPrototypes) {
        if ([prototype canHandleRequest:request]) {
            return prototype;
        }
    }
    return nil;
}

- (void)resetPrototypes {
    self.handlerPrototypesStorage = [NSMutableArray new];
    
    [self registerHandler:[IHTTPHandler handlerWithResponseBlock:^NSUInteger(IHTTPRequest *request, IHTTPResponse *response) {
        NSUInteger errorStatus = IHTTPStatus501NotImplemented;
        [response sendStatus:errorStatus];
        [response completeResponse];
        return errorStatus;
    }]];
    
    if (self.loggingLevel >= IHTTPServerLoggingDebug) {
        NSLog(@"%@ resetPrototypes", NSStringFromClass([self class]));
    }
}

// MARK: -

- (void)startServer {
    CFDataRef addressData = nil;
    
    if ((self.serverState != IHTTPServerStateStarting) && (self.serverState != IHTTPServerStateRunning)) {
        self.serverErrorStorage = nil;
        self.serverStateStorage = IHTTPServerStateStarting;
        self.serverRequestsStorage = [NSMutableSet new];
        
        if (self.loggingLevel >= IHTTPServerLoggingDebug) {
            NSLog(@"%@ startServer", NSStringFromClass([self class]));
        }
        
        self.serverSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, 0, NULL, NULL);
        if (!self.serverSocket) {
            [self errorWithName:@"Unable to create socket."];
            return;
        }

        int reuse = true;
        int fileDescriptor = CFSocketGetNative(self.serverSocket);
        if (setsockopt(fileDescriptor, SOL_SOCKET, SO_REUSEADDR,
            (void *)&reuse, sizeof(int)) != 0) {
            [self errorWithName:@"Unable to set socket options."];
            return;
        }
        
        struct sockaddr_in address;
        memset(&address, 0, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;
        address.sin_addr.s_addr = htonl(INADDR_ANY);
        address.sin_port = htons(self.serverPort);
        CFDataRef addressData = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)&address, sizeof(address));
        
        if (CFSocketSetAddress(self.serverSocket, addressData) != kCFSocketSuccess) {
            [self errorWithName:@"Unable to bind socket to address."];
            goto exit;
        }

        self.listeningHandle = [NSFileHandle.alloc initWithFileDescriptor:fileDescriptor closeOnDealloc:YES];

        [NSNotificationCenter.defaultCenter
            addObserver:self
            selector:@selector(receiveIncomingConnectionNotification:)
            name:NSFileHandleConnectionAcceptedNotification
            object:nil];
        [self.listeningHandle acceptConnectionInBackgroundAndNotify];
        
        self.serverState = IHTTPServerStateRunning;
    }
    else if (self.loggingLevel >= IHTTPServerLoggingWarnings) {
        NSLog(@"%@ warning can't startServer in state: %lu", NSStringFromClass([self class]), (unsigned long)self.serverState);
    }

exit:
    if (addressData) {
        CFRelease(addressData);
    }
}

- (void)stopServer {
	self.serverState = IHTTPServerStateStopping;

    if (self.loggingLevel >= IHTTPServerLoggingDebug) {
        NSLog(@"%@ stopServer", NSStringFromClass([self class]));
    }

    // stop listening
	[self.listeningHandle closeFile];
	self.listeningHandle = nil;

	[NSNotificationCenter.defaultCenter
		removeObserver:self
		name:NSFileHandleConnectionAcceptedNotification
		object:nil];

    // complete all serverTasks
    for (IHTTPRequest* request in self.serverRequests) {
        [request.input closeFile];
    }
    [self.serverRequestsStorage removeAllObjects];
    self.serverRequestsStorage = nil;


	if (self.serverSocket) {
		CFSocketInvalidate(self.serverSocket);
		// CFRelease(self.serverSocket);
		self.serverSocket = nil;
	}

	self.serverState = IHTTPServerStateIdle;
}

// MARK: -

- (void)errorWithName:(NSString *)errorName {
	self.serverError = [NSError errorWithDomain:@"IHTTPServerError" code:0 userInfo:@{
        NSLocalizedDescriptionKey: NSLocalizedStringFromTable(errorName, @"", @"IHTTPServerErrors")
    }];
}

// MARK: -

- (void)receiveIncomingConnectionNotification:(NSNotification *)notification {
	NSDictionary* userInfo = [notification userInfo];
	NSFileHandle* requestHandle = [userInfo objectForKey:NSFileHandleNotificationFileHandleItem];

    if (requestHandle) {
        IHTTPRequest* request = [IHTTPRequest requestWithInput:requestHandle];
        request.delegate = self;
        [self.serverRequestsStorage addObject:request];
        [request readHeaders]; // set the handler when the header read is complete
        
        if (self.loggingLevel >= IHTTPServerLoggingDebug) {
            NSLog(@"%@ incoming request at %@", NSStringFromClass([self class]), request.requestTime);
        }
    }
    
    // wait for the next connection
	[self.listeningHandle acceptConnectionInBackgroundAndNotify];
}

// MARK: - IHTTPRequestDelegate

- (void) request:(IHTTPRequest*) request parsedHeaders:(NSDictionary*) headers {
    // NSLog(@"request:%@ parsedHeaders:%@", request, headers);
    IHTTPHandler* prototype = [self prototypeForRequest:request];
    IHTTPHandler* handler = [prototype handlerForRequest:request];
    IHTTPResponse* response = [IHTTPResponse responseWithOutput:request.input];
    response.delegate = self;

    if (self.loggingLevel >= IHTTPServerLoggingRequests) {
        NSLog(@"%@ request: %@", NSStringFromClass([self class]), request);
    }

    [handler handleRequest:request withResponse:response];
    
    if (self.loggingLevel >= IHTTPServerLoggingResponses) {
        NSLog(@"%@ response: %@ handler: %@ ", NSStringFromClass([self class]), response, handler);
    }
}

// MARK: - IHTTPResponseDelegate

- (void) responseDidComplete:(IHTTPResponse *)response {
    for (IHTTPRequest* request in self.serverRequests) {
        if (response.output == request.input) {
            // NSLog(@"responseDidComplete:%@ sentHeaders:%@", response, response.responseHeaders);
            [request completeRequest];
            [self.serverRequestsStorage removeObject:request];

            if (self.loggingLevel >= IHTTPServerLoggingResponses) {
                NSLog(@"%@ complete: %@", NSStringFromClass([self class]), response);
            }

            return;
        }
    }
}

@end
