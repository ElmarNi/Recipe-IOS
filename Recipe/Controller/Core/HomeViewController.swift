//
//  HomeViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 31.05.23.
//

import UIKit

enum SectionType {
    case categories(viewModels: [Category])
    case popularRecipes(viewModels: [Recipe])
    case recommendedRecipes(viewModels: [Recipe])
    var title: String {
        switch self {
        case .categories: return "Top Categories"
        case .popularRecipes: return "Popular recipes"
        case .recommendedRecipes: return "Recommended recipes"
        }
    }
}

class HomeViewController: UIViewController {
    
    private var sections = [SectionType]()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
                return HomeViewController.configureSections(section: sectionIndex)
            }))
        collectionView.backgroundColor = .systemBackground
        collectionView.isPagingEnabled = false
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.register(PopularRecipeCollectionViewCell.self, forCellWithReuseIdentifier: PopularRecipeCollectionViewCell.identifier)
        collectionView.register(RecommendedRecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedRecipeCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderCollectionReusableView.identifier)
        return collectionView
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
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        view.addSubview(spinner)
        getDatas()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        spinner.center = view.center
    }
    
    private func getDatas() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        var categories = [Category]()
        var popularRecipes = [Recipe]()
        var recommendedRecipes = [Recipe]()
        
        ApiCaller.shared.getCategories(sessionDelegate: self) {[weak self] result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let categoriesModel):
                categories = categoriesModel
            case .failure(_):
                showAlert(title: "Error", message: "Can't get categories", target: self)
            }
        }
        
        ApiCaller.shared.getPopularRecipes(sessionDelegate: self) {[weak self] result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let popularRecipesModel):
                popularRecipes = popularRecipesModel
            case .failure(_):
                showAlert(title: "Error", message: "Can't get categories", target: self)
            }
        }
        
        ApiCaller.shared.getRecommendedRecipes(sessionDelegate: self) {[weak self] result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let recommendedRecipesModel):
                recommendedRecipes = recommendedRecipesModel
            case .failure(_):
                showAlert(title: "Error", message: "Can't get categories", target: self)
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.configureModels(categories: categories, popularRecipes: popularRecipes, recommendedRecipes: recommendedRecipes)
        }
    }
    
    private func configureModels(categories: [Category], popularRecipes: [Recipe], recommendedRecipes: [Recipe]) {
        sections.append(SectionType.categories(viewModels: categories))
        sections.append(SectionType.popularRecipes(viewModels: popularRecipes))
        sections.append(SectionType.recommendedRecipes(viewModels: recommendedRecipes))
        spinner.stopAnimating()
        collectionView.reloadData()
    }
    
    private static func configureSections(section: Int) -> NSCollectionLayoutSection {
        let supplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )]
        switch section {
        case 0:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                 heightDimension: .fractionalHeight(1)))
            
            //group
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(UIScreen.main.bounds.width / 2), heightDimension: .absolute(100)),
                repeatingSubitem: item,
                count: 1)
            
            //section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryItems
            return section
        case 1:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                 heightDimension: .fractionalHeight(1)))
            
            //group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2)),
                repeatingSubitem: item,
                count: 2)
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(UIScreen.main.bounds.width - 70), heightDimension: .absolute(300)),
                repeatingSubitem: verticalGroup,
                count: 1)
            
            //section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
            section.boundarySupplementaryItems = supplementaryItems
            return section
        default:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                 heightDimension: .fractionalHeight(1)))
            
            //group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(130)),
                repeatingSubitem: item,
                count: 1)
            
            //section
            let section = NSCollectionLayoutSection(group: verticalGroup)
            section.boundarySupplementaryItems = supplementaryItems
            return section
        }
    }
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .categories(let model):
            return model.count
        case .popularRecipes(let model):
            return model.count
        case .recommendedRecipes(let model):
            return model.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch  sections[indexPath.section] {
        case .categories(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath)
                    as? CategoryCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: models[indexPath.row])
            return cell
        case .popularRecipes(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularRecipeCollectionViewCell.identifier, for: indexPath)
                    as? PopularRecipeCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: models[indexPath.row])
            return cell
        case .recommendedRecipes(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedRecipeCollectionViewCell.identifier, for: indexPath)
                    as? RecommendedRecipeCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: models[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) ->
    UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderCollectionReusableView.identifier,
            for: indexPath) as? HeaderCollectionReusableView
        else {
            return UICollectionReusableView()
        }
        header.configure(with: sections[indexPath.section].title)
        return header
    }
}

extension HomeViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
