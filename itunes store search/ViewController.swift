//
//  ViewController.swift
//  itunes store search
//
//  Created by zipp on 2/1/19.
//  Copyright © 2019 zipp. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

var movies: [rest_api.movie] = []

class ColViewCell: UICollectionViewCell {
    var async_urlsession: URLSessionDataTask?
    
    override func prepareForReuse() {
        // this is called when a cell is dequeue'd, rather than it just having an id or
        // something terribly complicated like that
        
        // stop any existing async requests for this thumbnail
        async_urlsession?.cancel()
    }
    
    // this is called to build the cell
    func build(id: Int) {
        
        //print(movies[id])
        
        // remove anything in the cell
        for v: UIView in self.contentView.subviews {
            v.removeFromSuperview()
        }
        
        // show the track name
        let label: UILabel = UILabel(frame: CGRect(x: 5, y: 5, width: self.frame.width, height: 10))
        label.textAlignment = .left
        label.textColor = .black
        label.font = label.font.withSize(10.0)
        label.text = movies[id].trackName
        contentView.addSubview(label)
        
        if (movies[id].artworkUrl100 != nil) {
            // show the thumbnail
            let img: UIImageView = UIImageView(frame: CGRect(x: 0, y: 20, width: 100, height: 100))
            
            // setup the request
            let req_url = URL(string: movies[id].artworkUrl100!)
            print(req_url)
            var request = URLRequest(url: req_url!);
            
            // set the method
            request.httpMethod = "GET";
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            async_urlsession = session.dataTask(with: request) { data, response, error in
                let httpResponse = response as? HTTPURLResponse
                if (httpResponse == nil || data == nil) {
                    // this will happen when the request is cancelled
                    // or there is a failure with the request
                    return
                }
                if (200...299).contains(httpResponse!.statusCode) {
                    // good response
                    DispatchQueue.main.async {
                        let th = UIImage(data: data!)
                        
                        img.frame.size.width = (th?.size.width)!
                        img.frame.size.height = (th?.size.height)!
                        
                        img.image = th
                        
                        self.contentView.addSubview(img)
                    }
                }
                
            }
            
            async_urlsession?.resume()
            
        }
    }
    
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UITextFieldDelegate {
    
    // this lays out the collection view, in css you'd say margins, padding etc
    let l = UICollectionViewFlowLayout();
    override func viewDidLayoutSubviews() {
        
        // setup the flow layout
        self.l.itemSize = CGSize(width: 150, height: 120)
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
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colViewCell", for: indexPath) as! ColViewCell
        
        cell.build(id: indexPath.row)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("tapped cell " + String(indexPath.row))
        
        // show the single_app_view
        show_single_app(id: indexPath.row)
        
    }
    
    var async_urlsession: URLSessionDataTask?
    func show_single_app(id: Int) {
        
        if (async_urlsession != nil) {
            async_urlsession?.cancel()
        }
        
        // remove anything
        for v: UIView in single_app_view.subviews {
            v.removeFromSuperview()
        }
        
        // show the track name
        let label: UILabel = UILabel(frame: CGRect(x: 5, y: 5, width: 300, height: 20))
        label.textAlignment = .left
        label.textColor = .black
        label.font = label.font.withSize(24.0)
        label.text = movies[id].trackName
        single_app_view.addSubview(label)
        
        // show the price
        let n = NumberFormatter()
        n.locale = Locale.current
        n.numberStyle = .currency
        let price: UILabel = UILabel(frame: CGRect(x: 5, y: 25, width: 300, height: 20))
        price.textAlignment = .left
        price.textColor = .black
        price.font = price.font.withSize(24.0)
        price.text = n.string(from: movies[id].trackPrice as! NSNumber)
        single_app_view.addSubview(price)
        
        if (movies[id].artworkUrl100 != nil) {
            // show the thumbnail
            let img: UIImageView = UIImageView(frame: CGRect(x: 5, y: 80, width: 100, height: 100))
            
            // setup the request
            let req_url = URL(string: movies[id].artworkUrl100!)
            print(req_url)
            var request = URLRequest(url: req_url!);
            
            // set the method
            request.httpMethod = "GET";
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            async_urlsession = session.dataTask(with: request) { data, response, error in
                let httpResponse = response as? HTTPURLResponse
                if (httpResponse == nil || data == nil) {
                    // this will happen when the request is cancelled
                    // or there is a failure with the request
                    return
                }
                if (200...299).contains(httpResponse!.statusCode) {
                    // good response
                    DispatchQueue.main.async {
                        let th = UIImage(data: data!)
                        
                        img.frame.size.width = (th?.size.width)!
                        img.frame.size.height = (th?.size.height)!
                        
                        img.image = th
                        
                        self.single_app_view.addSubview(img)
                    }
                }
                
            }
            
            async_urlsession?.resume()
            
        }
        
        //let asset = AVURLAsset.init(url: URL.init(string: movies[id].previewUrl!)!)
        //let item = AVPlayerItem(asset: asset)
        //let player = AVPlayer(playerItem: item)
        print(movies[id].previewUrl)
        let player = AVPlayer(url: URL.init(string: movies[id].previewUrl!)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        playerViewController.view.frame.origin.x = 5
        playerViewController.view.frame.origin.y = 190
        playerViewController.view.frame.size.width = 320
        playerViewController.view.frame.size.height = 240
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController?.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        
        player.play()
        
        single_app_view.isHidden = false
        
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        // single_app_view was tapped, hide it
        single_app_view.isHidden = true
    }

    @IBOutlet weak var colview_apps: UICollectionView!
    @IBOutlet weak var search_field: UITextField!
    @IBOutlet weak var single_app_view: UIView!
    let api: rest_api = rest_api()
    
    // this is called when a character is typed into the text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // textField.text and string can be concatenated to get the text field value
        //print(textField.text! + string)
        
        // then we can get the movies
        get_movies(term: textField.text! + string)
        
        // need to return true otherwise iOS ignores the most recent character
        return true
    }
    
    var get_movies_urlsession: URLSessionDataTask? = nil
    func get_movies(term: String = "") {
        
        if (term == "") {
            // no need to search
            return
        }
        
        if (get_movies_urlsession != nil) {
            get_movies_urlsession?.cancel()
        }
        
        get_movies_urlsession = (api.get_request_async(endpoint: "search", args: ["term":term]) {
            (err: Bool, d: Data) in
            if (err) {
                
                // need to do this only if 404, check from Data for http response code
                var code = String(data: d, encoding: .utf8)!;
                
                print("error " + code)
                
                return;
            }
            
            // now parse d to rest_api.get_request_resp
            // and place the movies in movies
            let decoder = JSONDecoder()
            do {
                let nt = try decoder.decode(rest_api.result.self, from: d)
                
                //print(nt)
                movies = nt.results!
                print("got " + String(movies.count) + " new movies")
                
                DispatchQueue.main.async {
                    self.colview_apps.reloadData()
                }
                
            } catch {
                print("error decoding data from rest api")
                print(error)
            }
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        colview_apps.dataSource = self
        colview_apps.delegate = self
        search_field.delegate = self
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        single_app_view.addGestureRecognizer(tapper)
        
        colview_apps.reloadData()
    }


}

