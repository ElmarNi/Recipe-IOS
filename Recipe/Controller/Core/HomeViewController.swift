//
//  HomeViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 31.05.23.
//

import UIKit

enum SectionType {
    case categories(viewModels: [Category])
    
    var title: String {
        switch self {
        case .categories: return "Top Categories"
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
        collectionView.isPagingEnabled = true
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
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
        getCategories()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        spinner.center = view.center
    }
    
    private func getCategories() {
        ApiCaller.shared.getCategories(sessionDelegate: self) {[weak self] result in
            DispatchQueue.main.async {
                self?.spinner.stopAnimating()
                switch result {
                case .success(let categories):
                    self?.sections.append(SectionType.categories(viewModels: categories))
                    self?.collectionView.reloadData()
                case .failure(_):
                    showAlert(title: "Error", message: "Can't get categories", target: self)
                }
            }
        }
    }
    
    private static func configureSections(section: Int) -> NSCollectionLayoutSection{
        switch section {
        case 0:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                 heightDimension: .fractionalHeight(1)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            //group
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(UIScreen.main.bounds.width / 2), heightDimension: .absolute(100)),
                repeatingSubitem: item,
                count: 1)
            
            //section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
            return section
        default:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                 heightDimension: .fractionalHeight(1)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            //group
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(120), heightDimension: .absolute(100)),
                repeatingSubitem: item,
                count: 1)
            
            //section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
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
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath)
                as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        switch  sections[indexPath.section] {
        case .categories(let models):
            cell.configure(with: models[indexPath.row])
        }
        return cell
    }
}

extension HomeViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
