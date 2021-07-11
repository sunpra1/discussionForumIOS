import UIKit

extension UIViewController{
    func displayAlertMessage(message: String){
        let alert: UIAlertController = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
        let action: UIAlertAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                    let myPickerController = UIImagePickerController()
                    myPickerController.sourceType = .photoLibrary
                }
    }
}
