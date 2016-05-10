
#import <Foundation/Foundation.h>
#import <IcedHTTP/IcedHttp.h>

/*!
    @fuction main
    @abstract create and run an IHTTPServer with some example handlers

*/
int main(int argc, char** argv)
{
    int status = 0;
    @autoreleasepool {
        IHTTPServer* server = [IHTTPServer sharedIHTTPServer]; // TODO default to 8080 or use -p argument to set the port
        // [server registerPrototype:[IHTTPHandler handlerWithFilePath:@"~/Public/Sites"]]; // TODO one for each -f argument
        [server registerPrototype:[IHTTPHandler handlerWithRequestBlock:^(IHTTPRequest* request){
            return YES;
        } responseBlock: ^(IHTTPRequest* request, IHTTPResponse* response) {
            [response sendStatus:200];
            [response sendBody:[@"Hello IcedHttp" dataUsingEncoding:NSUTF8StringEncoding]]; // TODO one for each -s argument
            [response completeResponse];
            return (NSUInteger)200;
        }]];
        
        [server startServer];
        
        NSLog(@"server running http://localhost:8080"); // TODO server.URL
        
        [[NSRunLoop currentRunLoop] run]; // TODO runUntilDate?
        
        [server stopServer];
    }
    return status;
}

// Copyright © 2016 Alf Watt. Available under MIT License (MIT) in README.md
