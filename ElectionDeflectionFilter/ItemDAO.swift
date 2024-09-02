import CoreData

class ItemDAO {
    private let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func fetchItems() -> [EDItem] {
        // Create a fetch request for EDItem
        let fetchRequest: NSFetchRequest<EDItem> = EDItem.fetchRequest()
        do {
            // Perform the fetch request and return the results
            return try managedObjectContext.fetch(fetchRequest)
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }
}
