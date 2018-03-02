//
//  ObjectiveTableViewController.swift
//  GridRace
//
//  Created by Campbell Graham on 27/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ObjectiveTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ObjectiveTableViewControllerDelegate  {
    
    var tableView = UITableView()
    var dataCategory: ObjectiveCategory
    
    var objectives = [Objective]() {
        didSet {
            sortObjectives()
        }
    }
    
    var incompleteObjectives = [Objective]() {
        didSet {
            tableView.reloadData()
        }
    }
    var completeObjectives = [Objective]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    //will eventually take in data
    init(title: String, tabBarImage: UIImage, dataCategory: ObjectiveCategory) {
        self.dataCategory = dataCategory
        super.init(nibName: nil, bundle: nil)
        self.title = title
        tabBarItem = UITabBarItem(title: self.title, image: tabBarImage, selectedImage: tabBarImage)
        downloadObjectives()
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.reloadData()
    }
    
    func sortObjectives() {
        completeObjectives.removeAll()
        incompleteObjectives.removeAll()
        for (objective) in objectives {
            if ObjectiveManager.shared.completeObjectives.contains(objective.id) {
                completeObjectives.append(objective)
            } else {
                incompleteObjectives.append(objective)
            }
        }
    }
    
    func downloadObjectives() {
        
        //download if doesn't exist already
        
            var tempObjectives = [Objective]()
        
            let ref = Database.database().reference()
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                do {
                    if let dict = snapshot.value as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
                        let jsonDecoder = JSONDecoder()
                        
                        tempObjectives = self.dataCategory == .places ? try jsonDecoder.decode(ObjectList.self, from: data).places : try jsonDecoder.decode(ObjectList.self, from: data).bonus
                        
                        //attempt a load of previous data, if it can't then it will fail safely
                        self.loadLocalData()
                        
                        //check that they are the same length and have the same data, reset if not
                        if tempObjectives.count == self.objectives.count {
                            for (index, objective) in tempObjectives.enumerated() {
                                if !(objective == self.objectives[index]) {
                                    self.objectives = tempObjectives
                                    self.resetLocalData()
                                    break
                                }
                            }
                        } else {
                            self.objectives = tempObjectives
                            self.resetLocalData()
                        }
                        self.tableView.reloadData()
                    }
                } catch {
                    print(error)
                }
            })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func objectivesFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Objectives_\(dataCategory.rawValue).plist")
    }
    
    func pointsFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Points.plist")
    }
    
    func savedTextResponsesFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("TextResponses.plist")
    }
    
    func completeIDsFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Completed.plist")
    }
    
    func saveLocalData() {
        let encoder = PropertyListEncoder()
        do {
            let objectivesData = try encoder.encode(objectives)
            let pointsData = try encoder.encode(ObjectiveManager.shared.objectivePointMap)
            let completeData = try encoder.encode(ObjectiveManager.shared.completeObjectives)
            let textResponseData = try encoder.encode(ObjectiveManager.shared.savedTextResponses)
            try objectivesData.write(to: objectivesFilePath())
            try pointsData.write(to: pointsFilePath())
            try completeData.write(to: completeIDsFilePath())
            try textResponseData.write(to: savedTextResponsesFilePath())
        } catch {
            print ("Something went wrong when saving")
        }
        
        //sort at the end of saving
        sortObjectives()
    }
    
    func initiateSave() {
        print("Saving!")
        saveLocalData()
    }
    
    
    func loadLocalData() {
       
       //load objectives, points and completed data
        if let objectivesData = try? Data(contentsOf: objectivesFilePath()), let pointsData = try? Data(contentsOf: pointsFilePath()), let completeData = try? Data(contentsOf: completeIDsFilePath()),
            let textResponseData = try? Data(contentsOf: savedTextResponsesFilePath()) {
            let decoder = PropertyListDecoder()
            do {
                objectives = try decoder.decode([Objective].self, from: objectivesData)
                let pointValues = try decoder.decode([String: Int].self, from: pointsData)
                pointValues.forEach { ObjectiveManager.shared.objectivePointMap[$0.key] = $0.value }
                let completeValues = try decoder.decode(Set<String>.self, from: completeData)
                completeValues.forEach { ObjectiveManager.shared.completeObjectives.insert($0) }
                let textResponseValues = try decoder.decode([String: String].self, from: textResponseData)
                textResponseValues.forEach {ObjectiveManager.shared.savedTextResponses[$0.key] = $0.value}
                sortObjectives()
                }
            catch {
                print("Error decoding the local array, will re-download")
                //delete local file and re-download if there is an issue
                do {
                    try FileManager.default.removeItem(at: objectivesFilePath())
                    try FileManager.default.removeItem(at: pointsFilePath())
                    try FileManager.default.removeItem(at: completeIDsFilePath())
                    downloadObjectives()
                } catch {
                    print("Failed to delete corrupt data, if this triggers then sad react only cause there's not a lot you can do")
                }
                
            }
        } else {
            //delete local file and re-download if there is an issue
            do {
                try FileManager.default.removeItem(at: objectivesFilePath())
                try FileManager.default.removeItem(at: pointsFilePath())
                try FileManager.default.removeItem(at: completeIDsFilePath())
                downloadObjectives()
            } catch {
                print("Triggered due to the download method attempting to load first to make comparisons, it is fine if this appears")
            }
        }
    }
    
    func resetLocalData() {
        //clear the objective manager
        ObjectiveManager.shared.completeObjectives.removeAll()
        ObjectiveManager.shared.objectivePointMap.removeAll()
        ObjectiveManager.shared.savedTextResponses.removeAll()
        //save this information
        saveLocalData()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //styling
        view.backgroundColor = AppColors.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.backgroundColor = AppColors.backgroundColor
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = AppColors.textSecondaryColor
        
        //table view setup
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ObjectiveTableViewCell.self, forCellReuseIdentifier: "ObjectiveCell")
        tableView.register(CustomTableHeaderView.self, forHeaderFooterViewReuseIdentifier: "CustomHeaderView")
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        //add items to view
        view.addSubview(tableView)
        
        //layout constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return incompleteObjectives.count
        case 1:
            return completeObjectives.count
        default:
            return 0
        }
       
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //return a blank view for the header if that section does not have any objectives
        if section == 0 && incompleteObjectives.count == 0 {
            return UIView()
        } else if section == 1 && completeObjectives.count == 0 {
            return UIView()
        }
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeaderView") as! CustomTableHeaderView
        switch section {
        case 0:
            headerView.titleLabel.text = "Incomplete"
        case 1:
            headerView.titleLabel.text = "Complete"
        default:
            break
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0 :
            let destination = DetailViewController(objective: incompleteObjectives[indexPath.row])
            destination.delegate = self
            navigationController?.pushViewController(destination, animated: true)
        case 1 :
            let destination = DetailViewController(objective: completeObjectives[indexPath.row])
            destination.delegate = self
            navigationController?.pushViewController(destination, animated: true)
        default:
            print("invalid section")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectiveCell", for: indexPath) as! ObjectiveTableViewCell
        let objective = indexPath.section == 0 ? incompleteObjectives[indexPath.row] : completeObjectives[indexPath.row]
        
        cell.titleLabel.text = objective.name
        cell.pointsLabel.text = "\(ObjectiveManager.shared.objectivePointMap[objective.id] ?? objective.points)"
        
        //set font to heavy if complete
        
        cell.titleLabel.font = indexPath.section == 0 ? UIFont.systemFont(ofSize: 16, weight: .ultraLight) : UIFont.systemFont(ofSize: 16, weight: .medium)
        
        
        return cell
    }
}

protocol ObjectiveTableViewControllerDelegate: class {
    func initiateSave()
}
