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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    navigationItem.searchController = searchController
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.title = "Search Movies"
    
    searchController.obscuresBackgroundDuringPresentation = false
  }


}

