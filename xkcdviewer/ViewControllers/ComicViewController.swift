//
//  ComicViewController.swift
//  xkcdviewer
//
//  Created by Dipro on 6/14/23.
//  Copyright © 2023 TheRedSpecial. All rights reserved.
//

import UIKit

class ComicViewController: UIViewController {

    private let imageView: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let altLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .medium)
        } else {
            indicator = UIActivityIndicatorView(style: .gray)
        }
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        setupViews()
        fetchComicData()
    }
        
    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(altLabel)
        view.addSubview(numberLabel)
        view.addSubview(saveButton)
        view.addSubview(loadingIndicator)
        view.addSubview(errorMessageLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        altLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            altLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            altLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            altLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            altLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            numberLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            numberLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            errorMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchComicData() {
        loadingIndicator.startAnimating()
        
        guard let url = URL(string: "https://xkcd.com/info.0.json") else {
            showErrorMessage("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
            }
            
            guard let data = data, error == nil else {
                let errorMessage = error?.localizedDescription ?? "Failed to fetch data"
                self?.showErrorMessage(errorMessage)
                return
            }
            
            do {
                let comic = try JSONDecoder().decode(Comic.self, from: data)
                DispatchQueue.main.async {
                    self?.displayComic(comic)
                }
            } catch {
                let errorMessage = error.localizedDescription
                self?.showErrorMessage(errorMessage)
            }
        }
        task.resume()
    }
    
    private func displayComic(_ comic: Comic) {
        titleLabel.text = comic.title
        altLabel.text = comic.alt
        numberLabel.text = "Comic \(comic.num)"
        
        if let imageURL = URL(string: comic.img) {
            DispatchQueue.global().async { [weak self] in
                if let imageData = try? Data(contentsOf: imageURL),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessageLabel.text = message
        errorMessageLabel.isHidden = false
    }
    
    @objc private func didTapSaveButton() {
        guard let image = imageView.image else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func saveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully")
        }
    }
}
