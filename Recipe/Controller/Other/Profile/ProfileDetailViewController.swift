//
//  ProfileDetailViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 19.06.23.
//

import UIKit

class ProfileDetailViewController: UIViewController {
    
    private var properties = [String]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(spinner)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        guard let userId = UserDefaults.standard.value(forKey: "userId") as? String else { return }
        getUserData(userId: userId)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        spinner.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        spinner.center = view.center
        tableView.frame = view.bounds
    }
    
    private func getUserData(userId: String) {
        DispatchQueue.main.async {
            AuthManager.shared.getUserData(with: userId, sessionDelegate: self) {[weak self] result in
                switch result {
                case .success(let model):
                    self?.properties.append("Firstname: \(model.firstname)")
                    self?.properties.append("Lastname: \(model.lastname)")
                    self?.properties.append("Email: \(model.email)")
                    self?.properties.append("Username: \(model.userName)")
                    self?.tableView.reloadData()
                    self?.spinner.stopAnimating()
                case .failure(_):
                    showAlert(title: "Error", message: "Something went wrong", target: self)
                }
            }
        }
    }

}


extension ProfileDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = properties[indexPath.row]
        cell.contentConfiguration = content
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
