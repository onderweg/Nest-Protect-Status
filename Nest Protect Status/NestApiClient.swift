//
//  NestApiClient.swift
//  Nest Protect Status

import Foundation

typealias NestDevices = [String: NestDevice]

// Note: assigning default values to properties won't work:
// it won't get value from JSON, because property is immutable and already has a value set.
// See: https://forums.swift.org/t/revisit-synthesized-init-from-decoder-for-structs-with-default-property-values/12296/2
struct NestDevice : Decodable {
    let device_id: String
    let name : String
    let name_long : String
    let is_online: Bool
    let ui_color_state: String
    let battery_health: String // "ok", "replace"
    let co_alarm_state: String // "ok", "warning", "emergency"
    let smoke_alarm_state: String // "ok", "warning", "emergency"
    let is_manual_test_active: Bool
    let last_connection: Date
}

extension URLSession {
    func dataTask(with request: URLRequest, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: request) { (data, response, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let response = response, let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                result(.failure(error))
                return
            }
            result(.success((response, data)))
        }
    }
}

public enum RESTError : Error {
    case NoInternet
    case HTTPError(statusCode: Int)
    case RequestError(url: URL, message: String)
    case SerializationError
    
    var description: String {
        switch self {
        case .NoInternet:
            return "There is no internet connection."
        case .HTTPError(let statusCode):
            return "Request failed with HTTP status code \(statusCode)."
        case .RequestError(let url, let message):
            return "Request to \(url.host!) failed with message \"\(message)\"."
        default:
            return "An error occured"
        }
    }
}

fileprivate struct Constants {
    static let baseUrl: String = "https://developer-api.nest.com"
}

class NestApiClient {
    
    private let accessKey: String
    
    init(accessKey: String) {
        self.accessKey = accessKey
    }
    
    func callAPI<T: Decodable>(url: URL, callback: @escaping (Result<T, RESTError>) -> Void){
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // @TODO: URLSession refuses to send "Authorization header
        // Using url parameter with acess key for now
        //request.setValue("Bearer \(accessKey)", forHTTPHeaderField: "Authorization")
        request.url = request.url?.appending("auth", value: accessKey)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { (result) in
            switch result {
            case .success(let response, let data):                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0;
                guard 200..<299 ~= statusCode else {
                    callback(.failure(RESTError.HTTPError(statusCode: statusCode) ))
                    return
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    callback(.success(decoded))
                } catch {
                    callback(.failure(.SerializationError))
                }
                break
            case .failure(let error):
                callback(.failure(RESTError.RequestError(url: url, message: error.localizedDescription)));
                break
            }
        };
        task.resume()
    }
    
    func getProtectDevices(callback: @escaping (Result<NestDevices, RESTError>) -> Void) -> Void {
        let url = "\(Constants.baseUrl)/devices/smoke_co_alarms"
        self.callAPI(url: URL(string: url)!, callback: callback)
    }
}
