import Foundation

class Category{
    static let ID: String = "_id"
    static let CATEGORY: String = "category"
    static let DISCUSSIONS: String = "discussions"
    
    var id: String?
    var category: String?
    var discussions: Array<Discussion>?
    
    init(id: String){
        self.id = id
    }
    
    init(categoryDictionary: Dictionary<String, Any>) throws {
        if let val = categoryDictionary[Category.ID] as? String {
            id = val
        } else{
            throw Exception(message: "Category must contain key, id")
        }
        
        if let val = categoryDictionary[Category.CATEGORY] as? String {
            category = val
        } else{
            throw Exception(message: "Category must contain key, category")
        }
        
        if let val = categoryDictionary[Category.DISCUSSIONS] as? Array<Any> {
            discussions = try Discussion.getDiscussionArray(fromArrayOfDictionaty: val)
        } else {
            throw Exception(message: "Category must contain key, discussions")
        }
    }
    
    static func getCategoryArray(fromArrayOfDictionaty arrayDictionary: Array<Any>) throws -> Array<Category>{
        var categoryArray: Array<Category> = Array<Category>()
        if(arrayDictionary.count > 0){
            try arrayDictionary.forEach { item in
                if let item = item as? Dictionary<String, Any> {
                    categoryArray.append(try Category(categoryDictionary: item))
                } else if let item = item as? String {
                    categoryArray.append(Category(id: item))
                }
            }
        }
        return categoryArray
    }
}
