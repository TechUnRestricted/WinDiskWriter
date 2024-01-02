//
//  SimpleDownloadManager.m
//  WinDiskWriter
//
//  Created by Macintosh on 01.01.2024.
//

#import "SimpleDownloadManager.h"
#import "NSError+Common.h"

@implementation SimpleDownloadManager {
    NSURLRequest *urlRequest;
    NSURLConnection *urlConnection;
    
    DownloadCompletionHandler callback;
    
    UInt64 expectedFileSize;
    
    NSMutableData *mutableData;
}

- (instancetype)initWithSourceURL: (NSURL *)sourceURL
                  destinationPath: (NSString *)destinationPath {
    self = [super init];
    
    _sourceURL = sourceURL;
    _destinationPath = destinationPath;
    
    urlRequest = [NSURLRequest requestWithURL: sourceURL
                                  cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                              timeoutInterval: 30];
    
    urlConnection = [[NSURLConnection alloc] initWithRequest: urlRequest
                                                    delegate: self
                                            startImmediately: NO];
    
    return self;
}

- (void)downloadFileAsynchronouslyWithCallback: (DownloadCompletionHandler)callbackReference {
    expectedFileSize = 0;
    mutableData = [[NSMutableData alloc] init];
    
    callback = callbackReference;
    
    [urlConnection start];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString: NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSURLCredential *urlCredential = [NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust];
    
    [challenge.sender useCredential: urlCredential
         forAuthenticationChallenge: challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    expectedFileSize = [response expectedContentLength];
    
    if (expectedFileSize == NSURLResponseUnknownLength) {
        NSError *responseUnknownLengthError = [NSError errorWithStringValue: @"NSURLConnection Response length is unknown."];
        
        callback(SDMMessageDownloadDidReceiveResponse, SDMMessageTypeFailure, 0, expectedFileSize, responseUnknownLengthError);
        
        [self abortWithCleanup];
        return;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = httpResponse.statusCode;
    
    BOOL hasCorrectStatusCode = (statusCode == 200);
    if (!hasCorrectStatusCode) {
        NSError *incorrectStatusCodeError = [NSError errorWithStringValue: [NSString stringWithFormat: @"HTTP Response has incorrect status status code: %ld.", statusCode]];
        
        callback(SDMMessageDownloadDidReceiveResponse, SDMMessageTypeFailure, 0, expectedFileSize, incorrectStatusCodeError);
        
        [self abortWithCleanup];
        
        return;
    }
    
    BOOL shouldContinue = callback(SDMMessageDownloadDidReceiveResponse, SDMMessageTypeSuccess, 0, expectedFileSize, NULL);
    if (!shouldContinue) {
        [self abortWithCleanup];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [mutableData appendData: data];
    
    if (!callback(SDMMessageDownloadDidReceiveData, SDMMessageTypeSuccess, mutableData.length, expectedFileSize, NULL)) {
        [self abortWithCleanup];
        
        return;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    callback(SDMMessageDownloadDidFailWithError, SDMMessageTypeFailure, mutableData.length, expectedFileSize, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSUInteger mutableDataLength = mutableData.length;
    
    {
        BOOL shouldContinue = callback(SDMMessageDownloadDidFinishLoading, SDMMessageTypeSuccess, mutableDataLength, expectedFileSize, NULL);
        if (!shouldContinue) {
            return;
        }
    }
    
    {
        BOOL shouldContinue = callback(SDMMessageFinalAtomicFileWrite, SDMMessageTypeProcess, mutableDataLength, expectedFileSize, NULL);
        if (!shouldContinue) {
            return;
        }
    }
    
    NSError *atomicWriteError = NULL;
    BOOL atomicWriteSuccessful = [mutableData writeToFile: self.destinationPath
                                                  options: NSDataWritingAtomic
                                                    error: &atomicWriteError];
    
    callback(SDMMessageFinalAtomicFileWrite, (atomicWriteSuccessful ? SDMMessageTypeSuccess : SDMMessageTypeFailure), mutableDataLength, expectedFileSize, atomicWriteError);
}

- (void)abortWithCleanup {
    [urlConnection cancel];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: self.destinationPath]) {
        [fileManager removeItemAtPath: self.destinationPath
                                error: NULL];
    }
}

@end
