import Foundation
import RealmSwift

public class ForeignKeyModelTransform<T: Object where T:ApiModel>: ModelTransform<T> {
    public override init() { super.init() }
    
    public override func perform(value: AnyObject?, realm: Realm?) -> AnyObject? {
        if let pkValue = convertToApiId(value),
            pk = T.primaryKey() {
                let values = [ pk : pkValue ]
                return super.perform(values, realm: realm)
        }
        
        return nil
    }
}
