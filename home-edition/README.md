# 家庭版主机的替代方案

> 适用于：被控端是 **Windows 10/11 家庭版**，没有 RDP 服务端，无法被 `mstsc` 直接连接。

## 为什么家庭版不行

Windows 家庭版自带 `mstsc.exe` 客户端，可以连别人；但 **TermService 不接受 RDP 连接**。

- 设置里没有“远程桌面”开关
- 改注册表 `fDenyTSConnections=0` 也无效
- 底层是 `termsrv.dll` 里的版本检查，家庭版被硬编码禁用

这是授权限制，不是配置问题。

## 三条路线

| 路线 | 主机端一次性操作 | 客户端（Win7） | 之后使用 | 风险 |
|---|---|---|---|---|
| [RDP Wrapper](rdp-wrapper.md) | 装 RDPWrap，改 `termsrv.dll` | 零安装，复用现有 bat | 双击即用 | Defender 报毒、更新失效 |
| [TightVNC](tightvnc.md) | 装 TightVNC 服务端 | 包里带便携 viewer | 双击即用 | VNC 密码较弱 |
| [升级专业版](upgrade-to-pro.md) | 输入密钥 | 零安装，复用现有 bat | 双击即用 | 需要授权 |

## 怎么选

```
主机是家庭版
│
├─ 能拿到专业版授权？
│   └─ 是 → 升级专业版（最稳，零额外软件）
│
├─ 主机是 Win10 家庭版？
│   └─ 是 → RDP Wrapper（兼容性好，复用现有 bat）
│
└─ 主机是 Win11 家庭版 / 不想折腾？
    └─ TightVNC（兼容性最好，更新不影响）
```

## 共同前提

无论选哪条路线，主机端都要做一次操作。这是家庭版的硬限制，绕不过去。

客户端（Win7）可以始终保持零安装：

- RDP Wrapper / 升级专业版 → 继续用现有的 `一键连接.bat`
- TightVNC → 包里带一个免安装的 `tvnviewer.exe`，bat 调用

## 安全性提醒

| 方案 | 传输加密 | 认证强度 | 建议 |
|---|---|---|---|
| RDP（含 Wrapper） | TLS | 强（NLA） | 内网可用，公网需强密码 |
| TightVNC | 默认不加密 | 弱（DES 密码） | 仅内网；可加 SSH 隧道 |
| 升级专业版 | TLS | 强（NLA） | 同主方案 |

如果主机需要暴露到公网，不要用 TightVNC 的默认配置。
