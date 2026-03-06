# RJXJsonToModelFile

**RJXJsonToModelFile** 是一个将 JSON 字符串快速转换为 Swift Model 文件的工具库。支持复杂嵌套 JSON、自动类型推断、snake_case 转 camelCase 等功能，让你告别手写 Model 的烦恼。

## ✨ 特性

- 🚀 **快速转换** - 粘贴 JSON，一键生成 Swift Model
- 🔍 **自动类型推断** - 智能识别 String、Int、Double、Bool、Array、Object 等类型
- 📝 **命名转换** - 自动将 snake_case 转换为 camelCase，并生成 CodingKeys
- 🎯 **复杂嵌套支持** - 支持多层嵌套对象和数组，自动为嵌套对象生成独立 Struct
- 📦 **自动命名** - Model 名称自动追加"Model"后缀（如需要）
- 📁 **批量输出** - 所有生成的文件自动保存到桌面的工作区文件夹

### 手动安装

将 `RJXJsonToModelFile` 文件夹中的 `.swift` 文件复制到你的项目中：

- `JsonToModelConverter.swift` - 核心转换器
- `JsonToModel.swift` - 便捷调用接口

## 🚀 快速开始

### 基本用法

```swift
import RJXJsonToModelFile

"""

do {
    let modelCode = try JsonToModel.convert("json字符串", to: "model名字")
    print(modelCode)
} catch {
    print("转换失败：\(error)")
}
```

### 异步调用

```swift
import RJXJsonToModelFile

do {
    let modelCode = try JsonToModel.convertAsync("json字符串", to: "model名字")
    print(modelCode)
} catch {
    print("错误：\(error)")
}
```

## 📊 类型映射

| JSON 类型 | Swift 类型 | 说明 |
|---------|----------|------|
| String | `String` | 字符串 |
| Number (整数) | `Int` | 整数 |
| Number (小数) | `Double` | 浮点数 |
| Boolean | `Bool` | 布尔值 |
| Array | `[ElementType]` | 数组 |
| Object | `Struct` | 自动生成 Struct |
| null | `String?` | 可选字符串 |

## ⚠️ 注意事项

### 模拟器 vs 真机

由于 iOS 沙盒限制，本库的文件写入功能**仅在模拟器环境下可用**。

- **模拟器**：✅ 支持完整功能，文件可自动保存到桌面
- **真机**：❌ 文件写入功能已禁用，但转换功能仍可用（需自行处理输出）

### 工作区目录

生成的文件默认保存到桌面的工作区文件夹：

```
~/Desktop/RJXJsonToModelFile-Workspace/<ModelName>.swift
```

## 🛠 环境要求

- iOS 13.0+
- Swift 5.0+
- Xcode 14.0+

## 📄 许可证

RJXJsonToModelFile 使用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 👤 作者

- **RenJiaxinRealy** - [927453211@qq.com](mailto:927453211@qq.com)
- GitHub: [@RenJiaxinRealy](https://github.com/RenJiaxinRealy)

## 🙏 致谢

感谢使用 RJXJsonToModelFile！如果有任何问题或建议，欢迎提交 Issue 或 Pull Request。

---

<p align="center">
  <img src="https://img.shields.io/badge/Made%20with-%E2%9D%A4-red" alt="Made with Love">
</p>
