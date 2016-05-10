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
//  Portions Copyright © 2016 Alf Watt. Available under MIT License (MIT) in README.md
//

#import "IHTTPResponse.h"
#import "IHTTPServer.h"

#pragma mark -

@implementation IHTTPResponse
{
    CFHTTPMessageRef messageRef;
}

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

#pragma mark -

- (NSDictionary*) responseHeaders
{
    return CFBridgingRelease(CFHTTPMessageCopyAllHeaderFields(messageRef));
}

#pragma mark

- (void)sendStatus:(NSInteger)httpStatus
{
    messageRef = CFHTTPMessageCreateResponse(kCFAllocatorDefault, httpStatus, NULL, kCFHTTPVersion1_1);
}

- (void)sendHeaders:(NSDictionary *)headers
{
    for (NSString* key in headers.allKeys) {
        CFHTTPMessageSetHeaderFieldValue(messageRef, (__bridge CFStringRef)key, (__bridge CFStringRef)headers[key]);
    }
    
    CFDataRef headerData = CFHTTPMessageCopySerializedMessage(messageRef);
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

- (void)sendBody:(NSData *)bodyData
{
    if (!self.didSendHeaders) { // TODO check for the size of the data first
        CFHTTPMessageSetBody(messageRef, (__bridge CFDataRef)bodyData);
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
