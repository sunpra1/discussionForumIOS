import Foundation

class Comment{
    static let ID: String = "_id"
    static let COMMENT: String = "comment"
    static let APPROVED: String = "approved"
    static let USER: String = "user"
    static let DISCUSSION: String = "discussion"
    static let REPLIES: String = "replies"
    static let VOTES: String = "votes"
    static let CREATED_AT: String = "createdAt"
    
    var id: String?
    var comment: String?
    var approved: Bool?
    var user: User?
    var discussion: Discussion?
    var replies: Array<Reply>?
    var votes: Array<Vote>?
    var createdAt: Date?
    
    init(id: String) {
        self.id = id
    }
    
    init(commentDictionary: Dictionary<String, Any>) throws {
        if let val = commentDictionary[Comment.ID] as? String {
            id = val
        } else{
            throw Exception(message: "Comment must contain key, id")
        }
        
        if let val = commentDictionary[Comment.COMMENT] as? String {
            comment = val
        } else{
            throw Exception(message: "Comment must contain key, comment")
        }
        
        if let val = commentDictionary[Comment.APPROVED] as? Bool {
            approved = val
        } else{
            throw Exception(message: "Comment must contain key, approved")
        }
        
        if let val = commentDictionary[Comment.USER] as? Dictionary<String, Any> {
            user = try User(userDictionary: val)
        } else if let val = commentDictionary[Comment.USER] as? String{
            user = User(id: val)
        } else{
            throw Exception(message: "Comment must contain key, user")
        }
        
        if let val = commentDictionary[Comment.DISCUSSION] as? Dictionary<String, Any> {
            discussion = try Discussion(discussionDictionary: val)
        } else if let val = commentDictionary[Comment.DISCUSSION] as? String{
            discussion = Discussion(id: val)
        } else{
            throw Exception(message: "Comment must contain key, discussion")
        }
        
        if let val = commentDictionary[Comment.REPLIES] as? Array<Any> {
            replies = try Reply.getReplyArray(fromArrayOfDictionaty: val)
        } else {
            throw Exception(message: "Comment must contain key, replies")
        }
        
        if let val = commentDictionary[Comment.VOTES] as? Array<Any> {
            votes = try Vote.getVoteArray(fromArrayOfDictionaty: val)
        } else {
            throw Exception(message: "Comment must contain key, votes")
        }
        
        if let val = commentDictionary[Comment.CREATED_AT] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = APP.K.DATE_FORMAT_API
            dateFormatter.locale = .current
            createdAt =  dateFormatter.date(from: val)
        } else {
            throw Exception(message: "Comment must contain key, createdAt")
        }
    }
    
    static func getCommentArray(fromArrayOfDictionaty arrayDictionary: Array<Any>) throws -> Array<Comment>{
        var commentArray: Array<Comment> = Array<Comment>()
        if(arrayDictionary.count > 0){
            try arrayDictionary.forEach { item in
                if let item = item as? Dictionary<String, Any> {
                    commentArray.append(try Comment(commentDictionary: item))
                } else if let item = item as? String {
                    commentArray.append(Comment(id: item))
                }
            }
        }
        return commentArray
    }
}
