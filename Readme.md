### 有心情会改改，目前这玩意很烂23333
>用了一下以前的自述文件


# Command Line Interface-Minecraft Script Manager(CLIMSM)


## 启动器介绍
此启动器由Batch编写
并使用第三方和powershell
只能启动离线模式，目前版本只有1.13-1.18左右支持
目前还是个beta，里面所有代码结构均会做出改变（烂啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊）

> [!WARNING]
> 目前此版本无法正常使用


## 系统环境/要求
附带有Powershell的系统（高版本例如1.19的版本启动脚本需要powershell，命令长度Bat无法支持）
CMD支持UTF-8编码
VBS支持
java（启动MC需要）


## 进入脚本操作顺序
```
Useradd       添加用户
Config        更改Player改为刚刚自己设定用户名，保持设定，然后重启脚本
Getlist       刷新版本缓存
DGameC        获取游戏本体
DLib          获取游戏运行库文件
DNatives      下载MC的natives
DL4X          下载Log4j的配置文件
DAssets       下载资源文件（执行这一步可以喝一杯咖啡啥的w）
StpCMD/StpPS  CMD/POWERSHELL命令行启动游戏
```

## 下载
直接克隆


## 配置文件存放处
%LOCALAPPDATA%\CLIMSM
config.ini 配置文件
mcds\ 镜像源存放处（暂）
userlist\ 用户（包括正版）存放处


## 使用的第三方
Curl.exe
Wget.exe
jj.exe


> 感谢MCBBS为大家提供的镜像源
> 孩子知道写的烂QAQ
