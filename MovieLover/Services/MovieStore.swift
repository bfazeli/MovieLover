//
//  MovieStore.swift
//  MovieLover
//
//  Created by Bijan_Fazeli on 9/28/19.
//  Copyright © 2019 Fazeli, Bijan. All rights reserved.
//

import Foundation
import Combine

public class MovieStore: MovieService {
  
  public static let shared = MovieStore()
  private init() {}
  private let apiKey = "052e93f8d62666d3939e11da808af0a7"
  private let baseAPIURL = "https://api.themoviedb.org/3"
  private let urlSession = URLSession.shared
  private var subscriptions = Set<AnyCancellable>()
  
  private let jsonDecoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-mm-dd"
    jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    
    return jsonDecoder
  }()
  
  func searchMovies(query: String) -> Future<[Movie], MovieStoreAPIError> {
    return Future<[Movie], MovieStoreAPIError> { [unowned self] promise in
      guard let url = self.generateURL(with: .search, and: ["query":query, "page":"1"]) else {
        return promise(.failure(.urlError(URLError(URLError.unsupportedURL))))
      }
      print(url.absoluteString)
      self.urlSession.dataTaskPublisher(for: url)
        .tryMap { (data, response) -> Data in
          guard let httpResponse = response as? HTTPURLResponse,
            200...299 ~= httpResponse.statusCode else {
              throw MovieStoreAPIError.responseError((response as? HTTPURLResponse)?.statusCode ?? 500)
          }
          print(response)
          return  data
      }
      .decode(type: MoviesResponse.self, decoder: self.jsonDecoder)
      .receive(on: RunLoop.main)
      .sink(receiveCompletion: { (completion) in
        if case let .failure(error) = completion {
          switch error {
          case let urlError as URLError:
            promise(.failure(.urlError(urlError)))
          case let decodingError as DecodingError:
            promise(.failure(.decodingError(decodingError)))
          case let apiError as MovieStoreAPIError:
            promise(.failure(apiError))
          default:
            promise(.failure(.genericError))
          }
        }
      }, receiveValue: {promise(.success($0.results))})
        .store(in: &self.subscriptions)
    }
  }
  
  func fetchMovies(from endpoint: Endpoint) -> Future<[Movie], MovieStoreAPIError> {
    // Init and returning a future of movies
    return Future<[Movie], MovieStoreAPIError> { [unowned self] promise in
      guard let url = self.generateURL(with: endpoint) else {
        return promise(.failure(.urlError(URLError(URLError.unsupportedURL))))
      }
      
      // Using URLSession Datatask Publisher to fetch data from URL
      self.urlSession.dataTaskPublisher(for: url)
        .tryMap { (data, response) -> Data in   // Trymap to chain publishers (transforming publishers)
          guard let httpResponse = response as? HTTPURLResponse,
            200...299 ~= httpResponse.statusCode else {
              throw MovieStoreAPIError.responseError((response as? HTTPURLResponse)?.statusCode ?? 500)
          }
          
          return data
      }
        .decode(type: MoviesResponse.self, decoder: self.jsonDecoder)    // Decode data into model
        .receive(on: RunLoop.main)  // scheduling recieved values from publisher to run on main
        .sink(receiveCompletion: { (completion) in  // Subscribed to published through sink
          if case let .failure(error) = completion {  // Invoked after publisher finishes publishing a val
            switch error {
            case let urlError as URLError:
              promise(.failure(.urlError(urlError)))
            case let decodingError as DecodingError:
              promise(.failure(.decodingError(decodingError)))
            case let apiError as MovieStoreAPIError:
              promise(.failure(apiError))
            default:
              promise(.failure(.genericError))
            }
          }   // Invoked when subscription recieves a new value from the publisher
        }, receiveValue: {promise(.success($0.results))})
        .store(in: &self.subscriptions)
    }
  }
  
  func generateURL(with endpoint: Endpoint, and queryParams: [String:String]? = nil) -> URL? {
    
    guard let urlComponents = generateComponent(with: endpoint)
      else { return nil }
    
    var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
    if let items = queryParams {
      for (key, val) in items {
        queryItems.append(URLQueryItem(name: key, value: val))
      }
    }
    
    urlComponents.queryItems = queryItems
    
    return urlComponents.url
  }
  
  func generateComponent(with endpoint: Endpoint) -> NSURLComponents? {
    switch endpoint {
    case .search:
      return NSURLComponents(string: "\(baseAPIURL)/search/movie")
    default:
      return NSURLComponents(string: "\(baseAPIURL)/movie/\(endpoint.rawValue)")
    }
  }
}
