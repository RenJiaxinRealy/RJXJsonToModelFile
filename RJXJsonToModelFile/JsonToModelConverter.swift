import Foundation

/// JSON 转 Model 转换器
public class JsonToModelConverter {

    /// 工作区路径 - 桌面文件夹
    private let workspacePath: String

    /// 存储嵌套的 Struct 定义
    private var nestedStructs: [String] = []

    /// 已处理的类型名称集合（避免重复）
    private var processedTypeNames: Set<String> = []

    public init() {
        #if os(macOS)
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        self.workspacePath = "\(homeDir)/Desktop/RJXJsonToModelFile-Workspace"
        #else
        // iOS 模拟器：使用 documents 目录
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        var datas = documentsPath.components(separatedBy: "Library")
        self.workspacePath = "\(datas[0])Desktop/RJXJsonToModelFile-Workspace"
        #endif
    }

    /// 转换 JSON 字符串为 Model 文件
    /// - Parameters:
    ///   - jsonString: JSON 字符串
    ///   - modelName: Model 文件名称（不含扩展名）
    /// - Returns: 生成的 Model 代码
    public func convert(jsonString: String, modelName: String) throws -> String {
        // 仅在模拟器下运行
        #if !targetEnvironment(simulator)
        throw ConverterError.invalidJSON("此功能仅在模拟器下可用，真机环境已禁用")
        #endif

        // 如果 Model 名称不是以"Model"结尾，则追加"Model"
        let finalModelName = modelName.hasSuffix("Model") ? modelName : "\(modelName)Model"

        // 重置状态
        nestedStructs = []
        processedTypeNames = [finalModelName].toSet()

        // 确保工作区目录存在
        try createWorkspaceIfNeeded()

        // 解析 JSON
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw ConverterError.invalidJSON("无法将字符串转换为 Data")
        }

        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])

        // 生成 Model 代码
        let modelCode = generateModelCode(from: jsonObject, modelName: finalModelName)

        // 写入文件
        try writeModelFile(modelCode: modelCode, modelName: finalModelName)

        return modelCode
    }

    /// 创建的工作区目录
    private func createWorkspaceIfNeeded() throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: workspacePath) {
            try fileManager.createDirectory(atPath: workspacePath, withIntermediateDirectories: true, attributes: nil)
            print("已创建工作区目录：\(workspacePath)")
        }
    }

    /// 从 JSON 对象生成 Model 代码
    private func generateModelCode(from object: Any, modelName: String) -> String {
        var code = ""

        code += "//\n"
        code += "//  \(modelName).swift\n"
        code += "//  由 RJXJsonToModelConverter 自动生成\n"
        code += "//\n\n"

        code += "import Foundation\n\n"

        // 递归生成主模型和嵌套模型
        generateStruct(from: object, name: modelName, indent: "")

        // 添加所有嵌套的 Struct（在主模型之前）
        if !nestedStructs.isEmpty {
            code += nestedStructs.joined(separator: "\n")
            code += "\n"
        }

        // 生成主模型
        code += generateStructDefinition(from: object, name: modelName, indent: "")

        return code
    }

    /// 生成 Struct 定义（包含属性递归处理）
    private func generateStructDefinition(from object: Any, name: String, indent: String) -> String {
        var code = ""

        code += "\(indent)struct \(name): Codable {\n"

        if let dictionary = object as? [String: Any] {
            // 收集需要 CodingKeys 的属性
            var codingKeys: [(swiftName: String, jsonKey: String)] = []

            // 生成属性
            for (key, value) in dictionary.sorted(by: { $0.key < $1.key }) {
                let propertyName = convertToSwiftPropertyName(key)

                // 递归处理嵌套对象和数组
                let swiftType = inferSwiftType(from: value, parentName: name, propertyName: propertyName)

                code += "\(indent)    let \(propertyName): \(swiftType)\n"

                // 记录需要 CodingKeys 的情况
                if key != propertyName {
                    codingKeys.append((propertyName, key))
                }
            }

            // 生成 CodingKeys（如果需要）
            if !codingKeys.isEmpty {
                code += "\n\(indent)    enum CodingKeys: String, CodingKey {\n"
                for (swiftName, jsonKey) in codingKeys.sorted(by: { $0.swiftName < $1.swiftName }) {
                    if swiftName != jsonKey {
                        code += "\(indent)        case \(swiftName) = \"\(jsonKey)\"\n"
                    } else {
                        code += "\(indent)        case \(swiftName)\n"
                    }
                }
                code += "\(indent)    }\n"
            }
        }

        code += "\(indent)}\n"

        return code
    }

    /// 生成 Struct 定义（用于嵌套对象，返回是否生成了新结构）
    private func generateStruct(from object: Any, name: String, indent: String) {
        guard let dictionary = object as? [String: Any] else {
            return
        }

        // 先处理所有属性，收集嵌套类型
        for (key, value) in dictionary {
            let propertyName = convertToSwiftPropertyName(key)
            let typeName = makeTypeName(parent: name, property: propertyName)

            if let nestedDict = value as? [String: Any] {
                // 递归处理嵌套对象
                if !processedTypeNames.contains(typeName) {
                    processedTypeNames.insert(typeName)
                    generateStruct(from: nestedDict, name: typeName, indent: "")
                }
            } else if let array = value as? [Any] {
                // 处理数组中的元素
                handleArrayType(array, parentName: name, propertyName: propertyName)
            }
        }

        // 生成当前 Struct 定义并添加到列表
        let structDef = generateStructDefinition(from: object, name: name, indent: "")
        nestedStructs.append(structDef)
    }

    /// 处理数组类型，递归生成嵌套结构
    private func handleArrayType(_ array: [Any], parentName: String, propertyName: String) {
        guard let firstElement = array.first else {
            return
        }

        if let elementDict = firstElement as? [String: Any] {
            // 数组元素是对象，需要生成嵌套 Struct
            let typeName = makeTypeName(parent: parentName, property: propertyName)
            if !processedTypeNames.contains(typeName) {
                processedTypeNames.insert(typeName)
                generateStruct(from: elementDict, name: typeName, indent: "")
            }
        } else if let nestedArray = firstElement as? [Any] {
            // 数组元素是数组（多维数组）
            handleArrayType(nestedArray, parentName: parentName, propertyName: propertyName + "Item")
        }
    }

    /// 从 JSON 值推断 Swift 类型（支持递归嵌套）
    private func inferSwiftType(from value: Any, parentName: String, propertyName: String) -> String {
        switch value {
        case is String:
            return "String"
        case is Int:
            return "Int"
        case is Double:
            return "Double"
        case is Float:
            return "Float"
        case is Bool:
            return "Bool"
        case is NSNull:
            return "String?"
        case is [String: Any]:
            // 嵌套对象，生成 Inner 类型的 Struct
            return makeTypeName(parent: parentName, property: propertyName)
        case let array as [Any]:
            // 数组类型
            if array.isEmpty {
                return "[Any]"
            }
            let elementType = inferSwiftType(from: array.first!, parentName: parentName, propertyName: propertyName)
            return "[\(elementType)]"
        default:
            return "Any"
        }
    }

    /// 生成类型名称（基于父名称和属性名）
    private func makeTypeName(parent: String, property: String) -> String {
        // 将属性名转为首字母大写
        let capitalizedProperty = property.prefix(1).uppercased() + property.dropFirst()
        return "\(parent)\(capitalizedProperty)"
    }

    /// 将 JSON key 转换为 Swift 属性名（camelCase）
    private func convertToSwiftPropertyName(_ key: String) -> String {
        // 处理 snake_case 转 camelCase
        let components = key.split(separator: "_")
        if components.count == 1 {
            // 没有下划线，检查是否已经是合法的 Swift 标识符
            let cleaned = key.trimmingCharacters(in: .whitespaces)
            if cleaned.isEmpty {
                return "unknown"
            }
            // 确保首字母小写
            var result = cleaned
            if let firstChar = result.first {
                result.replaceSubrange(result.startIndex...result.startIndex, with: String(firstChar).lowercased())
            }
            // 处理非法字符
            result = result.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
            return result.isEmpty ? "unknown" : result
        } else {
            // snake_case 转 camelCase
            var result = ""
            for (index, component) in components.enumerated() {
                if index == 0 {
                    result += String(component).lowercased()
                } else {
                    if let firstChar = component.first {
                        result += String(firstChar).uppercased()
                        if component.count > 1 {
                            result += String(component.dropFirst()).lowercased()
                        }
                    }
                }
            }
            // 处理非法字符
            result = result.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
            return result.isEmpty ? "unknown" : result
        }
    }

    /// 写入 Model 文件
    private func writeModelFile(modelCode: String, modelName: String) throws {
        let filePath = "\(workspacePath)/\(modelName).swift"
        try modelCode.write(toFile: filePath, atomically: true, encoding: .utf8)
        print("Model 文件已创建：\(filePath)")
    }
}

/// 转换器错误
public enum ConverterError: LocalizedError {
    case invalidJSON(String)
    case fileWriteError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidJSON(let message):
            return "无效的 JSON: \(message)"
        case .fileWriteError(let message):
            return "文件写入错误：\(message)"
        }
    }
}

// MARK: - Helper Extensions

extension Array where Element: Hashable {
    func toSet() -> Set<Element> {
        return Set(self)
    }
}
