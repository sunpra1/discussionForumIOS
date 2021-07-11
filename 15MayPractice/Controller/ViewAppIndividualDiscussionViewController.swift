import UIKit

class ViewAppIndividualDiscussionViewController: UIViewController {
    private let GET_DISCUSSION_IDENTIFER: String = "GET_DISCUSSION_IDENTIFER"
    private let POST_NEW_COMMENT_IDENTIFER: String = "POST_NEW_COMMENT_IDENTIFER"
    private let POST_NEW_VOTE_IDENTIFER: String = "POST_NEW_VOTE_IDENTIFER"
    
    @IBOutlet weak var loading: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var discussionOwnerImageIV: UIImageView!
    @IBOutlet private weak var discussionOwnerNameLbl: UILabel!
    @IBOutlet private weak var discussionTitleLbl: UILabel!
    @IBOutlet private weak var discussionCategoryLbl: UILabel!
    @IBOutlet private weak var discussionStartDateLbl: UILabel!
    @IBOutlet private weak var discussionImageIV: UIImageView!
    @IBOutlet private weak var discussionTopicLbl: UILabel!
    @IBOutlet private weak var discussionCommentsCountLbl: UILabel!
    @IBOutlet private weak var discussionViewsCountLbl: UILabel!
    @IBOutlet private weak var discussionCommentsTV: UITableView!
    @IBOutlet private weak var noCommentsYetLbl: UILabel!
    @IBOutlet private weak var newCommentTF: UITextField!
    @IBOutlet private weak var addCommentBtn: UIButton!
    @IBOutlet private weak var discussionCommentsTVHeightConstraint: NSLayoutConstraint!
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private let hasInitialLoadFinished: Bool = false
    
    private var discussion: Discussion?
    var discussionID: String!
    var deligate: OnDiscussionRefreshed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "VIEW DISCUSSION"
        
        cardView.displayAsCard()
        discussionOwnerImageIV.addRoundedBorder(radius: discussionOwnerImageIV.layer.bounds.height / 2, width: 1.0, color: UIColor.white.cgColor)
        newCommentTF.addRoundedBorderAndShadow()
        addCommentBtn.addRoundedBorderAndShadow()
        
        discussionOwnerImageIV.image = UIImage(systemName: "person.circle")
        discussionOwnerNameLbl.text = ""
        discussionTitleLbl.text = ""
        discussionCategoryLbl.text = ""
        discussionStartDateLbl.text = ""
        discussionTopicLbl.text = ""
        discussionImageIV.image = UIImage(named: "image")
        discussionCommentsCountLbl.text = ""
        discussionViewsCountLbl.text = ""
        noCommentsYetLbl.isHidden = true
        discussionCommentsTV.delegate = self
        discussionCommentsTV.dataSource = self
        discussionCommentsTV.register(UINib(nibName: APP.K.APP_DISCUSSION_COMMENTS_NIB, bundle: nil), forCellReuseIdentifier: APP.K.APP_DISCUSSION_COMMENTS_CELL)
        discussionCommentsTV.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        refreshControl.addTarget(self, action: #selector(getDiscussion), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        getDiscussion()
    }
    
    @IBAction func onCommentBtnClicked(_ sender: UIButton) {
        if let comment = newCommentTF.text , !comment.isEmpty{
            do{
                let requestBody: Dictionary<String, String> = ["comment": comment]
                var apiRequest: APIRequest = try APIRequest(identifer: POST_NEW_COMMENT_IDENTIFER, url: APIRoute.postNewCommentRoute(inDiscussion: discussionID), requestType: .POST, requestBody: requestBody, authorizationToken: UserDefaults.standard.string(forKey: APP.K.TOKEN))
                apiRequest.delegate = self
                apiRequest.execute()
            }catch{
                print("Error occured: \((error as? Exception)?.message ?? error.localizedDescription)")
            }
            
        }else{
            Toast.make().show(message: "Please provide your comment", in: self, forDuration: .LENGTH_MEDIUM)
        }
    }
    
    private func updateView(){
        if let discussion = discussion {
            if let discussionOwnerImage = discussion.image{
                ImageLoader(URLString: "\(APIRoute.baseUrl())\(discussionOwnerImage)") { data in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.discussionOwnerImageIV.image = UIImage(data: data)
                        }
                    }
                }.load()
            }
            
