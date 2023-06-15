//
//  SearchViewController.swift
//  xkcdviewer
//
//  Created by Dipro on 6/14/23.
//  Copyright © 2023 TheRedSpecial. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    private let numberTextField: UITextField = {
           let textField = UITextField()
           textField.placeholder = "Enter comic number"
           textField.keyboardType = .numberPad
           textField.borderStyle = .roundedRect
           return textField
    }()
       
       private let searchButton: UIButton = {
           let button = UIButton(type: .system)
           button.setTitle("Search", for: .normal)
           button.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
           return button
    }()
    
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
    
    private let saveButton: UIButton = {
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
    }
    
    private func setupViews() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        scrollView.addSubview(numberTextField)
        scrollView.addSubview(searchButton)
        scrollView.addSubview(imageView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(altLabel)
        scrollView.addSubview(loadingIndicator)
        scrollView.addSubview(errorMessageLabel)
        
        numberTextField.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        altLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            numberTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            numberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            numberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            searchButton.topAnchor.constraint(equalTo: numberTextField.bottomAnchor, constant: 16),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            altLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            altLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            altLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            altLabel.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            errorMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchComicData(for comicNumber: Int) {
        let urlString = "https://xkcd.com/\(comicNumber)/info.0.json"
        guard let url = URL(string: urlString) else {
            // Display error message for invalid URL
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            DispatchQueue.main.async {
                // Handle loading indicator or other UI updates
            }
            
            guard let data = data, error == nil else {
                let errorMessage = error?.localizedDescription ?? "Failed to fetch data"
                DispatchQueue.main.async {
                    self?.showErrorMessage(errorMessage)
                }
                return
            }
            
            do {
                let comic = try JSONDecoder().decode(Comic.self, from: data)
                DispatchQueue.main.async {
                    // Update UI to display the fetched comic
                    self?.displayComic(comic)
                }
            } catch {
                let errorMessage = error.localizedDescription
                DispatchQueue.main.async {
                    self?.showErrorMessage(errorMessage)
                }
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
    
    @objc private func didTapSearchButton() {
        guard let comicNumberText = numberTextField.text,
              let comicNumber = Int(comicNumberText) else {
            // Display error message for invalid input
            showErrorMessage("Invalid comic number")
            return
        }
        
        numberTextField.resignFirstResponder()
        fetchComicData(for: comicNumber)
    }
}
