import CoreData

class CoreDataStack {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ElectionDeflectionModel")
        
        if let appGroupContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.millermedia.electiondeflection") {
            let storeURL = appGroupContainerURL.appendingPathComponent("ElectionDeflectionModel.sqlite")
            
            // Ensure directory exists
            do {
                try FileManager.default.createDirectory(at: appGroupContainerURL, withIntermediateDirectories: true, attributes: nil)
                print("Successfully ensured App Group directory exists.")
            } catch {
                print("Failed to create App Group directory: \(error)")
            }
            
            // Test writing a simple file to check permissions
            let testFileURL = appGroupContainerURL.appendingPathComponent("test.txt")
            do {
                try "Permission Test".write(to: testFileURL, atomically: true, encoding: .utf8)
                print("Successfully wrote to the App Group directory.")
            } catch {
                print("Failed to write to the App Group directory: \(error)")
            }
            
            let description = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [description]
        } else {
            fatalError("Failed to find app group container URL.")
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Handle any errors that occur during the loading of persistent stores
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
