import Foundation

class CommentRowViewModel: ObservableObject {
    @Published var comment: Comment
    
    init(comment: Comment){
        self.comment = comment
    }
}
