import Foundation

/// JSON 转 Model 工具类 - 简化调用
public class JsonToModel {

    private let converter = JsonToModelConverter()

    /// 将 JSON 字符串转换为 Model 文件
    /// - Parameters:
    ///   - jsonString: JSON 字符串
    ///   - modelName: Model 文件名称（不含 .swift 扩展名）
    /// - Returns: 生成的 Model 代码
    /// - Throws: ConverterError
    public static func convert(_ jsonString: String, to modelName: String) throws -> String {
        let converter = JsonToModelConverter()
        return try converter.convert(jsonString: jsonString, modelName: modelName)
    }

    /// 将 JSON 字符串转换为 Model 文件（异步版本）
    /// - Parameters:
    ///   - jsonString: JSON 字符串
    ///   - modelName: Model 文件名称（不含 .swift 扩展名）
    /// - Returns: 生成的 Model 代码
    public static func convertAsync(_ jsonString: String, to modelName: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                do {
                    let result = try convert(jsonString, to: modelName)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - 便捷使用示例
/*

 使用示例 1 - 基本用法:

 do {
     let jsonString = """
     {
         "name": "John",
         "age": 30,
         "email": "john@example.com"
     }
     """
     let modelCode = try JsonToModel.convert(jsonString, to: "User")
     print("Model 已生成并保存到桌面 RJXJsonToModelFile-Workspace 文件夹")
 } catch {
     print("错误：\(error)")
 }


 使用示例 2 - 嵌套 JSON:

 do {
     let jsonString = """
     {
         "user_id": 123,
         "user_name": "John",
         "profile": {
             "bio": "Developer",
             "avatar_url": "https://example.com/avatar.png"
         },
         "tags": ["ios", "swift"]
     }
     """
     let modelCode = try JsonToModel.convert(jsonString, to: "UserProfile")
 } catch {
     print("错误：\(error)")
 }

*/
