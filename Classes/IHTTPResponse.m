#import "IHTTPResponse.h"
#import "IHTTPServer.h"

@interface IHTTPResponse ()
@property(nonatomic,readonly) CFHTTPMessageRef messageRef;
@property(nonatomic,retain) id messageRefStorage;

@end

#pragma mark -

@implementation IHTTPResponse

#pragma mark -

/*!
    @method responseWithOutput:
    @discussion Init method for the handler. This method is mostly just a value copy operation
    @prarm outputHandle the NSFileHandle to write output to
    @returns the initialized IHTTPResponse
*/
+ (IHTTPResponse*)responseWithOutput:(NSFileHandle*)outputHandle
{
	IHTTPResponse* response = [IHTTPResponse new];
    response.output = outputHandle;
	return response;
}

#pragma mark - Properties

- (CFHTTPMessageRef) messageRef {
    return (__bridge CFHTTPMessageRef)self.messageRefStorage;
}

- (NSUInteger)responseStatus
{
    NSUInteger status = 0;
    
    if (self.messageRef) {
        status = (NSUInteger)CFHTTPMessageGetResponseStatusCode(self.messageRef);
    }
    
    return status;
}

- (NSDictionary*)responseHeaders
{
    return CFBridgingRelease(CFHTTPMessageCopyAllHeaderFields(self.messageRef));
}

#pragma mark -

- (void)sendStatus:(NSUInteger)httpStatus
{
    self.messageRefStorage = CFBridgingRelease(CFHTTPMessageCreateResponse(kCFAllocatorDefault, httpStatus, NULL, kCFHTTPVersion1_1));
}

- (void)sendHeaders:(NSDictionary *)headers
{
    for (NSString* key in headers.allKeys) {
        CFHTTPMessageSetHeaderFieldValue(self.messageRef, (__bridge CFStringRef)key, (__bridge CFStringRef)headers[key]);
    }
    
    if (self.messageRef) {
        CFDataRef headerData = CFHTTPMessageCopySerializedMessage(self.messageRef);
        @try {
            self.didSendHeaders = YES; // set first to prevent lopp via comleteResponse
            [self.output writeData:(__bridge NSData *)headerData];
        }
        @catch (NSException *exception) {
            // normally means the client closed the connection from the other end
            [self completeResponse];
        }
        @finally {
            CFRelease(headerData);
        }
    }
}

- (void)sendBody:(NSData *)bodyData
{
    if (!self.didSendHeaders) { // TODO check for the size of the data first
        CFHTTPMessageSetBody(self.messageRef, (__bridge CFDataRef)bodyData);
        [self sendHeaders:nil]; // no headers, complete message body
    }
    else { // headers have been sent, so write the body to the output stream
        @try {
            [self.output writeData:bodyData];
        }
        @catch (NSException *exception) {
            // normally means the client closed the connection from the other end
            self.outputException = exception;
            [self completeResponse];
        }
    }
}

- (void)completeResponse
{
    if (!self.didSendHeaders) {
        [self sendHeaders:nil];
    }

	if (self.output) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:self.output];
        // TODO [self.output synchronizeFile];
        [self.output closeFile];
		self.output = nil;
	}

    if (self.delegate && [self.delegate respondsToSelector:@selector(responseDidComplete:)]) {
        [self.delegate responseDidComplete:self];
    }
}

#pragma mark - NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@:%p http status: %ld headers: %@>",
        NSStringFromClass([self class]), self, self.responseStatus, self.responseHeaders];
}

//
// dealloc
//
// Stops the response if still running.
//
- (void)dealloc
{
    [self completeResponse];
}

@end

//
//  HTTPResponseHandler.m
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
//  Portions Copyright © 2016-2019 Alf Watt. Available under MIT License (MIT) in README.md
//
