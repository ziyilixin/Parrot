import Foundation

struct JSONUtils {
    /// 将任意对象尝试转换为 [String: Any]
    static func toDictionary(from object: Any) -> [String: Any]? {
        if let jsonString = object as? String,
           let data = jsonString.data(using: .utf8) {
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    return dictionary
                }
            } catch {
                print("JSON 解析失败: \(error)")
            }
        } else if let dictionary = object as? [String: Any] {
            return dictionary
        }
        return nil
    }
}

extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
            .flatMap { $0 as? [String: Any] }
    }
}
extension Array where Element: Encodable {
    func toDictionaryArray() -> [[String: Any]]? {
        return self.compactMap { $0.toDictionary() }
    }
}
