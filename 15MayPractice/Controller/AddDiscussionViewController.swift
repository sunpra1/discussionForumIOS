import UIKit

class AddDiscussionViewController: UIViewController {
    private let GET_CATEGORIES_IDENTIFER: String = "GET_CATEGORIES_IDENTIFER"
    private let POST_NEW_DISCUSSION_IDENTIFER: String = "POST_NEW_DISCUSSION_IDENTIFER"
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleErrorMessage: UILabel!
    @IBOutlet weak var topicTextField: UITextField!
    @IBOutlet weak var topicErrorMessage: UILabel!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var categoryErrorMessage: UILabel!
    @IBOutlet weak var selectImageBtn: UIButton!
    @IBOutlet weak var selectedImageHolder: UIImageView!
    @IBOutlet weak var selectedImageError: UILabel!
    @IBOutlet weak var addDiscussionBtn: UIButton!
    @IBOutlet weak var categoryPickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryTextField: UITextField!
    private var categories: Array<Category>?
    private var selectedCategory: Int = -1
    private var isCategoryPickerHidden:Bool = true
    private var selectedImage: UIImage?
    
    var delegate: OnNewDiscussionAddedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "ADD DISCUSSION"
        cardView.displayAsCard()
        titleTextField.addRoundedBorderAndShadow()
        topicTextField.addRoundedBorderAndShadow()
        categoryTextField.addRoundedBorderAndShadow()
        selectImageBtn.addRoundedBorderAndShadow()
        addDiscussionBtn.addRoundedBorderAndShadow()
        
        titleErrorMessage.isHidden = true
        topicErrorMessage.isHidden = true
        categoryErrorMessage.isHidden = true
        selectedImageError.isHidden = true
        
        categoryPicker.addBorder(width: 0.25, color: UIColor.gray.cgColor)
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        categoryPickerHeightConstraint.constant = 0
        getCategories()
    }
    
    @IBAction func onAddDiscussionBtnClicked(_ sender: UIButton) {
        if(validate()){
            let bodyPart: Dictionary<String, Any> = ["title": titleTextField.text!, "topic": topicTextField.text!, "category": categories![selectedCategory].id!]
            
            var filePart: Dictionary<String, Data> = Dictionary<String, Data>()
            if let image = selectedImage {
                filePart["image"] = image.jpegData(compressionQuality: 1)
            }
            
            do{
                var apiRequest = try APIRequest(identifer: GET_CATEGORIES_IDENTIFER, url: APIRoute.addDiscussionRoute(), requestType: RequestType.POST, fileParts: filePart, bodyPart: bodyPart, authorizationToken: UserDefaults.standard.string(forKey: APP.K.TOKEN))
                apiRequest.delegate = self
                apiRequest.execute()
                
            }catch{
                print("Unable to perform API Request: \(error.localizedDescription)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func onSelectImageButtonClicked(_ sender: UIButton) {
        let imageController: UIImagePickerController = UIImagePickerController()
        imageController.delegate = self
        imageController.allowsEditing = false
        
        let alert: UIAlertController = UIAlertController(title: "SELECT IMAGE SOURCE", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction: UIAlertAction = UIAlertAction(title: "Camera", style: .default) { action in
            if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                imageController.sourceType = .camera
                self.present(imageController, animated: true, completion: nil)
            }
        }
        
        let galleryAction: UIAlertAction = UIAlertAction(title: "Gallery", style: .default) { action in
            if(UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)){
                imageController.sourceType = .savedPhotosAlbum
                self.present(imageController, animated: true, completion: nil)
            }
        }
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editingDidEnd(_ sender: UITextField) {
        switch sender.tag {
        case 1:
            if let title = sender.text, title.isEmpty{
                titleTextField.layer.shadowColor = UIColor.red.cgColor
                titleErrorMessage.isHidden = false
                titleErrorMessage.text = "Title is required."
            }
            break
        case 2:
            if let topic = sender.text, topic.isEmpty{
                topicTextField.layer.shadowColor = UIColor.red.cgColor
                topicErrorMessage.isHidden = false
                topicErrorMessage.text = "Topic is required."
            }
            break
        default:
            break;
        }
    }
    
    @IBAction func editingDidBegin(_ sender: UITextField) {
        switch sender.tag {
        case 1:
            titleTextField.layer.shadowColor = UIColor.gray.cgColor
            titleErrorMessage.isHidden = true
            titleErrorMessage.text = ""
            break
        case 2:
            topicTextField.layer.shadowColor = UIColor.gray.cgColor
            topicErrorMessage.isHidden = true
            topicErrorMessage.text = ""
            break
        case 3:
            categoryTextField.layer.shadowColor = UIColor.gray.cgColor
            categoryErrorMessage.isHidden = true
            categoryErrorMessage.text = ""
            if(isCategoryPickerHidden){
                isCategoryPickerHidden = !isCategoryPickerHidden
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               options: .curveEaseIn,
                               animations: { () -> Void in
                                self.categoryPickerHeightConstraint.constant += 120
                                self.view.layoutIfNeeded()
                               }, completion: nil)
            }else{
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               options: .curveEaseOut,
                               animations: { () -> Void in
                                self.categoryPickerHeightConstraint.constant = 0
                                self.view.layoutIfNeeded()
                               }, completion: { (finished) -> Void in
                                self.isCategoryPickerHidden = !self.isCategoryPickerHidden
                               })
            }
            sender.endEditing(true)
            break
        default: break
        }
    }
    
    private func validate() -> Bool{
        var isValid = true
        
        if let title = titleTextField.text, title.isEmpty{
            titleTextField.layer.shadowColor = UIColor.red.cgColor
            titleErrorMessage.isHidden = false
            titleErrorMessage.text = "Title is required."
            isValid = false
        }
        
        if let topic = topicTextField.text, topic.isEmpty{
            topicTextField.layer.shadowColor = UIColor.red.cgColor
            topicErrorMessage.isHidden = false
            topicErrorMessage.text = "Topic is required."
            isValid = false
        }
        
        if(selectedCategory < 0){
            categoryTextField.layer.shadowColor = UIColor.red.cgColor
            categoryErrorMessage.isHidden = false
            categoryErrorMessage.text = "Category is required."
            isValid = false
        }
        
        if let image = selectedImage, (image.jpegData(compressionQuality: 1)!.count) / (1000 * 1000) > 10 {
            selectedImageHolder.layer.shadowColor = UIColor.red.cgColor
            selectedImageError.isHidden = false
            selectedImageError.text = "File size cannot exceed 10 MB"
            isValid = false
        }
        
        return isValid
    }
    
    private func getCategories(){
        do{
            var apiRequest: APIRequest = try APIRequest(identifer: GET_CATEGORIES_IDENTIFER, url: APIRoute.getCategoriesRoute(), requestType: RequestType.GET)
            apiRequest.delegate = self
            apiRequest.execute()
        }catch{
            print("Unable to perform API Request: \(error.localizedDescription)")
        }
    }
    
}

