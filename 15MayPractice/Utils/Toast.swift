import UIKit

class Toast {
    private var toastContainer: UIView
    private var toastLabel: UILabel
    private static var instance: Toast?
    private var hideTimer: Timer?
    
    private init(){
        toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 4
        toastContainer.clipsToBounds  =  true

        toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font.withSize(14.0)
        toastLabel.numberOfLines = 0
        toastLabel.clipsToBounds  =  true

        toastContainer.addSubview(toastLabel)

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false

        let labelLeCo: NSLayoutConstraint = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 16)
        let labelTrCo: NSLayoutConstraint = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -16)
        let labelBoCo: NSLayoutConstraint = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -16)
        let labelToCo: NSLayoutConstraint = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 16)
        toastContainer.addConstraints([labelLeCo, labelTrCo, labelBoCo, labelToCo])

        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                self.toastContainer.alpha = 0.0
            }, completion: {_ in
                self.toastContainer.removeFromSuperview()
            })
        })
    }
    
    static func make() -> Toast {
        if(instance == nil){
            instance = Toast()
        }        
        return instance!
    }
    
    
    private func updateToastDetails(message: String, rootView: UIView){
        rootView.addSubview(toastContainer)
        
        toastLabel.text = message
        
        let toastContainerLeCo: NSLayoutConstraint = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: rootView, attribute: .leading, multiplier: 1, constant: 16)
        let toastContainerTrCo: NSLayoutConstraint = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: rootView, attribute: .trailing, multiplier: 1, constant: -16)
        let toastContainerBoCo: NSLayoutConstraint = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: rootView, attribute: .bottom, multiplier: 1, constant: -16)
        rootView.addConstraints([toastContainerLeCo, toastContainerTrCo, toastContainerBoCo])
    }
    
    func show(message: String, in controller: UIViewController, forDuration: ToastDuration) {
        let rootView: UIView = controller.view
        if let hideTimer = hideTimer, hideTimer.isValid{
            hideTimer.invalidate()
            hideToast()
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { timer in
                self.updateToastDetails(message: message, rootView: rootView)
                self.displayToast(duration: forDuration)
            }
        }else{
            self.updateToastDetails(message: message, rootView: rootView)
            self.displayToast(duration: forDuration)
        }
    }
    
    private func displayToast(duration: ToastDuration){
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: {
            self.toastContainer.alpha = 1.0
            if(ToastDuration.LENGTH_INFINITY != duration){
                self.hideTimer = Timer.scheduledTimer(withTimeInterval: duration.getDuration(), repeats: false, block: { timer in
                    self.hideToast()
                })
            }
        }, completion: nil)
    }
    
    private func hideToast(){
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.toastContainer.alpha = 0.0
        }, completion: nil)
    }
}

enum ToastDuration{
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
