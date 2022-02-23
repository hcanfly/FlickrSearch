//
//  FlickrPhotoCell.swift
//  FlickrViewCell
//
//  Created by Gary Hanson on 9/12/21.
//

import UIKit


final class FlickrPhotoCell: UICollectionViewCell {
    static let reuseIdentifier = "FlickrPhotoCell"

    lazy var imageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))

        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        addSubview(iv)
        
        return iv
    }()
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
    
    private func commonInit() {
        self.imageView.frame = self.bounds
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.masksToBounds = true
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.imageView)
        
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            self.imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 0.5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
}
