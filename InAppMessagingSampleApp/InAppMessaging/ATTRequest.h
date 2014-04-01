// Copyright (c) 2013 AT&T (htpp://developer.att.com)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
@class AFHTTPRequestOperation;

extern NSString* const IAMTrue;
extern NSString* const IAMFalse;
extern NSString* const RTJson;

/** Encapsulates an HTTP request options as they apply for consuming 
 AT&T's RESTful APIs 
 
 ## Methods to override
 
 Sub-classes should override the `-parseResponse:forOperation:error:` method
 to implement the right mapping from the reponse to the native object.
 
 Sub-classes should override the `-prepareParameters` method to create the 
 correct `NSDictionary` to create the `AFHTTPRequestOperation`.
 */
@interface ATTRequest : NSObject


/// @name Accessing the properties

/** The HTTP method to be used in the request */
@property (nonatomic, copy) NSString* method;
/** The path to the API resource */
@property (nonatomic, copy) NSString* path;
/** The parameters for the HTTP request. 
 
 @discussion For `GET` and `DELETE` requests. They represent the 
 parameters in the query string. For the rest of the HTTP methods 
 the parameters are sent in the body.
 */
@property (nonatomic, retain, readonly) NSDictionary* params;
/** The type of the resource requested. 
 @discussion Used to determine which sub-class of AFHTTPRequesOperation to 
 use when creating the HTTP request. */
@property (nonatomic, retain) NSString* responseType;

/// @name Preparing the request parameters

/** Creates/Updates the dictionary of request parameters.

 @discussion The process of creating this dictionary is particular for each
 request. It has to take into account the following guidelines:
 
 * add parameters that are mandatory.
 * mandatory parameters should have reasonable default values.
 * optional parameters should have default values
 * add optional parameters only if they they have been assigned values
 different from the defaults.
 */
-(NSMutableDictionary*)prepareParameters;


/// @name Generating `NSObjects` from the response.

/** Converts the response into NSObjects to facilitate access to their properties. 
 
 @param response The `NSDictionary` or `NSData` obtained as the HTTP response.
 @param operation The `AFHTTPOperation` that originated the `response`
 @param error Used to report if there's an error during the tranformation.
 
 @discussion Most requests are sent as `AFJSONOperation` instances except the ones
 that request binary data, those will be sent as `AFHTTPRequestOperation` instances.
 */
-(id)parseResponse:(id)response forOperation:(AFHTTPRequestOperation*)operation
             error:(NSError**)error;


@end
