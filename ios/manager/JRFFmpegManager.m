//
//  JRFFmpegManager.m
//  FFmpeg_iOS_Demo
//
//  Created by 邱俊荣 on 2020/5/10.
//  Copyright © 2020 亚美科技. All rights reserved.
//

#import "JRFFmpegManager.h"
#import "ffmpeg.h"


@interface JRFFmpegManager ()

@property (nonatomic, assign) BOOL isRuning;
@property (nonatomic, assign) BOOL isBegin;
@property (nonatomic, assign) long long fileDuration;
@property (nonatomic, copy) void (^processBlock)(float process);
@property (nonatomic, copy) void (^completionBlock)(NSError *error);

@end

@implementation JRFFmpegManager

+ (JRFFmpegManager *)shared {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}


- (void)converWithInputPath:(NSString *)inputPath
                 outputPath:(NSString *)outpath
               processBlock:(void (^)(float process))processBlock
            completionBlock:(void (^)(NSError *error))completionBlock {
    
    self.processBlock = processBlock;
    self.completionBlock = completionBlock;
    self.isBegin = NO;
    
    // ffmpeg语法
    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -i %@ -vcodec h264 %@", inputPath, outpath];

    [[[NSThread alloc] initWithTarget:self selector:@selector(runCmd:) object:commandStr] start];
}

- (void)converWithCommand:(NSString *)commandStr
             processBlock:(void (^)(float process))processBlock
          completionBlock:(void (^)(NSError *error))completionBlock {
    
    self.processBlock = processBlock;
    self.completionBlock = completionBlock;
    self.isBegin = NO;
    
    // ffmpeg语法
    [[[NSThread alloc] initWithTarget:self selector:@selector(runCmd:) object:commandStr] start];
}

- (void)runCmd:(NSString *)commandStr{
    // 判断转换状态
    if (self.isRuning) {
        NSLog(@"正在转换,稍后重试");
    }
    self.isRuning = YES;

    // 根据 空格 将指令分割为指令数组
    NSArray *argv_array = [commandStr componentsSeparatedByString:(@" ")];

    
    int argc = (int)argv_array.count;
    char** argv = (char**)malloc(sizeof(char*)*argc);
    for(int i=0; i < argc; i++) {
        argv[i] = (char*)malloc(sizeof(char)*1024);
        strcpy(argv[i],[[argv_array objectAtIndex:i] UTF8String]);
    }
    
    [JRFFmpegManager shared].pause = NO;
    [JRFFmpegManager shared].cancel = NO;
    
    ffmpeg_main(argc,argv);
}

- (void)setPause:(BOOL)pause {
    _pause = pause;
    qjr_pauseOrResumeEncode();
}

- (void)setCancel:(BOOL)cancel {
    _cancel = cancel;
    qjr_cancelEncode();
}


+ (void)setDuration:(long long)time {
    [JRFFmpegManager shared].fileDuration = time;
}

+ (void)setCurrentTime:(long long)time {
    JRFFmpegManager *mgr = [JRFFmpegManager shared];
    mgr.isBegin = YES;
    
    if (mgr.processBlock && mgr.fileDuration) {
        float process = time/(mgr.fileDuration * 1.00);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            mgr.processBlock(process);
        });
    }
}

+ (void)stopRuning {
    JRFFmpegManager *mgr = [JRFFmpegManager shared];
    NSError *error = nil;
    if (!mgr.isBegin) {
        // 判断是否开始过，没开始过就设置失败
        error = [NSError errorWithDomain:@"转换失败,请检查源文件的编码格式!"
                                    code:0
                                userInfo:nil];
    }
    if (mgr.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            mgr.completionBlock(error);
        });
    }
    
    mgr.isRuning = NO;
}


@end
