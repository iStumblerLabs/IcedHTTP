
#import <Foundation/Foundation.h>
#import <IcedHTTP/IcedHTTP.h>

/*!
    @fuction main
    @abstract create and run an IHTTPServer with some example handlers
*/
int main(int argc, char** argv) {
    int status = 0;
    @autoreleasepool {
        NSUInteger serverPort = IHTTPDefaultPort;
        NSUInteger portIndex = [NSProcessInfo.processInfo.arguments indexOfObject:@"-p"];
        if (portIndex != NSNotFound) {
            if (NSProcessInfo.processInfo.arguments.count > (portIndex + 1)) {
                NSString* portString = NSProcessInfo.processInfo.arguments[(portIndex + 1)];
                if (portString) {
                    serverPort = portString.doubleValue;
                }
                else NSLog(@"WARNING invalid port (-p) argument: %@\nusing default: %lu", portString, (unsigned long)serverPort);
            }
            else NSLog(@"WARNING no port argument provided for -p in arguments: %@\nusing default: %lu", NSProcessInfo.processInfo.arguments, (unsigned long)serverPort);
        }
        
        IHTTPServer* server = [IHTTPServer serverOnPort:serverPort];

        NSUInteger fileIndex = [NSProcessInfo.processInfo.arguments indexOfObject:@"-f"];
        if (fileIndex != NSNotFound) {
            if (NSProcessInfo.processInfo.arguments.count < fileIndex) {
                NSString* pathString = NSProcessInfo.processInfo.arguments[(fileIndex + 1)];
                BOOL isDir = NO;
                if ([NSFileManager.defaultManager fileExistsAtPath:pathString isDirectory:&isDir] && isDir) {
                    [server registerHandler:[IHTTPHandler handlerWithFilePath:pathString]];
                }
                else NSLog(@"WARNING no file at path (%@) or isDir (%i)", pathString, isDir);
            }
            else NSLog(@"WARNING no file argument provided for -f in arguments: %@\nusing default: %lu", NSProcessInfo.processInfo.arguments, (unsigned long)serverPort);
        }

        if (server.handlerPrototypes.count == 1) { // register a default hello handler
            NSLog(@"registered default handler");
            [server registerHandler:[IHTTPHandler
                handlerWithRequestBlock:^(IHTTPRequest* request){
                    return YES; // handle all requests
                }
                responseBlock: ^(IHTTPRequest* request, IHTTPResponse* response) {
                    NSUInteger statusCode = IHTTPStatus200OK;
                    NSString* messageString = [NSString stringWithFormat:@"Hello IcedHttp @ %@", [NSDate date]];
                    NSData* bodyData = [messageString dataUsingEncoding:NSUTF8StringEncoding];
                    [response sendStatus:statusCode];
                    [response sendHeaders:@{
                        IHTTPContentTypeHeader: @"text/plain",
                        IHTTPContentLengthHeader: [NSString stringWithFormat:@"%lu", (unsigned long)bodyData.length]
                    }];
                    [response sendBody:bodyData];
                    [response completeResponse];
                    return statusCode;
                }
            ]];
        }
        
        [server startServer];
        
        NSLog(@"IcedHTTP server running %@", server.rootURL);
        
        [NSRunLoop.currentRunLoop run];
        
        [server stopServer];
    }
    return status;
}
