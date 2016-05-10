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
//  Portions Copyright © 2016 Alf Watt. Available under MIT License (MIT) in README.md
//

#import <Foundation/Foundation.h>
#import <IcedHTTP/IHTTPRequest.h>
#import <IcedHTTP/IHTTPResponse.h>
#import <IcedHTTP/IHTTPHandler.h>

/*! @header IHTTPServer.h
    @abstract IcedHTTP Server Class */

/*! @enum IHTTPServerState */
typedef enum
{
	IHTTPServerStateIdle,
	IHTTPServerStateStarting,
	IHTTPServerStateRunning,
	IHTTPServerStateStopping
}
IHTTPServerState;

/*! @const IHTTPServerDefaultPort */
extern NSUInteger const IHTTPServerDefaultPort;

/*! @const IHTTPServerStateChangedNote */
extern NSString* const IHTTPServerStateChangedNotification;

/*! @class IHTTPServer 
    @abstract IcedHTTPServer object */
@interface IHTTPServer : NSObject <IHTTPRequestDelegate, IHTTPResponseDelegate>

/*! @abstract the TCP port the server is running on */
@property(nonatomic, assign) NSUInteger serverPort;

/*! @abstract the current state of the server */
@property(nonatomic, assign) IHTTPServerState serverState;

/*! @abstract the last error encountered while processing incoming requests */
@property(nonatomic, retain) NSError* serverError;

/*! @abstract */
@property(nonatomic, retain) NSFileHandle* listeningHandle;

@property(nonatomic, retain) NSMutableArray* handlerPrototypes;

@property(nonatomic, retain) NSMutableSet* serverRequests;

#pragma mark -

/*! @abstract sharedIHTTPServer server on 8080 */
+ (IHTTPServer*) sharedIHTTPServer;

#pragma mark -

/*! @abstract registerPrototype */
- (void) registerPrototype:(IHTTPHandler*) prototype;

/*! @abstract startServer */
- (void) startServer;

/*! @abstract stopServer */
- (void) stopServer;

@end
