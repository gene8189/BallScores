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

    
    @IBOutlet weak var tableView: UITableView!
    lazy var coreDataStack = CoreDataStack(modelName: "BallScores")
    
    
    

    //3. label TO DISPLAY DATE
    
    lazy var fetchedResultsController: NSFetchedResultsController<Game> = {
        let fetchRequest = NSFetchRequest<Game>(entityName: "Game")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        return fetchResultsController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clearData()
       performFetch()
        

}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GameCell
        let game = fetchedResultsController.object(at: indexPath)
        
        cell.homeScoreLabel.text = String(game.homeTeamScore)
        cell.visitorScoreLabel.text = String(game.visitorTeamScore)
        cell.statusLabel.text = game.status!
        
        
        cell.homeAbbreviationLabel.text = game.homeTeam?.abbreviation
        cell.visitorAbbreviationLabel.text = game.visitorTeam?.abbreviation
        cell.homeImageView.image = UIImage(named: game.homeTeam!.fullName!)
        cell.visitorImageView.image = UIImage(named: game.visitorTeam!.fullName!)
            
        return cell
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func convertDateFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMM dd,yyyy"
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
        let fetchRequest = NSFetchRequest<Game>(entityName: "Game")
        let count = try! coreDataStack.managedContext.count(for:fetchRequest)
//        guard count == 0 else { return }
        do {
            let games = try coreDataStack.managedContext.fetch(fetchRequest)
            games.forEach { coreDataStack.managedContext.delete($0) }
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
    for jsonDictionary in jsonArray {
        
      let homeTeam = jsonDictionary["home_team"] as! [String:Any]
      let visitorTeam = jsonDictionary["visitor_team"] as! [String:Any]
      
      let game = Game(context: self.coreDataStack.managedContext)
      game.id = jsonDictionary["id"] as! Int32
      game.homeTeamScore = jsonDictionary["home_team_score"] as! Int32
      game.visitorTeamScore = jsonDictionary["visitor_team_score"] as! Int32
      game.season = jsonDictionary["season"] as! Int32
      let status = jsonDictionary["status"] as! String
      game.status = status.uppercased()

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
       } catch {
           print("json error \(error.localizedDescription)")
       }
   }
   
   task.resume()
    
    }
}




extension GamesViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Updating table....")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert: tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete: tableView.deleteRows(at: [indexPath!], with: .automatic)
        default: break
        }
        print("Did change table....")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Ending update....")
        tableView.endUpdates()
    }
}


