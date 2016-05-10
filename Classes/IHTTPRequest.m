#import "IHTTPRequest.h"

#pragma mark -

@implementation IHTTPRequest
{
    CFHTTPMessageRef messageRef;
}

+ (IHTTPRequest*) requestWithMessageRef:(CFHTTPMessageRef) messageRef
{
    return [[IHTTPRequest alloc] initWithMessageRef:messageRef];
}

#pragma mark - Initilizers

- (id) initWithMessageRef:(CFHTTPMessageRef) mRef
{
    if (self = [super init]) {
        messageRef = mRef; // CFRetain?
    }
    return self;
}

#pragma mark - Properties




- (NSString*) requestMethod
{
    return CFBridgingRelease(CFHTTPMessageCopyRequestMethod(messageRef));
}

- (NSDictionary*) requestHeaders
{
    return CFBridgingRelease(CFHTTPMessageCopyAllHeaderFields(messageRef));
}

- (NSURL*) requestURL
{
    return CFBridgingRelease(CFHTTPMessageCopyRequestURL(messageRef));
}

#pragma mark -

+ (IHTTPRequest*) requestWithInput:(NSFileHandle*) input
{
    IHTTPRequest* request = [IHTTPRequest new];
    request.input = input;
    return request;
}

#pragma mark -

- (void) readHeaders
{
    if (!self.didReadHeaders) {
        messageRef = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, YES);
		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(receiveIncomingDataNotification:)
			name:NSFileHandleDataAvailableNotification
			object:self.input];
		
        [self.input waitForDataInBackgroundAndNotify];
        self.didReadHeaders = YES;
    }
}

- (NSData*) readBody
{
    if (self.didReadHeaders) {
        return [self.input readDataToEndOfFile];
    }
    else {
        [self readHeaders];
        return nil;
    }
}

- (void) completeRequest
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:self.input];
    [self.input closeFile];
}

#pragma mark -

- (void)receiveIncomingDataNotification:(NSNotification *)notification
{
	NSFileHandle *incomingFileHandle = [notification object];
	NSData *data = [incomingFileHandle availableData];
	
	if ([data length] == 0) { // EoF
		[self completeRequest];
		return;
	}

    CFHTTPMessageAppendBytes(messageRef, [data bytes], [data length]);
    
	if (CFHTTPMessageIsHeaderComplete(messageRef)) {
        if ([self.delegate respondsToSelector:@selector(request:parsedHeaders:)]) {
            [self.delegate request:self parsedHeaders:self.requestHeaders];
            self.didReadHeaders = YES;
        }

        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:self.input];
    }
    else {
        [incomingFileHandle waitForDataInBackgroundAndNotify];
    }
}

@end

//  Copyright © 2016 Alf Watt. Available under MIT License (MIT) in README.md
