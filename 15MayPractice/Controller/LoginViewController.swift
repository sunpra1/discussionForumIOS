import UIKit
import Foundation

class LoginViewController: UIViewController {
    private let LOGIN_REQUEST_IDENTIFER = "LOGIN_REQUEST_IDENTIFER"
    private let GET_PROFILE_IDENTIFER = "GET_PROFILE_IDENTIFER"
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var passwordErrorLbl: UILabel!
    @IBOutlet weak var emailErrorLbl: UILabel!
    
    private let userDefault: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "LOGIN"
        if (userDefault.string(forKey: APP.K.TOKEN) != nil){
            makeGetProfileAPIRequest()
        }        
        emailTF.addRoundedBorderAndShadow()
        passwordTF.addRoundedBorderAndShadow()
        loginBtn.addRoundedBorderAndShadow()
        cardView.displayAsCard()
        emailErrorLbl.isHidden = true
        passwordErrorLbl.isHidden = true
    }
    
    @IBAction func editingDidBegin(_ sender: UITextField) {
        switch sender.tag {
        case 1:
            emailTF.layer.shadowColor = UIColor.gray.cgColor
            emailErrorLbl.isHidden = true
            emailErrorLbl.text = ""
            break
        case 2:
            passwordTF.layer.shadowColor = UIColor.gray.cgColor
            passwordErrorLbl.isHidden = true
            passwordErrorLbl.text = ""
            break
        default: break
        }
    }
    
    @IBAction func editingDidEnd(_ sender: UITextField) {
        switch sender.tag {
        case 1:
            if let email = sender.text{
                var message: String?
                if(email.isEmpty){
                    message = "Email address is required."
                }else if(!isValidEmail(email: email)){
                    message = "Invalid email address provided."
                }
                
                if let errorMessage = message {
                    emailTF.layer.shadowColor = UIColor.red.cgColor
                    emailErrorLbl.isHidden = false
                    emailErrorLbl.text = errorMessage
                }
                break
            }
        case 2:
            if let password = sender.text{
                var message: String?
                if(password.isEmpty){
                    message = "Password is required."
                }else if(password.count < 6){
                    message = "Password must be 6 Characters long."
                }
                if let errorMessage = message {
                    passwordTF.layer.shadowColor = UIColor.red.cgColor
                    passwordErrorLbl.isHidden = false
                    passwordErrorLbl.text = errorMessage
                }
                break
            }
        default: break
        }
    }
    
    @IBAction func onLoginBtnClicked(_ sender: UIButton) {
        if(validate()){
            makeLoginAPIRequest()
        }
    }
    
    private func validate() -> Bool{
        var isValid: Bool = true
        
        if let email = emailTF.text{
            var message: String?
            if(email.isEmpty){
                message = "Email address is required."
            }else if(!isValidEmail(email: email)){
                message = "Invalid email address provided."
            }
            
            if let errorMessage = message {
                emailTF.layer.shadowColor = UIColor.red.cgColor
                emailErrorLbl.isHidden = false
                emailErrorLbl.text = errorMessage
                isValid = false
            }
        }
        
        if let password = emailTF.text{
            var message: String?
            if(password.isEmpty){
                message = "Password is required."
            }else if(password.count < 6){
                message = "Password must be 6 Characters long."
            }
            if let errorMessage = message {
                passwordTF.layer.shadowColor = UIColor.red.cgColor
                passwordErrorLbl.isHidden = false
                passwordErrorLbl.text = errorMessage
                isValid = false
            }
        }        
        return isValid
    }
    
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func makeLoginAPIRequest(){
        do{
            var apiRequest: APIRequest = try APIRequest(identifer: LOGIN_REQUEST_IDENTIFER, url: APIRoute.loginRoute(), requestType: RequestType.POST, requestBody: ["email": emailTF.text!, "password": passwordTF.text!])
            apiRequest.delegate = self
            apiRequest.execute()
        }catch{
            print("Error occured: \((error as? Exception)?.message ?? error.localizedDescription)")
        }
    }
    
    func makeGetProfileAPIRequest(){
        do{
            var apiRequest: APIRequest = try APIRequest(identifer: GET_PROFILE_IDENTIFER, url: APIRoute.getUserProfileRoute(), requestType: RequestType.GET, authorizationToken: userDefault.string(forKey: APP.K.TOKEN))
            apiRequest.delegate = self
            apiRequest.execute()
        }catch{
            print("Error occured: \((error as? Exception)?.message ?? error.localizedDescription)")
        }
    }
}

extension LoginViewController: OnRequestResultDelegate{
    func onSuccessResponse(identifer: String, data: Data, statusCode: Int) {
        switch identifer {
        case LOGIN_REQUEST_IDENTIFER:
            do{
                let responseData: Dictionary<String, Any> = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Dictionary<String, Any>
                if let token = responseData[APP.K.TOKEN] as? String, let user = responseData[APP.K.USER] as? Dictionary<String, Any> {
                    userDefault.set(token, forKey: APP.K.TOKEN)
                    APP.getInstance().loggedInUser = try User(userDictionary: user)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "LoginToDiscussion", sender: self)
                    }
                }
            }catch{
                print("Error occured: \((error as? Exception)?.message ?? error.localizedDescription)")
            }
            break
        case GET_PROFILE_IDENTIFER:
            do{
                let responseData: Dictionary<String, Any> = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Dictionary<String, Any>
                APP.getInstance().loggedInUser = try User(userDictionary: responseData)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: APP.K.SEGUE_LOGIN_TO_APP_DISCUSSION, sender: self)
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
            case LOGIN_REQUEST_IDENTIFER:
                self.displayAlertMessage(message: Formatter.getSimplifiedErrorResponse(data: errorMessage) ?? "Invalid credentials provided")
                break
            case GET_PROFILE_IDENTIFER:
                if let message = Formatter.getSimplifiedErrorResponse(data: errorMessage){
                    displayAlertMessage(message: message)
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
