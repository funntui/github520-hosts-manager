# GitHub520 Hosts 一键管理工具（Windows）

一个双击即用的 Windows 批处理脚本，配合 [GitHub520](https://github.com/521xueweihan/GitHub520) 的 hosts 数据，通过菜单选择完成 GitHub hosts 的**智能更新、手动更新、配置检查、清理与开机自启**。

## 使用方法

1. 下载本仓库（Clone 或 Download ZIP）
2. 双击 `GitHub520管理工具.bat`
3. 需要管理员权限的操作会自动弹 UAC，点"是"即可
4. 更新完成后按 `Ctrl+F5` 强制刷新浏览器

## 菜单功能

| 选项 | 功能 | 管理员 |
|---|---|---|
| 1 | **智能更新**（推荐）：下载最新 IP + 自动测速选最快 github.com IP | 自动提权 |
| 2 | 一键更新：直接拉取官方 hosts 覆盖 | 自动提权 |
| 3 | 配置检查：只读查看当前 hosts 配置及关键域名覆盖 | 不需要 |
| 4 | 一键清理：移除全部 GitHub520 记录 | 自动提权 |
| 5 | 开机自启：开启/关闭/查看开机自动更新 | 自动提权 |

## 为什么推荐「智能更新」

GitHub 的 IP 经常变动，且不同网络环境对同一 IP 的连通性差异很大。智能更新会在下载官方 hosts 后，自动对 8 个 github.com 候选 IP 逐个测速，把当前最快、HTTP 200 的那个写入 hosts，避免手动排查。

## 工作原理

- **数据源**：优先 `https://raw.hellogithub.com/hosts`，失败回退 GitHub 仓库 raw 地址
- **智能选 IP**：对 8 个 github.com 候选 IP 做测速，选 HTTP 200 且延迟最低者
- **自动备份**：修改前备份为 `hosts.bak_时间戳`（位于 `C:\Windows\System32\drivers\etc\`）
- **自动刷新**：完成后执行 `ipconfig /flushdns`
- **开机自启**：通过 Windows 任务计划实现，开机自动运行智能更新

## 致谢与数据来源

本项目仅为 GitHub520 官方 hosts 数据的 Windows 一键化封装，hosts 数据版权归原作者所有：

- [GitHub520](https://github.com/521xueweihan/GitHub520) — hosts 数据来源（MIT License）

## License

本仓库基于 [MIT License](./LICENSE) 开源。
