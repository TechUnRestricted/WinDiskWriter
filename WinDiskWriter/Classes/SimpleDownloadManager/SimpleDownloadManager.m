//
//  SimpleDownloadManager.m
//  WinDiskWriter
//
//  Created by Macintosh on 01.01.2024.
//

#import "SimpleDownloadManager.h"
#import "LocalizedStrings.h"
#import "NSError+Common.h"

@implementation SimpleDownloadManager {
    NSMutableURLRequest *urlRequest;
    NSURLConnection *urlConnection;
    
    DownloadCompletionHandler callback;
    NSFileHandle *temporaryStorageFileHandle;
    NSFileManager *fileManager;
    
    UInt64 expectedFileSize;
    UInt64 chunkNumber;
    UInt64 downloadedBytesSize;
    
    CFRunLoopRef currentRunLoop;
    
    BOOL operationSuccessful;
}

- (instancetype)initWithSourceURL: (NSURL *)sourceURL
                  destinationPath: (NSString *)destinationPath
                temporaryFilePath: (NSString *)temporaryFilePath {
    self = [super init];
    
    _sourceURL = sourceURL;
    _destinationPath = destinationPath;
    _temporaryFilePath = temporaryFilePath;
    
    fileManager = [[NSFileManager alloc] init];
    
    _forbidUnknownResponseLength = YES;
    _forbidIncorrectStatusCode = YES;
    
    urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL: sourceURL];
    [urlRequest setTimeoutInterval: 15];
    [urlRequest setCachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [urlRequest setHTTPShouldHandleCookies: NO];
    
    if (@available(macOS 10.8, *)) {
        [urlRequest setAllowsCellularAccess: YES];
    }
    
    if (@available(macOS 10.15, *)) {
        [urlRequest setAllowsExpensiveNetworkAccess: YES];
        [urlRequest setAllowsConstrainedNetworkAccess: YES];
    }
    
    urlConnection = [[NSURLConnection alloc] initWithRequest: urlRequest
                                                    delegate: self
                                            startImmediately: NO];
    
    return self;
}

