import Foundation

extension URL {
    func appendingQueryItem(name: String, value: String) -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        
        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(URLQueryItem(name: name, value: value))
        urlComponents.queryItems = queryItems
        
        return urlComponents.url ?? self
    }
}

class RadioService {
    private var apiURL: URL?

    init() {
        resolveAPIServer()
    }

    private func resolveAPIServer(retryCount: Int = 0) {
        let maxRetries = 3
        let url = URL(string: "https://all.api.radio-browser.info/json/servers")!
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("🔴 FAILED TO FETCH SERVER LIST: \(error.localizedDescription)")
                if retryCount < maxRetries {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(retryCount + 1)) {
                        self?.resolveAPIServer(retryCount: retryCount + 1)
                    }
                } else {
                    print("🔴 MAX RETRIES REACHED - Using fallback server")
                    DispatchQueue.main.async {
                        self?.apiURL = URL(string: "https://de1.api.radio-browser.info")
                    }
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("🔴 INVALID HTTP RESPONSE")
                if retryCount < maxRetries {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(retryCount + 1)) {
                        self?.resolveAPIServer(retryCount: retryCount + 1)
                    }
                }
                return
            }
            
            guard let data = data else {
                print("🔴 NO DATA RECEIVED FOR SERVER LIST")
                if retryCount < maxRetries {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(retryCount + 1)) {
                        self?.resolveAPIServer(retryCount: retryCount + 1)
                    }
                }
                return
            }
            
            do {
                let servers = try JSONDecoder().decode([Server].self, from: data)
                guard let server = servers.first else {
                    print("🔴 NO SERVERS IN RESPONSE")
                    DispatchQueue.main.async {
                        self?.apiURL = URL(string: "https://de1.api.radio-browser.info")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self?.apiURL = URL(string: "https://\(server.name)")
                    print("✅ USING API SERVER: \(server.name)")
                }
            } catch {
                print("🔴 JSON DECODE ERROR: \(error.localizedDescription)")
                if retryCount < maxRetries {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(retryCount + 1)) {
                        self?.resolveAPIServer(retryCount: retryCount + 1)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.apiURL = URL(string: "https://de1.api.radio-browser.info")
                    }
                }
            }
        }.resume()
    }

    private struct Server: Decodable {
        let name: String
    }

    func fetchAllStations(completion: @escaping (Result<[RadioStation], Error>) -> Void) {
        guard let apiURL = apiURL else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.fetchAllStations(completion: completion)
            }
            return
        }

        let url = apiURL.appendingPathComponent("json/stations/search")
            .appendingQueryItem(name: "limit", value: "100")
            .appendingQueryItem(name: "order", value: "votes")
            .appendingQueryItem(name: "reverse", value: "true")
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15.0
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("RadioLead-WatchApp/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "RadioService", code: statusCode, 
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(statusCode)"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "RadioService", code: -1, 
                                  userInfo: [NSLocalizedDescriptionKey: "No data received"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            do {
                let stations = try JSONDecoder().decode([RadioStation].self, from: data)
                let filteredStations = stations.filter { !$0.name.isEmpty && !$0.url_resolved.isEmpty }
                DispatchQueue.main.async {
                    completion(.success(filteredStations))
                }
            } catch {
                print("🔴 JSON DECODE ERROR: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
