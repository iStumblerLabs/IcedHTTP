
#import "IHTTPHandler.h"

#import "IHTTPServer.h"
#import "IHTTPRequest.h"
#import "IHTTPResponse.h"

#pragma mark -

@interface IHTTPFileHandler : IHTTPHandler
@property(nonatomic,retain) NSString* filePath;
@end

#pragma mark -

@interface IHTTPBlockHandler : IHTTPHandler
@property(nonatomic,copy) IHTTPRequestBlock requestBlock;
@property(nonatomic,copy) IHTTPResponseBlock  responseBlock;
@end

#pragma mark -

@implementation IHTTPHandler

+ (IHTTPHandler*) handlerWithFilePath:(NSString*) filePath
{
    IHTTPFileHandler *handler = [IHTTPFileHandler new];
    handler.filePath = filePath;
    return handler;
}

+ (IHTTPHandler*) handlerWithRequestBlock:(IHTTPRequestBlock) requestBlock responseBlock:(IHTTPResponseBlock) responseBlock
{
    IHTTPBlockHandler* handler = [IHTTPBlockHandler new];
    handler.requestBlock = requestBlock;
    handler.responseBlock = responseBlock;
    return handler;
}

+ (IHTTPHandler*) handlerWithResponseBlock:(IHTTPResponseBlock) responseBlock
{
    IHTTPBlockHandler* handler = [IHTTPBlockHandler new];
    handler.responseBlock = responseBlock;
    return handler;
}

#pragma mark -

- (BOOL)canHandleRequest:(IHTTPRequest*) request
{
    [[NSException exceptionWithName:@"Unimplemented Method" reason:@"concrete subclases of IHTTPHandler must implement canHandleRequest:" userInfo:nil] raise];
    return NO;
}

- (IHTTPHandler*) handlerForRequest:(IHTTPRequest*) request
{
    IHTTPHandler* clone = [self copy];
    return clone;
}

- (NSUInteger)handleRequest:(IHTTPRequest*) request withResponse:(IHTTPResponse*) response
{
    [response sendStatus:400];
    [response completeResponse];
    return 400;
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    IHTTPHandler* clone = [IHTTPHandler new];
    return clone;
}


@end

#pragma mark -

@implementation IHTTPFileHandler

- (BOOL)canHandleRequest:(IHTTPRequest*)aRequest
{
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
	if ([fm fileExistsAtPath:self.filePath isDirectory:&isDirectory]) {
		return !isDirectory;
	}
	
	return NO;
}

- (NSUInteger)handleRequest:(IHTTPRequest*) request withResponse:(IHTTPResponse*) response
{
    NSUInteger responseCode = 400;
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
	if ([fm fileExistsAtPath:self.filePath isDirectory:&isDirectory] && !isDirectory) {
        // NSInputStream* inputStream = [NSInputStream inputStreamWithFileAtPath:self.filePath];
        //while ([inputStream hasBytesAvailable]) {
        //    [response.output writeData:inputStream.];
        //}
	}
    else {
        [response sendStatus:404]; // not found
        [response completeResponse];
    }
    
    return responseCode;
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    IHTTPFileHandler* clone = [IHTTPFileHandler new];
    clone.filePath = self.filePath;
    return clone;
}

@end

#pragma mark -

@implementation IHTTPBlockHandler

- (BOOL)canHandleRequest:(IHTTPRequest*)aRequest
{
    BOOL canHandle = YES;
    if (self.requestBlock) {
        canHandle = self.requestBlock(aRequest);
    }
    return canHandle;
}

- (NSUInteger)handleRequest:(IHTTPRequest*) request withResponse:(IHTTPResponse*) response
{
    return self.responseBlock(request, response);
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    IHTTPBlockHandler* clone = [IHTTPBlockHandler new];
    clone.requestBlock = self.requestBlock;
    clone.responseBlock = self.responseBlock;
    return clone;
}

@end

//  Copyright © 2016 Alf Watt. Available under MIT License (MIT) in README.md
