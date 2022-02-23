//
//  SearchViewController.swift
//  SearchViewController
//
//  Created by Gary Hanson on 9/11/21.
//

import UIKit

typealias DataSource = UICollectionViewDiffableDataSource<Section, FlickrPhoto>
typealias Snapshot = NSDiffableDataSourceSnapshot<Section, FlickrPhoto>


final class SearchViewController: UICollectionViewController, Storyboarded {
    weak var coordinator: SearchCoordinator?
    private let searchController = UISearchController(searchResultsController: nil)
    private var photos: [FlickrPhoto] = []
    private let debouncer = Debouncer()
    private var debounceReload: (() -> Void)!
    private let spinner = UIActivityIndicatorView(style: .large)
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let itemsPerRow: CGFloat = 3
    private var sections = Section.allSections
    private lazy var dataSource = makeDataSource()

    
    override func loadView() {
        super.loadView()

        self.view.backgroundColor = .systemMint

        self.setupViews()

        self.setupConstraints()
        
        self.configureLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.debounceReload = self.debouncer.debounce(delay: .seconds(2)) {
            if self.searchController.searchBar.text!.count > 2 {
                var cleanstring = self.searchController.searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                cleanstring = cleanstring.trimmingCharacters(in: .whitespacesAndNewlines)
                // just in case of an extra space inside string. more than that - too bad
                cleanstring = cleanstring.replacingOccurrences(of: "  ", with: " ")
                var searchString = cleanstring.replacingOccurrences(of: " ", with: "+")
                searchString = searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if searchString.count > 2 {
                    self.spinner.startAnimating()
                    self.findFlickrPhotos(title: searchString)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.searchController.searchBar.becomeFirstResponder()
    }

}

extension SearchViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photo = dataSource.itemIdentifier(for: indexPath) else {
          return
        }

        coordinator?.photoSelected(photo: photo)
    }
}

// MARK: DataSource
extension SearchViewController {
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, flickrPhoto) ->
                UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: FlickrPhotoCell.reuseIdentifier,
                    for: indexPath) as? FlickrPhotoCell
                
                let image = flickrPhoto.thumbnail
                
                cell?.imageView.image = image
                return cell
            })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier,
                for: indexPath) as? SectionHeaderReusableView
            let section = self.dataSource.snapshot()
                .sectionIdentifiers[indexPath.section]
            view?.titleLabel.text = section.title
            return view
        }
        
        return dataSource
    }
    
    private func applySnapshot(title: String, photos: [FlickrPhoto], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        let section = Section(title: title, photos: photos)
        
        Section.allSections.insert(section, at: 0)
        snapshot.appendSections(Section.allSections)
        Section.allSections.forEach { section in
          snapshot.appendItems(section.photos, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func findFlickrPhotos(title: String) {
        Task {
            do {
                let foundPhotos = try await FlickrDownload.searchFlickr(for: title)
                
                self.photos = foundPhotos
                self.applySnapshot(title: title, photos: foundPhotos)
                self.collectionView.setContentOffset(CGPoint.zero, animated: true)
                self.spinner.stopAnimating()
            } catch {
                self.spinner.stopAnimating()
                print(error)
            }
        }
    }
    
}

//MARK: SearchController
extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        self.debounceReload()
    }
}

extension SearchViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        var snapshot = Snapshot()
        
        Section.allSections.removeAll()
        snapshot.appendSections(Section.allSections)
        dataSource.apply(snapshot, animatingDifferences: true)
        spinner.stopAnimating()
    }
}

// MARK: Setup and Configure
extension SearchViewController {
    
    private func setupViews() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let frame = self.view.frame.insetBy(dx: 20, dy: 180)
        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(self.collectionView)
        
        self.collectionView.register(FlickrPhotoCell.self, forCellWithReuseIdentifier: FlickrPhotoCell.reuseIdentifier)
        
        self.searchController.delegate = self
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.autocapitalizationType = .none
        self.searchController.searchBar.delegate = self
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.backgroundColor = .systemGray
        
        self.searchController.searchBar.placeholder = "Search Flickr"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        self.definesPresentationContext = true
        
        self.spinner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(spinner)
        
        self.spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
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
    
    private func configureLayout() {
        collectionView.register(
            SectionHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier
        )
        
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            let leadingItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
            let leadingItem = NSCollectionLayoutItem(layoutSize: leadingItemSize)
            let leadingGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                   heightDimension: .fractionalHeight(1.0)),
                subitem: leadingItem, count: 2)
            
            let trailingItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3333))
            let trailingItem = NSCollectionLayoutItem(layoutSize: trailingItemSize)
            let trailingGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                   heightDimension: .fractionalHeight(1.0)),
                subitem: trailingItem, count: 3)
            
            let nestedGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(0.6)),
                subitems: [leadingGroup, trailingGroup])
            nestedGroup.contentInsets = NSDirectionalEdgeInsets(
                top: 5,
                leading: 0,
                bottom: 10,
                trailing: 0)
            
            let layoutSection = NSCollectionLayoutSection(group: nestedGroup)
            layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
            
            let headerFooterSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(20)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            layoutSection.boundarySupplementaryItems = [sectionHeader]
            return layoutSection
        })
    }
    
}

final class Debouncer {

    var currentWorkItem: DispatchWorkItem?

    func debounce(delay: DispatchTimeInterval, queue: DispatchQueue = .main, action: @escaping (() -> Void)) -> () -> Void {
        return {  [weak self] in
            guard let self = self else { return }
            
            self.currentWorkItem?.cancel()
            self.currentWorkItem = DispatchWorkItem { action() }
            queue.asyncAfter(deadline: .now() + delay, execute: self.currentWorkItem!)
        }
    }
}
