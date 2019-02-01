//
//  ViewController.swift
//  itunes store search
//
//  Created by zipp on 2/1/19.
//  Copyright © 2019 zipp. All rights reserved.
//

import UIKit

class ColViewCell: UICollectionViewCell {
    var async_urlsession: URLSessionDataTask?
    
    // self.tag is the index in current_view_images
    
    override func prepareForReuse() {
        // this is called when a cell is dequeue'd, rather than it just having an id or
        // something terribly complicated like that
        
        // stop any existing async requests for this thumbnail
        //async_urlsession?.cancel()
    }
    
    // this is called to build the cell
    func build() {
        let label: UILabel = UILabel(frame: CGRect(x: 5, y: 5, width: self.frame.width, height: self.frame.height))
        label.textAlignment = .left
        label.textColor = .black
        label.font = label.font.withSize(10.0)
        label.text = "testing"
        contentView.addSubview(label)
    }
    
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    // this lays out the collection view, in css you'd say margins, padding etc
    let l = UICollectionViewFlowLayout();
    override func viewDidLayoutSubviews() {
        
        // setup the flow layout
        self.l.itemSize = CGSize(width: 50, height: 50)
        self.l.minimumInteritemSpacing = 1;
        self.l.minimumLineSpacing = 1
        self.l.headerReferenceSize = CGSize(width: 0, height: 0)
        //self.l.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        //self.l.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.colview_apps.collectionViewLayout = l
        
        super.viewDidLayoutSubviews()
        
        // move to and flash the current thumbnail, this would happen after the
        // fullscreen view is hidden, because viewDidLayoutSubviews would be called
        DispatchQueue.main.async {
            DispatchQueue(label: "viewqueue").sync {
                
                /*
                if (self.current_fullscreen_image_index != -1) {
                    
                    self.collectionView.scrollToItem(at: IndexPath(item: self.current_fullscreen_image_index, section: 0), at: [.centeredVertically], animated: false)
                }
                */
                
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colViewCell", for: indexPath) as! ColViewCell
        
        cell.build()
        
        return cell
    }
    

    @IBOutlet weak var colview_apps: UICollectionView!
    @IBOutlet weak var search_field_apps: UITextField!
    @IBOutlet weak var single_app_view: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        colview_apps.dataSource = self
        colview_apps.delegate = self
        
        colview_apps.reloadData()
    }


}

