#import <Foundation/Foundation.h>

@class IHTTPHandler;
@class IHTTPRequest;
@class IHTTPResponse;
@protocol IHTTPServerDelegate;

/*! @header IHTTPServer.h
    @abstract IcedHTTP Server Class */

/*! @enum IHTTPServerState */
typedef NS_ENUM(NSUInteger, IHHTPServerState) {
	IHTTPServerStateIdle,
	IHTTPServerStateStarting,
	IHTTPServerStateRunning,
	IHTTPServerStateStopping
};

/*! @enum IHTTPServerLoggingLevel
    @brief IcedHTTP Server Logging Levels */
typedef NS_ENUM(NSUInteger, IHTTPServerLoggingLevel) {
    IHTTPServerLogginSilent,
    IHTTPServerLoggingErrors,
    IHTTPServerLoggingWarnings,
    IHTTPServerLoggingRequests,
    IHTTPServerLoggingResponses,
    IHTTPServerLoggingDebug
};

/*! @enum IHTTPServerErrorNumber
    @brief Error numbers for IHTTPServer
*/
typedef NS_ENUM(NSUInteger, IHTTPServerErrorNumber) {
    IHTTPSEerverNoError = 0
};

/*! @const IHTTPServerDefaultPort */
extern NSUInteger const IHTTPServerDefaultPort;

/*! @const IHTTPServerStateChangedNote */
extern NSString* const IHTTPServerStateChangedNotification;

#pragma mark -

/*! @class IHTTPServer 
    @brief IcedHTTPServer object */
@interface IHTTPServer : NSObject

/*! @brief the TCP port the server is running on */
@property(nonatomic, assign) NSUInteger serverPort;

/*! @brief the current state of the server */
@property(nonatomic, assign) IHHTPServerState serverState;

/*! @brief the current logging level of the server */
@property(nonatomic, assign) IHTTPServerLoggingLevel loggingLevel;

/*! @brief the last error encountered while processing incoming requests */
@property(nonatomic, retain) NSError* serverError;

/*! @brief the array of handler prototypes in the server */
@property(nonatomic, readonly) NSArray* handlerPrototypes;

/*! @brief the set of requests the server is currently handling */
@property(nonatomic, readonly) NSSet* serverRequests;

/*! @brief the rootURL of the server */
@property(nonatomic, readonly) NSURL* rootURL;

/*! @brief the delegate of the server */
@property(nonatomic, assign) id<IHTTPServerDelegate> delegate;

#pragma mark -

/*! @brief sharedIHTTPServer server on 8080 */
+ (IHTTPServer*) sharedIHTTPServer;

/*! @brief IHTTPServer on the specifed port */
+ (IHTTPServer*) serverOnPort:(NSUInteger)serverPort;

#pragma mark -

/*! @brief register a new handler prototype
    @discussion this method will place the handler on the top of the stack,
    giving it the first opportunit to respond to @selector(canHandleRequest:) */
- (void) registerHandler:(IHTTPHandler*) prototype;

/*! @brief clear all registered handler prototypes
    @discussion clears the list of prototypes and registers a default hander which
    responds to all request with an IHTTPStatus501NotImplemented error */
- (void) resetPrototypes;

/*! @brief start listening for connections on the designated port */
- (void) startServer;

/*! @brief stops accepting new connections, waits for any running hanlders to complete, and closes the socket */
- (void) stopServer;

@end

#pragma mark - IHTTPServerDelegate Protocol

@protocol IHTTPServerDelegate <NSObject>
@optional
- (void)IHTTPServerDidStart:(IHTTPServer*)server;
- (void)IHTTPServerDidReset:(IHTTPServer*)server;
- (void)IHTTPServer:(IHTTPServer*)server didRegister:(IHTTPHandler*)handler;
- (void)IHTTPServer:(IHTTPServer*)server didRecieve:(IHTTPRequest*)request;
- (void)IHTTPServer:(IHTTPServer*)server didComplete:(IHTTPResponse*)response;
- (void)IHTTPServerDidStop:(IHTTPServer*)server;

@end

#pragma mark - Copyright & License

//
//  HTTPServer.h
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
//  Portions Copyright © 2016-2019 Alf Watt. Available under MIT License (MIT) in README.md
//
