import Foundation

class Reply{
    static let ID: String = "_id"
    static let REPLY: String = "reply"
    static let APPROVED: String = "approved"
    static let USER: String = "user"
    static let COMMENT: String = "comment"
    
    
    var id: String?
    var reply: String?
    var approved: Bool?
    var user: User?
    var comment: Comment?
    
    init(id: String) {
        self.id = id
    }
    
    init(replyDictionary: Dictionary<String, Any>) throws {
        if let val = replyDictionary[Reply.ID] as? String {
            id = val
        } else{
            throw Exception(message: "Reply must contain key, id")
        }
        
        if let val = replyDictionary[Reply.REPLY] as? String {
            reply = val
        } else{
            throw Exception(message: "Reply must contain key, reply")
        }
        
        if let val = replyDictionary[Reply.APPROVED] as? String {
            approved = val == "true"
        } else{
            throw Exception(message: "Reply must contain key, approved")
        }
        
        if let val = replyDictionary[Reply.USER] as? Dictionary<String, Any> {
            user = try User(userDictionary: val)
        } else if let val = replyDictionary[Reply.USER] as? String{
            user = User(id: val)
        } else{
            throw Exception(message: "Reply must contain key, user")
        }
        
        if let val = replyDictionary[Reply.COMMENT] as? Dictionary<String, Any> {
            comment = try Comment(commentDictionary: val)
        } else if let val = replyDictionary[Reply.COMMENT] as? String{
            comment = Comment(id: val)
        } else{
            throw Exception(message: "Reply must contain key, comment")
        }
    }
    
    static func getReplyArray(fromArrayOfDictionaty arrayDictionary: Array<Any>) throws -> Array<Reply>{
        var repliesArray: Array<Reply> = Array<Reply>()
        if(arrayDictionary.count > 0){
            try arrayDictionary.forEach { item in
                if let item = item as? Dictionary<String, Any> {
                    repliesArray.append(try Reply(replyDictionary: item))
                } else if let item = item as? String {
                    repliesArray.append(Reply(id: item))
                }
            }
        }
        return repliesArray
    }
}
