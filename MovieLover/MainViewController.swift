//
//  ViewController.swift
//  MovieLover
//
//  Created by Bijan_Fazeli on 9/26/19.
//  Copyright © 2019 Fazeli, Bijan. All rights reserved.
//

import UIKit

private enum Constant {
  static let apiUrl: String = "https://api.themoviedb.org/3/movie/550?api_key=052e93f8d62666d3939e11da808af0a7"
}

class MainViewController: UITableViewController {
  
  let searchController: UISearchController = UISearchController(searchResultsController: nil)
  var subscriber: Any?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    setupSearchBarListeners()
    navigationItem.searchController = searchController
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.title = "Search Movies"
    
    searchController.obscuresBackgroundDuringPresentation = false
  }
  
  fileprivate func setupSearchBarListeners() {
    let publisher = NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: searchController.searchBar.searchTextField)
    
    subscriber = publisher.map {
      ($0.object as! UISearchTextField).text
    }
    .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
    .sink {
      guard let queryText = $0 else { return }
      self.searchMovies(query: queryText)
    }
//    subscriber = publisher.sink {
//      guard let searchTextField = $0.object as? UISearchTextField else { return }
//      print(searchTextField.text)
//    }
  }
  
  private func searchMovies(query: String) {
    
  }

}

