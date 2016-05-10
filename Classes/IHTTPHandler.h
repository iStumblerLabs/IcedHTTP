#import <Foundation/Foundation.h>

@class IHTTPRequest;
@class IHTTPResponse;

/*! @header IHTTPHandler.h 
    @abstract Handlers are created as prototypes, registered with the server,
    copied to handle a request, then completed */

/*! @typedef IHTTPRequestBlock
    @param request the IHTTPRequest*  to evaulate
    @returns BOOL YES if the handler can handle the request */
typedef BOOL (^ IHTTPRequestBlock)(IHTTPRequest* request);

/*! @typedef IHTTPResponseBlock
    @param request the IHTTPRequest* request input stream
    @param response the IHTTPResponse* response output stream
    @returns NSUInteger HTTP response code */
typedef NSUInteger (^ IHTTPResponseBlock)(IHTTPRequest* request, IHTTPResponse* response);

/*! @class IHTTPHandler
    @abstract Handlers are used to service individual reqeusts */
@interface IHTTPHandler : NSObject <NSCopying>

/*! @abstract a handler which will return the file at the path provided */
+ (IHTTPHandler*) handlerWithFilePath:(NSString*) filePath;

/*! @abstract a handler will whill execute the blocks provided to evaulate and service the request */
+ (IHTTPHandler*) handlerWithRequestBlock:(IHTTPRequestBlock) requestBlock responseBlock:(IHTTPResponseBlock) responseBlock;

/*! @abstract a handler which will execute the responseBlock for any request */
+ (IHTTPHandler*) handlerWithResponseBlock:(IHTTPResponseBlock) responseBlock;

#pragma mark -

/*!
    @method canHandleRequest:
    @param request
    @return BOOL YES if the handler can handle the request provided
    @discussion called by the server on each prototype handler until one answers YES
*/
- (BOOL) canHandleRequest:(IHTTPRequest*) request;

/*!
    @method handlerForRequest:
    @param request
    @returns a copy of the current handler
*/
- (IHTTPHandler*) handlerForRequest:(IHTTPRequest*) request;

/*!
    @method handleRequest:withResponse
    @param request
    @param response
*/
- (NSUInteger) handleRequest:(IHTTPRequest*) request withResponse:(IHTTPResponse*) response;

@end

// Copyright © 2016 Alf Watt. Available under MIT License (MIT) in README.md
