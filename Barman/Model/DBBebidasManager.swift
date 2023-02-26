//
//  DBBebidasManager.swift
//  Barman
//
//  Created by De la Cruz Hernandez on 25/02/23.
//

import Foundation
import CoreData

class BDBebidasManager {
    private var dbbebidas : [BDBebidas] = []
    private var context : NSManagedObjectContext
    
    init(context : NSManagedObjectContext){
        self.context = context
    }
    
    func fecth() {
        do{
            self.dbbebidas = try self.context.fetch(BDBebidas.fetchRequest())
        }catch{
            print("Error:", error)
        }
    }
    func fecthWithPredicate(searchValue : String) {
        do{
            let fetchRequestWP = NSFetchRequest<BDBebidas>(entityName: "BDBebidas")
            fetchRequestWP.predicate = NSPredicate(format: "name = %@", searchValue)
            self.dbbebidas = try self.context.fetch(fetchRequestWP)
        }catch{
            print("Error:", error)
        }
    }
    func fecthWithCompountPredicate(name : String = "", ingredients: String = "", directions : String = "") {
        var predicates : [NSPredicate] = []
        if !(name.isEmpty) {
            predicates.append(NSPredicate(format: "name LIKE %@", name))
        }
        if !(ingredients.isEmpty) {
            predicates.append(NSPredicate(format: "ingredients LIKE %@", ingredients))
        }
        if !(directions.isEmpty) {
            predicates.append(NSPredicate(format: "directions LIKE %@", directions))
        }
        let compountPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        do{
            let fetchRequestWCP = NSFetchRequest<BDBebidas>(entityName: "BDBebidas")
            fetchRequestWCP.predicate = compountPredicate
            self.dbbebidas = try self.context.fetch(fetchRequestWCP)
        }catch{
            print("Error:", error)
        }
    }
    func getBebida(at index : Int) -> BDBebidas {
        return dbbebidas[index]
    }
    func countBebida() -> Int {
        return dbbebidas.count
    }
    func pushBebida(newBebida : BDBebidas){
        dbbebidas.append(newBebida)
    }
}
