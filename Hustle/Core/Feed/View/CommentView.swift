import SwiftUI
import UIKit

struct CommentView: View {
    @StateObject var viewModel = CommentViewModel()
    @Environment(\.presentationMode) var presentationMode
    var tweet: Tweet
    
    init(tweet: Tweet){
        self.tweet = tweet
    }
    
    var body: some View {
        VStack(spacing: 0){
            ZStack(alignment: .bottomTrailing){
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack{
                            ForEach(viewModel.comments){ comment in
                                CommentRowView(comment: comment)
                                    .padding()
                            }
                        }
                        .onAppear {
                            proxy.scrollTo(viewModel.comments.reversed().last?.id, anchor: .bottom)
                        }
                    }
                }

                 
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "x.circle")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .padding()
                }
                .background(Color(.systemGray))
                .foregroundColor(.white)
                .clipShape(Circle())
            }
            .padding(.top, 10)
            
            Divider()
            
            TweetRowView(tweet: tweet)
        }


    }
}
/*
struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView()
    }
}
*/