extension AddDiscussionViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCategory = row
        
        categoryTextField.layer.shadowColor = UIColor.gray.cgColor
        categoryErrorMessage.isHidden = true
        categoryErrorMessage.text = ""
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { () -> Void in
                        self.categoryPickerHeightConstraint.constant = 0
                        self.view.layoutIfNeeded()
                       }, completion: { (finished) -> Void in
                        self.isCategoryPickerHidden = !self.isCategoryPickerHidden
                        self.categoryTextField.text = self.categories?[row].category
                       })
    }
}

extension AddDiscussionViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories![row].category!
    }
}

extension AddDiscussionViewController: OnRequestResultDelegate{
    func onSuccessResponse(identifer: String, data: Data, statusCode: Int) {
        switch identifer {
        case GET_CATEGORIES_IDENTIFER:
            do{
                if let data = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Array<Any>{
                    categories = try Category.getCategoryArray(fromArrayOfDictionaty: data)
                    DispatchQueue.main.async {
                        self.categoryPicker.reloadAllComponents()
                    }
                }
            }catch{
                print("Error occured: \((error as? Exception)?.message ?? error.localizedDescription)")
            }
            break
            
        case POST_NEW_DISCUSSION_IDENTIFER:
            DispatchQueue.main.async {
                self.titleTextField.text = ""
                self.topicTextField.text = ""
                self.categoryTextField.text = ""
                self.selectedImageHolder.image = UIImage(named: "image")
                do{
                    if let data = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String, Any>{
                        let discussion = try Discussion(discussionDictionary: data)
                        self.delegate?.onNewDiscussionAdded(discussion: discussion)
                        self.navigationController?.popViewController(animated: true)
                    }
                }catch{
                    print("Error occured: \((error as? Exception)?.message ?? error.localizedDescription)")
                }
            }
            break
            
        default:
            break
            
        }
    }
    
    func onFailedResponse(identifer: String, errorMessage: Data, statusCode: Int) {
        switch identifer {
        case GET_CATEGORIES_IDENTIFER:
            DispatchQueue.main.async {
                self.displayAlertMessage(message: Formatter.getSimplifiedErrorResponse(data: errorMessage) ?? "Unable to get categories.")
            }
            break
        case POST_NEW_DISCUSSION_IDENTIFER:
            DispatchQueue.main.async {
                self.displayAlertMessage(message: Formatter.getSimplifiedErrorResponse(data: errorMessage) ?? "Unable to add new discussion.")
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

extension AddDiscussionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let img:UIImage? = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        dismiss(animated: true, completion: nil)
        if let img = img {
            if(Float(img.jpegData(compressionQuality: 1)!.count) / (1000 * 1000) > 10.0){
                selectedImageHolder.layer.shadowColor = UIColor.red.cgColor
                selectedImageError.isHidden = false
                selectedImageError.text = "File size cannot exceed 10 MB"
            }else{
                selectedImage = img
                selectedImageHolder.image = img
                selectedImageHolder.layer.shadowColor = UIColor.white.cgColor
                selectedImageError.isHidden = true
                selectedImageError.text = ""
            }
        }else {
            displayAlertMessage(message: "No image selected")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

protocol OnNewDiscussionAddedDelegate {
    func onNewDiscussionAdded(discussion: Discussion)
}
