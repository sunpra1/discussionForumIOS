import Foundation

struct Formatter {
    static func getSimplifiedErrorResponse(data: Data?) -> String? {
        var formattedString: String? = String()
        if let data = data {
            do{
                if let errorResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String, Any>, let errorMessage = errorResponse[APP.K.MESSAGE] as? Dictionary<String, Any>{
                    errorMessage.forEach { key, value in
                        if let value = value as? String {
                            formattedString!.append(value)
                            formattedString!.append("\n")
                        }
                    }
                } else {
                    if let errorResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String, Any>, let errorMessage = errorResponse[APP.K.MESSAGE] as? String{
                            formattedString!.append(errorMessage)
                            formattedString!.append("\n")
                    }
                }
            } catch {
                print("Failed to get simplified error: \(error.localizedDescription)")
            }
        }
        return formattedString
    }
}
