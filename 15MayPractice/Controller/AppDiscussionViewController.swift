import UIKit

class AppDiscussionViewController: UIViewController{
    let GET_APP_DISCUSSIONS_IDENTIFER = "GET_APP_DISCUSSIONS_IDENTIFER"
    
    @IBOutlet private weak var discussionsTableView: UITableView!
    private var discussions: Array<Discussion> = Array<Discussion>()
    private var didPulledToRefresh = false
    private var selectedDiscussionIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "DISCUSSIONS"
        navigationItem.hidesBackButton = true
        discussionsTableView.dataSource = self
        discussionsTableView.delegate = self
        discussionsTableView.estimatedRowHeight = discussionsTableView.rowHeight
        discussionsTableView.rowHeight = UITableView.automaticDimension
        discussionsTableView.register(UINib(nibName: APP.K.APP_DISCUSSIONS_NIB, bundle: nil), forCellReuseIdentifier: APP.K.APP_DISCUSSIONS_CELL)
        
        let uiRefreshControl: UIRefreshControl = UIRefreshControl()
        uiRefreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        discussionsTableView.refreshControl = uiRefreshControl        
        
        getDiscussions()
    }
    
    @IBAction func addNewDiscussionBarBtnClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: APP.K.SEGUE_APP_DISCUSSIONS_TO_ADD_DISCUSSION, sender: self)
    }
    
    @objc private func pullToRefresh(){
        didPulledToRefresh = true
        getDiscussions()
    }
    
    private func getDiscussions(){
        do{
            var apiRequest = try APIRequest(identifer: GET_APP_DISCUSSIONS_IDENTIFER, url: APIRoute.getDiscussionsRoute(), requestType: RequestType.GET)
            apiRequest.delegate = self
            apiRequest.execute()
        }catch{
            print("Unable to perform API Request: \(error.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addDiscussionVC = segue.destination as? AddDiscussionViewController {
            addDiscussionVC.delegate = self
        } else if let viewAppIndividualDiscussion = segue.destination as? ViewAppIndividualDiscussionViewController {
            viewAppIndividualDiscussion.deligate = self
            viewAppIndividualDiscussion.discussionID = discussions[selectedDiscussionIndex].id!
        }
    }
}

extension AppDiscussionViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let leadingAction: UIContextualAction = UIContextualAction(style: .normal, title: nil) { action, view, completion in
            completion(true)
        }
        leadingAction.image = UIImage(systemName: "pencil")
        leadingAction.backgroundColor = UIColor.green.withAlphaComponent(0.7)
        
        return UISwipeActionsConfiguration(actions: [leadingAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let trailingAction: UIContextualAction = UIContextualAction(style: .destructive, title: nil) { action, view, complition in
            complition(true)
        }
        trailingAction.image = UIImage(systemName: "trash")
        trailingAction.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        
        return UISwipeActionsConfiguration(actions: [trailingAction])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discussions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AppDiscussionsTableViewCell = tableView.dequeueReusableCell(withIdentifier: APP.K.APP_DISCUSSIONS_CELL, for: indexPath) as! AppDiscussionsTableViewCell
        let discussion = discussions[indexPath.row]
        cell.discussionOwnerName.text = discussion.user!.name!
        cell.discussionTitle.text = discussion.title!
        cell.discussionCategory.text = discussion.category!.category!
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = APP.K.DATE_FORMAT_APP
        cell.discussionStartDate.text = dateFormat.string(from: discussion.createdAt!)
        cell.viewCount.text = "\(discussion.views!)"
        cell.commentCount.text = "\(discussion.comments!.count)"
        if let ownerImageURL = discussion.user?.image {
            ImageLoader(URLString: "\(APIRoute.baseUrl())\(ownerImageURL)") { data in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.discussionOwnerImage.image = UIImage(data: data)
                    }
                }
            }.load()
        }else{
            cell.discussionOwnerImage.image = UIImage(named: "image")
        }
        return cell
    }
}

extension AppDiscussionViewController: OnRequestResultDelegate {
    func onSuccessResponse(identifer: String, data: Data, statusCode: Int) {
        switch identifer {
        case GET_APP_DISCUSSIONS_IDENTIFER:
            do{
                if let response = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Array<Any>{
                    discussions = try Discussion.getDiscussionArray(fromArrayOfDictionaty: response)
                    DispatchQueue.main.async {
                        self.discussionsTableView.reloadData()
                        if(self.didPulledToRefresh) {
                            self.discussionsTableView.refreshControl?.endRefreshing()
                        }
                    }
                }
            }catch{
                print("Error occured: \((error as? Exception)?.message ?? error.localizedDescription)")
            }
            break
        default:
            break
        }
    }
    
    func onFailedResponse(identifer: String, errorMessage: Data, statusCode: Int) {
        switch identifer {
        case GET_APP_DISCUSSIONS_IDENTIFER:
                DispatchQueue.main.async {
                    self.displayAlertMessage(message: Formatter.getSimplifiedErrorResponse(data: errorMessage) ?? "Unable to get discussions.")
                }
                break
            default:
                break
        }
    }
    
    func onErrorThrown(identifer: String, error: String) {
        DispatchQueue.main.async {
            self.displayAlertMessage(message: error)
        }
    }
}

extension AppDiscussionViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDiscussionIndex = indexPath.row
        performSegue(withIdentifier: APP.K.SEGUE_APP_DISCUSSIONS_TO_VIEW_APP_INDIVIDUAL_DISCUSSION, sender: self)
    }
}

extension AppDiscussionViewController: OnNewDiscussionAddedDelegate{
    func onNewDiscussionAdded(discussion: Discussion) {
        discussions.insert(discussion, at: 0)
        discussionsTableView.reloadData()
    }
}

extension AppDiscussionViewController: OnDiscussionRefreshed {
    func refreshed(refreshedDiscussion: Discussion) {
        if let discussionIndex: Int = discussions.firstIndex(where: { discussion in refreshedDiscussion.id! == discussion.id!}){
            discussions[discussionIndex] = refreshedDiscussion
            discussionsTableView.reloadRows(at: [IndexPath(row: discussionIndex, section: 0)], with: .automatic)
        }
    }
}
