import Foundation

class APIRoute {
    private static let BASE_URL: String = "http://192.168.0.174:5000/"
    
    static func baseUrl() -> String{
        return BASE_URL
    }
    
    static func loginRoute() -> String {
        return "\(BASE_URL)users/login"
    }
    
    static func getUserProfileRoute() ->  String {
        return "\(BASE_URL)users/profile"
    }
    
    static func getDiscussionsRoute(page: Int = 1, limit: Int = 100, category: String = "null", search: String = "null", sortOptions: String = "null") -> String {
        return "\(BASE_URL)discussions/\(limit)/\(page)/\(category)/\(search)/\(sortOptions)"
    }
    
    static func getCategoriesRoute() -> String {
        return "\(BASE_URL)categories"
    }
    
    static func addDiscussionRoute() -> String{
        return "\(BASE_URL)discussions"
    }
    
    static func getIndividualDiscussion(withId id: String) -> String{
        return "\(BASE_URL)discussions/\(id)"
    }
    
    static func postNewCommentRoute(inDiscussion discussionID: String) -> String{
        return "\(BASE_URL)discussions/\(discussionID)/comments"
    }
    
    static func postVoteRoute(inComment commentID: String, ofDiscussion discussionID: String) -> String{
        return "\(BASE_URL)discussions/\(discussionID)/comments/\(commentID)/votes"
    }
}
