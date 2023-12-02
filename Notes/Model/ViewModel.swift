//
//  ViewModel.swift
//  Notes
//
//  Created by JoyDev on 29.11.2023.
//

import Foundation

protocol ViewModelProtocol: AnyObject {
    var dataStorage: [UserDTO] { get }
    var updator: () -> Void { get set }
    func loadMore()
    func reload()
    func saveUser(login: String, email: String, password: String)
}

final class ViewModel: ViewModelProtocol {
    var dataStorage: [UserDTO] = []
    var updator: () -> Void = {}
    private var totalPages: Int = 0
    private var currentPage: Int = 0
    private let session = URLSession.shared

    func loadMore() {
        currentPage += 1
        fetchUsers(page: currentPage)
    }
    
    func reload() {
        currentPage = 1
        fetchUsers(page: currentPage)
    }
    
    private func fetchUsers(page: Int) {
        let url = URL(string: "https://myurl/users")!

        let task = session.dataTask(with: url) { [weak self] data, response, error in

            if error != nil || data == nil {
                print("Client error!")
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            guard let jsonData = data else {
                print("Response Data is empty")
                return
            }
                        
            let decoder = JSONDecoder()
            let responseDecoded = try? decoder.decode(UsersResponse.self, from: jsonData)
            
            guard let decodedResponse = responseDecoded else {
                print("Unable to parse data from response")
                return
            }
            
            DispatchQueue.main.async {
                self?.dataStorage = decodedResponse.data.map { UserDTO(from: $0) }
                self?.updator()
            }
        }

        task.resume()
    }
    
    func saveUser(login: String, email: String, password: String) {
        guard let url = URL(string: "https://myurl/users") else {
            print("Invalid URL")
            return
        }
        
        let parameters = ["login": login, "email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error encoding parameters: \(error.localizedDescription)")
            return
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error saving user: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Invalid status code: \(httpResponse.statusCode)")
                return
            }
            
            print("User saved successfully")
            
        }
        
        task.resume()
    }
}

