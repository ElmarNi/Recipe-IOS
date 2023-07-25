//
//  TabBarViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 31.05.23.
//

import UIKit

class TabBarViewController: UITabBarController {

    private let homeController = HomeViewController()
    private let searchController = SearchViewController()
    private let addController = AddViewController()
    private let bookmarkController = BookmarksViewController(isForUserRecipes: false)
    private let profileController = ProfileViewController()
    
    private let appearence: UIBarAppearance = {
        let appearence = UIBarAppearance()
        appearence.configureWithDefaultBackground()
        return appearence
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().standardAppearance = UINavigationBarAppearance(barAppearance: appearence)
        UINavigationBar.appearance().compactAppearance = UINavigationBarAppearance(barAppearance: appearence)
        UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBarAppearance(barAppearance: appearence)
        UINavigationBar.appearance().prefersLargeTitles = false
        UINavigationBar.appearance().tintColor = .label
        UITabBar.appearance().tintColor = .label
        UITabBar.appearance().standardAppearance = UITabBarAppearance(barAppearance: appearence)
        UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance(barAppearance: appearence)
        
        homeController.title = "Home"
        searchController.title = "Search"
        addController.title = "Add recipe"
        bookmarkController.title = "Bookmarks"
        profileController.title = "Profile"
        
        let homeControllerNav = UINavigationController(rootViewController: homeController)
        let searchControllerNav = UINavigationController(rootViewController: searchController)
        let addControllerNav = UINavigationController(rootViewController: addController)
        let bookmarkControllerNav = UINavigationController(rootViewController: bookmarkController)
        let profileControllerNav = UINavigationController(rootViewController: profileController)
        
        homeControllerNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        searchControllerNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        addControllerNav.tabBarItem = UITabBarItem(title: "Add recipe", image: UIImage(systemName: "plus.circle.fill"), tag: 3)
        bookmarkControllerNav.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark"), tag: 4)
        profileControllerNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 5)
        
        setViewControllers([homeControllerNav, searchControllerNav, addControllerNav, bookmarkControllerNav, profileControllerNav], animated: false)
    }

}
