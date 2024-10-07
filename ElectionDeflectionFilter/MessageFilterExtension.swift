import IdentityLookup

// Simplified Message Filter Extension without Core Data
final class MessageFilterExtension: ILMessageFilterExtension {
    // List of keywords to filter
    var keywords: [String] = ["trump", "vance", "harris", "walz", "election", "vote", "campaign", "giuliani", "kamala", "democrat", "republican", "senate", "cruz", "congress", "impeach", "ballot", "radical left", "far right", "cmp.lk", "jim jordan", "fundprogress.us", "dems ", "gop ", "kellyanne conway", "steve garvey", "gov. abbott", "governor abbott", "win4tx.org", "biden", "potus", " dems ", "left-wing", "right-wing", "super pac", "actblue", "winred", "dnc ", "rnc ", "nancy pelosi", "chuck schumer", "mitch mcconnell", "lindsey graham", "bernie sanders", "elizabeth warren", "alexandria ocasio-cortez", "aoc ", "ron desantis", "mike pence", "nikki haley", "newsom", "marjorie taylor greene", "matt gaetz", "lauren boebert", "kevin mccarthy", "dm24.co", "bob casey", "dave mccormick", "rep-24", "reagan", "usred.co", "kari lake", "hannity", "maddow", "24-red", "gop-victory.com", "vivek", "ramaswamy", "cheney", "clinton", "obama", "dan osborn", "deb fischer", "vote24.io", "savedemocracypac", "letamericavote", "momsfedup", "lincoln project", "electdemsnow", "boldpac", "hmpac", "electdemocracticwomen", "bluewave", "demmajority", "retireddemocrat", "demgovs", "tim kaine", "trustrightusa", "israelsrvy", "cbcpac", "colin allred", "colinallred.com", "24win.co", "blue wave", "goplink", "tth07"
    ]

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