            discussionOwnerNameLbl.text = discussion.user!.name!
            discussionTitleLbl.text = discussion.title!
            discussionCategoryLbl.text = discussion.category!.category!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = APP.K.DATE_FORMAT_APP
            discussionStartDateLbl.text = dateFormatter.string(from: discussion.createdAt!)
            
            discussionTopicLbl.text = discussion.topic!
            
            if let discussionImage = discussion.image {
                discussionImageIV.isHidden = false
                ImageLoader(URLString: "\(APIRoute.baseUrl())\(discussionImage)") { data in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.discussionImageIV.image = UIImage(data: data)
                        }
                    }
                }.load()
            }else {
                discussionImageIV.isHidden = true
            }
            
            discussionCommentsCountLbl.text = "\(discussion.comments!.count)"
            discussionViewsCountLbl.text = "\(discussion.views!)"
            
            noCommentsYetLbl.isHidden = discussion.comments!.count != 0
            
            discussionCommentsTV.reloadData()
        }
    }
    
    @objc private func getDiscussion(){
        do{
            var apiRequest:APIRequest = try APIRequest(identifer: GET_DISCUSSION_IDENTIFER, url: APIRoute.getIndividualDiscussion(withId: discussionID), requestType: .GET)
            apiRequest.delegate = self
            apiRequest.execute()
        }catch{
            print("Error occured: \((error as? Exception)?.message ?? error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        discussionCommentsTV.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize"{
            if object is UITableView{
                if let newValue = change?[.newKey]{
                    let newSize = newValue as! CGSize
                    discussionCommentsTVHeightConstraint.constant = newSize.height
                }
            }
        }
    }
    
    private func postVote(commentID: String, voteType: Vote.VoteType){
        do{
            let requestBody: Dictionary<String, String> = ["type": voteType.getString()]
            var apiRequest: APIRequest = try APIRequest(identifer: POST_NEW_VOTE_IDENTIFER, url: APIRoute.postVoteRoute(inComment: commentID, ofDiscussion: discussionID), requestType: .POST, requestBody: requestBody, authorizationToken: UserDefaults.standard.string(forKey: APP.K.TOKEN))
            apiRequest.delegate = self
            apiRequest.execute()
        }catch{
            print("Error occured: \((error as? Exception)?.message ?? error.localizedDescription)")
        }
    }
}

extension ViewAppIndividualDiscussionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let leadingAction: UIContextualAction = UIContextualAction(style: .normal, title: nil) { action, view, completion in
            self.postVote(commentID: self.discussion!.comments![indexPath.row].id!, voteType: .POSITIVE)
            completion(true)
        }
        leadingAction.image = UIImage(systemName: "hand.thumbsup.fill")
        leadingAction.backgroundColor = UIColor.green.withAlphaComponent(0.7)
        return UISwipeActionsConfiguration(actions: [leadingAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let trailingAction: UIContextualAction = UIContextualAction(style: .destructive, title: nil) { action, view, completion in
            self.postVote(commentID: self.discussion!.comments![indexPath.row].id!, voteType: .NEGATIVE)
            completion(true)
        }
        trailingAction.image = UIImage(systemName: "hand.thumbsdown.fill")
        trailingAction.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        return UISwipeActionsConfiguration(actions: [trailingAction])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discussion != nil ? discussion!.comments!.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AppDiscussionCommentsTableViewCell = tableView.dequeueReusableCell(withIdentifier: APP.K.APP_DISCUSSION_COMMENTS_CELL) as! AppDiscussionCommentsTableViewCell
        let comment: Comment = discussion!.comments![indexPath.row]
        
        if let ownerImage = comment.user!.image {
            ImageLoader(URLString: "\(APIRoute.baseUrl())\(ownerImage)") { data in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.commentOwnerImageIV.image = UIImage(data: data)
                    }
                }
            }.load()
        }
        
        cell.commentOwnerNameLbl.text = comment.user!.name!
        cell.commentLbl.text = comment.comment!
        
        let positiveVoteCount: Int = comment.votes!.reduce(0, { result, vote in
            var sum: Int = result
            if(vote.type == .POSITIVE){
                sum += 1
            }
            return sum
        })
        let negativeVoteCount = comment.votes!.count - positiveVoteCount
        
        cell.positiveVoteCountLbl.text = "\(positiveVoteCount)"
        cell.negativeVoteCountLbl.text = "\(negativeVoteCount)"
        cell.repliesCountLbl.text = "\(comment.replies!.count)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = APP.K.DATE_FORMAT_APP
        cell.commentPostDateLbl.text = dateFormatter.string(from: comment.createdAt!)
        
        return cell
    }
}

