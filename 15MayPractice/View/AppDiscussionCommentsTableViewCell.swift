import UIKit

class AppDiscussionCommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var commentOwnerImageIV: UIImageView!
    @IBOutlet weak var commentOwnerNameLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var positiveVoteCountLbl: UILabel!
    @IBOutlet weak var negativeVoteCountLbl: UILabel!
    @IBOutlet weak var repliesCountLbl: UILabel!
    @IBOutlet weak var commentPostDateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.displayAsCard()
        borderView.addBorder(width: 1, color: UIColor.gray.cgColor)
        commentOwnerImageIV.addRoundedBorder(radius: commentOwnerImageIV.layer.bounds.height / 2, width: 0.5, color: UIColor.white.cgColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
