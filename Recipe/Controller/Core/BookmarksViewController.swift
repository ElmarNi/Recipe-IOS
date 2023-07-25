//
//  BookmarksViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 31.05.23.
//

import UIKit

class BookmarksViewController: UIViewController {

    private let notSignedIn = NotSignedIn(frame: .zero)
    private var recipes = [Recipe]()
    private let isForUserRecipes: Bool
    
    init(isForUserRecipes: Bool) {
        self.isForUserRecipes = isForUserRecipes
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
                //item
                let item = NSCollectionLayoutItem(layoutSize:
                                                    NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                           heightDimension: .fractionalHeight(1)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                //group
                let group = NSCollectionLayoutGroup.horizontal(layoutSize:
                                                                NSCollectionLayoutSize(widthDimension: .absolute(UIScreen.main.bounds.width / 2),
                                                                                       heightDimension: .absolute(UIScreen.main.bounds.width / 2 + 75)),
                                                               repeatingSubitem: item,
                                                               count: 2)
                
                //section
                let section = NSCollectionLayoutSection(group: group)
                return section
            }))
        return collectionView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(notSignedIn)
        view.addSubview(collectionView)
        view.addSubview(spinner)
        spinner.startAnimating()
        guard let isSignedIn = UserDefaults.standard.value(forKey: "isSignedIn") as? Bool else { return }
        notSignedIn.isHidden = isSignedIn
        notSignedIn.delegate = self
        if !isSignedIn {
            spinner.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let isSignedIn = UserDefaults.standard.value(forKey: "isSignedIn") as? Bool else { return }
        
        if isSignedIn {
            collectionView.isHidden = !isSignedIn
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(BookmarkCollectionViewCell.self, forCellWithReuseIdentifier: BookmarkCollectionViewCell.identifier)
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
            collectionView.addGestureRecognizer(gesture)
            
            guard let userId = UserDefaults.standard.value(forKey: "userId") as? String else { return }
            if isForUserRecipes {
                getUserRecipes(userId: userId)
                title = "Recipes"
            }
            else {
                getBookmarks(userId: userId)
                title = "Bookmarks"
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        notSignedIn.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        collectionView.frame = view.bounds
        spinner.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        spinner.center = view.center
    }

}

extension BookmarksViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookmarkCollectionViewCell.identifier, for: indexPath) as? BookmarkCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.configure(with: recipes[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipeVC = RecipeViewController(recipeId: recipes[indexPath.row].id ?? 0)
        navigationController?.pushViewController(recipeVC, animated: true)
    }
    
}

extension BookmarksViewController: NotSignedInDelegate {
    
    func notSignedInTapped() {
        let welcomeVC = WelcomeViewController()
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(welcomeVC, animated: true)
        navigationController?.viewControllers[0].removeFromParent()
    }
    
}

extension BookmarksViewController {
    
    private func getBookmarks(userId: String) {
        DispatchQueue.main.async {
            ApiCaller.shared.getBookmarks(userId: userId, sessinDelegate: self) {[weak self] result in
                switch result {
                case .success(let model):
                    self?.recipes = model
                    self?.collectionView.reloadData()
                    self?.spinner.stopAnimating()
                case .failure(_):
                    showAlert(title: "Error", message: "Can't get recipes", target: self)
                }
            }
        }
    }
    
    private func getUserRecipes(userId: String) {
        DispatchQueue.main.async {
            ApiCaller.shared.getUserRecipes(userId: userId, sessinDelegate: self) {[weak self] result in
                switch result {
                case .success(let model):
                    self?.recipes = model
                    self?.collectionView.reloadData()
                    self?.spinner.stopAnimating()
                case .failure(_):
                    showAlert(title: "Error", message: "Can't get recipes", target: self)
                }
            }
        }
    }
    
    @objc private func longPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: collectionView)
            guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
            
            let recipe = recipes[indexPath.row]
            let alertTitle = self.isForUserRecipes ? "Remove recipe" : "Remove from bookmarks"
            let alertMessage = self.isForUserRecipes ? "Would you like remove \(recipe.name)?" : "Would you like remove \(recipe.name) from bookmarks?"
            
            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
                DispatchQueue.main.async {
                    guard let userId = UserDefaults.standard.value(forKey: "userId") as? String else { return }
                    if self.isForUserRecipes {
                        ApiCaller.shared.removeRecipe(recipeId: recipe.id ?? 0, sessionDelegate: self) {[weak self] result in
                            if result {
                                showAlert(title: "Success", message: "Recipe removed", target: self)
                                self?.recipes.remove(at: indexPath.row)
                                self?.collectionView.reloadData()
                            }
                            else {
                                showAlert(title: "Error", message: "Recipe not removed", target: self)
                            }
                        }
                    }
                    else {
                        ApiCaller.shared.removeBookmark(userId: userId, recipeId: recipe.id ?? 0, sessionDelegate: self) {[weak self] result in
                            if result {
                                showAlert(title: "Success", message: "Recipe removed from bookmarks", target: self)
                                self?.recipes.remove(at: indexPath.row)
                                self?.collectionView.reloadData()
                            }
                            else {
                                showAlert(title: "Error", message: "Recipe not removed from bookmarks", target: self)
                            }
                        }
                    }
                }
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true)
        }
    }
}
