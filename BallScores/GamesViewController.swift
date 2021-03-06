//
//  ViewController.swift
//  infoBalls
//
//  Created by Tan Yee Gene on 28/01/2020.
//  Copyright © 2020 Tan Yee Gene. All rights reserved.
//

import UIKit
import CoreData

class GamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // make
    
    
    //MARK: - Variables & Instances
    @IBOutlet weak var tableView: UITableView!
    lazy var coreDataStack = CoreDataStack(modelName: "BallScores")
    lazy var fetchedResultsController: NSFetchedResultsController<Game> = {
        let fetchRequest = NSFetchRequest<Game>(entityName: "Game")
        let sort1 = NSSortDescriptor(key: "id", ascending: false)
        let sort2 = NSSortDescriptor(key: "gameTime", ascending: false)
        fetchRequest.sortDescriptors = [sort1,sort2]
        fetchRequest.fetchBatchSize = 20
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataStack.managedContext, sectionNameKeyPath: "gameTime", cacheName: "Times")
        fetchResultsController.delegate = self
        return fetchResultsController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findPageNumber()
        
        

}
    
    
    func findPageNumber() {
        let url = URL(string: "https://balldontlie.io/api/v1/games")!
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data,response,error in
            if error != nil || data == nil {
                print("Client error!")
                              return
                       }
                       guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                       print("Server error!")
                       return
                       }
                       guard let mime = response.mimeType, mime == "application/json" else {
                       print("Wrong MIME type!")
                       return
                       }
                       do {
                       let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [.allowFragments]) as! [String:Any]
                       DispatchQueue.main.async {
                        let metaDict = jsonDict["meta"] as! [String:Any]
                        print(metaDict)
            }
                       } catch let error as NSError {
                        print(error)
            }
            
    }
    }
   
    
    
}
//MARK: - UI
extension GamesViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//MARK: - Helper Functions
extension GamesViewController {
   func convertDateFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date!)
    }
    
    func performFetch() {
        do {
        try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print(error)
        }
    }

    func clearData() {
        let gameFetchRequest = NSFetchRequest<Game>(entityName: "Game")
        let homeFetchRequest = NSFetchRequest<HomeTeam>(entityName: "HomeTeam")
        let visitorFetchRequest = NSFetchRequest<VisitorTeam>(entityName: "VisitorTeam")
        let count = try! coreDataStack.managedContext.count(for:gameFetchRequest)
        guard count == 0 else { return }
        do {
            let games = try coreDataStack.managedContext.fetch(gameFetchRequest)
            let homes = try coreDataStack.managedContext.fetch(homeFetchRequest)
            let visits = try coreDataStack.managedContext.fetch(visitorFetchRequest)
            games.forEach { coreDataStack.managedContext.delete($0) }
            homes.forEach { coreDataStack.managedContext.delete($0) }
            visits.forEach { coreDataStack.managedContext.delete($0) }
            coreDataStack.saveContext()
            importJSON()
        } catch let error as NSError {
            print("Error fetching: \(error), \(error.userInfo)")
        }
    }
    
            
    func importJSON() {
        let url = URL(string: "https://balldontlie.io/api/v1/games?page=1951")!
       let session = URLSession.shared
       let task = session.dataTask(with: url) { data,response,error in
           if error != nil || data == nil {
               print("Client error!")
               return
        }
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
        print("Server error!")
        return
        }
        guard let mime = response.mimeType, mime == "application/json" else {
        print("Wrong MIME type!")
        return
        }
        do {
        let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [.allowFragments]) as! [String:Any]
        DispatchQueue.main.async {
        let jsonArray = jsonDict["data"] as! [[String:Any]]
            self.populate(dict: jsonArray)
           }
        }catch {
               print("json error \(error.localizedDescription)")
           }
       }
       task.resume()
  }
        
    func populate(dict: [[String:Any]]) {
        for jsonDictionary in dict {
        let homeTeam = jsonDictionary["home_team"] as! [String:Any]
        let visitorTeam = jsonDictionary["visitor_team"] as! [String:Any]
            
        let game = Game(context: self.coreDataStack.managedContext)
        game.id = jsonDictionary["id"] as! Int32
        game.homeTeamScore = jsonDictionary["home_team_score"] as! Int32
        game.visitorTeamScore = jsonDictionary["visitor_team_score"] as! Int32
        game.season = jsonDictionary["season"] as! Int32
        let status = jsonDictionary["status"] as! String
        game.status = status.uppercased()
        game.gameTime = convertDateFormater((jsonDictionary["date"] as? String)!)
            
        let visitor = VisitorTeam(context: self.coreDataStack.managedContext)
       visitor.fullName = visitorTeam["full_name"] as? String
       visitor.abbreviation = visitorTeam["abbreviation"] as? String
       visitor.id = visitorTeam["id"] as! Int32
        game.visitorTeam = visitor
                   
       let home = HomeTeam(context: self.coreDataStack.managedContext)
       home.fullName = homeTeam["full_name"] as? String
       home.abbreviation = homeTeam["abbreviation"] as? String
       home.id = homeTeam["id"] as! Int32
       game.homeTeam = home
        }
          self.coreDataStack.saveContext()
        
    }
    
}



//MARK: - Table View Data Source
extension GamesViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = fetchedResultsController.sections![section]
    return sectionInfo.numberOfObjects
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GameCell
       let game = fetchedResultsController.object(at: indexPath)
       cell.homeScoreLabel.text = String(game.homeTeamScore)
       cell.visitorScoreLabel.text = String(game.visitorTeamScore)
       cell.statusLabel.text = game.status
       cell.homeAbbreviationLabel.text = game.homeTeam?.abbreviation
       cell.visitorAbbreviationLabel.text = game.visitorTeam?.abbreviation
       cell.homeImageView.image = UIImage(named: game.homeTeam!.fullName!)
       cell.visitorImageView.image = UIImage(named: game.visitorTeam!.fullName!)
        
       return cell
   }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(white: 1.0, alpha: 0.8)
        label.backgroundColor = UIColor(red: 218/255.0, green: 161/255.0, blue: 160/255.0 , alpha: 1.0)
        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.addSubview(label)

        return view
    }
    

}



//MARK: - Fetch Controller Data Source
extension GamesViewController: NSFetchedResultsControllerDelegate {
func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print("*** controllerWillChangeContent")
    tableView.beginUpdates()
}


func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
    switch type {
    case .insert:
        print("*** NSFetchedRequestChangeInsert (object)")
        tableView.insertRows(at: [newIndexPath!], with: .fade)
        
    case .update:
        print("****NSFetchResultChangeUpdate")
    
    case .delete:
        print("***NSFetchedRequestChangeDelete (object)")
        tableView.deleteRows(at: [indexPath!], with: .fade)
    
    case .move:
        print("***NSFetchedResultsChangeMove (object)")
        tableView.deleteRows(at: [indexPath!], with: .fade)
        tableView.insertRows(at: [newIndexPath!], with: .fade)
    
    @unknown default:
        fatalError("Unhandled switch case of NSFetchedResultsChangeType")
    }
}

func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
        print("***NSFetchedResultsChangeInsert (section)")
        tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        
    case .delete:
        print("***NSFetchedResultsChangeDelete (section)")
        tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        
    case .update:
        print("***NSFetchedResultsChangeUpdate (section)")
    case .move:
        print("***NSFetchedResultsChangeMove (section)")
    
    @unknown default:
    fatalError("Unhandled switch case of NSFetchedResultsChangeType")
    }

}

func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print("*** controllerDidChangeContent")
    tableView.endUpdates()
    }
}



