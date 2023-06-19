//
//  SearchResultViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 09.06.23.
//

import UIKit

protocol SearchResultViewControllerDelegate: AnyObject {
    func didTapRecipe(recipe: Recipe)
}

class SearchResultViewController: UIViewController {
    
    private var recipes = [Recipe]()
    weak var delegate: SearchResultViewControllerDelegate?
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let noRecipeLabel: UILabel = {
        let label = UILabel()
        label.text = "Not found"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
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
                                                                NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                       heightDimension: .absolute(150)),
                                                               repeatingSubitem: item,
                                                               count: 4)
                
                //section
                let section = NSCollectionLayoutSection(group: group)
                return section
            }))
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.register(PopularRecipeCollectionViewCell.self, forCellWithReuseIdentifier: PopularRecipeCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(spinner)
        view.addSubview(noRecipeLabel)
        
        guard let isSignedIn = UserDefaults.standard.value(forKey: "isSignedIn") as? Bool else { return }
        
        if isSignedIn {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
            collectionView.addGestureRecognizer(gesture)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        noRecipeLabel.frame = CGRect(x: 0, y: 0, width: view.width, height: 20)
        noRecipeLabel.center = view.center
        spinner.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        spinner.center = view.center
    }
    
    public func update(with query: String) {
        getRecipes(query: query)
    }
    
    public func clear() {
        recipes = []
        collectionView.reloadData()
        spinner.startAnimating()
        noRecipeLabel.isHidden = true
    }
    
    private func getRecipes(query: String) {
        DispatchQueue.main.async {
            ApiCaller.shared.searchRecipe(with: query, sessionDelegate: self) {[weak self] result in
                switch result {
                case .success(let model):
                    self?.recipes = model
                    self?.noRecipeLabel.isHidden = model.count != 0
                    self?.collectionView.reloadData()
                    self?.spinner.stopAnimating()
                case .failure(_):
                    showAlert(title: "Error", message: "Can't get categories", target: self)
                }
            }
        }
    }
    
    @objc private func longPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: collectionView)
            guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
            
            let recipe = recipes[indexPath.row]
            
            let alertController = UIAlertController(title: "Add to bookmarks", message: "Would you like add \(recipe.name) to bookmarks?", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
                print("OK")
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true)
        }
    }
}

extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularRecipeCollectionViewCell.identifier, for: indexPath)
                as? PopularRecipeCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.configure(with: recipes[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTapRecipe(recipe: recipes[indexPath.row])
    }
    
}
