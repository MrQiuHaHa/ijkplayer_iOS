
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
> 执行完后，可以在extra目录下，看到ffmpeg文件夹的源码

## 5. 下载 openssl 并初始化（增加HTTPS支持）

```
# 脚本已修改升级制定拉取版本为OpenSSL_1_0_2u版本，耗时过程，建议开启代理
./init-ios-openssl.sh
```
> 执行完后，可以在extra目录下，看到openssl文件夹的源码

## 6. 编译（最关键且容易出错的步骤）
> 如果下一步提示错误`xcrun: error: SDK "iphoneos" cannot be located`, 请执行`sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer/`, 再重新执行下一步

```
cd ios
# 编译前还是多再清空一下
sh compile-ffmpeg.sh clean
```


> 下面两个步骤耗时久，会先在ios目录下编译出各个平台架构的源码，然后在ios/build目录下编译出各个平台的.a文件，最后合并多架构文件到ios/build/universal/lib下

- 对已下载的openssl进行编译

```
./compile-openssl.sh all
```

> 编译完openssl后会生成支持 https 的静态文件 libcrypto.a 和 libssl.a 在目录ios/build/universal/lib

- 对已下载的ffmpeg进行编译

```
./compile-ffmpeg.sh all
```

> 编译完后生成的.a文件在目录ios/build/universal/lib下，以及目录ios/build/universal/include下的头文件

```
但是其自动生成的头文件不全，会缺少一些后续我们需要使用的头文件，所以直接把我上传在ios目录下的include文件夹整个拖过去替换掉即可。
```


- 最后，把自己的OC调用C的文件和写好的C++对ffmpeg的api调用的功能文件拖到对应的位置
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
