//
//  RecentsViewController.swift
//  FlickrSearch
//
//  Created by Gary Hanson on 2/1/22.
//

import UIKit


final class RecentsViewController: UIViewController, Storyboarded {
    enum Section {
      case main
    }
    typealias DataSource = UICollectionViewDiffableDataSource<Section, FlickrPhoto>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, FlickrPhoto>

    weak var coordinator: RecentsCoordinator?
    private lazy var dataSource = makeDataSource()
    private var collectionView: UICollectionView!
    private var photos: [FlickrPhoto] = []
    private let spinner = UIActivityIndicatorView(style: .large)
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .systemCyan
        title = "Recent Photos"
        
        self.setupViews()
        
        self.setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRecents()
    }
    
}

// MARK: DataSource
extension RecentsViewController {
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(photos)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, image) ->
                UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlickrPhotoCell.reuseIdentifier,
                                                              for: indexPath) as? FlickrPhotoCell
                let image = self.photos[indexPath.row].thumbnail
                
                cell?.imageView.image = image
                return cell
            })
        return dataSource
    }
    
    private func loadRecents() {
        Task {
            do {
                self.spinner.startAnimating()
                
                let recentPhotos = try await FlickrDownload.recentFlickr()
                
                self.photos = recentPhotos
                applySnapshot()
                self.spinner.stopAnimating()
            } catch {
                self.spinner.stopAnimating()
                print(error)
            }
        }
    }
}

extension RecentsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photo = dataSource.itemIdentifier(for: indexPath) else {
          return
        }

        coordinator?.photoSelected(photo: photo)
    }
}

//MARK: Setup
extension RecentsViewController {
    
    private func setupViews() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 120, height: 120)
        let frame = self.view.frame.insetBy(dx: 20, dy: 180)
        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.view.addSubview(self.collectionView)
        
        self.collectionView.register(FlickrPhotoCell.self, forCellWithReuseIdentifier: FlickrPhotoCell.reuseIdentifier)
        
        self.spinner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(spinner)
        
        self.spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        self.definesPresentationContext = true
    }
    
    private func setupConstraints() {
        let edgeInsets = self.view.safeAreaInsets
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: edgeInsets.bottom),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: edgeInsets.right)
        ])
    }
}
