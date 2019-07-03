#import <Foundation/Foundation.h>

@protocol IHTTPRequestDelegate;

/*! @header IHTTPRequest.h
    @brief IHTTPRequest class */

/*! @class IHTTPRequest
    @brief IHTTPRequest parses the server's input */
@interface IHTTPRequest : NSObject

/*! @brief the NSFilehandle with the HTTP Request headers and body */
@property(nonatomic, retain) NSFileHandle* input;

@property(nonatomic, assign) id<IHTTPRequestDelegate> delegate;

/*! @brief YES if the headers have been read */
@property(nonatomic, assign) BOOL didReadHeaders;

/*! @brief HTTP Request Method */
@property(nonatomic, readonly) NSString* requestMethod;

/*! @brief HTTP Request Headers in dictionary form */
@property(nonatomic, readonly) NSDictionary* requestHeaders;

/*! @brief HTTP Request URL */
@property(nonatomic, readonly) NSURL* requestURL;

/*! @brief HTTP Reqeust Time */
@property(nonatomic, readonly) NSDate* requestTime;

#pragma mark -

/*! @brief create a request object ewith the file handle provided */
+ (IHTTPRequest*) requestWithInput:(NSFileHandle*) input;

#pragma mark -

/*! @brief read the headers of the request */
- (void) readHeaders;

/*! @brief NSData with the body of the IHTTPRequest */
- (NSData*) readBody;

/*! @brief close the input stream */
- (void) completeRequest;

@end

#pragma mark -

@protocol IHTTPRequestDelegate <NSObject>

- (void) request:(IHTTPRequest*) request parsedHeaders:(NSDictionary*) headers;

@end

#pragma mark - Copyright & License

//  Copyright © 2016-2019 Alf Watt. Available under MIT License (MIT) in README.md
