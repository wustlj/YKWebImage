//
//  UIImageView+YKImageCache.m
//  YKWebImage
//
//  Created by lijian on 16/2/25.
//  Copyright © 2016年 youku. All rights reserved.
//

#import "UIImageView+YKImageCache.h"
#import <objc/runtime.h>
#import "YKImageCache.h"
#import "YKImageDownload.h"
#import "YKImageDownloadOperation.h"

static char imageURLKey;
static char operationKey;

@interface UIImageView ()

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) id operation;

@end

@implementation UIImageView (YKImageCache)

- (NSURL *)imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)setImageURL:(NSURL *)imageURL {
    objc_setAssociatedObject(self, &imageURLKey, imageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)operation {
    return objc_getAssociatedObject(self, &operationKey);
}

- (void)setOperation:(id)operation {
    objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder  {
    [self setImageWithURL:url placeholderImage:placeholder completionBlock:NULL];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completionBlock:(void (^)(void))block {
    [self cancelImageDownload];
    
    self.imageURL = url;
    
    self.image = placeholder;
    
    if (url) {
        UIImage *image = [[YKImageCache shareInstance] imageFromCacheForKey:[url absoluteString]];
        
        if (!image) {
            __weak __typeof(self) wself = self;
           YKImageDownloadOperation *operation = [[YKImageDownload shareInstance] downloadImageWithURL:url progress:NULL completed:^(UIImage *image, NSError *error, BOOL isFinished) {
                UIImageView *sself = wself;
                if (!sself) return ;
               
                sself.operation = nil;
               
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        sself.image = image;
                        [sself setNeedsLayout];
                    });
                    
                    if (isFinished) {
                        [[YKImageCache shareInstance] storeImage:image forKey:[url absoluteString]];
                    }
                    
                    if (block) {
                        block();
                    }
                }
            }];
            
            self.operation = operation;
        } else {
            NSLog(@"use cache (%@)", url);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
            });
            
            if (block) {
                block();
            }
        }
    }
}

- (void)cancelImageDownload {
    YKImageDownloadOperation *opeartion = self.operation;
    if (opeartion) {
        [opeartion cancel];
        
        self.operation = nil;
    }
}

- (void)setImageSmooth:(UIImage *)image {
    [self performSelector:@selector(setImage:) withObject:image afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
}

@end
