//
//  HTTPResponseHandler.h
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

#import <Foundation/Foundation.h>

@class IHTTPServer;
@class IHTTPRequest;
@protocol IHTTPResponseDelegate;

/*! @header IHTTPResponse.h
    @abstract IHTTPResponse Class */

/*! @class IHTTPResponse 
    @abstract IHTTPResponse Class */
@interface IHTTPResponse : NSObject

@property(nonatomic, weak) id<IHTTPResponseDelegate> delegate;

/*! @abstract output the NSFileHandle the response will write it's output to */
@property(nonatomic, retain) NSFileHandle* output;

/*! @abstract didSendHeaders YES if sendHeaders: has been called, sucessfully or not */
@property(nonatomic, assign) BOOL didSendHeaders;

/*! @abstract outputException the NSException which was encountered trying to write to the output */
@property(nonatomic, retain) NSException* outputException;

@property(nonatomic, readonly) NSDictionary* responseHeaders;

#pragma mark - Class Methods

/*! @param outputHandle the NSFileHandle for the response
    @returns an IHTTPResponse* with the file handle provided */
+ (IHTTPResponse*)responseWithOutput:(NSFileHandle*)outputHandle;

#pragma mark - IHTTPResponse Methods

/*! @abstract send the status code */
- (void) sendStatus:(NSInteger) httpStatus;

/*! @abstract send the headers provided */
- (void) sendHeaders:(NSDictionary*) headers;

/*! @abstract send the body data provided */
- (void) sendBody:(NSData*) bodyData;

/*! @abstract closes the outgoing file handle and completes the response */
- (void) completeResponse;

@end

#pragma mark -

/*! @protocol IHTTPResponseDelegate */
@protocol IHTTPResponseDelegate <NSObject>

/*! @abstract called on the delegate when the response is completed */
- (void) responseDidComplete:(IHTTPResponse *)response;

@end
