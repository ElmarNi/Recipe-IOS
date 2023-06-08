//
//  RecommendedRecipeCollectionViewCell.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 06.06.23.
//

import UIKit

class RecommendedRecipeCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedRecipeCollectionViewCell"
    
    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(image)
        image.addSubview(spinner)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.sizeToFit()
        image.frame = CGRect(x: 10, y: 5, width: contentView.height - 10, height: contentView.height - 10)
        spinner.frame = CGRect(x: image.width / 2, y: image.height / 2, width: 0, height: 0)
    }
    
    public func configure(with model: Recipe) {
        nameLabel.text = model.name
        guard let url = URL(string: model.imageUrl ?? "") else { return }
        image.download(from: url, sessionDelegate: self) {[weak self] in
            self?.spinner.stopAnimating()
        }
    }
}

extension RecommendedRecipeCollectionViewCell: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

