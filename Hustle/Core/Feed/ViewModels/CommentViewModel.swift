import Foundation

class CommentViewModel: ObservableObject{
    @Published var comments = [Comment]()
    let service = TweetService()
    let userService = UserService()

    func getComments(withTweet tweet: Tweet){
        service.getComments(tweet: tweet) { comments in
            self.comments = comments
            for i in 0 ..< comments.count {
                
                let uid = comments[i].uid
                self.userService.fetchUser(withUid: uid) { user in
                    self.comments[i].user = user
                }
            }
        }
    }
}
    
