//
//  SearchTweetsVC.swift
//  TwitterSearch
//
//  Created by Tarun Bhargava on 28/12/18.
//  Copyright © 2018 searchTwitter. All rights reserved.
//

import UIKit

class SearchTweetsVC: UITableViewController,UISearchBarDelegate {
    
    private let tweetCellReuseId = "TweetCellReuseIdentifier"
    private let topCellReuseId = "TopCellReuseIdentifier"
    private let sortCellReuseId = "sortCellReuseIdentifier"
    private var currentSearchKey : String = ""
    var promptShown = false
  //  private var topCellText : String = "Start Typing to Search Tweets"
    var tweetStore : TweetStore?
    var imageCache :ImageCache = ImageCache.init()
    var favImage = UIImage(named: "heartIconClearBackgorund1")?.resizeImage(targetSize: CGSize(width: 30, height: 30))
    var retweetImage = UIImage(named: "RetweetClearBackground")?.resizeImage(targetSize: CGSize(width: 25, height: 25))
    
   var profileImage = UIImage(named: "DefaultPerson")?.resizeImage(targetSize: CGSize(width: 40, height: 40))


//retweet_count, favorite_count
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search Tweets"
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload(_:)), name: Notification.Name("com.searchNews.updateTable"), object: nil)

    }
    
    @objc func reload(_ notification:Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    
    private func sendHeightWithNumberOfLines(str:String?) -> CGFloat {
        if let validStr = str {
            var count = 0
            validStr.enumerateLines(invoking: {
                (str,stop) in
                 count += 1
            })
            let addition = count > 5 ? 100 : count*20
            return CGFloat(integerLiteral: 100 + addition)
        }
        return CGFloat(integerLiteral: 100)
    }
    
}




//MARK:- Tableviewdelegate methods

extension SearchTweetsVC  {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let store = tweetStore {
            if store.numberOfTweets() > 0 {
                return store.numberOfTweets() + 1 + (store.sortedByPopularity ? 0 : 1)
            }
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: topCellReuseId, for: indexPath) as? TopCell
            if let store = tweetStore{
                if store.numberOfTweets() > 0 {
                    var str = !store.endReched ? "Load More Recent Results" : "No more results to show"
                    if store.sortedByPopularity {
                        str = "Sorted by popularity"
                    }
                    cell?.cellLabel?.text = str
                    cell?.isUserInteractionEnabled = !store.endReched ?(store.sortedByPopularity ? false : true) : false
                } else {
                    cell?.cellLabel?.text = "No tweets matching keyword"
                    cell?.isUserInteractionEnabled = false
                }
            } else{
               cell?.cellLabel?.text = "Start Typing to Search Tweets"
               cell?.isUserInteractionEnabled = false
            }
            return cell!
        }
      
        guard
            let store = tweetStore else {
                return UITableViewCell.init(frame: .zero)
        }

        
        if(indexPath.row == 1) {
            if !store.sortedByPopularity {
              let cell = tableView.dequeueReusableCell(withIdentifier: sortCellReuseId, for: indexPath)
              return cell
            }
        }
        
        let index = indexPath.row - (tableView.numberOfRows(inSection: 0) - store.numberOfTweets())
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetCellReuseId, for: indexPath)
        if let validCell = cell as? TweetCell {
            validCell.favCountLabel?.text = store.getFavCountString(index: index)
            validCell.retweetCountLabel?.text = store.getRetweetCountString(index: index)
            validCell.favImageView?.image = favImage
            validCell.retweetImageView?.image = retweetImage
            validCell.handleLabel?.text = store.getHandleLabelString(index: index)
            validCell.tweetTextLabel?.text = store.getTweetTextString(index: index)
            validCell.nameLabel?.text = store.getNameLabelString(index: index)
            validCell.profileImageView?.image = profileImage
          //  validCell.tweetTextLabel?.text.enumera
            guard let str = store.getImageUrl(index : index) else {
                return validCell
            }
            
            let cacheid = store.getCacheIndexingKey(index: index)
            
            switch(store.getImageCacheState(index: index)) {
            case .failed:
                print("Failed for \(index) URL:::  \(str)")
            case .loading:
                print("Loading for \(index)")
            case .loaded:
                if let image = self.imageCache.getImage(forKey: cacheid) {
                    validCell.profileImageView?.image = image
                }
                else{
                    fallthrough
                }
            case .unknown:
                store.setImageCacheState(state: .loading, index: index)
                validCell.profileImageView?.loadImageForItem(url: str, handler: {
                (data,error) in
                  DispatchQueue.main.async {
                    var failed = true
                    if error == nil {
                        if let validData = data , !validData.isEmpty {
                            if let imageObj = UIImage(data: validData) {
                                if let resizedImage = imageObj.resizeImage(targetSize :CGSize(width: 40, height: 40)) {
                                    if let visibleCell = self.tableView.cellForRow(at: indexPath) as? TweetCell {
                                        visibleCell.profileImageView?.image =  resizedImage
                                    }
                                    failed = false
                                    store.setImageCacheState(state: .loaded, index: index)
                                    self.imageCache.setImage(resizedImage, forKey: cacheid)
                                }
                            }
                        }
                    }
                    if failed {
                        store.setImageCacheState(state: .failed, index: index)
                    }
                 }
                })
            }
            
            
            return validCell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let store = tweetStore else {
            return 50
        }
        
        if(indexPath.row == 0 || (indexPath.row == 1 && !store.sortedByPopularity)) {
                return 50
        }
        return  120/* sendHeightWithNumberOfLines(str : tweetStore?.getTweetTextString(index: indexPath.row))*/
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
        if let store = tweetStore {
            let cell = tableView.cellForRow(at: indexPath) as? TopCell
            if store.numberOfTweets() != 0 {
                cell?.cellLabel?.text = store.sortedByPopularity ? "Sorted by Popularity": "Fetching"
                cell?.isUserInteractionEnabled = false
                if !store.sortedByPopularity {
                  store.fetchPageResults()
                }
            }
            else {
                //there is a tweeStore implying valid search keyword but no results
                cell?.isUserInteractionEnabled = false
            }
            
            }
            return
         }
        
        guard let store = tweetStore else {
            return
        }
        
        var index = indexPath.row
        if store.sortedByPopularity {
            index -= 1
        } else {
            if index == 1 {
                store.sortByPopularity()
                return
            }
            else {
                index -= 2
            }
        }
        
       
        if !promptShown {
         let alert =  UIAlertController.init(title: "Login once with your twitter credentials,when prompted, for continued access", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: {
                action in
                  if let webVC =  self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as? WebViewVC {
                      webVC.url = store.getTweetUrl(index: index)
                    self.navigationController?.pushViewController(webVC, animated: true)
                }
            }))
            self.present(alert, animated: true, completion: {
                self.promptShown = true
            })
        }
        else {
            if let webVC =  self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as? WebViewVC {
                webVC.url = store.getTweetUrl(index: index)
                self.navigationController?.pushViewController(webVC, animated: true)
            }
        }

        
    }
}

//MARK:- SearchBar delegate methods


extension SearchTweetsVC {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing*** -- \(String(describing: searchBar.text))")
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       // print("textDidChange*** -- \(String(describing: searchText))")
        if let keyword = searchBar.text {
           currentSearchKey = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            if currentSearchKey.isEmpty {
                
            }
            else {
                //TODO : Show Spinner
                tweetStore = TweetStore(searchTerm:currentSearchKey)
             }
        }
    }
}
