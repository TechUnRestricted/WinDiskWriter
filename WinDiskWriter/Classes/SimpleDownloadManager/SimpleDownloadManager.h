//
//  SimpleDownloadManager.h
//  WinDiskWriter
//
//  Created by Macintosh on 01.01.2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SimpleDownloadManager : NSObject<NSURLConnectionDataDelegate>

typedef NS_ENUM(NSUInteger, SDMMessageType) {
    SDMMessageTypeProcess,
    SDMMessageTypeSuccess,
    SDMMessageTypeFailure
};

typedef NS_ENUM(NSUInteger, SDMMessage) {
    SDMMessageDownloadDidReceiveResponse,
    SDMMessageDownloadDidReceiveData,
    SDMMessageDownloadDidFinishLoading,
    SDMMessageDownloadDidFailWithError,
    SDMMessageFinalAtomicFileWrite
};

typedef BOOL (^DownloadCompletionHandler) (SDMMessage message, SDMMessageType messageType, UInt64 bytesDownloaded, UInt64 expectedFileSize, NSError *_Nullable error);

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSourceURL: (NSURL *)sourceURL
                  destinationPath: (NSString *)destinationPath;

- (void)downloadFileAsynchronouslyWithCallback: (DownloadCompletionHandler)callbackReference;

@property (readonly, copy, nonatomic) NSURL *sourceURL;
@property (readonly, copy, nonatomic) NSString *destinationPath;

@end

NS_ASSUME_NONNULL_END
