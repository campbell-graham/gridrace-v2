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

class ObjectiveTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var tableView = UITableView()
    var objectives = [Objective]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    //will eventually take in data
    init(title: String, tabBarImage: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        tabBarItem = UITabBarItem(title: self.title, image: tabBarImage, selectedImage: tabBarImage)
        populateData()
    }
    
    func populateData() {
        let ref = Database.database().reference()

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            do {
                if let dict = snapshot.value as? [String: Any] {
                    let data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let jsonDecoder = JSONDecoder()
                    self.objectives = try jsonDecoder.decode(ObjectList.self, from: data).objects
                }
            } catch {
                
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        return objectives.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectiveCell", for: indexPath) as! ObjectiveTableViewCell
        cell.titleLabel.text = objectives[indexPath.row].name
        cell.pointsLabel.text = String(objectives[indexPath.row].pointsCount)
        
        //make the title green if the objective is complete
        cell.titleLabel.textColor = indexPath.section == 1 ? AppColors.greenHighlightColor : AppColors.textPrimaryColor
        
        return cell
    }
}
