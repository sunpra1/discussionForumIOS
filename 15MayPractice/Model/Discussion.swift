import Foundation

class Discussion{
    static let ID: String = "_id"
    static let TITLE: String = "title"
    static let TOPIC: String = "topic"
    static let IMAGE: String = "image"
    static let VIEWS: String = "views"
    static let USER: String = "user"
    static let CATEGORY: String = "category"
    static let COMMENTS: String = "comments"
    static let SUBSCRIBERS: String = "subscribers"
    static let CREATED_AT: String = "createdAt"
    
    var id: String?
    var title: String?
    var topic: String?
    var image: String?
    var views: Int?
    var user: User?
    var category: Category?
    var comments: Array<Comment>?
    var subscribers: Array<User>?
    var createdAt: Date?
    
    init(id: String){
        self.id = id
    }
    
    init(discussionDictionary: Dictionary<String, Any>) throws {
        if let val = discussionDictionary[Discussion.ID] as? String {
            id = val
        } else{
            throw Exception(message: "Discussion must contain key, id")
        }
        
        if let val = discussionDictionary[Discussion.TITLE] as? String {
            title = val
        } else{
            throw Exception(message: "Discussion must contain key, title")
        }
        
        if let val = discussionDictionary[Discussion.TOPIC] as? String {
            topic = val
        } else{
            throw Exception(message: "Discussion must contain key, topic")
        }
        
        if let val = discussionDictionary[Discussion.IMAGE] as? String {
            image = val
        }
        
        if let val = discussionDictionary[Discussion.VIEWS] as? Int {
            views = val
        } else{
            throw Exception(message: "Discussion must contain key, views")
        }
        
        if let val = discussionDictionary[Discussion.USER] as? Dictionary<String, Any> {
            user = try User(userDictionary: val)
        } else if let val = discussionDictionary[Comment.USER] as? String{
            user = User(id: val)
        } else{
            throw Exception(message: "Discussion must contain key, user")
        }
        
        if let val = discussionDictionary[Discussion.CATEGORY] as? Dictionary<String, Any> {
            category = try Category(categoryDictionary: val)
        } else if let val = discussionDictionary[Discussion.CATEGORY] as? String{
            category = Category(id: val)
        } else{
            throw Exception(message: "Discussion must contain key, category")
        }
        
        if let val = discussionDictionary[Discussion.COMMENTS] as? Array<Any> {
            comments = try Comment.getCommentArray(fromArrayOfDictionaty: val)
        } else {
            throw Exception(message: "Discussion must contain key, comments")
        }
        
        if let val = discussionDictionary[Discussion.CREATED_AT] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = APP.K.DATE_FORMAT_API
            dateFormatter.locale = .current
            createdAt =  dateFormatter.date(from: val)
        } else {
            throw Exception(message: "Discussion must contain key, createdAt")
        }
        
        if let val = discussionDictionary[Discussion.SUBSCRIBERS] as? Array<Any>{
            subscribers = try User.getUserArray(fromArrayOfDictionaty: val)
        }else{
            throw Exception(message: "Discussion must contain key, subscribers")
        }
    }
    
    static func getDiscussionArray(fromArrayOfDictionaty arrayDictionary: Array<Any>) throws -> Array<Discussion>{
        var discussionArray: Array<Discussion> = Array<Discussion>()
        if(arrayDictionary.count > 0){
            try arrayDictionary.forEach { item in
                if let item = item as? Dictionary<String, Any> {
                    discussionArray.append(try Discussion(discussionDictionary: item))
                } else if let item = item as? String {
                    discussionArray.append(Discussion(id: item))
                }
            }
        }
        return discussionArray
    }
    
}
