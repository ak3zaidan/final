import SwiftUI
import Kingfisher

struct CommentRowView: View {
    @ObservedObject var viewModel: CommentRowViewModel
    @State var dateFinal: String = ""
    
    init(comment: Comment){
        self.viewModel = CommentRowViewModel(comment: comment)
    }
    
    var body: some View {
        VStack(alignment: .leading){
            
            if let user = viewModel.comment.user{
                
                HStack(alignment: .top, spacing: 12){
                    KFImage(URL(string: user.profileImageUrl))
                        .resizable()
                        .frame(width:35, height: 35)
                        .clipShape(Circle())
                        .scaledToFill()
                    VStack(alignment: .leading, spacing: 3){
                        HStack{
                            Text(user.fullname)
                                .font(.subheadline).bold()
                            Text("@\(user.username)")
                                .foregroundColor(.gray)
                                .font(.caption)
                            Text(dateFinal)
                                .foregroundColor(.gray)
                                .font(.caption)
                                .onReceive(viewModel.$comment) { tweet in
                                    let dateString = viewModel.comment.timestamp.formatted(.dateTime.month().day().year().hour().minute())
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                    dateFormatter.dateFormat = "MMMM dd, yyyy 'at' h:mm a"
                                    if let date = dateFormatter.date(from:dateString){
                                        if Calendar.current.isDateInToday(date){
                                            dateFinal = viewModel.comment.timestamp.formatted(.dateTime.hour().minute())}
                                        else if Calendar.current.isDateInYesterday(date) {dateFinal = "Yesterday"}
                                        else{
                                            if let dayBetween  = Calendar.current.dateComponents([.day], from: viewModel.comment.timestamp, to: Date()).day{
                                                dateFinal = String(dayBetween + 1) + "d"
                                            }
                                        }
                                    }
                                }
                        }
                        Text(viewModel.comment.text)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
    }
}

