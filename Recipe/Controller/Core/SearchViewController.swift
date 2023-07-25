//
//  SearchViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 31.05.23.
//

import UIKit

class SearchViewController: UIViewController {

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: SearchResultViewController())
        searchController.searchBar.placeholder = "Search for recipes"
        return searchController
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
                                                                NSCollectionLayoutSize(widthDimension: .absolute(UIScreen.main.bounds.width / 3),
                                                                                       heightDimension: .absolute(UIScreen.main.bounds.width / 3)),
                                                               repeatingSubitem: item,
                                                               count: 3)
                
                //section
                let section = NSCollectionLayoutSection(group: group)
                return section
            }))
        return collectionView
    }()
    
    private var categories = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        collectionView.register(SearchCategoryCollectionViewCell.self, forCellWithReuseIdentifier: SearchCategoryCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        searchController.searchBar.delegate = self
        getCategories()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        spinner.center = view.center
    }
    
    private func getCategories() {
        DispatchQueue.main.async {
            ApiCaller.shared.getCategories(sessionDelegate: self) {[weak self] result in
                switch result {
                case .success(let model):
                    self?.spinner.stopAnimating()
                    self?.categories = model
                    self?.collectionView.reloadData()
                case .failure(_):
                    showAlert(title: "Error", message: "Can't get categories", target: self)
                }
            }
        }
    }
    
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCategoryCollectionViewCell.identifier, for: indexPath)
                as? SearchCategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: categories[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categoryVC = CategoryViewController(category: categories[indexPath.row])
        navigationController?.pushViewController(categoryVC, animated: true)
    }
    
}

extension SearchViewController: UISearchBarDelegate, SearchResultViewControllerDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultController = searchController.searchResultsController as? SearchResultViewController,
              let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            return
        }
        resultController.delegate = self
        resultController.update(with: query)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let resultController = searchController.searchResultsController as? SearchResultViewController
        else { return }
        resultController.clear()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let resultController = searchController.searchResultsController as? SearchResultViewController,
              let query = searchBar.text,
              query.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }
        resultController.clear()
    }
    
    func didTapRecipe(recipe: Recipe) {
        let recipeVC = RecipeViewController(recipeId: recipe.id ?? 0)
        navigationController?.pushViewController(recipeVC, animated: true)
    }
    
}
