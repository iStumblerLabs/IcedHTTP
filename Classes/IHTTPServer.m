//
//  HTTPServer.m
//  TextTransfer
//
//  Created by Matt Gallagher on 2009/07/13.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
//  Portions Copyright © 2016 Alf Watt. Available under MIT License (MIT) in README.md
//

#import "IHTTPServer.h"
#import <sys/socket.h>
#import <netinet/in.h>

#import "IHTTPRequest.h"
#import "IHTTPResponse.h"
#import "IHTTPHandler.h"

@class IHTTPServerTask;

NSUInteger const IHTTPServerDefaultPort = 8080;
NSString * const IHTTPServerStateChangedNotification = @"IHTTPServerStateChangedNotification";

#pragma mark -

@implementation IHTTPServer
{
	CFSocketRef serverSocket;
    IHTTPServerState serverState;
    NSError* serverError;
}

#pragma mark -

+ (IHTTPServer *)sharedIHTTPServer
{
    static IHTTPServer* sharedIHTTPServer = nil;
	@synchronized(self) {
		if (sharedIHTTPServer == nil) {
			sharedIHTTPServer = [IHTTPServer new];
		}
	}
	
	return sharedIHTTPServer;
}

#pragma mark -

- (id)init
{
	self = [super init];
	if (self != nil) {
        self.serverPort = IHTTPServerDefaultPort;
		self.serverState = IHTTPServerStateIdle;
        self.handlerPrototypes = [NSMutableArray new];
	}
	return self;
}

#pragma mark - Properties

- (IHTTPServerState) serverState
{
    return serverState;
}

- (void)setServerState:(IHTTPServerState)newState
{
	if (serverState == newState) {
		return;
	}

	serverState = newState;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:IHTTPServerStateChangedNotification object:self];
}

- (NSError*)serverError
{
    return serverError;
}

- (void)setServerError:(NSError*) anError
{
	serverError = anError;
	
	if (serverError == nil) {
		return;
	}
	
	[self stopServer];
	
	self.serverState = IHTTPServerStateIdle;
	NSLog(@"HTTPServer error: %@", serverError);
}

#pragma mark - Prototype Registory

- (void)registerPrototype:(IHTTPHandler *)prototype
{
	[self.handlerPrototypes addObject:prototype];
}

- (IHTTPHandler *)prototypeForRequest:(IHTTPRequest *)request
{
    for (IHTTPHandler* prototype in self.handlerPrototypes) {
        if ([prototype canHandleRequest:request]) {
            return prototype;
        }
    }
    return nil;
}

#pragma mark -

- (void)startServer
{
	self.serverError = nil;
	self.serverState = IHTTPServerStateStarting;
    self.serverRequests = [NSMutableSet new];
    
    [self registerPrototype:[IHTTPHandler handlerWithResponseBlock:^NSUInteger(IHTTPRequest *request, IHTTPResponse *response) {
        NSUInteger error = 404;
        [response sendStatus:404];
        [response completeResponse];
        return error;
    }]];

	serverSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, 0, NULL, NULL);
	if (!serverSocket) {
		[self errorWithName:@"Unable to create socket."];
		return;
	}

	int reuse = true;
	int fileDescriptor = CFSocketGetNative(serverSocket);
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
	
	if (CFSocketSetAddress(serverSocket, addressData) != kCFSocketSuccess) {
		[self errorWithName:@"Unable to bind socket to address."];
		goto exit;
	}

	self.listeningHandle = [[NSFileHandle alloc] initWithFileDescriptor:fileDescriptor closeOnDealloc:YES];

	[[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(receiveIncomingConnectionNotification:)
        name:NSFileHandleConnectionAcceptedNotification
        object:nil];
	[self.listeningHandle acceptConnectionInBackgroundAndNotify];
	
	self.serverState = IHTTPServerStateRunning;

exit:
    CFRelease(addressData);
}

- (void)stopServer
{
	self.serverState = IHTTPServerStateStopping;

    // stop listening
	[self.listeningHandle closeFile];
	self.listeningHandle = nil;

	[[NSNotificationCenter defaultCenter]
		removeObserver:self
		name:NSFileHandleConnectionAcceptedNotification
		object:nil];

    // complete all serverTasks
    for (IHTTPRequest* request in self.serverRequests) {
        [request.input closeFile];
    }
    [self.serverRequests removeAllObjects];
    self.serverRequests = nil;

		
	if (serverSocket) {
		CFSocketInvalidate(serverSocket);
		CFRelease(serverSocket);
		serverSocket = nil;
	}

	self.serverState = IHTTPServerStateIdle;
}

#pragma mark -

- (void)errorWithName:(NSString *)errorName
{
	self.serverError = [NSError errorWithDomain:@"IHTTPServerError" code:0 userInfo:@{
        NSLocalizedDescriptionKey: NSLocalizedStringFromTable(errorName, @"", @"IHTTPServerErrors")
    }];
}

#pragma mark -

- (void)receiveIncomingConnectionNotification:(NSNotification *)notification
{
	NSDictionary* userInfo = [notification userInfo];
	NSFileHandle* requestHandle = [userInfo objectForKey:NSFileHandleNotificationFileHandleItem];

    if(requestHandle) {
        IHTTPRequest* request = [IHTTPRequest requestWithInput:requestHandle];
        request.delegate = self;
        [self.serverRequests addObject:request];
        [request readHeaders]; // set the handler when the header read is complete
    }
    
    // wait for the next connection
	[self.listeningHandle acceptConnectionInBackgroundAndNotify];
}

#pragma mark - IHTTPRequestDelegate

- (void) request:(IHTTPRequest*) request parsedHeaders:(NSDictionary*) headers
{
    // NSLog(@"request:%@ parsedHeaders:%@", request, headers);
    IHTTPHandler* prototype = [self prototypeForRequest:request];
    __block IHTTPHandler* handler = [prototype handlerForRequest:request];
    __block IHTTPResponse* response = [IHTTPResponse responseWithOutput:request.input];
    [handler handleRequest:request withResponse:response];
    return;
}

#pragma mark - IHTTPResponseDelegate

- (void) responseDidComplete:(IHTTPResponse *)response
{
    for (IHTTPRequest* request in self.serverRequests) {
        if (response.output == request.input) {
            // NSLog(@"responseDidComplete:%@ sentHeaders:%@", response, response.responseHeaders);
            [request completeRequest];
            [self.serverRequests removeObject:request];
            return;
        }
    }
}

@end
