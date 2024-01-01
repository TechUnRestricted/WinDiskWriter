//
//  DownloadManager.h
//  WinDiskWriter
//
//  Created by Macintosh on 01.01.2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadManager : NSObject<NSURLConnectionDataDelegate>

typedef NS_ENUM(NSUInteger, DMMessageType) {
    DMMessageTypeSuccess,
    DMMessageTypeFailure
};

typedef NS_ENUM(NSUInteger, DMMessage) {
    DMMessageDownloadDidReceiveResponse,
    DMMessageDownloadDidReceiveData,
    DMMessageDownloadDidFinishLoading,
    DMMessageDownloadDidFailWithError,
    DMMessageBlankFileCreated,
    DMMessageOpenFileHandle,
    DMMessageOldFileRemove,
    DMMessageFileChunkWrite
};

typedef BOOL (^DownloadCompletionHandler) (DMMessage message, DMMessageType messageType, UInt64 bytesCopied, UInt64 expectedFileSize, NSError *_Nullable error);

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSourceURL: (NSURL *)sourceURL
                  destinationPath: (NSString *)destinationPath;

- (void)downloadFileAsynchronouslyWithCallback: (DownloadCompletionHandler)callbackReference;

@property (readonly, copy, nonatomic) NSURL *sourceURL;
@property (readonly, copy, nonatomic) NSString *destinationPath;

@end

NS_ASSUME_NONNULL_END
