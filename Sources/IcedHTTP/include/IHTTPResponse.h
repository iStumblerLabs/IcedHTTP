#import <Foundation/Foundation.h>

@class IHTTPServer;
@class IHTTPRequest;
@protocol IHTTPResponseDelegate;

/*! @header IHTTPResponse.h
    @abstract IHTTPResponse Class
*/

/*! @class IHTTPResponse 
    @brief IcedHTTP Response Object
    @discussion contains the output stream, provides for sending headers and body content,
    as well as monitoring the completion of the response via a delegate method
*/
@interface IHTTPResponse : NSObject

@property(nonatomic, weak) id<IHTTPResponseDelegate> delegate;

/*! @abstract the NSFileHandle the response will write it's output to */
@property(nonatomic, retain) NSFileHandle* output;

/*! @abstract YES if sendHeaders: has been called, successfully or not */
@property(nonatomic, assign) BOOL didSendHeaders;

/*! @abstract the NSException which was encountered trying to write to the output */
@property(nonatomic, retain) NSException* outputException;

/*! @abstract HTTP response status code set to the client, or 0 if it hasn't been sent */
@property(nonatomic, readonly) NSUInteger responseStatus;

/*! @abstract HTTP response headers sent to the client, or nil if headers have not been sent */
@property(nonatomic, readonly) NSDictionary* responseHeaders;

// MARK: - Class Methods

/*! @param outputHandle the NSFileHandle for the response
    @returns an IHTTPResponse* with the file handle provided */
+ (IHTTPResponse*)responseWithOutput:(NSFileHandle*)outputHandle;

// MARK: - IHTTPResponse Methods

/*! @abstract send the status code */
- (void) sendStatus:(NSUInteger) httpStatus;

/*! @abstract send the headers provided */
- (void) sendHeaders:(NSDictionary*) headers;

/*! @abstract send the body data provided */
- (void) sendBody:(NSData*) bodyData;

/*! @abstract closes the outgoing file handle and completes the response */
- (void) completeResponse;

@end

// MARK: -

/*! @protocol IHTTPResponseDelegate */
@protocol IHTTPResponseDelegate <NSObject>

/*! @brief called on the delegate when the response is completed */
- (void) responseDidComplete:(IHTTPResponse *)response;

@end
