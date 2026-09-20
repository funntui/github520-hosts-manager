# GitHub520 Hosts 一键管理工具（Windows）

三个双击即用的 Windows 批处理脚本，配合 [GitHub520](https://github.com/521xueweihan/GitHub520) 的 hosts 数据，一键完成 GitHub hosts 的**更新、清理与检查**，无需手动改 hosts 文件。

## 脚本说明

| 文件 | 作用 | 是否需要管理员权限 |
|---|---|---|
| `GitHub520一键更新hosts.bat` | 联网拉取最新 IP，自动备份原 hosts、替换旧配置、刷新 DNS 缓存 | 自动弹窗提权 |
| `GitHub520一键清理hosts.bat` | 一键移除 hosts 中全部 GitHub520 记录，恢复原始内容 | 自动弹窗提权 |
| `GitHub520配置检查.bat` | 只读检查当前 hosts 是否存在 GitHub520 配置及覆盖情况 | 不需要 |

## 使用方法

1. 下载本仓库（Clone 或直接 Download ZIP）
2. 双击对应 `.bat` 文件
3. 更新 / 清理脚本会自动弹出 UAC 提权窗口，点击“是”即可
4. 更新完成后可在命令行运行 `ping github.com` 验证连通性

## 工作原理

- **数据源**：优先 GitHub520 官方 CDN `https://raw.hellogithub.com/hosts`，失败自动回退 GitHub 仓库 raw 地址
- **安全校验**：写入前先校验下载内容包含官方起止标记，校验失败**不会改动** hosts
- **自动备份**：每次修改前自动在 `C:\Windows\System32\drivers\etc\` 下备份为 `hosts.bak_时间戳`
- **最小改动**：只操作 `# GitHub520 Host Start` 与 `# GitHub520 Host End` 之间的区块，不影响你 hosts 里的其他配置
- **自动刷新**：操作完成后自动执行 `ipconfig /flushdns` 刷新 DNS 缓存

> 注意：清理脚本按上述官方标记识别。如果你手动添加过不带这两个标记的 hosts 记录，不会被删除（有意设计，避免误删）。

## 致谢与数据来源

本项目仅为 GitHub520 官方 hosts 数据的 Windows 一键化封装，hosts 数据版权归原作者所有：

- [GitHub520](https://github.com/521xueweihan/GitHub520) — hosts 数据来源（MIT License）

## 免责声明

修改 hosts 仅用于提升访问 GitHub 的速度与稳定性，请自行遵守当地法律法规。脚本按官方标记识别并修改对应区块；如因网络环境变化导致访问异常，运行「一键清理」脚本即可完全恢复。

## License

本仓库脚本基于 [MIT License](./LICENSE) 开源。
