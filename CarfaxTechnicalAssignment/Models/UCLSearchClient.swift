//
//  ListingRetriever.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/6/21.
//

import Foundation

class UCLSearchClient {
    
    private let url = "https://carfax-for-consumers.firebaseio.com/assignment.json"
    
    enum Error: Swift.Error {
        case unknownAPIResponse
    }
    
    func pullListings(_ completion: @escaping (Result<UCLSearchResponse, Swift.Error>) -> Void) {
        URLSession.shared.dataTask(with: URLRequest(url: URL(string: url)!)) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard
                (response as? HTTPURLResponse) != nil,
                let data = data,
                let status = (response as? HTTPURLResponse)?.statusCode
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
