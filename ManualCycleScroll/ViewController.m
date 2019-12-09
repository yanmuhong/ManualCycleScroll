//
//  ViewController.m
//  ManualCycleScroll
//
//  Created by Hertz Goo on 2019/12/9.
//  Copyright © 2019 Hertz Goo. All rights reserved.
//

#import "ViewController.h"
#import "UIView+BBLayout.h"

#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight [UIScreen mainScreen].bounds.size.height
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kBackgroundColor UIColorFromRGB(0xf5f5f5)
#define kZYellowColor UIColorFromRGB(0xff9600)

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *redRollArr;
@property (nonatomic, strong) NSArray *originalImageArr;
@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, assign) BOOL isLoadCollection;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.redRollArr = [NSMutableArray array];
    
    [self loadAppOpenAds];
}

- (void)loadAppOpenAds {
    
    self.originalImageArr = @[
                              @"feedingthedog",
                              @"lbxxboycool"
                              ];
    self.imageArr = [NSMutableArray array];
    for (int i = 0; i < 50; i++) {
        [self.imageArr addObjectsFromArray:self.originalImageArr];
    }
    [self imageArrAdUI];
}

-(void)imageArrAdUI {
    
    // 布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kDeviceWidth, KDeviceHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    // UICollectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, KDeviceHeight) collectionViewLayout:layout];
    collectionView.backgroundColor = kBackgroundColor;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.pagingEnabled = YES;
    collectionView.bounces = NO;
    [self.view addSubview:collectionView];
    
    // 设置代理
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    // 注册cell
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
    // 圆点
    CGFloat redRoll_w = 10;
    CGFloat redRoll_space = 20;
    UIView *redRollBackView = [[UIView alloc] initWithFrame:CGRectMake(0, KDeviceHeight - redRoll_w*3, self.originalImageArr.count*redRoll_w + (self.originalImageArr.count - 1)*redRoll_space, redRoll_w)];
    redRollBackView.bb_centerX = self.view.bb_centerX;
    [self.view addSubview:redRollBackView];
    if (self.originalImageArr.count <= 1) {
        redRollBackView.hidden = YES;
    }
    
    [self.redRollArr removeAllObjects];
    for (int i = 0; i < self.originalImageArr.count; i++) {
        CGFloat redRoll_x = redRoll_space*i+redRoll_w*i;
        UIView *redRoll = [[UIView alloc] initWithFrame:CGRectMake(redRoll_x, 0, redRoll_w, redRoll_w)];
        redRoll.tag = i;
        redRoll.layer.cornerRadius = redRoll_w*0.5;
        redRoll.layer.masksToBounds = NO;
        [redRollBackView addSubview:redRoll];
        if (i == 0) {
            redRoll.bb_width = redRoll_w + 10;
            redRoll.backgroundColor = kZYellowColor;
        } else {
            redRoll.bb_width = redRoll_w;
            redRoll.backgroundColor = kBackgroundColor;
        }
        [self.redRollArr addObject:redRoll];
    }
}

-(UIImage *)gifImageView:(NSURL *)gifUrl {
    
    UIImage *animatedImage = nil;
    NSData *gifData = [NSData dataWithContentsOfURL:gifUrl];
    //    NSData *gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"demo.gif" ofType:nil]];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)gifData, NULL);
    size_t imageCount = CGImageSourceGetCount(source);
    if (imageCount <= 1) {
        animatedImage = [[UIImage alloc] initWithData:gifData];
    } else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < imageCount; i++) {
            
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            if (!imageRef) {
                continue;
            }
            
            float frameDuration = 0.1f;
            
            CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, i, nil);
            
            NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
            
            NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];    // 从字典中获取这一帧持续的时间
            NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            if (delayTimeUnclampedProp) {
                frameDuration = [delayTimeUnclampedProp floatValue];
            } else {
                NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
                if (delayTimeProp) {
                    frameDuration = [delayTimeProp floatValue];
                }
            }
            
            CFRelease(cfFrameProperties);
            duration += frameDuration;
            [images addObject:[UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            CGImageRelease(imageRef);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * imageCount;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
        CFRelease(source);
    }
    return animatedImage;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
// 几组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1; //外层数组个数
}

// 每组对应几个item
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArr.count; //外层数组对应的内层数组个数
}

// 设置item具体内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    NSString *cdnurlios = self.imageArr[indexPath.row];
    
    if (cdnurlios.length > 0) {
        CGRect tipRect = CGRectMake(0, 0, kDeviceWidth, KDeviceHeight);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:tipRect];
        imgView.image = [UIImage imageNamed:cdnurlios];
        [cell.contentView addSubview:imgView];
    }
    
    return cell;
}

// item选中之后做什么事
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isLoadCollection == NO) {
        self.isLoadCollection = YES;
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.originalImageArr.count*6 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    
    for (UIView *redRoll in self.redRollArr) {
        if (redRoll.tag == indexPath.row%self.originalImageArr.count) {
            NSLog(@"%ld===%lu",(long)redRoll.tag,indexPath.row%self.originalImageArr.count);
            redRoll.bb_width = 20;
            redRoll.backgroundColor = kZYellowColor;
        } else {
            redRoll.bb_width = 10;
            redRoll.backgroundColor = kBackgroundColor;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger index = scrollView.contentOffset.x/kDeviceWidth + 0.5;
    for (UIView *redRoll in self.redRollArr) {
        if (redRoll.tag == index%self.originalImageArr.count) {
            redRoll.bb_width = 20;
            redRoll.backgroundColor = kZYellowColor;
        } else {
            redRoll.bb_width = 10;
            redRoll.backgroundColor = kBackgroundColor;
        }
    }
}

@end
