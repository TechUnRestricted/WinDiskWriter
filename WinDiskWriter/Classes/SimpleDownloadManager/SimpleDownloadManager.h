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
    SDMMessageDidReceiveResponse,
    SDMMessageDidReceiveData,
    SDMMessageDidFinishLoading,
    SDMMessageDidFailWithError
};

typedef struct {
    NSURLRequest *urlRequest;
    NSURLResponse *urlResponse;
} SDMCallbackStructDidReceiveResponse;

typedef struct {
    NSData *data;
    UInt64 expectedFileSize;
    UInt64 downloadedBytesSize;
    UInt64 chunkNumber;
} SDMCallbackStructDidReceiveData;

typedef struct {
    UInt64 expectedFileSize;
    UInt64 downloadedBytesSize;
} SDMCallbackStructDidFinishLoading;

typedef struct {
    NSURLRequest *urlRequest;
} SDMCallbackStructDidFailWithError;

typedef BOOL (^DownloadCompletionHandler) (SDMMessage message, SDMMessageType messageType, void *SDMCallbackStruct, NSError *_Nullable error);

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSourceURL: (NSURL *)sourceURL
                  destinationPath: (NSString *)destinationPath
                temporaryFilePath: (NSString *)temporaryFilePath;

- (BOOL)downloadFileSynchronouslyWithCallback: (DownloadCompletionHandler)callbackReference;

@property (readonly, copy, nonatomic) NSURL *sourceURL;
@property (readonly, copy, nonatomic) NSString *destinationPath;
@property (readonly, copy, nonatomic) NSString *temporaryFilePath;

@property (readwrite, nonatomic) BOOL forbidUnknownResponseLength;
@property (readwrite, nonatomic) BOOL forbidIncorrectStatusCode;


@end

NS_ASSUME_NONNULL_END
