import SwiftUI
import UIKit

struct FeedView: View {
    @State private var showNewTweetView = false
    @StateObject var viewModel = FeedViewModel()
    @StateObject var viewModeler = CommentViewModel()
    @State private var buttonOne: Bool = true
    @State private var buttonTwo: Bool = false
    @State private var buttonThree: Bool = false
    static let lowGrey = Color("lowgrey")
    static let highGrey = Color("highgrey")
    @State private var showNewCommentView = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack(spacing: 0){
            Text("Hustles")
                .offset(x: -130,y: -12)
                .font(.title).bold()
            
            HStack(alignment: .center, spacing: 0) {
                Button {
                    viewModel.fetchNew()
                    buttonOne = true
                    buttonTwo = false
                    buttonThree = false
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                } label: {
                    Text("New")
                        .foregroundColor(.black)
                        .frame(width: 80, height: 25)
                }.background(buttonOne ? FeedView.highGrey : FeedView.lowGrey).border(Color.black, width: buttonOne ? 3 : 1)
                Button {
                    viewModel.fetchLeaderBoard()
                    buttonOne = false
                    buttonTwo = true
                    buttonThree = false
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                } label: {
                    Text("LeaderBoard")
                        .foregroundColor(.black)
                        .frame(width: 120, height: 25)
                }.background(buttonTwo ? FeedView.highGrey : FeedView.lowGrey).border(Color.black, width: buttonTwo ? 3 : 1)
                Button {
                    viewModel.fetchHot()
                    buttonOne = false
                    buttonTwo = false
                    buttonThree = true
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                } label: {
                    Text("Hot")
                        .foregroundColor(.black)
                        .frame(width: 80, height: 25)
                }.background(buttonThree ? FeedView.highGrey : FeedView.lowGrey).border(Color.black, width: buttonThree ? 3 : 1)
            }
            .mask {
                RoundedRectangle(cornerRadius: 5)
            }
            
            ZStack(alignment: .bottomTrailing){
                ScrollView {
                    LazyVStack{
                        ForEach(viewModel.tweets){ tweet in
                            Button{
                                showNewCommentView.toggle()
                                viewModeler.getComments(withTweet: tweet)
                            } label: {
                                TweetRowView(tweet: tweet)
                                    .padding()
                            }
                            .fullScreenCover(isPresented: $showNewCommentView){
                                CommentView(tweet: tweet)
                            }
                        }
                    }
                }

                Button {
                    showNewTweetView.toggle()
                } label: {
                    Image(systemName: "h.circle")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 28, height: 28)
                        .padding()
                }
                .background(Color(.systemBlue))
                .foregroundColor(.white)
                .clipShape(Circle())
                .padding()
                .fullScreenCover(isPresented: $showNewTweetView){
                    NewTweetView()
                }
            }
            .padding(.top, 10)
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