extension ViewAppIndividualDiscussionViewController: UITableViewDelegate {
    
}

extension ViewAppIndividualDiscussionViewController: OnRequestResultDelegate{
    func onSuccessResponse(identifer: String, data: Data, statusCode: Int) {
        switch identifer {
        case GET_DISCUSSION_IDENTIFER:
            do{
                if let responseData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String, Any> {
                    discussion = try Discussion(discussionDictionary: responseData)
                    DispatchQueue.main.async {
                        if let discussion = self.discussion {
                            self.updateView()
                            if !self.hasInitialLoadFinished && !self.loading.isHidden {
                                self.loading.isHidden = true
                            }
                            if self.refreshControl.isRefreshing {
                                self.refreshControl.endRefreshing()
                            }
                                
                            if let deligate = self.deligate {
                                deligate.refreshed(refreshedDiscussion: discussion)
                            }
                        }
                    }
                }
            }catch{
                print("Error occured: \((error as? Exception)?.message ?? error.localizedDescription)")
            }
            break
        case POST_NEW_COMMENT_IDENTIFER:
            do{
                if let responseData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String, Any> {
                    let comment: Comment = try Comment(commentDictionary: responseData)
                    DispatchQueue.main.async {
                        if let discussion = self.discussion {
                            discussion.comments!.append(comment)
                            self.updateView()
                            if let deligate = self.deligate {
                                deligate.refreshed(refreshedDiscussion: discussion)
                            }
                        }
                    }
                }
            }catch{
                print("Error occured: \((error as? Exception)?.message ?? error.localizedDescription)")
            }
            break
        case POST_NEW_VOTE_IDENTIFER:
            do{
                if let responseData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String, Any>{
                    let vote: Vote = try Vote(voteDictionary: responseData)
                    let commentIndex: Int? = discussion!.comments!.firstIndex(where: { comment in comment.id! == vote.comment!.id!  })
                    if let commentIndex = commentIndex {
                        DispatchQueue.main.async {
                            self.discussion!.comments![commentIndex].votes!.append(vote)
                            self.deligate?.refreshed(refreshedDiscussion: self.discussion!)
                            Toast.make().show(message: "\(vote.type!.getString().uppercased()) provided successfully.", in: self, forDuration: .LENGTH_MEDIUM)
                            self.discussionCommentsTV.reloadRows(at: [IndexPath(row: commentIndex, section: 0)], with: .automatic)
                        }
                    }
                }
            }catch{
                print("Error occured: \((error as? Exception)?.message ?? error.localizedDescription)")
            }
        default:
            break
        }
    }
    
    func onFailedResponse(identifer: String, errorMessage: Data, statusCode: Int) {
        switch identifer {
        case GET_DISCUSSION_IDENTIFER:
            DispatchQueue.main.async {
                self.displayAlertMessage(message: Formatter.getSimplifiedErrorResponse(data: errorMessage) ?? "Unable to load discussion.")
            }
            break
        case POST_NEW_COMMENT_IDENTIFER:
            DispatchQueue.main.async {
                self.displayAlertMessage(message: Formatter.getSimplifiedErrorResponse(data: errorMessage) ?? "Unable to post your comment.")
            }
            break
        case POST_NEW_VOTE_IDENTIFER:
            DispatchQueue.main.async {
                self.displayAlertMessage(message: Formatter.getSimplifiedErrorResponse(data: errorMessage) ?? "Unable to post your vote.")
            }
            break
        default:
            break
        }
    }
    
    func onErrorThrown(identifer:String, error: String) {
        DispatchQueue.main.async {
            self.displayAlertMessage(message: error)
        }
    }
}

protocol OnDiscussionRefreshed {
    func refreshed(refreshedDiscussion: Discussion)
}
