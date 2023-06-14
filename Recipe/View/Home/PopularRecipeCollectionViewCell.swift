//
//  PopularRecipeCollectionViewCell.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 06.06.23.
//

import UIKit

class PopularRecipeCollectionViewCell: UICollectionViewCell {
    static let identifier = "PopularRecipeCollectionViewCell"
    
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
    
    private let heartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private let likesStackView: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    private let peopleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        imageView.tintColor = .white
        return imageView
    }()
    
    private let peopleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private let timeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        imageView.tintColor = .white
        return imageView
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(image)
        image.addSubview(overlayView)
        likesStackView.addSubview(heartButton)
        likesStackView.addSubview(likesLabel)
        contentView.addSubview(likesStackView)
        contentView.addSubview(peopleImageView)
        contentView.addSubview(peopleLabel)
        contentView.addSubview(timeImageView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(authorNameLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(spinner)
        heartButton.addTarget(self, action: #selector(buttonDidTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        likesLabel.sizeToFit()
        peopleLabel.sizeToFit()
        timeLabel.sizeToFit()
        authorNameLabel.sizeToFit()
        nameLabel.sizeToFit()
        
        image.frame = CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height)
        overlayView.frame = CGRect(x: 0, y: 0, width: image.width, height: image.width)
        likesStackView.frame = CGRect(x: 0, y: 10, width: image.width, height: 25)
        heartButton.frame = CGRect(x: likesStackView.width - 38, y: 0, width: 28, height: 25)
        likesLabel.frame = CGRect(x: heartButton.left - likesLabel.width - 5, y: 0, width: likesLabel.width, height: 25)
        peopleImageView.frame = CGRect(x: image.width - 33, y: image.height - 30, width: 23, height: 20)
        peopleLabel.frame = CGRect(x: peopleImageView.left - peopleLabel.width - 5, y: image.height - 30, width: peopleLabel.width, height: 20)
        timeImageView.frame = CGRect(x: image.width - 33, y: image.height - 55, width: 23, height: 20)
        timeLabel.frame = CGRect(x: timeImageView.left - timeLabel.width - 5, y: image.height - 55, width: timeLabel.width, height: 20)
        authorNameLabel.frame = CGRect(x: 10, y: image.height - 30, width: image.width - peopleLabel.width - peopleImageView.width - 30, height: 20)
        nameLabel.frame = CGRect(x: 10,
                                 y: image.height - nameLabel.height - 35,
                                 width: image.width - timeLabel.width - timeImageView.width - 30,
                                 height: nameLabel.height)
        spinner.frame = CGRect(x: image.width / 2, y: image.height / 2, width: 0, height: 0)
    }
    
    @objc private func buttonDidTapped() {
        print("TAPPED")
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
