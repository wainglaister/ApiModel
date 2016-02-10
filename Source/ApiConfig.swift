import Alamofire
import RealmSwift

public class ApiConfig {
    public var host: String = ""
    public var manager: Manager = Manager.sharedInstance
    public var parser: ApiParser = JSONParser()
    public var encoding: ParameterEncoding = .URL
    public var requestLogging: Bool = true
    public var rootNamespace = ""
    public var addHook: (Realm?, Object) -> Void = { $0?.add($1) }
    public var modifyHook: (Realm?, Object) -> Void = { $0?.add($1) }
    public var deleteHook: (Realm?, Object) -> Void = { $0?.delete($1) }

    public required init() {
    }

    public convenience init(host: String) {
        self.init()
        self.host = host
    }
    
    public convenience init(apiConfig: ApiConfig) {
        self.init()
        self.host = apiConfig.host
        self.parser = apiConfig.parser
        self.encoding = apiConfig.encoding
        self.requestLogging = apiConfig.requestLogging
        self.rootNamespace = apiConfig.rootNamespace
    }
    
    public func copy() -> ApiConfig {
        return ApiConfig(apiConfig: self)
    }
}
