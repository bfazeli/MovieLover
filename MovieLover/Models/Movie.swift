//
//  Movie.swift
//  MovieLover
//
//  Created by Bijan_Fazeli on 9/26/19.
//  Copyright © 2019 Fazeli, Bijan. All rights reserved.
//

import Foundation

public struct MovieResponse: Codable {
  public let page: Int
  public let totalResults: Int
  public let totalPages: Int
  public let results: [Movie]
}

public struct Movie: Codable, Equatable, Hashable {
  public let id: Int
  public let backdropPath: String?
  public let posterPath: String?
  public let overview: String
  public let releaseDate: Data
  public let voteAverage: Double
  public let voteCount: Int
  public let tagline: String?
  public let genres: [MovieGenre]?
  public let videos: MovieVideoResponse?
  public let credits: MovieCreditResponse?
  public let adult: Bool
  public let runtime: Int?
  public var posterURL: URL {
    return URL(string: "https://image.tmdb.org/t/p/q500\(posterPath ?? "")")!
  }
  
  public var voteAveragePercentText: String {
    return "\(Int(voteAverage * 10))%"
  }
  
  public var ratingText: String {
    let rating = Int(voteAverage)
    let ratingText = (0..<rating).reduce("") { (accumulator, _) -> String in
      return accumulator + "⭐️"
    }
    
    return ratingText
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
  
  public static func == (lhs: Movie, rhs: Movie) -> Bool {
    return lhs.id == rhs.id
  }
}

public struct MovieGenre: Codable {
  public let results: [MovieVideo]
}

public struct MovieVideoResponse: Codable {
  public let results: [MovieVideo]
}

public struct MovieVideo: Codable {
  public let id: String
  public let key: String
  public let name: String
  public let site: String
  public let size: Int
  public let type: String
  
  public var youtubeURL: URL? {
    guard site == "YouTube" else {
      return nil
    }
    return URL(string: "Https://www.youtube.com/watch?v=\(key)")
  }
}

public struct MovieCreditResponse: Codable {
  public let cast: [MovieCast]
  public let crew: [MovieCrew]
}

public struct MovieCast: Codable {
  public let character: String
  public let name: String
}

public struct MovieCrew: Codable {
  public let id: Int
  public let department: String
  public let job: String
  public let name: String
}

