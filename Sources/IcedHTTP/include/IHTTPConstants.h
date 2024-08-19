#ifndef IHTTPConstants_h
#define IHTTPConstants_h

#include <Foundation/Foundation.h>

/*! @brief HTTP/1.1 header fields
    https://tools.ietf.org/html/rfc7231
    https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
*/
typedef NS_ENUM(NSUInteger, IHTTPStatusCodes) {
    IHTTPStatusCodeUnknown                      = 0,

    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.1.1 */
    IHTTPStatus100Continue                      = 100,
    
    /*! @biref https://tools.ietf.org/html/rfc2616#section-10.1.2 */
    IHTTPStatus101SwitchingProtocols            = 101,
    
    /*! @brief https://tools.ietf.org/html/rfc2518 */
    IHTTPStatus102Processing                    = 102,
    
    /*! @brief http://www.iana.org/go/rfc8297 */
    IHTTPStatus103EarlyHints                    = 103,
    
    /* -- 200: Success -- */
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.2.1 */
    IHTTPStatus200OK                            = 200,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.2.2 */
    IHTTPStatus201Created                       = 201,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.2.3 */
    IHTTPStatus202Accepted                      = 202,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.2.4 */
    IHTTPStatus203NonAuthoritativeInformation   = 203,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.2.5 */
    IHTTPStatus204NoContent                     = 204,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.2.6 */
    IHTTPStatus205ResetContent                  = 205,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.2.7
        https://tools.ietf.org/html/rfc7233 */
    IHTTPStatus206PartialContent                = 206,
    
    /*! @brief https://tools.ietf.org/html/rfc4918 */
    IHTTPStatus207MultiStatus                   = 207,
    
    /*! @brief https://tools.ietf.org/html/rfc5842 */
    IHTTPStatus208AlreadyReported               = 208,
    
    /*! @brief https://tools.ietf.org/html/rfc3229 */
    IHTTPStatus226IMUsed                        = 226,

    /* -- 300: Redirect */

    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.3.1 */
    IHTTPStatus300MultipleChoices               = 300,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.3.2 */
    IHTTPStatus301MovedPermanently              = 301,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.3.3 */
    IHTTPStatus302Found                         = 302,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.3.4 */
    IHTTPStatus303SeeOther                      = 303,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.3.5
        https://tools.ietf.org/html/rfc7232 */
    IHTTPStatus304NotModified                   = 304,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.3.6 */
    IHTTPStatus305UseProxy                      = 305,
    
    /*! @brief UNUSED https://tools.ietf.org/html/rfc2616#section-10.3.7
        https://tools.ietf.org/html/draft-cohen-http-305-306-responses-00 */
    IHTTPStatus306SwitchProxy                   = 306,

    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.3.8 */
    IHTTPStatus307TemporaryRedirect             = 307,
    
    /*! @brief https://tools.ietf.org/html/rfc7538 */
    IHTTPStatus308PermanentRedirect             = 308,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.1 */
    IHTTPStatus400BadRequest                    = 400,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.2 */
    IHTTPStatus401Unauthorized                  = 401,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.3 */
    IHTTPStatus402PaymentRequired               = 402,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.4 */
    IHTTPStatus403Forbidden                     = 403,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.5 */
    IHTTPStatus404NotFound                      = 404,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.6 */
    IHTTPStatus405MethodNotAllowed              = 405,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.7 */
    IHTTPStatus406NotAcceptable                 = 406,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.8
        https://tools.ietf.org/html/rfc7235 */
    IHTTPStatus407ProxyAuthenticationRequired   = 407,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.9 */
    IHTTPStatus408RequestTimeout                = 408,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.10 */
    IHTTPStatus409Conflict                      = 409,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.11 */
    IHTTPStatus410Gone                          = 410,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.12 */
    IHTTPStatus411LengthRequired                = 411,

    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.13
        https://tools.ietf.org/html/rfc7232 */
    IHTTPStatus412PreconditionFailed            = 412,

    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.14
        https://tools.ietf.org/html/rfc7231 */
    IHTTPStatus413PayloadTooLarge               = 413,
    
    /*! https://tools.ietf.org/html/rfc2616#section-10.4.15 */
    IHTTPStatus414RequestURITooLarge            = 414,
    
    /*! https://tools.ietf.org/html/rfc2616#section-10.4.16 */
    IHTTPStatus415UnsupportedMediaType          = 415,

    /*! @brief https://tools.ietf.org/html/rfc7233 */
    IHTTPStatus416RangeNotSatisfiable           = 416,
    
    /*! @brief https://tools.ietf.org/html/rfc2616#section-10.4.18 */
    IHTTPStatus417ExpectationFailed             = 417,
    
    /*! @brief https://tools.ietf.org/html/rfc2324
        https://tools.ietf.org/html/rfc7168 */
    IHTTPStatus418ImATeapot                     = 418,
    
    /*! @brief https://tools.ietf.org/html/rfc7540 */
    IHTTPStatus421MisdirectedRequest            = 421,
    
    /*! @brief https://tools.ietf.org/html/rfc4918 - WebDAV */
    IHTTPStatus422UnprocessableEntity           = 422,
    IHTTPStatus423Locked                        = 423,
    IHTTPStatus424FailedDependency              = 424,
    
    /*! @brief https://tools.ietf.org/html/rfc8470 */
    IHTTPStatus425TooEarly                      = 425,
    
    IHTTPStatus426UpgradeRequired               = 426,
    
    /*! @brief https://tools.ietf.org/html/rfc6585 */
    IHTTPStatus428PreconditionRequired          = 428,
    IHTTPStatus429TooManyRequests               = 429,
    
    IHTTPStatus431RequestHeaderFieldsTooLarge   = 431,
    
    /*! @brief https://tools.ietf.org/html/rfc7725 */
    IHTTPStatus451UnavailableForLegalReasons    = 451,

    /* -- 5xx: Server errors -- */
    
    IHTTPStatus500InternalServerError           = 500,
    IHTTPStatus501NotImplemented                = 501,
    IHTTPStatus502BadGateway                    = 502,
    IHTTPStatus503ServiceUnavailable            = 503,
    IHTTPStatus504GatewayTimeout                = 504,
    IHTTPStatus505HTTPVersionNotSupported       = 505,

    /*! @brief https://tools.ietf.org/html/rfc2295 */
    IHTTPStatus506VariantAlsoNegotiates         = 506,
    
    /*! @brief https://tools.ietf.org/html/rfc4918 */
    IHTTPStatus507InsufficientStorage           = 507,
    
    /*! @brief https://tools.ietf.org/html/rfc5842 */
    IHTTPStatus508LoopDetected                  = 508,
    
    /*! @brief https://tools.ietf.org/html/rfc2774 */
    IHTTPStatus510NotExtended                   = 510,
    
    /*! @brief https://tools.ietf.org/html/rfc6585 */
    IHTTPStatus511NetworkAuthenticationRequired = 511
};

