//
//  DownloadManager.m
//  WinDiskWriter
//
//  Created by Macintosh on 01.01.2024.
//

#import "DownloadManager.h"
#import "NSError+Common.h"

@implementation DownloadManager {
    NSURLRequest *urlRequest;
    NSURLConnection *urlConnection;
    
    DownloadCompletionHandler callback;
    
    UInt64 expectedFileSize;
    UInt64 receivedBytesSize;
    
    NSFileHandle *destinationFileHandle;
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
    receivedBytesSize = 0;
    
    callback = callbackReference;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath: self.destinationPath]) {
        NSError *fileRemoveError = nil;
        [fileManager removeItemAtPath: self.destinationPath
                                error: &fileRemoveError];
        
        BOOL shouldContinue = callback(DMMessageOldFileRemove, (fileRemoveError != NULL ? DMMessageTypeSuccess : DMMessageTypeFailure), 0, 0, fileRemoveError);
        
        if (!shouldContinue || fileRemoveError != NULL) {
            return;
        }
    }
    
    {
        NSError *emptyFileCreateError = NULL;
        BOOL emptyFileCreated = [fileManager createFileAtPath: self.destinationPath
                                                     contents: nil
                                                   attributes: nil];
        
        if (!emptyFileCreated) {
            emptyFileCreateError = [NSError errorWithStringValue: @"Can't create an empty file for file handle."];
        }
        
        BOOL shouldContinue = callback(DMMessageBlankFileCreated, (emptyFileCreateError == NULL ? DMMessageTypeSuccess : DMMessageTypeFailure), 0, 0, emptyFileCreateError);
        
        if (!shouldContinue || emptyFileCreateError != NULL) {
            [self stopWithCleanup];
            
            return;
        }
    }
    
    {
        NSError *openFileHandleError;
        destinationFileHandle = [NSFileHandle fileHandleForWritingAtPath: self.destinationPath];
        
        if (destinationFileHandle == NULL) {
            openFileHandleError = [NSError errorWithStringValue: @"Can't open the file handle for the destination device."];
        }
        
        BOOL shouldContinue = callback(DMMessageOpenFileHandle, (destinationFileHandle != NULL ? DMMessageTypeSuccess : DMMessageTypeFailure), 0, 0, openFileHandleError);
        
        if (!shouldContinue || openFileHandleError != NULL) {
            [self stopWithCleanup];
            
            return;
        }
    }
    
    [urlConnection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    expectedFileSize = [response expectedContentLength];
    
    BOOL shouldContinue = callback(DMMessageDownloadDidReceiveResponse, DMMessageTypeSuccess, 0, expectedFileSize, NULL);
    if (!shouldContinue) {
        [self stopWithCleanup];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    receivedBytesSize += data.length;
    
    if (!callback(DMMessageDownloadDidReceiveData, DMMessageTypeSuccess, receivedBytesSize, expectedFileSize, NULL)) {
        [self stopWithCleanup];
        
        return;
    }
    
    NSError *writeDataChunkError = NULL;
    @try {
        [destinationFileHandle writeData: data];
    } @catch (NSException *exception) {
        writeDataChunkError = [NSError errorWithStringValue: exception.reason];
    }
    
    BOOL shouldContinue = callback(DMMessageFileChunkWrite, (writeDataChunkError == NULL ? DMMessageTypeSuccess : DMMessageTypeFailure), receivedBytesSize, expectedFileSize, writeDataChunkError);
    
    if (writeDataChunkError != NULL || !shouldContinue) {
        [self stopWithCleanup];
        
        return;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    callback(DMMessageDownloadDidFailWithError, DMMessageTypeFailure, receivedBytesSize, expectedFileSize, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    callback(DMMessageDownloadDidFinishLoading, DMMessageTypeSuccess, receivedBytesSize, expectedFileSize, NULL);
}

- (void)stopWithCleanup {
    [urlConnection cancel];
    
    if (destinationFileHandle != NULL) {
        [destinationFileHandle closeFile];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: self.destinationPath]) {
        [fileManager removeItemAtPath: self.destinationPath
                                error: NULL];
    }
}

- (void)dealloc {
    [self stopWithCleanup];
}

@end
