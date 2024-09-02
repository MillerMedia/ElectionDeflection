import IdentityLookup
import CoreData

// Assuming EDItem is a Core Data entity with an attribute 'editem'
final class MessageFilterExtension: ILMessageFilterExtension {
    var keywords: [String] = []
    let coreDataStack = CoreDataStack()
    
    override init() {
        super.init()
        print("MessageFilterExtension initialized") // Add this print statement
        loadKeywords()
    }

    func loadKeywords() {
        let context = coreDataStack.persistentContainer.viewContext
        let itemDAO = ItemDAO(managedObjectContext: context)
        let allItems = itemDAO.fetchItems()

        // Debug: Check how many items are fetched
        print("Loaded \(allItems.count) items from Core Data")

        // Debug: Print all keywords being loaded
        self.keywords = allItems.compactMap { $0.editem?.lowercased() }
        print("Loaded keywords: \(self.keywords)")
    }

    private func determineAction(for messageBody: String) -> ILMessageFilterAction {
        // Debug: Print the message being evaluated
        print("Evaluating message: \(messageBody)")

        for keyword in keywords {
            if messageBody.contains(keyword) {
                print("Keyword matched: \(keyword), categorizing as Promotion")
                return .promotion // Categorize the message as Promotion
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