/*! @brief default and secure ports for the IHTTPServer
    @discussion because IcedHTTP is written in Objective-C it's not secure to run it as root,
    which would be required to connect to the standard HTTP (80) and HTTPS (443) ports
 
*/
typedef NS_ENUM(NSUInteger, IHTTPDefaultPorts) {
    IHTTPDefaultPort = 8080,
    IHTTPSecurePort = 8443
};

// MARK: - HTTP Header Fields

// static NSString* const IHTTPHeaderTemplate                   = @"Header";
static NSString* const IHTTPContentTypeHeader                   = @"Content-Type";
static NSString* const IHTTPDateHeader                          = @"Date";
static NSString* const IHTTPPragmaHeader                        = @"Pragma";
static NSString* const IHTTPCacheControlHeader                  = @"Cache-Control";
static NSString* const IHTTPConnectionHeader                    = @"Connection";
static NSString* const IHTTPContentLengthHeader                 = @"Content-Length";
static NSString* const IHTTPContentMD5Header                    = @"Content-MD5";
static NSString* const IHTTPUpgradeHeader                       = @"Upgrade";
static NSString* const IHTTPViaHeader                           = @"Via";
static NSString* const IHTTPWarningHeader                       = @"Warning";

// MARK: - HTTP Request Header Fields

