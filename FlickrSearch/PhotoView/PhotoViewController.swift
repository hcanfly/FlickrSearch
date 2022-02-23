//
//  ImageViewController.swift
//  ImageViewController
//
//  Created by Gary Hanson on 9/12/21.
//

import UIKit

final class PhotoViewController: UIViewController {
    var photo: FlickrPhoto!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = photo.title
        //imageView.image = photo.thumbnail - generally very quick. don't think really need spinner here for now
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let photoInfo = FlickrPhotoInfo(id: photo.photoID, farm: photo.farm, server: photo.server, secret: photo.secret, title: photo.title)
        Task {
            do {
                let flickrphoto = try await FlickrDownload.getPhotos(photoData: [photoInfo], getLargeImage: true)
                imageView.image = flickrphoto[0].largeImage
            } catch {
                print("oops")
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
}

// got most of this from a Ray Wenderlich tutorial some time ago
extension PhotoViewController {
    
  private func updateMinZoomScaleForSize(_ size: CGSize) {
    let widthScale = size.width / imageView.bounds.width
    let heightScale = size.height / imageView.bounds.height
    let minScale = min(widthScale, heightScale)
      
    scrollView.minimumZoomScale = minScale
    scrollView.zoomScale = minScale
  }
  
    private func updateConstraintsForSize(_ size: CGSize) {
    let yOffset = max(0, (size.height - imageView.frame.height) / 2)
      
    imageViewTopConstraint.constant = yOffset
    imageViewBottomConstraint.constant = yOffset
    
    let xOffset = max(0, (size.width - imageView.frame.width) / 2)
      
    imageViewLeadingConstraint.constant = xOffset
    imageViewTrailingConstraint.constant = xOffset
      
    view.layoutIfNeeded()
  }
    
}

extension PhotoViewController: UIScrollViewDelegate {
    
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    updateConstraintsForSize(view.bounds.size)
  }
    
}
