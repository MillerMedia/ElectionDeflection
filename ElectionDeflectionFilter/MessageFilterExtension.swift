import IdentityLookup

// Simplified Message Filter Extension without Core Data
final class MessageFilterExtension: ILMessageFilterExtension {
    // List of keywords to filter
    var keywords: [String] = ["trump", "vance", "harris", "walz", "election", "vote", "campaign", "giuliani", "kamala", "democrat", "republican", "senate", "cruz", "congress", "impeach", "ballot", "radical left", "far right"]

    override init() {
        super.init()
        print("MessageFilterExtension initialized") // Add this print statement
        print("Loaded keywords: \(self.keywords)")
    }

    private func determineAction(for messageBody: String) -> ILMessageFilterAction {
        // Debug: Print the message being evaluated
        print("Evaluating message: \(messageBody)")

        for keyword in keywords {
            if messageBody.contains(keyword) {
                print("Keyword matched: \(keyword), categorizing as Promotion")
                return .junk // Categorize the message as Promotion
            }
        }
        print("No keywords matched, allowing the message")
        return .allow // Allow the message
    }
}

extension MessageFilterExtension: ILMessageFilterQueryHandling {

    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        let response = ILMessageFilterQueryResponse()
        
        if let messageBody = queryRequest.messageBody?.lowercased() {
            print("Received message: \(messageBody)") // Debug: Print received message
            response.action = determineAction(for: messageBody)
        } else {
            print("No message body found.") // Debug: Message body is nil
            response.action = .allow // Allow if no message body
        }
        
        // Debug: Print the action taken for the message
        print("Action taken: \(response.action == .allow ? "Allow" : "Promotion")")
        
        completion(response)
    }
}
