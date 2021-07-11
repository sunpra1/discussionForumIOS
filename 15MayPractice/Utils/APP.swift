import Foundation

class APP {
    private init(){}
    var loggedInUser: User?
    private static var instance: APP?
    static func getInstance() -> APP{
        if (instance == nil){
            instance = APP()
        }
        return self.instance!
    }
    
    class K {
        static let TOKEN: String = "token"
        static let USER: String = "user"
        static let MESSAGE: String = "message"
        static let APP_DISCUSSIONS_CELL = "AppDiscussionsTableViewCell"
        static let APP_DISCUSSIONS_NIB = "AppDiscussionsTableViewCell"
        static let DATE_FORMAT_API = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        static let DATE_FORMAT_APP = "MMM dd, yyyy"
        static let SEGUE_APP_DISCUSSIONS_TO_ADD_DISCUSSION = "APPDiscussionsToAddDiscussion"
        static let SEGUE_LOGIN_TO_APP_DISCUSSION = "LoginToAppDiscussions"
        static let SEGUE_APP_DISCUSSIONS_TO_VIEW_APP_INDIVIDUAL_DISCUSSION = "AppDiscussionsToViewAppIndividualDiscussion"
        static let APP_DISCUSSION_COMMENTS_CELL = "AppDiscussionCommentsTableViewCell"
        static let APP_DISCUSSION_COMMENTS_NIB = "AppDiscussionCommentsTableViewCell"
    }
}
