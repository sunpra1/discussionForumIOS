import Foundation

class Vote{
    static let ID: String = "_id"
    static let COMMENT: String = "comment"
    static let USER: String = "user"
    static let TYPE: String = "type"
    
    var id: String?
    var comment: Comment?
    var user: User?
    var type: VoteType?
    
    init(id: String) {
        self.id = id
    }
    
    init(voteDictionary: Dictionary<String, Any>) throws {
        if let val = voteDictionary[Vote.ID] as? String {
            id = val
        } else{
            throw Exception(message: "Vote must contain key, id")
        }
        
        if let val = voteDictionary[Vote.COMMENT] as? Dictionary<String, Any> {
            comment = try Comment(commentDictionary: val)
        } else if let val = voteDictionary[Vote.COMMENT] as? String {
            comment = Comment(id: val)
        }else{
            throw Exception(message: "Vote must contain key, comment")
        }
        
        if let val = voteDictionary[Vote.USER] as? Dictionary<String, Any> {
            self.user = try User(userDictionary: val)
        } else if let val = voteDictionary[Vote.USER] as? String{
            user = User(id: val)
        } else{
            throw Exception(message: "Vote must contain key, user")
        }
        
        if let val = voteDictionary[Vote.TYPE] as? String {
            self.type = try VoteType.getVoteType(voteType: val)
        } else{
            throw Exception(message: "Vote must contain key, type")
        }
    }
    
    static func getVoteArray(fromArrayOfDictionaty arrayDictionary: Array<Any>) throws -> Array<Vote>{
        var voteArray: Array<Vote> = Array<Vote>()
        if(arrayDictionary.count > 0){
            try arrayDictionary.forEach { item in
                if let item = item as? Dictionary<String, Any> {
                    voteArray.append(try Vote(voteDictionary: item))
                } else if let item = item as? String {
                    voteArray.append(Vote(id: item))
                }
            }
        }
        return voteArray
    }
    
    enum VoteType {
        case POSITIVE, NEGATIVE
        
        func getString() -> String {
            var voteType: String
            switch self {
                case .POSITIVE:
                    voteType = "positive"
                case .NEGATIVE:
                    voteType = "negative"
                }
            return voteType
        }
        
        static func getVoteType(voteType: String) throws -> VoteType{
            var type: VoteType
            switch voteType {
                case "positive":
                    type = .POSITIVE
                    break
                case "negative":
                    type = .NEGATIVE
                    break
                default:
                    throw Exception(message: "Invalid vote type provided")
            }
            return type
        }
    }
}
