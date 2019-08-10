#import "IHTTPHandler.h"

#import "IHTTPConstants.h"
#import "IHTTPRequest.h"
#import "IHTTPResponse.h"
#import "IHTTPServer.h"

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
    [response sendStatus:IHTTPStatus501NotImplemented];
    [response completeResponse];
    return IHTTPStatus501NotImplemented;
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

+ (NSUInteger) copyFile:(NSString*)filePath toStream:(NSFileHandle*)outStream
{
    NSUInteger chunk = 4096;
    NSUInteger bytes = 0;
    NSMutableData *buffer = [NSMutableData dataWithLength:chunk];
    NSInputStream* inputStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    while ([inputStream hasBytesAvailable]) {
        NSUInteger read = [inputStream read:buffer.mutableBytes maxLength:chunk];
        [outStream writeData:((read < chunk) ? [buffer subdataWithRange:NSMakeRange(0, read)] : buffer)];
        bytes += read;
    }

    return bytes;
}

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
    NSUInteger responseCode = IHTTPStatus500InternalServerError;
    BOOL isDirectory = NO;
	if ([NSFileManager.defaultManager fileExistsAtPath:self.filePath isDirectory:&isDirectory] && !isDirectory) {
        [response sendStatus:IHTTPStatus200OK];
        [IHTTPFileHandler copyFile:self.filePath toStream:response.output];
        goto complete;
	}
    else if (isDirectory) {
        for (NSString* defaultPage in @[@"index.html", @"default.html"]) {
            if ([NSFileManager.defaultManager fileExistsAtPath:[self.filePath stringByAppendingPathComponent:defaultPage] isDirectory:&isDirectory]
             && !isDirectory) {
                [response sendStatus:IHTTPStatus200OK];
                [IHTTPFileHandler copyFile:[self.filePath stringByAppendingPathComponent:defaultPage] toStream:response.output];
                goto complete;
            }
        }
        // TODO check the request headers and send a ToC
        // - get a list of the files
        // - decide on an output format
        // - render to the response.output
        [response sendStatus:IHTTPStatus501NotImplemented]; // not implemented
        goto complete;
    }
    else {
        [response sendStatus:IHTTPStatus404NotFound]; // not found
        goto complete;
    }
    
complete:
    [response completeResponse];

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

#pragma mark - Copyright & License

//  Copyright © 2016-2019 Alf Watt. Available under MIT License (MIT) in README.md
