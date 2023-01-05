
import Firebase

struct TweetService{
    
    func uploadTweet(caption: String, completion: @escaping(Bool) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["uid": uid,
                    "caption": caption,
                    "likes": 0,
                    "comments": 0,
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        Firestore.firestore().collection("tweets").document()
            .setData(data) { error in
                if let error = error {
                    print("failed to upload tweet with error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    
    func getComments(tweet: Tweet, completion: @escaping([Comment]) -> Void){
        guard let tweetId = tweet.id else { return }
        var comments = [Comment]()
        
        Firestore.firestore().collection("tweets")
            .whereField("id", isEqualTo: tweetId)
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                
                documents.forEach{ doc in
                    let id = doc.documentID
                    print("id\(id)")
                    Firestore.firestore().collection("tweets").document(id)
                        .collection("comments")
                        .getDocuments { snapshot, _ in
                            guard let documents = snapshot?.documents else { return }
                            comments = documents.compactMap{ document -> Comment? in
                                do{
                                    return try document.data(as: Comment.self)
                                } catch{
                                    return nil
                                }
                            }
                            print("cmm\(comments)")
                            completion(comments.sorted(by: { $0.timestamp < $1.timestamp }) )
                        }
                }
        }
    }
    
    func uploadComment(tweet: Tweet, text: String, completion: @escaping() -> Void){
        guard let tweetId = tweet.id else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["id": "\(UUID())",
                    "uid": uid,
                    "text": text,
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        Firestore.firestore().collection("tweets").document(tweetId)
            .updateData(["comments": tweet.comments + 1]) { _ in }
        
        Firestore.firestore().collection("tweets").document(tweetId).collection("comments").document()
            .setData(data) { error in
                if let error = error {
                    print("failed to upload tweet with error: \(error.localizedDescription)")
                    completion()
                    return
                }
                completion()
            }
    }
    func fetchUserTweet(forUid uid: String, completion: @escaping([Tweet]) -> Void){
        Firestore.firestore().collection("tweets")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let tweets = documents.compactMap({ try? $0.data(as: Tweet.self)} )
                completion(tweets.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }) )
            }
        
    }
    func fetchHot(completion: @escaping([Tweet]) -> Void){
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let query = Firestore.firestore().collection("tweets").whereField("timestamp", isGreaterThanOrEqualTo: threeDaysAgo)
        query.getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let tweets = documents.compactMap({ try? $0.data(as: Tweet.self)} )
                let top30Percent = Array(tweets.sorted { $0.likes > $1.likes }.prefix(Int(Double(tweets.count) * 0.3)))
                completion(top30Percent)
            }
    }
    func fetchLeaderBoard(completion: @escaping([Tweet]) -> Void){
        let query = Firestore.firestore().collection("tweets").order(by: "likes", descending: true).limit(to: 100)

        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let tweets = documents.compactMap({ try? $0.data(as: Tweet.self)} )
            completion(tweets)
        }
    }
    func fetchNew(completion: @escaping([Tweet]) -> Void){
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let query = Firestore.firestore().collection("tweets").whereField("timestamp", isGreaterThanOrEqualTo: threeDaysAgo)
        query.getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let tweets = documents.compactMap({ try? $0.data(as: Tweet.self)} )
                completion(tweets)
            }
    }
}

extension TweetService {
    func likeTweet(_ tweet: Tweet, completion: @escaping() -> Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let tweetId = tweet.id else { return }
        
        let userLikesRef = Firestore.firestore().collection("users").document(uid).collection("user-likes")
        
        Firestore.firestore().collection("tweets").document(tweetId)
            .updateData(["likes": tweet.likes + 1]) { _ in
                userLikesRef.document(tweetId).setData([:]) { _ in
                    completion()
                }
            }
    }
    
    func unlikeTweet(_ tweet: Tweet, completion: @escaping() -> Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let tweetId = tweet.id else { return }
        guard tweet.likes > 0 else { return }
        
        let userLikesRef = Firestore.firestore().collection("users").document(uid).collection("user-likes")
        
        Firestore.firestore().collection("tweets").document(tweetId)
            .updateData(["likes": tweet.likes - 1]) { _ in
                userLikesRef.document(tweetId).delete { _ in
                    completion()
                }
            }
        
    }
    
    func checkIfUserLikedTweet(_ tweet: Tweet, completion: @escaping(Bool) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let tweetId = tweet.id else { return }
        
        Firestore.firestore().collection("users")
            .document(uid)
            .collection("user-likes")
            .document(tweetId).getDocument{ snapshot, _ in
                guard let snapshot = snapshot else { return }
                completion(snapshot.exists) // exists checks if document exists in firbase
            }
        
    }
    
    func fetchLikedTweets(forUid uid: String, completion: @escaping([Tweet]) -> Void){
        var tweets = [Tweet]()
        Firestore.firestore().collection("users")
            .document(uid)
            .collection("user-likes")
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }

                documents.forEach { doc in
                    let tweetID = doc.documentID

                    Firestore.firestore().collection("tweets")
                        .document(tweetID)
                        .getDocument { snapshot, _ in
                            guard let tweet = try? snapshot?.data(as: Tweet.self) else { return }
                            tweets.append(tweet)
                            completion(tweets)
                    }
                }
                
        }
    }
}
