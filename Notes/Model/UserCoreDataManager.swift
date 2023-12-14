//
//  UserCoreDataManager.swift
//  Notes
//
//  Created by JoyDev on 04.12.2023.
//

import Foundation
import CoreData

class UserCoreDataManager {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
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
    
    func saveUser(login: String, email: String, password: String) {
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: context) else {
            return
        }

        let user = NSManagedObject(entity: entity, insertInto: context)
        user.setValue(login, forKey: "login")
        user.setValue(email, forKey: "email")
        user.setValue(password, forKey: "password")

        saveContext()
    }

    func fetchUsers(login: String, password: String) -> [UserEntity] {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        request.predicate = NSPredicate(format: "login == %@ && password == %@", login, password)

        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }

    
}