static NSString* const IHTTPAcceptHeader                        = @"Accept";
static NSString* const IHTTPAcceptCharsetHeader                 = @"Accept-Charset";
static NSString* const IHTTPAcceptDatetimeHeader                = @"Accept-Datetime";
static NSString* const IHTTPAcceptEncodingHeader                = @"Accept-Encoding";
static NSString* const IHTTPAcceptLanguageHeader                = @"Accept-Language";
static NSString* const IHTTPAccessControlRequestMethodHeader    = @"Access-Control-Request-Method";
static NSString* const IHTTPAccessControlRequestHeadersHeader   = @"Access-Control-Request-Headers";
static NSString* const IHTTPAuthorizationHeader                 = @"Authorization";
static NSString* const IHTTPCookieHeader                        = @"Cookie";
static NSString* const IHTTPExpectHeader                        = @"Expect";
static NSString* const IHTTPForwardedHeader                     = @"Forwarded";
static NSString* const IHTTPFromHeader                          = @"From";
static NSString* const IHTTPHostHeader                          = @"Host";
static NSString* const IHTTPIfMatchHeader                       = @"If-Match";
static NSString* const IHTTPIfModifiedSinceHeader               = @"If-Modified-Since";
static NSString* const IHTTPIfNoneMatchHeader                   = @"If-None-Match";
static NSString* const IHTTPIfRangeHeader                       = @"If-Range";
static NSString* const IHTTPIfUnmodifiedSinceHeader             = @"If-Unmodified-Since";
static NSString* const IHTTPMaxForwardsHeader                   = @"Max-Forwards";
static NSString* const IHTTPOriginHeader                        = @"Origin";
static NSString* const IHTTPProxyAuthorizationHeader            = @"Proxy-Authorization";
static NSString* const IHTTPRangeHeader                         = @"Range";
static NSString* const IHTTPRefererHeader                       = @"Referer";
static NSString* const IHTTPReferrerHeader                      = IHTTPRefererHeader;
static NSString* const IHTTPTEHeader                            = @"TE";
static NSString* const IHTTPUserAgentHeader                     = @"User-Agent";

// MARK: - HTTP Response Header Fields

static NSString* const IHTTPAccessControlAllowOriginHeader      = @"Access-Control-Allow-Origin";
static NSString* const IHTTPAccessControlAllowCredentialsHeader = @"Access-Control-Allow-Credentials";
static NSString* const IHTTPAccessControlExposeHeadersHeader    = @"Access-Control-Expose-Headers";
static NSString* const IHTTPAccessControlMaxAgeHeader           = @"Access-Control-Max-Age";
static NSString* const IHTTPAccessControlAllowMethodsHeader     = @"Access-Control-Allow-Methods";
static NSString* const IHTTPAccessControlAllowHeadersHeader     = @"Access-Control-Allow-Headers";
static NSString* const IHTTPAcceptPatchHeader                   = @"Accept-Patch";
static NSString* const IHTTPAcceptRangesHeader                  = @"Accept-Ranges";
static NSString* const IHTTPAgeHeader                           = @"Age";
static NSString* const IHTTPAllowHeader                         = @"Allow";
static NSString* const IHTTPAltSvcHeader                        = @"Alt-Svc";
static NSString* const IHTTPContentDispositionHeader            = @"Content-Disposition";
static NSString* const IHTTPContentEncodingHeader               = @"Content-Encoding";
static NSString* const IHTTPContentLanguageHeader               = @"Content-Language";
static NSString* const IHTTPContentLocationHeader               = @"Content-Location";
static NSString* const IHTTPContentRangeHeader                  = @"Content-Range";
static NSString* const IHTTPDeltaBaseHeader                     = @"Delta-Base";
static NSString* const IHTTPETagHeader                          = @"ETag";
static NSString* const IHTTPExpiresHeader                       = @"Expires";
static NSString* const IHTTPIMHeader                            = @"IM";
static NSString* const IHTTPLastModifiedHeader                  = @"Last-Modified";
static NSString* const IHTTPLinkHeader                          = @"Link";
static NSString* const IHTTPLocationHeader                      = @"Location";
static NSString* const IHTTPP3PHeader                           = @"P3P";
static NSString* const IHTTPProxyAuthenticateHeader             = @"Pragma";
static NSString* const IHTTPPublicKeyPinsHeader                 = @"Public-Key-Pins";
static NSString* const IHTTPRetryAfterHeader                    = @"Retry-After";
static NSString* const IHTTPServerHeader                        = @"Server";
static NSString* const IHTTPSetCookieHeader                     = @"Set-Cookie";
static NSString* const IHTTPStrictTransportSecurityHeader       = @"Strict-Transport-Security";
static NSString* const IHTTPTrailerHeader                       = @"Trailer";
static NSString* const IHTTPTransferEncodingHeader              = @"Transfer-Encoding";
static NSString* const IHTTPTkHeader                            = @"Tk";
static NSString* const IHTTPVaryHeader                          = @"Vary";
static NSString* const IHTTPWWWAuthenticateHeader               = @"WWW-Authenticate";
static NSString* const IHTTPXFrameOptionsHeader                 = @"X-Frame-Options";

#endif /* IHTTPConstants_h */
