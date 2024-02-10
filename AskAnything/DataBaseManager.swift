//
//  DataBaseManager.swift
//  AskAnything
//
//  Created by Touchzing media on 28/01/24.
//

import Foundation
import FMDB
var shareInstance = DatabaseManager()
class DatabaseManager: NSObject{
    
    var database:FMDatabase? = nil
    
    
    class func getInstance() -> DatabaseManager{
        if shareInstance.database == nil{
            shareInstance.database = FMDatabase(path: Util.getPath("database.db"))
        }
        return shareInstance
    }
    
    // "INSERT INTO reginfo (name, username, email, password) VALUES(?,?,?,?)"
    func getAllChats() -> [Int: (msg: String, user: String)] {
        var totalmsg: [Int: (msg: String, user: String)] = [:]

        guard let database = shareInstance.database, database.open() else {
            return totalmsg
        }

        do {
            let resultSet = try database.executeQuery("SELECT user, content FROM chatLog", values: nil)
            var index = 0
            while resultSet.next() {
                if let user = resultSet.string(forColumn: "user"), let content = resultSet.string(forColumn: "content") {
                    totalmsg[index] = (msg: content, user: user)
                    index += 1
                }
            }
        } catch {
            print("Error fetching chat data: \(error)")
        }

        database.close()
        return totalmsg
    }


    
    func updateMenuItem(id: Int, newName: String) -> Bool {
            guard let database = database, database.open() else {
                return false
            }

            do {
                let query = "UPDATE menu SET name = ? WHERE id = ?"
                let success = try database.executeUpdate(query, values: [newName, id])
                database.close()
                return true
            } catch {
                print("Error updating menu item: \(error)")
                database.close()
                return false
            }
        }
    
    
    func deleteMenuItemByName(name: String) -> Bool {
           guard let database = database, database.open() else {
               return false
           }

           do {
               let query = "DELETE FROM menu WHERE name = ?"
               let success = try database.executeUpdate(query, values: [name])
               database.close()
               return true
           } catch {
               print("Error deleting menu item: \(error)")
               database.close()
               return false
           }
       }
    
    
    func insertChats(user: String, content: String) -> Bool {
         guard let database = database, database.open() else {
             return false
         }
       
         do {
             let query = "INSERT INTO chatLog (user, content) VALUES (?, ?)"
             let success = try database.executeUpdate(query, values: [user, content])
             database.close()
             return true
         } catch {
             print("Error inserting menu item: \(error)")
             database.close()
             return false
         }
     }

     // Get the number of rows in the 'menu' table
    func numberOfRowsInMenuTable() -> Int {
        guard let database = database, database.open() else {
            return 0
        }

        do {
            let resultSet = try database.executeQuery("SELECT COUNT(*) as count FROM menu", values: nil)
            if resultSet.next() {
                let rowCount = resultSet.int(forColumn: "count")
                database.close()
                return Int(rowCount)
            }
        } catch {
            print("Error getting row count: \(error)")
        }

        database.close()
        return 0
    }

    
    func getIDByName(name: String) -> Int? {
           guard let database = database, database.open() else {
               return nil
           }

           do {
               let query = "SELECT id FROM menu WHERE name = ?"
               let resultSet = try database.executeQuery(query, values: [name])

               if resultSet.next() {
                   let id = resultSet.int(forColumn: "id")
                   database.close()
                   return Int(id)
               }
           } catch {
               print("Error getting ID by name: \(error)")
           }

           database.close()
           return nil
       }
}
