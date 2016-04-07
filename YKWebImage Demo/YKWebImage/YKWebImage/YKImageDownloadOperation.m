//
//  YKImageDownloadOperation.m
//  YKWebImage
//
//  Created by lijian on 16/2/22.
//  Copyright © 2016年 youku. All rights reserved.
//

#import "YKImageDownloadOperation.h"
#import "UIImage+Decode.h"

@interface YKImageDownloadOperation () <NSURLConnectionDataDelegate>
{
    NSInteger _expectedSize;
}
@property (nonatomic, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, assign, getter=isFinished) BOOL finished;

@property (nonatomic, copy) YKImageDownloadProgressBlock progressBlock;
@property (nonatomic, copy) YKImageDownloadCompletedBlock completedBlock;

@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSThread *thread;

@property (nonatomic, assign) BOOL shouldDecompressImage;

@end

@implementation YKImageDownloadOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

- (id)initWithRequest:(NSURLRequest *)request progress:(YKImageDownloadProgressBlock)progressBlock completed:(YKImageDownloadCompletedBlock)completedBlock {
    self = [super init];
    if (self) {
        _request = request;
        _progressBlock = [progressBlock copy];
        _completedBlock = [completedBlock copy];
        self.name = [request.URL absoluteString];
        _shouldDecompressImage = YES;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"YKImageDownloadOperation dealloc (%@)", self.request.URL);
}

- (void)start {
    @synchronized(self) {
        if (self.isCancelled) {
            self.finished = YES;
            return;
        }
        
        self.executing = YES;
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
        self.thread = [NSThread currentThread];
    }
    
    [self.urlConnection start];
    
    CFRunLoopRun();
    
    if ([self isCancelled]) {
        [self finish];
        return;
    }
    if (!self.finished) {
        [self.urlConnection cancel];
    }
}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)cancel {
    @synchronized(self) {
        if (self.thread) {
            [self performSelector:@selector(cancelInternalAndStop) onThread:self.thread withObject:nil waitUntilDone:nil];
        } else {
            [self cancelInternal];
        }
    }
}

- (void)cancelInternalAndStop {
    [self cancelInternal];
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)cancelInternal {
    if (self.isFinished) return;
    
    NSLog(@"cancel %@", self.request.URL);

    [super cancel];
    
    if (self.isExecuting) {
        [self.urlConnection cancel];
        self.finished = YES;
        self.executing = NO;
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    NSLog(@"%@", response);
    
    if (![response respondsToSelector:@selector(statusCode)] || ([(NSHTTPURLResponse *)response statusCode] < 400 && [(NSHTTPURLResponse *)response statusCode] != 304)) {
        _expectedSize = response.expectedContentLength;
        self.receivedData = [[NSMutableData alloc] initWithCapacity:_expectedSize];
    } else {
        NSUInteger code = [((NSHTTPURLResponse *)response) statusCode];

        if (code == 304) {
            [self cancel];
        } else {
            [self.urlConnection cancel];
        }
        
        if (self.completedBlock) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:code userInfo:@{NSURLErrorFailingURLErrorKey: self.request.URL}];
            self.completedBlock(nil, error, YES);
        }
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
    
    if (self.progressBlock) {
        self.progressBlock(self.receivedData.length, _expectedSize);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    CFRunLoopStop(CFRunLoopGetCurrent());
    
    if (self.completedBlock) {
        UIImage *image = [UIImage imageWithData:self.receivedData];
        
        if (self.shouldDecompressImage) {
            image = [UIImage decodeImageWithImage:image];
        }
        
//        uint8_t c;
//        [self.receivedData getBytes:&c length:1];
//        NSLog(@"%hhu", c);
        
        NSLog(@"download finished (%@)", self.request.URL);
        self.completedBlock(image, nil, YES);
    }
    
    [self finish];
}

- (void)finish {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);

    CFRunLoopStop(CFRunLoopGetCurrent());

    [self finish];
    
    self.receivedData = nil;
    
    if (self.completedBlock) {
        self.completedBlock(nil, error, YES);
    }
}

@end
