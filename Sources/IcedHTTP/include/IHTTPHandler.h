#import <Foundation/Foundation.h>

@class IHTTPRequest;
@class IHTTPResponse;

/*! @header IHTTPHandler.h 
    @abstract Handlers are created as prototypes, registered with the server,
    copied to handle a request, then completed */

/*! @typedef IHTTPRequestBlock
    @param request the IHTTPRequest*  to evaluate
    @returns BOOL YES if the handler can handle the request */
typedef BOOL (^ IHTTPRequestBlock)(IHTTPRequest* request);

/*! @typedef IHTTPResponseBlock
    @param request the IHTTPRequest* request input stream
    @param response the IHTTPResponse* response output stream
    @returns NSUInteger HTTP response code */
typedef NSUInteger (^ IHTTPResponseBlock)(IHTTPRequest* request, IHTTPResponse* response);

/*! @class IHTTPHandler
    @abstract Handlers are used to service individual requests */
@interface IHTTPHandler : NSObject <NSCopying>

/*! @abstract a handler which will return the file at the path provided */
+ (IHTTPHandler*) handlerWithFilePath:(NSString*) filePath;

/*! @abstract a handler which will execute the blocks provided to evaluate and service the request */
+ (IHTTPHandler*) handlerWithRequestBlock:(IHTTPRequestBlock) requestBlock responseBlock:(IHTTPResponseBlock) responseBlock;

/*! @abstract a handler which will execute the responseBlock for any request */
+ (IHTTPHandler*) handlerWithResponseBlock:(IHTTPResponseBlock) responseBlock;

// MARK: -

/*!
    @method canHandleRequest:
    @param request the request to consider
    @return BOOL YES if the handler can handle the request provided
    @discussion called by the server on each prototype handler, in reverse order of registration, until one answers YES
*/
- (BOOL) canHandleRequest:(IHTTPRequest*) request;

/*!
    @method handlerForRequest:
    @param request the request to find a handler for
    @returns a copy of the current handler
*/
- (IHTTPHandler*) handlerForRequest:(IHTTPRequest*) request;

/*!
    @method handleRequest:withResponse
    @param request the request to handle
    @param response the response object
*/
- (NSUInteger) handleRequest:(IHTTPRequest*) request withResponse:(IHTTPResponse*) response;

@end
