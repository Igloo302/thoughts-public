---
tags:
  - indie-dev
  - guide
  - ios
date: 2026-01-22
status: active
area: 2-Areas/职业发展
---

# 上下文
[Medium](https://dimillian.medium.com/how-to-use-cursor-for-ios-development-54b912c23941)
[Cursor – iOS & macOS (Swift)](https://docs.cursor.com/guides/languages/swift)

# iOS AI Coding 系统规则

## 1. 项目结构与组织

### 1.1 目录结构
- 使用标准的 iOS 项目结构
- 按功能模块组织代码（Models, Views, Controllers, Services, Utils）
- 资源文件统一放在 Resources 文件夹
- 测试文件与源文件保持对应关系

### 1.2 文件命名规范
- Swift 文件使用 PascalCase（如：UserProfileViewController.swift）
- 资源文件使用 snake_case（如：user_avatar_placeholder.png）
- 测试文件添加 Tests 后缀（如：UserServiceTests.swift）

## 2. 代码规范

### 2.1 Swift 编码规范
- 遵循 Swift API Design Guidelines
- 使用 4 个空格缩进，不使用 Tab
- 行长度限制在 120 字符以内
- 类型名使用 PascalCase，变量和函数名使用 camelCase
- 常量使用 static let，避免使用全局变量

### 2.2 代码注释
- 公开 API 必须添加文档注释
- 复杂逻辑添加行内注释说明
- 使用 `// MARK: -` 分隔代码段
- TODO 和 FIXME 注释必须包含负责人和时间

### 2.3 错误处理
- 优先使用 Result 类型处理可能失败的操作
- 自定义错误类型实现 LocalizedError 协议
- 避免使用 force unwrapping（!），优先使用 guard let 或 if let

## 3. 架构模式

### 3.1 推荐架构
- 小型项目：MVC + Coordinator
- 中大型项目：MVVM + Coordinator
- 复杂项目：Clean Architecture + MVVM

### 3.2 依赖注入
- 使用协议定义依赖接口
- 通过构造函数注入依赖
- 避免使用单例模式，除非确实需要全局状态

## 4. 测试策略

### 4.1 单元测试
- 测试覆盖率目标：核心业务逻辑 > 80%
- 使用 XCTest 框架
- Mock 外部依赖（网络、数据库等）
- 测试文件命名：`[ClassName]Tests.swift`

### 4.2 UI 测试
- 关键用户流程必须有 UI 测试覆盖
- 使用 XCUITest 框架
- 测试数据使用独立的测试环境

## 5. 模拟器测试

### 5.1 模拟器配置
- 默认使用 iOS 17.0 模拟器
- 测试设备：iPhone 15 Pro (iOS 17.0)
- 在规则中说明模拟器版本、包名，Trae 会运行以下的命令进行测试：
  ```bash
  xcrun simctl launch booted com.yourcompany.yourapp
  ```

### 5.2 测试场景
- 不同屏幕尺寸适配测试
- 横竖屏切换测试
- 内存警告处理测试
- 网络状态变化测试

## 6. 性能优化

### 6.1 内存管理
- 避免循环引用，合理使用 weak 和 unowned
- 及时释放不需要的资源
- 使用 Instruments 检测内存泄漏

### 6.2 启动优化
- 延迟加载非关键组件
- 优化 App Delegate 中的初始化代码
- 减少启动时的同步操作

### 6.3 渲染优化
- 避免在主线程进行重计算
- 合理使用图片缓存
- 优化 TableView/CollectionView 的 cell 复用

## 7. 安全规范

### 7.1 数据安全
- 敏感数据使用 Keychain 存储
- 网络请求使用 HTTPS
- 实现证书固定（Certificate Pinning）

### 7.2 代码安全
- 不在代码中硬编码密钥和密码
- 使用混淆技术保护关键算法
- 定期更新第三方依赖库

## 8. 依赖管理

### 8.1 包管理工具
- 优先使用 Swift Package Manager
- 复杂依赖可考虑 CocoaPods
- 避免使用 Carthage（已不推荐）

### 8.2 版本控制
- 锁定依赖版本，避免自动更新
- 定期审查和更新依赖
- 记录依赖变更原因

## 9. 调试与日志

### 9.1 日志系统
- 使用统一的日志框架（如 os_log）
- 区分日志级别：Debug, Info, Warning, Error
- 生产环境禁用 Debug 日志

### 9.2 调试工具
- 使用 LLDB 进行断点调试
- 利用 Xcode Instruments 进行性能分析
- 集成崩溃报告工具（如 Crashlytics）

## 10. 发布与部署

### 10.1 版本管理
- 使用语义化版本号（Semantic Versioning）
- 维护详细的 CHANGELOG
- 使用 Git 标签标记发布版本

### 10.2 自动化构建
- 配置 CI/CD 流水线
- 自动化测试和代码质量检查
- 自动化打包和分发流程

## 11. AI 编程特殊注意事项

### 11.1 代码生成质量
- AI 生成的代码必须经过人工审查
- 确保生成的代码符合项目规范
- 验证 AI 生成代码的安全性和性能

### 11.2 提示词优化
- 提供清晰的需求描述
- 包含具体的技术栈和约束条件
- 提供相关的代码上下文

### 11.3 迭代改进
- 记录 AI 编程的成功案例和失败经验
- 持续优化系统规则和提示词
- 建立代码质量反馈机制
