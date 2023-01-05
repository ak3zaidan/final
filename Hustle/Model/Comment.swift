import Foundation

struct Comment: Identifiable, Decodable{
    var id: String
    var uid: String
    var text: String
    var timestamp: Date
    
    var user: User?
}
