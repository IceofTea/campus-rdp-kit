# 升级到专业版：最干净的解法

> 适用：学校/单位有 Windows 批量授权（KMS 或 MAK），或者愿意购买升级。
>
> 效果：升级后家庭版变成专业版，现有的 `一键连接.bat` 直接可用，不需要任何第三方补丁。

## 为什么推荐

| 对比项 | 升级专业版 | RDP Wrapper | TightVNC |
|---|---|---|---|
| 官方支持 | ✅ | ❌ | ✅（第三方软件） |
| 系统更新影响 | 无 | 可能失效 | 无 |
| 安全性 | 高 | 中 | 中（密码弱） |
| 客户端改动 | 无 | 无 | 需要 viewer |
| 成本 | 授权费 | 免费 | 免费 |

如果学校有授权，这是最省心的路线。

## 确认当前版本

```cmd
winver
```

或：

```powershell
(Get-CimInstance Win32_OperatingSystem).Caption
(Get-CimInstance Win32_OperatingSystem).OperatingSystemSKU
```

`OperatingSystemSKU` 对照：

| SKU | 版本 |
|---|---|
| 101 | Windows 10/11 家庭版 |
| 48 | Windows 10/11 专业版 |
| 4 | Windows 10/11 企业版 |
| 121 | Windows 10/11 教育版 |

## 获取密钥

三种常见来源：

| 来源 | 说明 |
|---|---|
| 学校 KMS | 连校园网自动激活，通常不需要手动输密钥 |
| 学校 MAK | 一次性密钥，输入后永久激活 |
| 零售/升级包 | 微软商店或授权经销商购买 |

问学校网络中心/信息办要“Windows 专业版升级密钥”或“KMS 服务器地址”。

## 升级步骤

### 方式 1：设置界面

1. `设置 → 系统 → 激活 → 更改产品密钥`
2. 输入专业版密钥
3. 等待升级完成，重启

### 方式 2：命令行

管理员运行 cmd：

```cmd
slmgr /ipk <你的专业版密钥>
slmgr /ato
```

### 方式 3：KMS

如果学校有 KMS 服务器：

```cmd
slmgr /skms kms.学校域名:1688
slmgr /ipk <KMS 客户端密钥>
slmgr /ato
```

KMS 客户端密钥是微软公开的，不是盗版；激活有效期 180 天，连校园网会自动续期。

## 验证

```cmd
winver
```

应该显示“Windows 10/11 专业版”。

再确认 RDP 可用：

```powershell
(Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server').fDenyTSConnections
Get-Service TermService
netstat -ano | findstr :3389
```

然后按主方案配置：

- 开启远程桌面
- 放行防火墙
- 加入 `Remote Desktop Users`
- 设置 `AllowEncryptionOracle=2`（Win7 兼容）

## 注意

| 项目 | 说明 |
|---|---|
| 是否需要重装 | 不需要。家庭版 → 专业版是原地升级，文件和程序都保留 |
| 是否需要重启 | 需要，通常 1-2 次 |
| 激活失败 | 检查网络、密钥类型（KMS/MAK 不能混用）、系统版本 |
| 降级 | 专业版不能直接降回家庭版，需要重装 |

## 升级后

升级完成后，直接回到主方案：

- [README.md](../README.md) 的“快速开始”
- 客户端继续用现有的 `一键连接.bat`
- 不需要 RDP Wrapper，也不需要 TightVNC

## 如果拿不到授权

退而求其次：

- Win10 家庭版 → [RDP Wrapper](rdp-wrapper.md)
- Win11 家庭版 → [TightVNC](tightvnc.md)
