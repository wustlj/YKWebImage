//
//  ViewController.m
//  YKWebImage
//
//  Created by lijian on 16/2/22.
//  Copyright © 2016年 youku. All rights reserved.
//

#import "ViewController.h"
#import <YKWebImage/YKWebImage.h>
#import <YKWebImage/UIImage+Decode.h>

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
    [self setupData];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[YKImageCache shareInstance] cleanCache];
//    });
}

- (void)setupData {
    _dataArray = [[NSMutableArray alloc] initWithCapacity:10];

    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1601/20yuanxingyinyingtubiao/lollipop.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1601/20yuanxingyinyingtubiao/lifebuoy.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1601/20yuanxingyinyingtubiao/home.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1601/zen-icons/zen-icons-pen.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1507/34yuanxing-icon/stats.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1511/wsj2015/wsj2015-1.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1511/wsj2015/wsj2015-2.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1511/wsj2015/wsj2015-3.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1511/wsj2015/wsj2015-4.png"];
    [_dataArray addObject:@"http://d.lanrentuku.com/down/png/1511/wsj2015/wsj2015-5.png"];

    for (int i=0; i<100; i++) {
        [_dataArray addObject:[NSString stringWithFormat:@"https://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage%03d.jpg", i]];
    }

/*
    [_dataArray addObject:@"FICDDemoImage001.jpg"];
    [_dataArray addObject:@"FICDDemoImage002.jpg"];
    [_dataArray addObject:@"FICDDemoImage004.jpg"];
*/
    
#pragma Test Cache
/*
    [_dataArray addObject:@"lifebuoy.png"];
    [_dataArray addObject:@"lollipop.png"];
    [_dataArray addObject:@"stats.png"];
    [_dataArray addObject:@"zen-icons-pen.png"];
    for (NSString *name in _dataArray) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        [[YKImageCache shareInstance] storeImage:image forKey:name];
    }
 */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSString *fileName = [_dataArray[indexPath.row] lastPathComponent];

    [cell.imageView setImageWithURL:[NSURL URLWithString:_dataArray[indexPath.row]] placeholderImage:[UIImage imageNamed:@"2015sdj_002.png"]];

#pragma mark - Test Image decode
/*
    UIImage *originImage = [UIImage imageNamed:_dataArray[indexPath.row]];
    UIImage *decodeImage = [UIImage decodeImageWithImage:originImage];
    
    NSData *oData = UIImageJPEGRepresentation(originImage, 0.5);
    NSData *dData = UIImagePNGRepresentation(decodeImage);
    
    NSString *oPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [fileName stringByDeletingPathExtension]]];
    NSString *dPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [fileName stringByDeletingPathExtension]]];
    [oData writeToFile:oPath atomically:YES];
    [dData writeToFile:dPath atomically:YES];
    
    NSLog(@"%lu,%lu", (unsigned long)[oData length], (unsigned long)[dData length]);
    
    cell.imageView.image = decodeImage;
*/
    cell.textLabel.text = fileName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.imageView cancelImageDownload];
}

@end
