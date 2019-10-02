//
//  ViewController.swift
//  MovieLover
//
//  Created by Bijan_Fazeli on 9/26/19.
//  Copyright © 2019 Fazeli, Bijan. All rights reserved.
//

import UIKit
import Combine

private enum Constant {
  static let apiUrl: String = "https://api.themoviedb.org/3/movie/550?api_key=052e93f8d62666d3939e11da808af0a7"
}

fileprivate enum Section {
  case main
}

class MainViewController: UITableViewController {
  
  let searchController: UISearchController = UISearchController(searchResultsController: nil)
//  var subscriber: Any?
  
  fileprivate var diffableDataSource: UITableViewDiffableDataSource<Section, Movie>!
  private var subscriptions = Set<AnyCancellable>()
  var movieAPI = MovieStore.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    setupSearchBarListeners()
    navigationItem.searchController = searchController
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.title = "Search Movies"
    
    searchController.obscuresBackgroundDuringPresentation = false
    
    setupTableView()
    fetchMovies()
  }
  
  fileprivate func setupSearchBarListeners() {
    let publisher = NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: searchController.searchBar.searchTextField)
    
    _ = publisher.map {
      ($0.object as! UISearchTextField).text
    }
    .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
    .removeDuplicates()
    .sink {
      guard let searchText = $0 else { return }
      let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
      guard let _ = trimmedText.first else { return }
    
      self.searchMovies(query: trimmedText)
    }
  }
  
  private func searchMovies(query: String) {
    self.movieAPI.searchMovies(query: query)
      .sink(receiveCompletion: { [unowned self](completion) in
        if case let .failure(error) = completion {
          self.handleError(apiError: error)
        }
        }, receiveValue: {[unowned self] (result) in
          self.generateSnapshot(with: result)
        })
      .store(in: &self.subscriptions)
  }
  
  private func fetchMovies() {
    // TODO: Implement Fetch Movies
    self.movieAPI.fetchMovies(from: .nowPlaying)
      .sink(receiveCompletion: { [unowned self] (completion) in
        if case let .failure(error) = completion {
          self.handleError(apiError: error)
        }
        }, receiveValue: {[unowned self] in self.generateSnapshot(with: $0)})
      .store(in: &self.subscriptions)
    
  }
  
  private func setupTableView() {
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    diffableDataSource = UITableViewDiffableDataSource<Section, Movie>(tableView: tableView, cellProvider: { (tableView, indexPath, movie) -> UITableViewCell? in
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
      cell.textLabel?.text = movie.title
      
      return cell
    })
  }
  
  private func generateSnapshot(with movies: [Movie]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
    snapshot.appendSections([.main])
    snapshot.appendItems(movies)
    diffableDataSource.apply(snapshot, animatingDifferences: true)
  }
  
  func handleError(apiError: MovieStoreAPIError) {
    let alertController = UIAlertController(title: "Error", message: apiError.localizedDescription, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    present(alertController, animated: true)
  }

}

fileprivate extension UIActivityIndicatorView {
  var combine_isAnimating: Bool {
    set {
      if newValue {
        startAnimating()
      } else {
        stopAnimating()
      }
    }
    
    get {
      return isAnimating
    }
  }
}

