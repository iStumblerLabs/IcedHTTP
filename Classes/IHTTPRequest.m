#import "IHTTPRequest.h"

#pragma mark -

@implementation IHTTPRequest
{
    CFHTTPMessageRef messageRef;
    NSDate* requestTime;
}

+ (IHTTPRequest*) requestWithMessageRef:(CFHTTPMessageRef) messageRef
{
    return [[IHTTPRequest alloc] initWithMessageRef:messageRef];
}

#pragma mark - Initilizers

- (id)init
{
    if (self = [super init]) {
        requestTime = [NSDate date];
    }
    return self;
}

- (id) initWithMessageRef:(CFHTTPMessageRef) mRef
{
    if (self = [self init]) {
        messageRef = mRef;
    }
    return self;
}

#pragma mark - Properties

- (NSString*) requestMethod
{
    return (messageRef ? CFBridgingRelease(CFHTTPMessageCopyRequestMethod(messageRef)) : nil);
}

- (NSDictionary*) requestHeaders
{
    return (messageRef ? CFBridgingRelease(CFHTTPMessageCopyAllHeaderFields(messageRef)) : nil);
}

- (NSURL*) requestURL
{
    return (messageRef ? CFBridgingRelease(CFHTTPMessageCopyRequestURL(messageRef)) : nil);
}

- (NSDate*) requestTime
{
    return requestTime;
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

#pragma mark - NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@:%p on: %@ headers: %@>",
        NSStringFromClass([self class]), self, self.requestTime, self.requestHeaders];
}

@end

//  Copyright © 2016 Alf Watt. Available under MIT License (MIT) in README.md
