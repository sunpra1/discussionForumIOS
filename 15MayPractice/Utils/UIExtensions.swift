import UIKit

extension UITextField {
    @objc open override func addRoundedBorderAndShadow(){
        borderStyle = .none
        backgroundColor = UIColor.white

        addRoundedBorder(radius: frame.size.height / 2, width: 0.25, color: UIColor.gray.cgColor)
        addShadow(radius: 3, opacity: 1, offset: CGSize.zero, color: UIColor.gray.cgColor)

        //To apply padding
        let paddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: frame.height))
        leftView = paddingView
        rightView = paddingView
        leftViewMode = UITextField.ViewMode.always
        rightViewMode = UITextField.ViewMode.always
    }
}

extension UIView{
    @objc open func addRoundedBorderAndShadow(){
        addRoundedBorder(radius: frame.size.height / 2, width: 0.25, color: layer.backgroundColor ?? UIColor.gray.cgColor)
        addShadow(radius: 3, opacity: 1, offset: CGSize.zero, color: UIColor.gray.cgColor)
    }
    
    func displayAsCard(){
        layer.cornerRadius = 4.0        
        addBorder(width: 0.25, color: UIColor.gray.cgColor)
        addShadow(radius: 3, opacity: 1, offset: CGSize.zero, color: UIColor.gray.cgColor)
    }
    
    func addShadow(radius: CGFloat, opacity: Float, offset: CGSize, color: CGColor){
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.shadowColor = color
    }
    
    func addRoundedBorder(radius: CGFloat, width: CGFloat, color: CGColor){
        layer.cornerRadius = radius
        addBorder(width: width, color: color)
    }    
    
    func addBorder(width: CGFloat, color: CGColor){
        layer.borderWidth = width
        layer.borderColor = color
    }
}
