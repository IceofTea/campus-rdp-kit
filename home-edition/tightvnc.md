# TightVNC：家庭版最稳的替代方案

> 适用：**Windows 10/11 家庭版**，尤其是 Win11 家庭版
>
> 效果：主机装一次服务端，Win7 端用包里带的便携 viewer，双击 bat 即连。

## 原理

VNC 是跨平台的远程桌面协议，和 Windows 版本无关。

- 主机：TightVNC Server 监听 5900
- 客户端：TightVNC Viewer 连接 `主机IP:5900`
- 认证：VNC 密码（最多 8 位）
- 传输：默认不加密，适合内网

家庭版完全可以装 TightVNC Server，不受版本限制。

## 主机端（家庭版笔记本）

### 1. 下载

官网：`tightvnc.com`

下载 Windows 安装包（`tightvnc-2.8.81-gpl-setup-64bit.msi` 或更高版本）。

### 2. 安装

运行安装包，选择 **Custom**，只装：

- ✅ TightVNC Server
- ❌ TightVNC Viewer（客户端不需要）

安装过程中会要求设置密码：

- 密码最多 **8 位**
- 这是 VNC 的协议限制，不是 TightVNC 的问题
- 建议用 8 位强密码

### 3. 配置服务端

打开 `TightVNC Server` 配置窗口：

| 项目 | 建议值 |
|---|---|
| Main port | 5900 |
| Accept connections on port | 5900 |
| Run TightVNC Server as a service | ✅ 勾选 |
| Password | 8 位强密码 |
| Allow only loopback connections | ❌ 不勾选（否则只有本机能连） |

如果要限制来源，可以在 `Access Control` 里只允许校园网网段。

### 4. 放行防火墙

```powershell
New-NetFirewallRule -DisplayName "TightVNC 5900" -Direction Inbound -Protocol TCP -LocalPort 5900 -Action Allow
```

### 5. 验证

```powershell
netstat -ano | findstr :5900
```

应该看到 `0.0.0.0:5900 LISTENING`。

## 客户端（Win7）

包里会带一个免安装的 `tvnviewer.exe`，放在：

```
campus-vnc-kit\tools\tvnviewer.exe
```

`一键连接.bat` 会调用它：

```bat
tools\tvnviewer.exe -host=<主机IP> -port=5900 -password=<密码>
```

首次运行如果提示缺少 DLL，把 TightVNC 安装目录里的 `*.dll` 一起复制到 `tools\`。

## 包结构

```
campus-vnc-kit/
├── 一键连接.bat
├── config.ini          主机IP / 端口 / 密码
├── 说明.txt
├── 技术说明.md
└── tools/
    ├── probe.ps1
    └── tvnviewer.exe
```

## config.ini 示例

```ini
LAN_HOST=YOUR-PC
LAN_IP=192.168.1.100
VNC_PORT=5900
VNC_PASSWORD=12345678
```

> 密码明文存在 `config.ini` 里。内网可接受；如果在意，可以改成首次运行时手动输入。

## 常见问题

| 现象 | 原因 | 处理 |
|---|---|---|
| 连接被拒绝 | 服务没启动 | 检查 `TightVNC Server` 服务 |
| 提示密码错误 | 超过 8 位被截断 | 用 8 位以内的密码 |
| 黑屏 | 显示器休眠 / 驱动 | 关闭睡眠、更新显卡驱动 |
| 画面卡 | 带宽 / 编码 | 降低颜色深度、关闭桌面特效 |
| 连不上但 ping 通 | 防火墙拦 5900 | 放行入站 TCP 5900 |

## 安全建议

| 项目 | 建议 |
|---|---|
| 密码 | 8 位，混合大小写数字 |
| 网络 | 只在校园网/内网使用 |
| 公网 | 不要直接暴露 5900；必须用时加 SSH 隧道或 VPN |
| 访问控制 | 在 TightVNC 里限制允许的 IP 段 |
| 日志 | 定期看 TightVNC 的连接日志 |

## 和 RDP 的差异

| 项目 | RDP | TightVNC |
|---|---|---|
| 会话 | 单会话，本地锁屏 | 镜像本地桌面，本地不锁 |
| 加密 | TLS | 默认不加密 |
| 认证 | NLA（强） | VNC 密码（弱） |
| 性能 | 好 | 一般 |
| 家庭版 | 不支持（需 Wrapper） | 支持 |
| Win7 客户端 | 自带 mstsc | 需要 viewer |

TightVNC 的一个重要特点：**它是镜像本地桌面，不是新建会话**。所以主机屏幕上的操作和远程看到的是同一个画面，本地不会被锁屏。
