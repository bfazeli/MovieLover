//
//  MovieStoreAPIError.swift
//  MovieLover
//
//  Created by Bijan_Fazeli on 9/27/19.
//  Copyright © 2019 Fazeli, Bijan. All rights reserved.
//

import Foundation

enum MovieStoreAPIError: Error, LocalizedError {
  case urlError(URLError)
  case responseError(Int)
  case decodingError(DecodingError)
  case genericError
  
  var localizedDescription: String {
    switch self {
    case .urlError(let error):
      return error.localizedDescription
    case .decodingError(let error):
      return error.localizedDescription
    case .responseError(let status):
      return "Bad response code: \(status)"
    case .genericError:
      return "An unknown error has occured "
    }
  }
}
