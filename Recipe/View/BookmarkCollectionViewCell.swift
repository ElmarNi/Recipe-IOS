//
//  BookmarkCollectionViewCell.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 20.06.23.
//

import UIKit

class BookmarkCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "BookmarkCollectionViewCell"
    
    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let overlayView: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = .black
        overlay.alpha = 0.6
        return overlay
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let likesImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        imageView.tintColor = .label
        return imageView
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private let likesStackView = UIStackView()
    
    private let peopleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        imageView.tintColor = .label
        return imageView
    }()
    
    private let peopleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private let peopleStackView = UIStackView()
    
    private let timeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        imageView.tintColor = .label
        return imageView
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private let timeStackView = UIStackView()
    
    private let stackView = UIStackView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 6
        contentView.clipsToBounds = true
        
        contentView.addSubview(image)
        image.addSubview(overlayView)
        
        likesStackView.addSubview(likesImageView)
        likesStackView.addSubview(likesLabel)
        stackView.addSubview(likesStackView)
        
        peopleStackView.addSubview(peopleImageView)
        peopleStackView.addSubview(peopleLabel)
        stackView.addSubview(peopleStackView)
        
        timeStackView.addSubview(timeImageView)
        timeStackView.addSubview(timeLabel)
        stackView.addSubview(timeStackView)
        
        contentView.addSubview(stackView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(authorNameLabel)
        contentView.addSubview(spinner)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        likesLabel.sizeToFit()
        peopleLabel.sizeToFit()
        timeLabel.sizeToFit()
        
        image.frame = CGRect(x: 10, y: 10, width: contentView.width - 20, height: contentView.width - 20)
        
        likesStackView.frame = CGRect(x: 0, y: 0, width: likesLabel.width + 20, height: 20)
        likesImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        likesLabel.frame = CGRect(x: likesImageView.right, y: 0, width: likesLabel.width, height: 20)
        
        peopleStackView.frame = CGRect(x: likesStackView.right + 10, y: 0, width: peopleLabel.width + 20, height: 20)
        peopleImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        peopleLabel.frame = CGRect(x: peopleImageView.right, y: 0, width: peopleLabel.width, height: 20)
        
        timeStackView.frame = CGRect(x: peopleStackView.right + 10, y: 0, width: timeLabel.width + 20, height: 20)
        timeImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        timeLabel.frame = CGRect(x: timeImageView.right, y: 0, width: timeLabel.width, height: 20)
        
        let stackViewsWidth = timeStackView.width + peopleStackView.width + likesStackView.width + 20
        stackView.frame = CGRect(x: (contentView.width - stackViewsWidth) / 2, y: image.bottom + 5, width: stackViewsWidth, height: 20)
        nameLabel.frame = CGRect(x: 10, y: stackView.bottom + 10, width: contentView.width - 20, height: 20)
        authorNameLabel.frame = CGRect(x: 10, y: nameLabel.bottom + 5, width: contentView.width - 20, height: 15)
        spinner.frame = CGRect(x: contentView.width / 2, y: contentView.height / 2, width: 0, height: 0)
    }
    
    public func configure(with model: Recipe) {
        likesLabel.text = "\(model.likes)"
        peopleLabel.text = "\(model.people)"
        timeLabel.text = model.time
        nameLabel.text = model.name
        authorNameLabel.text = model.authorName
        guard let url = URL(string: model.imageUrl ?? "") else { return }
        image.download(from: url, sessionDelegate: self) {[weak self] in
            self?.spinner.stopAnimating()
        }
    }
}
