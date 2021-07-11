import UIKit

struct APIRequest {
    private var request: URLRequest
    private var identifier: String
    var delegate: OnRequestResultDelegate?
    
    init(identifer: String, url: String, requestType: RequestType, requestBody: Dictionary<String, Any>? = nil, authorizationToken: String? = nil) throws {
        self.identifier = identifer
        if let url: URL = URL(string: url){
            request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            if let authorizationToken = authorizationToken {
                request.addValue(authorizationToken, forHTTPHeaderField: "authorization")
            }
            
            request.httpMethod = requestType.toString()
            
            if let requestBody = requestBody {
                do{
                    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: JSONSerialization.WritingOptions())
                }catch{
                    throw Exception(message: "Unable to parse the dictionary into JSON Object: \(error.localizedDescription)")
                }
            }
        }else{
            throw Exception(message: "Invalid url provided")
        }
        
    }
    
    init(identifer: String, url: String, requestType: RequestType, fileParts: Dictionary<String, Data>? = nil, bodyPart: Dictionary<String, Any>? = nil, authorizationToken: String? = nil) throws {
        self.identifier = identifer
        
        let lineBreak: String = "\r\n"
        let boundary: String = "--------------------------\(UUID().uuidString)"
        
        if let url: URL = URL(string: url){
            request = URLRequest(url: url)
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")
            request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
            
            if let authorizationToken = authorizationToken {
                request.addValue(authorizationToken, forHTTPHeaderField: "authorization")
            }
            
            request.httpMethod = requestType.toString()
            
            var requestData = Data()
            if let bodyPart = bodyPart, !bodyPart.isEmpty {
                for (key, value) in bodyPart{
                    if let value = value as? String {
                        print("\(key) -> \(value)")
                        requestData.append("\(lineBreak)--\(boundary+lineBreak)" .data(using: .utf8)!)
                        requestData.append("content-disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)".data(using: .utf8)!)
                        requestData.append(value.data(using: .utf8)!)
                    }
                }
            }
            
            if let fileParts = fileParts, !fileParts.isEmpty {
                for (key, value) in fileParts {
                        requestData.append("\(lineBreak)--\(boundary+lineBreak)" .data(using: .utf8)!)
                        requestData.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"discussionImage.jpeg\"\(lineBreak)".data(using: .utf8)!)
                        requestData.append("Content-Type: image/jpeg \(lineBreak + lineBreak)" .data(using: .utf8)!)
                        requestData.append(value)
                }
            }
            
            requestData.append("\(lineBreak)--\(boundary)--\(lineBreak)".data(using: .utf8)!)
            request.addValue("\(requestData.count)", forHTTPHeaderField: "content-length")
            request.httpBody = requestData
        }else{
            throw Exception(message: "Invalid url provided")
        }
    }
    
    func execute(){
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let delegate = delegate {
                if(error == nil){
                    print("Data------------->\n\(String(data: data!, encoding: .utf8) ?? "Unable to encode"))\n<-------------->")
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode, let data = data{
                        if((200...300).contains(statusCode)){
                            delegate.onSuccessResponse(identifer: identifier, data: data, statusCode: statusCode)
                        }else{
                            delegate.onFailedResponse(identifer: identifier, errorMessage: data, statusCode: statusCode)
                        }
                    }
                }else{
                    print(error!.localizedDescription)
                    delegate.onErrorThrown(identifer: identifier, error: error!.localizedDescription)
                }
            }
        }.resume()
    }
}

enum RequestType {
    case POST, GET
    func toString() -> String{
        var type: String
        switch self {
        case .POST:
            type = "POST"
            break
        case .GET:
            type = "GET"
            break
        }
        return type
    }
}

protocol OnRequestResultDelegate {
    func onSuccessResponse(identifer: String, data: Data, statusCode: Int)
    func onFailedResponse(identifer: String, errorMessage: Data, statusCode: Int)
    func onErrorThrown(identifer: String, error: String)
}