- (BOOL)downloadFileSynchronouslyWithCallback: (DownloadCompletionHandler)callbackReference {
    expectedFileSize = 0;
    chunkNumber = 0;
    downloadedBytesSize = 0;
    
    callback = callbackReference;
    
    currentRunLoop = CFRunLoopGetCurrent();
    
    operationSuccessful = NO;
    
    SDMCallbackStructDidFailWithError callbackStruct; {
        callbackStruct.urlRequest = urlRequest;
    }
    
    for (NSString *outputFilePath in @[self.destinationPath, self.temporaryFilePath]) {
        BOOL fileExists = [fileManager fileExistsAtPath: outputFilePath];
        
        if (!fileExists) {
            continue;
        }
        
        NSError *fileRemoveError = NULL;
        
        [fileManager removeItemAtPath: outputFilePath
                                error: &fileRemoveError];
        
        if (fileRemoveError != NULL) {
            callback(SDMMessageDidFailWithError, SDMMessageTypeFailure, &callbackStruct, fileRemoveError);
            
            return NO;
        }
    }
    
    
    {
        BOOL fileCreateSuccess = [fileManager createFileAtPath: self.temporaryFilePath
                                                      contents: NULL
                                                    attributes: NULL];
        
        
        if (!fileCreateSuccess) {
            NSString *fileCreateErrorString = [LocalizedStrings errorTextCantCreateTemporaryBlankFileWithArgument1: self.temporaryFilePath];
            NSError *fileCreateError = [NSError errorWithStringValue: fileCreateErrorString];
            
            callback(SDMMessageDidFailWithError, SDMMessageTypeFailure, &callbackStruct, fileCreateError);
            
            return NO;
        }
    }
    
    temporaryStorageFileHandle = [NSFileHandle fileHandleForWritingAtPath: self.temporaryFilePath];
    if (temporaryStorageFileHandle == NULL) {
        NSString *errorString = [LocalizedStrings errorTextCantOpenFilehandleForTempFilePathWithArgument1: self.temporaryFilePath];
        NSError *openFileHandleError = [NSError errorWithStringValue: errorString];
        
        callback(SDMMessageDidFailWithError, SDMMessageTypeFailure, &callbackStruct, openFileHandleError);

        return NO;
    }
    
    [urlConnection start];
    
    CFRunLoopRun();
    
    return operationSuccessful;
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
    
    SDMCallbackStructDidReceiveResponse callbackStruct; {
        callbackStruct.urlRequest = urlRequest;
        callbackStruct.urlResponse = response;
    }
    
    if (self.forbidUnknownResponseLength && expectedFileSize == NSURLResponseUnknownLength) {
        NSError *responseUnknownLengthError = [NSError errorWithStringValue: [LocalizedStrings errorTextUrlConnectionUnknownResponseLength]];
        
        callback(SDMMessageDidReceiveResponse, SDMMessageTypeFailure, &callbackStruct, responseUnknownLengthError);
        
        [self abortWithCleanup];
        return;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = httpResponse.statusCode;
    
    BOOL hasCorrectStatusCode = (statusCode == 200);
    if (self.forbidIncorrectStatusCode && !hasCorrectStatusCode) {        
        NSError *incorrectStatusCodeError = [NSError errorWithStringValue: [LocalizedStrings errorTextHttpResponseIncorrectStatusWithArgument1: statusCode]];
        
        callback(SDMMessageDidReceiveResponse, SDMMessageTypeFailure, &callbackStruct, incorrectStatusCodeError);
        
        [self abortWithCleanup];
        
        return;
    }
    
    BOOL shouldContinue = callback(SDMMessageDidReceiveResponse, SDMMessageTypeSuccess, &callbackStruct, NULL);
    if (!shouldContinue) {
        [self abortWithCleanup];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    SDMCallbackStructDidReceiveData callbackStruct; {
        callbackStruct.data = data;
        callbackStruct.expectedFileSize = expectedFileSize;
        callbackStruct.chunkNumber = ++chunkNumber;
        callbackStruct.downloadedBytesSize = (downloadedBytesSize += data.length);
    }
    
    NSError *fileHandleWriteError = NULL;
    if (@available(macOS 10.15, *)) {
        [temporaryStorageFileHandle writeData: data
                                        error: &fileHandleWriteError];
    } else {
        @try {
            [temporaryStorageFileHandle writeData: data];
        } @catch (NSException *exception) {
            fileHandleWriteError = [NSError errorWithStringValue: exception.reason];
        }
    }
    
    BOOL shouldContinue = callback(SDMMessageDidReceiveData, (fileHandleWriteError == NULL ? SDMMessageTypeSuccess : SDMMessageTypeFailure), &callbackStruct, fileHandleWriteError);
    
    if (fileHandleWriteError != NULL || !shouldContinue) {
        [self abortWithCleanup];
        
        return;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SDMCallbackStructDidFailWithError callbackStruct; {
        callbackStruct.urlRequest = urlRequest;
    }
    
    callback(SDMMessageDidFailWithError, SDMMessageTypeFailure, &callbackStruct, error);
    
    [self stopRunLoop];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    SDMCallbackStructDidFinishLoading callbackStruct; {
        callbackStruct.downloadedBytesSize = downloadedBytesSize;
        callbackStruct.expectedFileSize = expectedFileSize;
    }
    
    NSError *moveFromTemporaryFolderError = NULL;
    
    [fileManager moveItemAtPath: self.temporaryFilePath
                         toPath: self.destinationPath
                          error: &moveFromTemporaryFolderError];
    
    callback(SDMMessageDidFinishLoading, (moveFromTemporaryFolderError == NULL ? SDMMessageTypeSuccess : SDMMessageTypeFailure), &callbackStruct, moveFromTemporaryFolderError);
    
    operationSuccessful = YES;
    
    [self stopRunLoop];
}

- (void)abortWithCleanup {
    [urlConnection cancel];
    
    for (NSString *pathToRemove in @[self.temporaryFilePath, self.destinationPath]) {
        if ([fileManager fileExistsAtPath: pathToRemove]) {
            [fileManager removeItemAtPath: pathToRemove
                                    error: NULL];
        }
    }
    
    [self stopRunLoop];
}

- (void)stopRunLoop {
    CFRunLoopStop(currentRunLoop);    
}

@end
