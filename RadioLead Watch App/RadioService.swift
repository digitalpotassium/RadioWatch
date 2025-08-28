import Foundation

class RadioService {
    private var apiURL: URL?

    init() {
        resolveAPIServer()
    }

    private func resolveAPIServer() {
        let url = URL(string: "http://all.api.radio-browser.info/json/servers")!
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Failed to resolve API server.")
                return
            }
            if let servers = try? JSONDecoder().decode([Server].self, from: data), let server = servers.first {
                self?.apiURL = URL(string: "https://\(server.name)")
                print("Using API server: \(server.name)")
            }
        }.resume()
    }

    private struct Server: Decodable {
        let name: String
    }

    func fetchStations(countryCode: String = "US", completion: @escaping (Result<[RadioStation], Error>) -> Void) {
        guard let apiURL = apiURL else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Wait for server resolution
                self.fetchStations(countryCode: countryCode, completion: completion)
            }
            return
        }

        let url = apiURL.appendingPathComponent("json/stations/bycountrycodeexact/\(countryCode)")
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
                let stations = try JSONDecoder().decode([RadioStation].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(stations))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
