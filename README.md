# IcedHTTP

A very small HTTP Server framework suitable for embedding into iOS or Mac OS Apps,<br>
maybe even tvOS or watchOS, haven't tried.

IcedHTTP has no dependencies, only four classes and ships with handler objects for serving<br>
up files and executing a block of code when a request is received for a dynamic response.

Primary design goals are: small size, simple integration and scaleable to light workloads.

Based on [TextTransfer Example App](http://www.cocoawithlove.com/2009/07/simple-extensible-http-server-in-cocoa.html)
by [Matt Gallagher](http://www.cocoawithlove.com)

## Usage

    \#import <Foundation/Foundation.h>
    \#import <IcedHTTP/IcedHttp.h>

    int main(int argc, char** argv) {
        @autoreleasepool {
            NSUInteger serverPort = 8080;
            IHTTPServer* server = [IHTTPServer serverOnPort:serverPort];
            [server registerHandler:[IHTTPHandler
                handlerWithRequestBlock:^(IHTTPRequest* request){ return YES; } // handle all requests
                responseBlock: ^(IHTTPRequest* request, IHTTPResponse* response) {
                    NSUInteger responseCode = 200;
                    NSString* messageString = [NSString stringWithFormat:@"Hello IcedHttp @ %@", [NSDate date]];
                    [response sendStatus:responseCode];
                    [response sendBody:[messageString dataUsingEncoding:NSUTF8StringEncoding]]; // TODO one for each -s argument
                    [response completeResponse];
                    return responseCode;
                }
            ]];
            
            [server startServer];
            
            NSLog(@"IcedHTTP server running %@", server.rootURL);
            
            [NSRunLoop.currentRunLoop run];
            
            [server stopServer];
        }
        return 0;
    }

## Building

A simple Makefile is provided to build the framework and documentation:

    make build
    make headerdoc
    make clean

## Theory of Operation

The IcedHTTP Server is intended for simple embedded applications which wish to share<br>
a small set of files or some dynamic content while running in the foreground or, for a short time,<br>
while the application is in the background, before it is terminated.

- [IHTTPServer](IHTTPServer_h/Classes/IHTTPServer/index.html)
- [IHTTPRequest](IHTTPRequest_h/Classes/IHTTPRequest/index.html)
- [IHTTPResponse](IHTTPResponse_h/Classes/IHTTPResponse/index.html)
- [IHTTPHandler](IHTTPHandler_h/Classes/IHTTPHandler/index.html)

Full [API Documentation](masterTOC.html) is available after running `make headerdoc`.

### Handler Prototypes

The IHTTPServer class uses handler prototypes to respond to multiple incoming requests<br>
concurrently with low memory overhead:

- After creating the `IHTTPServer`, register `IHTTPHandler` objects with `registerPrototype`
- `IHTTPRequests` are created when connections are made to the server, which calls `canHandleRequest:` on each prototype
- The first handler which responds `YES` is cloned via `handlerForRequest:`
- `handleRequest:response:` is called on the cloned handler 

## Change log

### 1.2 — 19 August 2024: Swift Package Manager Support

### 1.1 — Logging

### 1.0 — IcedHTTP.framework Initial Release

- Create `IcedHTTP.xcodeproject` with `IcedHTTP.framework` targets for `MacOS` and `iOS`
- Add this `README.md` and `Makefile` for automated builds 
- Rename classes with `IHTTP` prefix across the board
- Convert to Modern Objective-C and `ARC`
- Refactor request and response code into `IHTTPRequest` and `IHTTPResponse`
- Add `IHTTPHandler` to allow for apps to easily add dynamic responses


## Copyright & Licenses

    The MIT License (MIT)

    Copyright (c) 2015-2024 Alf Watt

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

TextTransfer Example App by Matt Gallagher

    Created by Matt Gallagher on 2009/07/13.
    Copyright 2009 Matt Gallagher. All rights reserved.
    
    Permission is given to use this source code file, free of charge, in any
    project, commercial or otherwise, entirely at your risk, with the condition
    that any redistribution (in part or whole) of source code must retain
    this copyright and permission notice. Attribution in compiled projects is
    appreciated but not required.
