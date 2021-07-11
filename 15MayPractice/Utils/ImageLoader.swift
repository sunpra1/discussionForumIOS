import Foundation

class ImageLoader: OnRequestResultDelegate {
    private let onLoadComplete: (Data?) -> Void
    private var request: APIRequest?
    
    init(URLString: String, onLoadComplete: @escaping (Data?) -> Void ) {
        self.onLoadComplete = onLoadComplete
        do{
            request = try APIRequest(identifer:"", url: URLString, requestType: RequestType.GET)
            request!.delegate = self
        }catch{
            print("Unable to get load image: \((error as? Exception)?.message ?? error.localizedDescription)")
            onLoadComplete(nil)
        }
    }
    
    func load(){
        request!.execute()
    }
    
    func onSuccessResponse(identifer: String, data: Data, statusCode: Int) {
        onLoadComplete(data)
    }
    
    func onFailedResponse(identifer: String, errorMessage: Data, statusCode: Int) {
        onLoadComplete(nil)
    }
    
    func onErrorThrown(identifer: String, error: String) {
        onLoadComplete(nil)
    }
}
