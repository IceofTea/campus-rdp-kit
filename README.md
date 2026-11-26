# 校园网 RDP 直连工具包

让校园网 / 局域网内的 Windows 7 电脑，双击一个 bat 就能远程控制 Windows 10/11 主机。

只用 Windows 自带的远程桌面（RDP），不装向日葵、TeamViewer 等第三方软件。

## 适用场景

- 实验室 / 机房有一台常开的主机（Win10/11 专业版）
- 其他电脑（包括 Win7）在同一个校园网 / 局域网
- 想用最少的配置实现远程控制
- 不想把 3389 暴露到公网

## 版本要求

| 角色 | 要求 | 说明 |
|---|---|---|
| 主机（被控端） | Win10/11 **专业版**、企业版、教育版 | 家庭版没有 RDP 服务端，无法被连接 |
| 客户端 | Win7 任意版本 | 家庭版也自带 `mstsc.exe`，可以连别人 |
| 客户端 | Win10/11 任意版本 | 同上 |

> 家庭版作为被控端时，设置里没有“远程桌面”开关，改注册表也无效。这是系统授权限制，不是配置问题。
>
> 变通方案：升级专业版 / RDP Wrapper（第三方，有风险）/ 换 RustDesk 等协议。

## 特点

| 特点 | 说明 |
|---|---|
| 零第三方软件 | 客户端只需要系统自带的 `mstsc.exe` |
| Win7 兼容 | 处理了 CredSSP、TLS 1.2 两个经典坑 |
| 双击即连 | 自动探测主机名和 IP，失败才提示 |
| 可学习 | 附带原理说明和排错手册 |

## 快速开始

### 1. 主机端（被控电脑，Win10/11 专业版）

以管理员身份运行 PowerShell：

```powershell
# 开启远程桌面
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0
Set-Service TermService -StartupType Manual
Start-Service TermService

# 放行防火墙（如果防火墙开着）
Enable-NetFirewallRule -DisplayGroup "远程桌面"

# 允许账户
net localgroup "Remote Desktop Users" Administrator /add

# Win7 兼容：允许旧版 CredSSP 客户端
$p = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters'
if (-not (Test-Path $p)) { New-Item $p -Force | Out-Null }
New-ItemProperty $p -Name AllowEncryptionOracle -Value 2 -PropertyType DWord -Force

# 禁止睡眠
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
```

> `AllowEncryptionOracle=2` 会降低 CredSSP 安全性。只在可信内网使用；如果主机暴露在公网，请改用“给 Win7 打补丁”的方案。

### 2. 客户端配置

编辑 `config.ini`：

```ini
LAN_HOST=YOUR-PC
LAN_IP=192.168.1.100
USER=YOUR-PC\Administrator
```

- `LAN_HOST`：主机名（同网段可自动解析）
- `LAN_IP`：主机 IP（主机名解析失败时用）
- `USER`：登录账户

### 3. 连接

双击 `一键连接.bat`。

首次连接输入密码，勾选“记住我的凭据”。之后双击直接进。

## 文件结构

```
campus-rdp-kit/
├── 一键连接.bat      主入口
├── config.ini        配置
├── 说明.txt          给使用者的简短说明
├── 技术说明.md       原理、配置、排错
└── tools/
    └── probe.ps1     TCP 端口探测（PS2.0）
```

## 工作原理（简版）

```
Win7 mstsc ──TCP 3389──▶ 主机 TermService ──▶ 桌面会话
```

握手分 5 层：TCP → X.224 → TLS → CredSSP/NLA → RDP 会话。

Win7 连 Win10/11 最常见的两个失败点：

1. **CredSSP 版本不匹配** → 报“要求的函数不受支持”
   - 解决：主机设 `AllowEncryptionOracle=2`，或给 Win7 打 KB4103718
2. **TLS 版本不匹配** → 报“由于安全设置错误…”
   - 解决：Win7 装 KB3140245 并启用 TLS 1.2

详见 [技术说明.md](技术说明.md)。

## 常见问题

### 双击后提示“校园网直连不通”

1. 确认客户端连着校园网
2. 确认主机开机
3. 主机 IP 变了：改 `config.ini` 的 `LAN_IP`
4. 主机名解析不了：同网段才有效，跨网段用 IP

### 连接后主机本地被锁定

RDP 单会话限制。远程登录会断开本地 console 会话，这是正常的。

### 第一次连接弹证书警告

点“是”。RDP 用的是主机自签名证书，没有域 CA。

### 想退出全屏

`Ctrl + Alt + Break`

## 安全提醒

- 只在可信内网使用
- 密码要强，不要用空密码
- 不要把这套方案直接暴露到公网
- `AllowEncryptionOracle=2` 是兼容性妥协，不用 Win7 后建议改回 `1`

## License

MIT
