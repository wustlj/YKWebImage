//
//  YKImageDownload.m
//  YKWebImage
//
//  Created by lijian on 16/2/22.
//  Copyright © 2016年 youku. All rights reserved.
//

#import "YKImageDownload.h"
#import "YKImageDownloadOperation.h"

@interface YKImageDownload ()
{
    NSOperationQueue *_downloadQueue;
}

@end

@implementation YKImageDownload

- (id)init {
    self = [super init];
    if (self) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 6;
        _downloadTimeoutInterval = 30;
    }
    return self;
}

+ (YKImageDownload *)shareInstance {
    static YKImageDownload *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[YKImageDownload alloc] init];
    });
    
    return shareInstance;
}

- (YKImageDownloadOperation *)downloadImageWithURL:(NSURL *)url progress:(YKImageDownloadProgressBlock)progressBlock completed:(YKImageDownloadCompletedBlock)completedBlock {
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.downloadTimeoutInterval];
    __weak __typeof(self) wself = self;
    YKImageDownloadOperation *operation = [[YKImageDownloadOperation alloc] initWithRequest:request progress:progressBlock completed:^(UIImage *image, NSError *error, BOOL isFinished) {
        if (!wself) return ;
        
        completedBlock(image, error, isFinished);
    }];
    
    [_downloadQueue addOperation:operation];
    
    NSLog(@"add request : %@", request.URL);
    
    return operation;
}

- (void)setSuspended:(BOOL)suspended {
    _downloadQueue.suspended = suspended;
}

- (void)setMaxConcurrentDownloadCount:(NSInteger)maxConcurrentDownloadCount {
    _downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloadCount;
}

- (NSInteger)maxConcurrentDownloadCount {
    return _downloadQueue.maxConcurrentOperationCount;
}

@end
