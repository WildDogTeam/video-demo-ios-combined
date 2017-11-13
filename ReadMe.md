# video-demo-android-combined

## 1. 创建应用

在 Wilddog [控制面板](https://www.wilddog.com/dashboard/) 中创建一个新应用或使用已有应用。 [如何创建应用？](https://docs.wilddog.com/console/creat.html)

## 2. 开启匿名登录认证方式

应用创建成功后，进入“管理应用-->身份认证-->登录方式”。开启匿名登录。

![](https://github.com/WildDogTeam/video-demo-android-conference/raw/master/images/openanonymous.png)

## 3. 开启实时视频通话

进入 管理应用-实时视频通话，开启视频通话功能。此处注意配置页面下方`config`中的`videoURL`

![](https://github.com/WildDogTeam/video-demo-android-conference/raw/master/images/video_quickstart_openVideo.png)

**提示：**
如果之前没有使用过sync服务的需要手动开启
![](https://github.com/WildDogTeam/video-demo-android-conference/raw/master/images/opensync.png)

## 4. 代码使用

1. improve the information on **WDGRoomConfig.h** first
2. open **WDGRoomDemo.xcworkspace** after **pod install**
3. enjoy yourself
