//
//  MovieService.swift
//  MovieLover
//
//  Created by Bijan_Fazeli on 9/27/19.
//  Copyright © 2019 Fazeli, Bijan. All rights reserved.
//

import Foundation
import Combine

protocol MovieService {
  func fetchMovies(from endpoint: Endpoint) -> Future<[Movie], MovieStoreAPIError>
  func searchMovies(query: String) -> Future<[Movie], MovieStoreAPIError>
//  func fetchMovie(with id: Int) -> Future<Movie, MovieStoreAPIError>
}

public enum Endpoint: String, CustomStringConvertible, CaseIterable {
  case nowPlaying = "now_playing"
  case upcoming
  case popular
  case search
  case topRated = "top_rated"
  
  public var description: String {
    switch self {
    case .nowPlaying: return "Now Playing"
    case .upcoming: return "Upcoming"
    case .popular: return "Popular"
    case .topRated: return "Top Rated"
    case .search: return "Search"
    }
  }
  
  public init?(index: Int) {
    switch index {
    case 0: self = .nowPlaying
    case 1: self = .popular
    case 2: self = .upcoming
    case 3: self = .search
    case 4: self = .topRated
    default: return nil
    }
  }
  
  public init?(description: String) {
    guard let first = Endpoint.allCases.first(where: {$0.description == description}) else {
      return nil
    }
    
    self = first
  }
}
