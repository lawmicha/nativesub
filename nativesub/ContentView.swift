//
//  ContentView.swift
//  nativesub
//
//  Created by Law, Michael on 9/28/20.
//
import Amplify
import AmplifyPlugins
import SwiftUI
import Combine

extension GraphQLRequest {
    static func onCreateComment(byPostId id: String) -> GraphQLRequest<Comment> {
        let operationName = "onCommentByPostId"
        let document = """
        subscription onCreateCommentByPostId($id:ID!) {
          \(operationName)(postCommentsId: $id) {
            content
            createdAt
            id
            postCommentsId
            updatedAt
          }
        }
        """
        return GraphQLRequest<Comment>(document: document,
                                    variables: ["id": id],
                                    responseType: Comment.self,
                                    decodePath: operationName)
    }
}


class ContentViewModel2: ObservableObject {
    var subscription: GraphQLSubscriptionOperation<Comment>?
    var dataSink: AnyCancellable?
func createSubscription() {
    subscription = Amplify.API.subscribe(request: .onCreateComment(byPostId: "12345"))
    dataSink = subscription?.subscriptionDataPublisher.sink {
        if case let .failure(apiError) = $0 {
            print("Subscription has terminated with \(apiError)")
        } else {
            print("Subscription has been closed successfully")
        }
    }
    receiveValue: { result in
        switch result {
        case .success(let createdComment):
            print("Successfully got comment from subscription: \(createdComment)")
        case .failure(let error):
            print("Got failed result with \(error.errorDescription)")
        }
    }
}
}
class ContentViewModel: ObservableObject {
    var subscription: GraphQLSubscriptionOperation<Comment>?
func createSubscription() {
    subscription = Amplify.API.subscribe(request: .onCreateComment(byPostId: "12345"), valueListener: { (subscriptionEvent) in
        switch subscriptionEvent {
        case .connection(let subscriptionConnectionState):
            print("Subscription connect state is \(subscriptionConnectionState)")
        case .data(let result):
            switch result {
            case .success(let createdComment):
                print("Successfully got comment from subscription: \(createdComment)")
            case .failure(let error):
                print("Got failed result with \(error.errorDescription)")
            }
        }
    }, completionListener: { (result) in
        switch result {
        case .success:
            print("Subscription has been closed successfully")
        case .failure(let apiError):
            print("Subscription has terminated with \(apiError)")
        }
    })
}
}
struct ContentView: View {

    @ObservedObject var vm = ContentViewModel()
    @ObservedObject var vm2 = ContentViewModel2()

    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            Button(action: {
                vm.createSubscription()
            }, label: {
                Text("subscribe iOS 11")
            })
            Button(action: {
                vm2.createSubscription()
            }, label: {
                Text("subscribe iOS 13")
            })
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
