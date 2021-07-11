import UIKit

class SnackBar{
    private var snackBarContainer: UIView
    private var messageLabel: UILabel
    private var actionButton: UIButton
    private var hideTimer: Timer?
    private var snackBarAction: SnackBarAction?
    private static var instance: SnackBar?
    private var onDismissListener: (() -> Void)?
    private var isActionClicked: Bool = false
    
    @objc private func actionBtnClicked(){
        isActionClicked = true
        if let hideTimer = hideTimer, hideTimer.isValid {
            hideTimer.invalidate()
        }
        snackBarAction?.action()
        hideSnackBar()
    }
    
    @objc private func onSnackbarDismissed(sender: UISwipeGestureRecognizer){
        if let hideTimer = hideTimer, hideTimer.isValid {
            hideTimer.invalidate()
        }
        hideSnackBar()
    }
    
    func addOnDismissedListener(listener: @escaping () -> Void) -> SnackBar{
        onDismissListener = listener
        return self
    }
    
    func withAction(title: String, listener: @escaping () -> Void) -> SnackBar{
        snackBarAction = SnackBarAction(title: title, action: listener)
        return self
    }
    
    private init(){
        snackBarContainer = UIView(frame: CGRect())
        snackBarContainer.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        snackBarContainer.alpha = 0.0
        snackBarContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView: UIView = UIView(frame: CGRect())
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel = UILabel(frame: CGRect())
        messageLabel.textColor = UIColor.white
        messageLabel.font.withSize(17.0)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        actionButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 48))
        actionButton.setTitleColor(UIColor.red.withAlphaComponent(0.7), for: .normal)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        paddingView.addSubview(messageLabel)
        paddingView.addSubview(actionButton)
        snackBarContainer.addSubview(paddingView)
        
        let leftSwipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(onSnackbarDismissed(sender:)))
        leftSwipeGesture.direction = .left
        
        let rightSwipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(onSnackbarDismissed(sender:)))
        rightSwipeGesture.direction = .right
        
        snackBarContainer.addGestureRecognizer(leftSwipeGesture)
        snackBarContainer.addGestureRecognizer(rightSwipeGesture)
        
        let messageLabelLeCo: NSLayoutConstraint = NSLayoutConstraint(item: messageLabel, attribute: .leading, relatedBy: .equal, toItem: paddingView, attribute: .leading, multiplier: 1, constant: 8)
        let messageLabelTrCo: NSLayoutConstraint = NSLayoutConstraint(item: messageLabel, attribute: .trailing, relatedBy: .equal, toItem: actionButton, attribute: .leading, multiplier: 1, constant: -8)
        let messageLabelToCo: NSLayoutConstraint = NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: paddingView, attribute: .top, multiplier: 1, constant: 8)
        let messageLabelBoCo: NSLayoutConstraint = NSLayoutConstraint(item: messageLabel, attribute: .bottom, relatedBy: .equal, toItem: paddingView, attribute: .bottom, multiplier: 1, constant: -8)
        
        let actionButtonTrCo: NSLayoutConstraint = NSLayoutConstraint(item: actionButton, attribute: .trailing, relatedBy: .equal, toItem: paddingView, attribute: .trailing, multiplier: 1, constant: -8)
        let actionButtonYAxisCo = NSLayoutConstraint(item: actionButton, attribute: .centerY, relatedBy: .equal, toItem: paddingView, attribute: .centerY, multiplier: 1, constant: 0)
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: actionButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 32)
        
        actionButton.addConstraints([height])
        paddingView.addConstraints([messageLabelLeCo, messageLabelTrCo, messageLabelToCo, messageLabelBoCo, actionButtonTrCo, actionButtonYAxisCo])
        
        let paddingViewLeCo: NSLayoutConstraint = NSLayoutConstraint(item: paddingView, attribute: .leading, relatedBy: .equal, toItem: snackBarContainer, attribute: .leading, multiplier: 1, constant: 8)
        let paddingViewTrCo: NSLayoutConstraint = NSLayoutConstraint(item: paddingView, attribute: .trailing, relatedBy: .equal, toItem: snackBarContainer, attribute: .trailing, multiplier: 1, constant: -8)
        let paddingViewToCo: NSLayoutConstraint = NSLayoutConstraint(item: paddingView, attribute: .top, relatedBy: .equal, toItem: snackBarContainer, attribute: .top, multiplier: 1, constant: 8)
        let paddingViewBoCo: NSLayoutConstraint = NSLayoutConstraint(item: paddingView, attribute: .bottom, relatedBy: .equal, toItem: snackBarContainer, attribute: .bottom, multiplier: 1, constant: -8)
        
        snackBarContainer.addConstraints([paddingViewLeCo, paddingViewTrCo, paddingViewToCo, paddingViewBoCo])
    }
    
    static func make() -> SnackBar{
        if(instance == nil){
            instance = SnackBar()
        }
        return instance!
    }
    
    private func updateSnackBarDetails(message: String, rootView: UIView){
        rootView.addSubview(snackBarContainer)
        
        let snackbarContainerLeCo: NSLayoutConstraint = NSLayoutConstraint(item: snackBarContainer, attribute: .leading, relatedBy: .equal, toItem: rootView, attribute: .leading, multiplier: 1, constant: 0)
        let snackbarContainerTrCo: NSLayoutConstraint = NSLayoutConstraint(item: snackBarContainer, attribute: .trailing, relatedBy: .equal, toItem: rootView, attribute: .trailing, multiplier: 1, constant: 0)
        let snackbarContainerBoCo: NSLayoutConstraint = NSLayoutConstraint(item: snackBarContainer, attribute: .bottom, relatedBy: .equal, toItem: rootView, attribute: .bottom, multiplier: 1, constant: 0)
        rootView.addConstraints([snackbarContainerLeCo, snackbarContainerTrCo, snackbarContainerBoCo])
        
        if let action = snackBarAction{
            snackBarAction = action
            actionButton.isHidden = false
            actionButton.setTitle(action.title, for: .normal)
            let width = NSLayoutConstraint(item: actionButton, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: !action.title.isEmpty ? CGFloat(action.title.count) * 16 : 48)
            actionButton.addConstraint(width)
            actionButton.addTarget(self, action: #selector(actionBtnClicked), for: .touchUpInside)
        }else{
            actionButton.isHidden = true
            actionButton.setTitle(nil, for: .normal)
            actionButton.removeTarget(self, action: #selector(actionBtnClicked), for: .touchUpInside)
        }
        
        messageLabel.text = message
    }
    
    func show(message: String, in controller: UIViewController, forDuration: SnackBarDuration){
        let rootView: UIView = controller.view
        if let hideTimer = hideTimer, hideTimer.isValid{
            hideTimer.invalidate()
            hideSnackBar()
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { timer in
                self.updateSnackBarDetails(message: message, rootView: rootView)
                self.displaySnackBar(duration: forDuration)
            }
        }else{
            updateSnackBarDetails(message: message, rootView: rootView)
            displaySnackBar(duration: forDuration)
        }
    }
    
    private func displaySnackBar(duration: SnackBarDuration){
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: {
            self.snackBarContainer.alpha = 1.0
            if(SnackBarDuration.LENGTH_INFINITY != duration){
                self.hideTimer = Timer.scheduledTimer(withTimeInterval: duration.getDuration(), repeats: false, block: { timer in
                    self.hideSnackBar()
                })
            }
        }, completion: nil)
    }
    
    private func hideSnackBar(){
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.snackBarContainer.alpha = 0.0
        }, completion: { _ in
            if(!self.isActionClicked){
                if let onDismissListener = self.onDismissListener {
                    onDismissListener()
                }
            }else{
                self.isActionClicked = false
            }
        })
    }
}

class SnackBarAction{
    let title: String
    let action: () -> Void
    
    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

enum SnackBarDuration{
    case LENGTH_LONG, LENGTH_MEDIUM, LENGTH_SHORT, LENGTH_INFINITY
    
    func getDuration() -> Double{
        var duration: Double
        switch self {
        case .LENGTH_LONG:
            duration = 3.5
            break
        case .LENGTH_MEDIUM:
            duration = 2.5
            break
        case .LENGTH_SHORT:
            duration = 1.5
            break
        case .LENGTH_INFINITY:
            duration = Double.infinity
            break
        }        
        return duration
    }
}
