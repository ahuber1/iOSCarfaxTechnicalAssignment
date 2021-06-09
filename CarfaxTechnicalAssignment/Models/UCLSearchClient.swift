//
//  UCLSearchClient.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/6/21.
//

import Foundation

/// A utility that pulls listings from UCL.
class UCLSearchClient {
        
    enum Error: Swift.Error {
        case unknownAPIResponse
    }
    
    private let url = "https://carfax-for-consumers.firebaseio.com/assignment.json"
    
    
    /// Pulls listings from UCL asynchronously and invokes the completion handler with the results upon completion.
    /// - Parameter completion: The completion handler to invoke after listings were pulled from UCL asynchronously.
    func pullListings(_ completion: @escaping (Result<UCLSearchResponse, Swift.Error>) -> Void) {
        URLSession.shared.dataTask(with: URLRequest(url: URL(string: url)!)) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard
                (response as? HTTPURLResponse) != nil,
                let data = data
            else {
                completion(.failure(Error.unknownAPIResponse))
                return
            }
                        
            do {
                let uclResponse = try JSONDecoder().decode(UCLSearchResponse.self, from: data)
                completion(.success(uclResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
