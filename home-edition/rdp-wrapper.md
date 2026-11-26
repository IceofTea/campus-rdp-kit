# RDP Wrapper：解锁家庭版的 RDP 服务端

> 适用：**Windows 10 家庭版**（Win11 家庭版兼容性较差，建议改用 [TightVNC](tightvnc.md)）
>
> 效果：解锁后，家庭版可以像专业版一样接受 `mstsc` 连接，现有的 `一键连接.bat` 直接可用。

## 原理

家庭版的 `termsrv.dll` 里有版本检查，发现是家庭版就拒绝 RDP 连接。

RDP Wrapper 通过一个 DLL 补丁（`rdpwrap.dll`）拦截这些检查函数，让 `TermService` 以为自己是专业版。

它不改系统文件本身，而是通过 `TermService` 的 DLL 注入生效。所以：

- 系统更新后，`termsrv.dll` 版本变了，旧的 ini 配置可能失效
- Windows Defender 可能把补丁 DLL 报成病毒

## 步骤

### 1. 确认系统版本

```cmd
winver
```

或：

```powershell
(Get-CimInstance Win32_OperatingSystem).Caption
(Get-Item C:\Windows\System32\termsrv.dll).VersionInfo.FileVersion
```

记下 `termsrv.dll` 的版本号，后面更新 ini 要用。

### 2. 下载 RDPWrap

GitHub 仓库：`stascorp/rdpwrap`

下载最新的 `RDPWrap-v1.6.2.zip`（或更高版本），解压到：

```
C:\Program Files\RDP Wrapper\
```

### 3. 安装

以管理员身份运行解压目录里的 `install.bat`。

它会：

- 把 `rdpwrap.dll` 复制到 `C:\Program Files\RDP Wrapper\`
- 注册服务
- 修改 `TermService` 的 `ServiceDll` 指向 `rdpwrap.dll`

### 4. 检查状态

运行 `RDPConf.exe`，看四项状态：

| 项目 | 正常值 |
|---|---|
| Listener state | `Listening` |
| Service state | `Running` |
| Wrapper state | `Installed` |
| 版本行 | `[10.0.xxxxx.xxxx]` 后面显示 `Fully supported` |

如果显示 `Not supported`，说明 `rdpwrap.ini` 里没有当前 `termsrv.dll` 版本的配置，需要更新 ini。

### 5. 更新 rdpwrap.ini（如果 Not supported）

社区维护的 ini 仓库：

- `sebaxakerhtjujad/rdpwrap.ini`
- `affan/rdpwrap`

下载最新的 `rdpwrap.ini`，覆盖：

```
C:\Program Files\RDP Wrapper\rdpwrap.ini
```

然后重启服务：

```powershell
Restart-Service TermService -Force
```

再打开 `RDPConf.exe` 检查。

### 6. 放行防火墙

```powershell
Enable-NetFirewallRule -DisplayGroup "远程桌面"
```

或者按端口：

```powershell
New-NetFirewallRule -DisplayName "RDP 3389" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow
```

### 7. 验证

```powershell
netstat -ano | findstr :3389
```

应该看到 `0.0.0.0:3389 LISTENING`。

然后在 Win7 上用现有的 `一键连接.bat` 连接。

## 常见问题

| 现象 | 原因 | 处理 |
|---|---|---|
| `RDPConf.exe` 打不开 | .NET Framework 缺失 | 装 .NET 4.x |
| `Wrapper state: Not installed` | `install.bat` 没跑成功 | 管理员重跑，看错误信息 |
| `Not supported` | ini 缺当前版本 | 更新 `rdpwrap.ini` |
| 连接后立刻断开 | 版本不匹配 | 换 ini 或换 TightVNC |
| Defender 报毒 | 补丁 DLL 被误报 | 加排除项，或换 TightVNC |

## 卸载

管理员运行解压目录里的 `uninstall.bat`，然后重启。

## 风险

| 风险 | 说明 |
|---|---|
| 系统更新失效 | 每次大版本更新后可能要重新找 ini |
| 杀软误报 | Defender/360 可能直接删除 `rdpwrap.dll` |
| 安全风险 | 补丁绕过了微软的版本检查，理论上可能引入未修复漏洞 |
| 无官方支持 | 出问题只能靠社区 |

如果主机是 Win11 家庭版，或者你不想折腾 ini，直接用 [TightVNC](tightvnc.md) 更省事。
