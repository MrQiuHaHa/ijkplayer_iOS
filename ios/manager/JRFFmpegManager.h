//
//  JRFFmpegManager.h
//  FFmpeg_iOS_Demo
//
//  Created by 邱俊荣 on 2020/5/10.
//  Copyright © 2020 亚美科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JRFFmpegManager : NSObject

+ (JRFFmpegManager *)shared;

/// 暂停或者继续转码
@property (nonatomic, assign) BOOL pause;

/// 取消转码
@property (nonatomic, assign) BOOL cancel;

/**
 @param inputPath 输入视频路径
 @param outpath 输出视频路径
 @param processBlock 进度回调
 @param completionBlock 结束回调
 *
 */
- (void)converWithInputPath:(NSString *)inputPath
                 outputPath:(NSString *)outpath
               processBlock:(void (^)(float process))processBlock
            completionBlock:(void (^)(NSError *error))completionBlock;


/// @param commandStr FFmpeg的命令行语法
/// @param processBlock 进度回调
/// @param completionBlock 结束回调
- (void)converWithCommand:(NSString *)commandStr
             processBlock:(void (^)(float process))processBlock
          completionBlock:(void (^)(NSError *error))completionBlock;

/*监听进度使用*/
//设置总时长
+ (void)setDuration:(long long)time;

// 设置当前时间
+ (void)setCurrentTime:(long long)time;

// 转换停止
+ (void)stopRuning;

@end

NS_ASSUME_NONNULL_END
