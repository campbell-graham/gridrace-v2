//
//  StartScreenViewController.swift
//  GridRace
//
//  Created by Campbell Graham on 7/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class StartScreenViewController: UIViewController {
    
    var startButton = UIButton()
    var backgroundImage = UIImageView()
    let timerView = TimerView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        //button set up
        startButton.backgroundColor = AppColors.greenHighlightColor
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(AppColors.backgroundColor, for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        startButton.layer.cornerRadius = 10
        startButton.alpha = 0
        startButton.addTarget(self, action: #selector(startRace), for: .touchUpInside)
        
        //image set up
        backgroundImage.image = #imageLiteral(resourceName: "gridrace_splash-min")
        
        //add items to view
        view.addSubview(backgroundImage)
        view.addSubview(startButton)
        
        //layout constraints
        startButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            //start button
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            
            //background image
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
        self.startButton.alpha = 1.0
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @objc func startRace() {
        //add date object to user defaults
        UserDefaults.standard.set(Date(), forKey: "FirstLaunchDate")
        
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            let interval = Date().timeIntervalSince(AppResources.firstLaunchDate)
            
            let ti = NSInteger(interval)
            
            let seconds = ti % 60
            let minutes = (ti / 60) % 60
            let hours = ti / 3600
            
            AppResources.timeToDisplay = NSString(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds) as String
            self.timerView.timeLabel.text = AppResources.timeToDisplay
        })
        
        let placesViewController = ObjectiveTableViewController(title: "Places", tabBarImage: #imageLiteral(resourceName: "directional_arrow"), dataCategory: ObjectiveCategory(rawValue: "places"), objectives: &AppResources.placesObjectives, data: &AppResources.placesUserData)
        let bonusViewController = ObjectiveTableViewController(title: "Bonus", tabBarImage: #imageLiteral(resourceName: "clock_outline"), dataCategory: .bonus, objectives: &AppResources.bonusObjectives, data: &AppResources.bonusUserData)
        
        let mainTabController = UITabBarController()
        
        mainTabController.tabBar.barTintColor = AppColors.backgroundColor
        mainTabController.tabBar.tintColor = AppColors.textPrimaryColor
        
        mainTabController.viewControllers = [UINavigationController(rootViewController: placesViewController), UINavigationController(rootViewController: bonusViewController)]
        
        addTimerToTabBar(tabBar: mainTabController.tabBar)
        
        present(mainTabController, animated: true, completion: nil)
    }
    
    func addTimerToTabBar(tabBar: UITabBar) {
        tabBar.addSubview(timerView)
        
        timerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timerView.centerXAnchor.constraint (equalTo: tabBar.centerXAnchor),
            timerView.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor),
            timerView.heightAnchor.constraint(equalToConstant: tabBar.bounds.height),
            timerView.widthAnchor.constraint(equalToConstant: tabBar.frame.width * 0.3)
            ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
