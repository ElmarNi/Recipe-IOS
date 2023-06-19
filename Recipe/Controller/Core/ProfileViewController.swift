//
//  ProfileViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 31.05.23.
//

import UIKit
struct Option {
    let title: String
    let handler: () -> Void
}
struct Section {
    let title: String
    let options: [Option]
}

class ProfileViewController: UIViewController {

    private let notSignedIn = NotSignedIn(frame: .zero)
    private var sections = [Section]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(notSignedIn)
        
        guard let isSignedIn = UserDefaults.standard.value(forKey: "isSignedIn") as? Bool else { return }
        
        notSignedIn.isHidden = isSignedIn
        notSignedIn.delegate = self
        tableView.isHidden = !isSignedIn
        tableView.dataSource = self
        tableView.delegate = self
        
        configureSections()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        notSignedIn.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        tableView.frame = view.bounds
    }
    
    private func configureSections() {
        
        let viewYourRecipes = Option(title: "View your recipes") {
            print("View recipes")
        }
        
        let viewYourBookmarks = Option(title: "View your bookmarks") {
            print("View bookmarks")
        }
        
        let viewYourProfile = Option(title: "View your profile") {[weak self] in
            self?.viewProfileTapped()
        }
        
        let signOut = Option(title: "Sign out") {[weak self] in
            self?.signOutTapped()
        }
        
        sections.append(Section(title: "Recipes", options: [viewYourRecipes, viewYourBookmarks]))
        sections.append(Section(title: "Profile", options: [viewYourProfile, signOut]))
        
        tableView.reloadData()
    }
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = sections[indexPath.section].options[indexPath.row].title
        cell.contentConfiguration = content
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sections[indexPath.section].options[indexPath.row].handler()
    }
    
}

extension ProfileViewController: NotSignedInDelegate {
    
    func notSignedInTapped() {
        goToWelcomeVc()
    }
    
}

extension ProfileViewController {
    
    private func viewProfileTapped() {
        let profileDetailVC = ProfileDetailViewController()
        navigationController?.pushViewController(profileDetailVC, animated: true)
    }
    
    private func signOutTapped() {
        let alert = UIAlertController(title: "Sign out", message: "Are you sure for sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: {[weak self] _ in
            self?.goToWelcomeVc()
            UserDefaults.standard.setValue(false, forKey: "isSignedIn")
            UserDefaults.standard.setValue(nil, forKey: "userId")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(alert, animated: true)
    }
    
    private func goToWelcomeVc() {
        let welcomeVC = WelcomeViewController()
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(welcomeVC, animated: true)
        navigationController?.viewControllers[0].removeFromParent()
    }
}
