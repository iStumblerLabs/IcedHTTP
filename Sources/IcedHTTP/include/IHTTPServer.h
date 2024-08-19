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
    IHTTPServerLoggingSilent,
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
    IHTTPServerNoError = 0
};

/*! @const IHTTPServerDefaultPort */
extern NSUInteger const IHTTPServerDefaultPort;

/*! @const IHTTPServerStateChangedNote */
extern NSString* const IHTTPServerStateChangedNotification;

// MARK: -

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

// MARK: -

/*! @brief sharedIHTTPServer server on 8080 */
+ (IHTTPServer*) sharedIHTTPServer;

/*! @brief IHTTPServer on the specified port */
+ (IHTTPServer*) serverOnPort:(NSUInteger)serverPort;

// MARK: -

/*! @brief register a new handler prototype
    @discussion this method will place the handler on the top of the stack,
    giving it the first opportunity to respond to @selector(canHandleRequest:) */
- (void) registerHandler:(IHTTPHandler*) prototype;

/*! @brief clear all registered handler prototypes
    @discussion clears the list of prototypes and registers a default hander which
    responds to all request with an IHTTPStatus501NotImplemented error */
- (void) resetPrototypes;

/*! @brief start listening for connections on the designated port */
- (void) startServer;

/*! @brief stops accepting new connections, waits for any running handlers to complete, and closes the socket */
- (void) stopServer;

@end

// MARK: - IHTTPServerDelegate Protocol

@protocol IHTTPServerDelegate <NSObject>
@optional
- (void)IHTTPServerDidStart:(IHTTPServer*)server;
- (void)IHTTPServerDidReset:(IHTTPServer*)server;
- (void)IHTTPServer:(IHTTPServer*)server didRegister:(IHTTPHandler*)handler;
- (void)IHTTPServer:(IHTTPServer*)server didReceive:(IHTTPRequest*)request;
- (void)IHTTPServer:(IHTTPServer*)server didComplete:(IHTTPResponse*)response;
- (void)IHTTPServerDidStop:(IHTTPServer*)server;

@end
