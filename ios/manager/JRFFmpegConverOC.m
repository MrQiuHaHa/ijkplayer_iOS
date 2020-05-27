//
//  JRFFmpegConverOC.m
//  FFmpeg_iOS_Demo
//
//  Created by 邱俊荣 on 2020/5/10.
//  Copyright © 2020 亚美科技. All rights reserved.
//

#import "JRFFmpegConverOC.h"
#import <Foundation/Foundation.h>
#import "JRFFmpegManager.h"

// 转换停止回调
void stopRuning(void) {
    [JRFFmpegManager stopRuning];
}

// 获取总时间长度
void setDuration(long long int time) {
    [JRFFmpegManager setDuration:time/1000000 + 1];
}

// 获取当前时间
void setCurrentTime(char info[1024]) {
    NSString *temp = @"";
    BOOL isBegin = false;
    int j = 5;
    for (int i = 0; i < 1024; i++) {
        // 获得时间开始的标记t
        if (info[i] == 't') {
            isBegin = true;
        }
        if (isBegin) {
            // 判断是否结束,结束了会输出空格
            if (info[i] == ' ') {
                break;
            }
            if (j > 0) {
                j--;
                continue;
            }else{
                temp = [temp stringByAppendingFormat:@"%c",info[i]];
            }
        }
    }
    //结果是00:00:00.00格式,转换为秒的格式
    int hour,min,second;
    hour = [[temp substringWithRange:NSMakeRange(0, 2)] intValue];
    min = [[temp substringWithRange:NSMakeRange(3, 2)] intValue];
    second = [[temp substringWithRange:NSMakeRange(6, 2)] intValue];
    second = hour * 3600 + min * 60 + second + 1;
    [JRFFmpegManager setCurrentTime:second];
}
