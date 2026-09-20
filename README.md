# GitHub520 Hosts 一键管理工具（Windows）

五个双击即用的 Windows 批处理脚本，配合 [GitHub520](https://github.com/521xueweihan/GitHub520) 的 hosts 数据，一键完成 GitHub hosts 的**智能更新、清理、检查与开机自启**，无需手动改 hosts 文件。

## 脚本说明

| 文件 | 作用 | 管理员 |
|---|---|---|
| `GitHub520智能更新.bat` | **推荐**：下载最新 IP + 自动测速多个 github.com 候选 IP，选当前最快的写入 | 自动提权 |
| `GitHub520一键更新hosts.bat` | 直接拉取官方 hosts 覆盖，简单直接 | 自动提权 |
| `GitHub520一键清理hosts.bat` | 移除 hosts 中全部 GitHub520 记录，恢复原状 | 自动提权 |
| `GitHub520配置检查.bat` | 只读检查当前 hosts 配置及关键域名覆盖 | 不需要 |
| `GitHub520开机自启.bat` | 开启/关闭开机自动运行智能更新（菜单式操作） | 自动提权 |

## 使用方法

1. 下载本仓库（Clone 或 Download ZIP）
2. 双击对应 `.bat` 文件
3. 需要管理员权限的脚本会自动弹 UAC，点“是”即可
4. 更新完成后按 `Ctrl+F5` 强制刷新浏览器验证

## 为什么推荐「智能更新」

GitHub 的 IP 经常变动，且不同网络环境（运营商、地区）对同一 IP 的连通性差异很大。官方 hosts 给出的 IP 在你网络下可能恰好被封或超时（就是你遇到的情况）。**智能更新脚本**会在下载官方 hosts 后，自动对 8 个 github.com 候选 IP 逐个测速，把当前最快、HTTP 200 的那个写入 hosts，避免手动排查。

## 工作原理

- **数据源**：优先 `https://raw.hellogithub.com/hosts`，失败回退 GitHub 仓库 raw 地址
- **智能选 IP**：对 8 个 github.com 候选 IP 做 TCP + HTTPS 测速，选 HTTP 200 且延迟最低者
- **安全校验**：写入前校验官方起止标记，校验失败不改 hosts
- **自动备份**：修改前备份为 `hosts.bak_时间戳`（位于 `C:\Windows\System32\drivers\etc\`）
- **最小改动**：只替换 `# GitHub520 Host Start` 与 `End` 之间的区块
- **自动刷新**：完成后执行 `ipconfig /flushdns`

> 注意：清理脚本按官方标记识别。手动添加且不带这两个标记的 hosts 记录不会被删除（有意设计，避免误删）。

## 致谢与数据来源

本项目仅为 GitHub520 官方 hosts 数据的 Windows 一键化封装，hosts 数据版权归原作者所有：

- [GitHub520](https://github.com/521xueweihan/GitHub520) — hosts 数据来源（MIT License）

## 免责声明

修改 hosts 仅用于提升访问 GitHub 的速度与稳定性，请自行遵守当地法律法规。如因网络环境变化导致访问异常，运行「一键清理」即可完全恢复。

## License

本仓库脚本基于 [MIT License](./LICENSE) 开源。
