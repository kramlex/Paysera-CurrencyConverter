//
//  APIRouter.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import Alamofire
import Foundation
import RxSwift

private struct Constants {
    enum HttpHeaderField: String {
        case authentication = "Authorization"
        case contentType = "Content-Type"
        case acceptType = "Accept"
        case acceptEncoding = "Accept-Encoding"
    }
    
    enum ContentType: String {
        case json = "application/json"
    }
}


protocol APIRouter: URLRequestConvertible {
  var baseUrl: String { get }
  var method: HTTPMethod { get }
  var path: String { get }
  var parameters: Parameters? { get }
}

extension APIRouter {
  
  var parameters: Parameters? { nil }
  
  //MARK: - URLRequestConvertible
  func asURLRequest() throws -> URLRequest {
    let url = try baseUrl.asURL()
    
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    
    urlRequest.httpMethod = method.rawValue
    
    urlRequest.setValue(Constants.ContentType.json.rawValue, forHTTPHeaderField: Constants.HttpHeaderField.acceptType.rawValue)
    urlRequest.setValue(Constants.ContentType.json.rawValue, forHTTPHeaderField: Constants.HttpHeaderField.contentType.rawValue)
    
    let encoding: ParameterEncoding = {
      switch method {
      case .get:
        return URLEncoding.default
      default:
        return JSONEncoding.default
      }
    }()
    
    return try encoding.encode(urlRequest, with: parameters)
  }
}

func sendRequest<T: Codable> (_ router: APIRouter) -> Observable<T> {
  return Observable<T>.create { observer in
    let request = AF.request(router).responseDecodable { ( response: DataResponse<T, AFError>) in
      switch response.result {
      case .success(let value):
        observer.onNext(value)
      case .failure(let error):
        observer.onError(error)
      }
    }
    
    return Disposables.create {
      request.cancel()
    }
  }
}
