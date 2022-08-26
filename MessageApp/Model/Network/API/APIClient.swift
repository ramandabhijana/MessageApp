//
//  APIClient.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 02/08/22.
//

import Foundation
import Alamofire
import RxSwift

struct TerrarestaAPIClient {
  private static let BASE_URL:  URL = URL(string: "https://terraresta.com")!
  
  static func performRequest<T: APIRequest>(_ request: T) -> Observable<T.Response> {
    var url = BASE_URL.appendingPathComponent(request.path)
    // Params
    if !request.params.isEmpty {
      var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
      urlComponents?.queryItems = request.params
      url = (urlComponents?.url)!
    }
    // URL Request
    var urlRequest = URLRequest(url: url)
    // ContentType
    urlRequest.addValue(request.contentType, forHTTPHeaderField: "Content-Type")
    // AdditionalHeaders
    request.additionalHeaders.forEach { key, value in
      urlRequest.addValue(value, forHTTPHeaderField: key)
    }
    // HTTP Method
    urlRequest.httpMethod = request.method.rawValue
    // HTTP Body
    urlRequest.httpBody = request.body
    
    return Observable<T.Response>.create { observer in
      AF.request(urlRequest)
        .response { response in
          guard let httpResponse = response.response,
                200..<300 ~= httpResponse.statusCode else {
            let statusCode = response.response?.statusCode ?? -1
            return observer.onError(APIError.requestFailed(statusCode: statusCode))
          }
          guard let data = response.data else {
            return observer.onError(APIError.noData)
          }
          do {
            let decodedData = try request.decode(data: data)
            observer.onNext(decodedData)
            observer.onCompleted()
          } catch APIError.badResponse(let response) {
            observer.onError(APIError.badResponse(response))
            observer.onCompleted()
          } catch {
            print("Catch error for request: \(request).\nError: \(error)")
            observer.onError(APIError.postProcessingFailed(error))
            observer.onCompleted()
          }
        }
      return Disposables.create()
    }
  }
}

protocol APIRequest {
  associatedtype Response
  
  var method: HTTPMethod { get }
  var path: String { get }
  var body: Data? { get }
  var contentType: String { get }
  var additionalHeaders: [String: String] { get }
  var params: [URLQueryItem] { get }
  
  func decode(data: Data) throws -> Response
}

enum HTTPMethod: String {
  case GET
  case POST
  case PUT
  case DELETE
}
