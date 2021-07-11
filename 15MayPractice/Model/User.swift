import Foundation

class User {
    static let ID: String = "_id"
    static let NAME: String = "name"
    static let GENDER: String = "gender"
    static let DOB: String = "dob"
    static let ADDRESS: String = "address"
    static let EMAIL: String = "email"
    static let IMAGE: String = "image"
    static let ROLE: String = "role"
    
    var id: String?
    var name: String?
    var gender: Gender?
    var dob: Date?
    var address: String?
    var email: String?
    var image : String?
    var role: Role?
    
    init(id: String) {
        self.id = id
    }
    
    init(userDictionary: Dictionary<String, Any>) throws {
        if let val = userDictionary[User.ID] as? String {
            id = val
        }else {
            throw Exception(message: "User must contain key, id")
        }
        
        if let val = userDictionary[User.NAME] as? String{
            name = val
        }
        
        if let val = userDictionary[User.GENDER] as? String {
            gender = try Gender.getGender(gender: val)
        }
        
        if let val = userDictionary[User.DOB] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dob =  dateFormatter.date(from: val)
        }
        
        if let val = userDictionary[User.ADDRESS] as? String {
            address = val
        }
        
        if let val = userDictionary[User.EMAIL] as? String {
            email = val
        }else {
            throw Exception(message: "User must contain key, email")
        }
        
        if let val = userDictionary[User.IMAGE] as? String{
            image = val
        }
        
        if let val = userDictionary[User.ROLE] as? String {
            role = try Role.getRole(role: val)
        }else {
            throw Exception(message: "User must contain key, role")
        }
    }
    
    static func getUserArray(fromArrayOfDictionaty arrayDictionary: Array<Any>) throws -> Array<User>{
        var userArray: Array<User> = Array<User>()
        if(arrayDictionary.count > 0){
            try arrayDictionary.forEach { item in
                if let item = item as? Dictionary<String, Any> {
                    userArray.append(try User(userDictionary: item))
                } else if let item = item as? String {
                    userArray.append(User(id: item))
                }
            }
        }
        return userArray
    }
    
    enum Gender {
        case MALE, FEMALE, OTHER
        
        static func getGender(gender: String) throws -> Gender{
            var userGender: Gender
            switch gender {
                case "male":
                    userGender = Gender.MALE
                    break
                case "female":
                    userGender = Gender.MALE
                    break
                case "other":
                    userGender = Gender.OTHER
                    break
                default:
                    throw Exception(message: "Invalid gender type provided")
            }
            return userGender
        }
    }
    
    enum Role {
        case USER, ADMIN
        
        static func getRole(role: String) throws -> Role{
            var userRole: Role
            
            switch role {
                case "user":
                    userRole = Role.USER
                    break
                case "admin":
                    userRole = Role.ADMIN
                    break
                default:
                    throw Exception(message: "Invalid role type provided")
            }
            return userRole
        }
    }
}
