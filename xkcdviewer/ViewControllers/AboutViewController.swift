//
//  AboutViewController.swift
//  xkcdviewer
//
//  Created by Dipro on 6/14/23.
//  Copyright © 2023 TheRedSpecial. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "xkcd"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "by TheRedSpecial"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.textColor = .gray
        return label
    }()
    
    private var apiStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let siteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Open Site", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        
        button.addTarget(self, action: #selector(openWebsiteButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        setupViews()
        checkAPIStatus()
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(apiStatusLabel)
        view.addSubview(siteButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            apiStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            apiStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            siteButton.topAnchor.constraint(equalTo: apiStatusLabel.bottomAnchor, constant: 32),
            siteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            siteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            siteButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func checkAPIStatus() {
        let urlString = "https://xkcd.com/info.0.json"
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (_, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                DispatchQueue.main.async {
                    if statusCode == 200 {
                        self?.apiStatusLabel.text = "API Status: Online"
                    } else {
                        self?.apiStatusLabel.text = "API Status: Offline"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.apiStatusLabel.text = "Could not check API status"
                }
            }
        }
        task.resume()
    }
    
    @objc private func openWebsiteButtonTapped() {
        guard let websiteURL = URL(string: "https://xkcd.com/") else {
            return
        }
        UIApplication.shared.open(websiteURL, options: [:], completionHandler: nil)
    }
    
}

