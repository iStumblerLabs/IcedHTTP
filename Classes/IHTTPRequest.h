#import <Foundation/Foundation.h>

@protocol IHTTPRequestDelegate;

/*! @header IHTTPRequest.h
    @abstract IHTTPRequest class */

/*! @class IHTTPRequest
    @abstract IHTTPRequest parses the server's input */
@interface IHTTPRequest : NSObject

/*! @abstract the NSFilehandle with the HTTP Request headers and body */
@property(nonatomic, retain) NSFileHandle* input;

@property(nonatomic, assign) id<IHTTPRequestDelegate> delegate;

/*! @abstract YES if the headers have been read */
@property(nonatomic, assign) BOOL didReadHeaders;

/*! @abstract HTTP Request Method */
@property(nonatomic, readonly) NSString* requestMethod;

/*! @abstract HTTP Request Headers in dictionary form */
@property(nonatomic, readonly) NSDictionary* requestHeaders;

/*! @abstract HTTP Request URL */
@property(nonatomic, readonly) NSURL* requestURL;

#pragma mark -

/*! @abstract create a request object ewith the file handle provided */
+ (IHTTPRequest*) requestWithInput:(NSFileHandle*) input;

#pragma mark -

/*! @abstract read the headers of the request */
- (void) readHeaders;

/*! @abstract NSData with the body of the IHTTPRequest */
- (NSData*) readBody;

/*! @abstract close the input stream */
- (void) completeRequest;

@end

#pragma mark -

@protocol IHTTPRequestDelegate <NSObject>

- (void) request:(IHTTPRequest*) request parsedHeaders:(NSDictionary*) headers;

@end

//  Copyright © 2016 Alf Watt. Available under MIT License (MIT) in README.md
