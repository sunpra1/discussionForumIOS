import UIKit

class AppDiscussionsTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var discussionOwnerImage: UIImageView!
    @IBOutlet weak var discussionOwnerName: UILabel!
    @IBOutlet weak var discussionTitle: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var discussionCategory: UILabel!
    @IBOutlet weak var discussionStartDate: UILabel!
    @IBOutlet weak var viewCount: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.displayAsCard()
        borderView.addBorder(width: 1, color: UIColor.gray.cgColor)
        discussionOwnerImage.addRoundedBorder(radius: discussionOwnerImage.layer.frame.height / 2, width: 0.5, color: UIColor.white.cgColor)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
