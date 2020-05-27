//
//  JRFFmpegConverOC.h
//  FFmpeg_iOS_Demo
//
//  Created by 邱俊荣 on 2020/5/10.
//  Copyright © 2020 亚美科技. All rights reserved.
//

/**
 提供给FFmpeg使用的方法
 - 先获取总时长
 - 每次转码后会返回当前的时长，百分比即为进度
 */

// 获取总时间长度回调
void setDuration(long long int time);

// 获取当前时间回调
void setCurrentTime(char info[1024]);

// 转换结束回调
void stopRuning(void);
