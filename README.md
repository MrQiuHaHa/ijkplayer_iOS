
## 0. 编译环境

- Mac OS X 10.15.4
- Xcode 11.4.1

## 1. 安装 homebrew, git, yasm工具，在终端输入

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
brew install yasm
```

## 2. 下载当前已经修改过的ijkplayer源码

`git clone https://github.com/MrQiuHaHa/ijkplayer_iOS.git`
> 源码的修改过程在git上有记录，当前工程是官方k0.8.8版本，修改后升级了FFmpeg4.0版本，以及openssl版本，和修复卡线程bug，对x264的支持，新增了默认支持的编码格式

## 3. 配置编解码器格式 

```
cd config
# 删除当前的 module.sh 文件
rm module.sh
# 创建软链接 module.sh 指向 module-lite-hevc.sh
ln -s module-lite-hevc.sh module.sh

cd ..
cd ios
# 清空历史编译记录（防止之前编译过导致冲突）
sh compile-ffmpeg.sh clean
```

## 4. 下载 FFmpeg 并初始化

```
cd ..
# 脚本已经被修改为拉取FFmpeg4.0版本，此过程耗时久（建议后续步骤开启代理，你懂得）
./init-ios.sh
```
> 执行完后，可以在extra目录下看到ffmpeg文件夹的源码以及 **按照我们配置的参数** 在ios目录下拉取各个平台架构的ffmpeg源码

## 5. 下载 openssl 并初始化（增加HTTPS支持）

```
# 脚本已修改升级制定拉取版本为OpenSSL_1_0_2u版本，耗时过程，建议开启代理
./init-ios-openssl.sh
```
> 执行完后，可以在extra目录下，看到openssl文件夹的源码以及 **按照我们配置的参数** 在ios目录下拉取各个平台架构的openssl源码

## 6. 编译（最关键且容易出错的步骤）
> 如果下一步提示错误`xcrun: error: SDK "iphoneos" cannot be located`, 请执行`sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer/`, 再重新执行下一步

```
cd ios
# 编译前还是多再清空一下
sh compile-ffmpeg.sh clean
```


> 下面两个步骤耗时久，在ios/build目录下编译出各个架构平台的.a文件，最后合并多架构文件到ios/build/universal/lib下

##### 6.1 对已下载的openssl进行编译

```
./compile-openssl.sh all
```

> 编译完openssl后会生成支持 https 的静态文件 libcrypto.a 和 libssl.a 在目录ios/build/universal/lib

##### 6.2 对已下载的ffmpeg进行编译

```
./compile-ffmpeg.sh all
```

> 编译完ffmpeg后生成的.a文件在目录ios/build/universal/lib下，以及目录ios/build/universal/include下的头文件

##### 6.3 把自己准备的文件拖到对应的位置（查看第9点说明作用）

```
6.2步骤编译生成的include下的头文件，会缺少一些后续我们需要使用的头文件，所以直接把我上传在ios目录下的include文件夹整个拖过去替换掉即可
仅仅是增加了一些我们需要使用头文件，假如后续需要更多头文件直接去源码拷贝过来即可
```

```
把ios目录下的manager、fftools文件夹拖到ios/build/universal目录下
把ios目录下的libx264.a文件拖到ios/build/universal/lib目录下
（至此：ios/build/universal这个目录下已经有我们所有要准备的东西）
```

## 7. 打开 IJKMediaDemo 项目

- 把上面步骤准备好的ios/build/universal目录下的相关文件依赖到IJKMediaDemo工程下
```
# 打开工程，在ios目录下可以看到工程IJKMediaDemo
open IJKMediaDemo/IJKMediaDemo.xcodeproj
# 找到目录IJKMediaDemo->IJKMediaPlayer.xcodeproj->Classes->IJKFFMoviePlayerController->ffmpeg->lib，鼠标右击delete -> Remove References
# 把ios/build/universal下的四个文件夹拖到上面的ffmpeg目录下，完成依赖。
# 至此：全部完成，已经可以直接真机调试demo
```

## 8. 打包 framwork 注意点
> 大家会发现除了 IJKMediaFramework这个target, 还有一个叫 IJKMediaFrameworkWithSSL, 但是不推荐使用这个, 因为大部分基于 ijkplayer 的第三方框架都是使用的前者, 你把后者导入项目还是会报找不到包的错误, 就算你要支持 https 也推荐使用前者, 然后按照上一步添加 openssl即可支持

```
打包的时候把工程的debug改成release（常识别忘记啦）
模拟器和真机的架构都需要，这样把framework推导pod私有源才可以通过校验
```

## 9. 最后

> 这里有我已经编译完成的framework，也支持私有源直接导入
https://github.com/MrQiuHaHa/JRIJKMediaFramework.git

> 这里有我对framework的使用方式的demo，并且有对UI控制层的封装
https://github.com/MrQiuHaHa/YMPlayer.git

```

# 特别强调一下，前面自己加入的manager、fftools功能是为了利用ijkplayer内部集成的ffmpeg对视频进行转码下载操作，因为你的需求可能不仅仅只是播放视频，也可能想下载下来保存到iOS相册，而iOS相册只能保存h264编码视频。
# 这里的inputPath可以只是本地路径也可以是一个网络url
    [[JRFFmpegManager shared] converWithInputPath:inputUrlPath outputPath:outputPath processBlock:^(float process) {
        NSLog(@"转码进度---- %f",process);
        if (weakSelf.downLoadProgressCallBack) {
            weakSelf.downLoadProgressCallBack(process);
        }
    } completionBlock:^(NSError * _Nonnull error) {
        
        if (firstErr == 1) {
            firstErr = 2;//使用在线转码功能，ffmpeg会直接先回调个错误，具体原因暂未排查
        } else {
            if (error) {
                NSLog(@"转码错误 %@",error);
                if (weakSelf.downLoadWithErrorCallBack) {
                    weakSelf.downLoadWithErrorCallBack(@"下载失败，请重试");
                }
            } else {
                if (weakSelf.didFinishDownLoadCallBack) {
                    weakSelf.didFinishDownLoadCallBack(outputPath);
                }
            }
            
            weakSelf.gestureControl.forbidGesture = NO;
        }
    }];
```

```
# 引入YMPlayer的播放器的私有库后，你的项目可以直接push到播放器控制器。UI控制层的修改可以在VideoControlView目录对应的view直接修改
- (IBAction)jumpToPlayerPage:(id)sender {
    
    NSArray *videoArr = @[
       [NSURL URLWithString:@"https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4"],
       [NSURL URLWithString:@"https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/peter/mac-peter-tpl-cc-us-2018_1280x720h.mp4"],
       [NSURL URLWithString:@"https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/grimes/mac-grimes-tpl-cc-us-2018_1280x720h.mp4"],
       [NSURL URLWithString:@"http://yamei-adr-oss.iauto360.cn/SOS_N_000000002_20190924_497cf6b6-df6a-44b8-9468-56d4d1b92fa8.mp4"]];
       NSArray *titleArr = @[@"iphone11介绍视频",@"我是第二个视频",@"我是第三个最后的视频",@"车智汇视频"];
    YMWisdomVideoPlayerVC *vc = [[YMWisdomVideoPlayerVC alloc] init];
    vc.assetURLs = videoArr;
    vc.assetTitles = titleArr;
    [self.navigationController pushViewController:vc animated:NO];
}
```