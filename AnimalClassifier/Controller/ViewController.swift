//
//  ViewController.swift
//  AnimalClassifier
//
//  Created by yauheni prakapenka on 15.11.2019.
//  Copyright © 2019 yauheni prakapenka. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    private var animalRecognitionRequest = VNRecognizeAnimalsRequest(completionHandler: nil)
    private let animalRecognitionWorkQueue = DispatchQueue(label: "PetClassifierRequest", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    // MARK: - Subview
    
    private lazy var catAndDogImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .clear
        image.image = #imageLiteral(resourceName: "cat-and-dog-select-default")
        image.contentMode = .scaleAspectFit
        
        return image
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "plus-button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var arButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "360-degrees"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(arButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var boosterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(boosterButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var dotsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "bag-active"), for: .normal)
        button.imageView?.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(dotsButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var selectedImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .clear
        image.contentMode = .scaleAspectFit
        
        return image
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 26, weight: .light)
        label.textColor = #colorLiteral(red: 0.7051772475, green: 0.4836726785, blue: 0.2945596576, alpha: 1)
        label.text = ""
        
        return label
    }()
    
    private lazy var aboutLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = #colorLiteral(red: 0.08396864682, green: 0.08843047172, blue: 0.2530170083, alpha: 1)
        label.text = "Об авторе"
        
        return label
    }()
    
    private lazy var boosterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = #colorLiteral(red: 0.08396864682, green: 0.08843047172, blue: 0.2530170083, alpha: 1)
        
        return label
    }()
    
    private lazy var addLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = #colorLiteral(red: 0.08396864682, green: 0.08843047172, blue: 0.2530170083, alpha: 1)
        label.text = "Добавить фото"
        
        return label
    }()
    
    private lazy var dotsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = #colorLiteral(red: 0.08396864682, green: 0.08843047172, blue: 0.2530170083, alpha: 1)
        label.text = "Выполнить задание"
        
        return label
    }()
    
    private lazy var backgroundImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .white
        image.image = #imageLiteral(resourceName: "cat-pattern")
        image.alpha = 0.08
        image.contentMode = .scaleAspectFill
        
        return image
    }()
    
    // MARK: - View lifecycle
    
    override func loadView() {
        self.view = UIView()
        
        view.backgroundColor = .white
        
        view.addSubview(backgroundImage)
        view.addSubview(catAndDogImageView)
        view.addSubview(selectedImageView)
        view.addSubview(resultLabel)
        view.addSubview(addButton)
        view.addSubview(arButton)
        view.addSubview(aboutLabel)
        view.addSubview(addLabel)
        view.addSubview(boosterButton)
        view.addSubview(boosterLabel)
        view.addSubview(dotsButton)
        view.addSubview(dotsLabel)
        
        makeConstraints()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        resultLabel.alpha = 0
        setupVision()
        
        setBoosterButtonAvailability()
        
        setBoosterLabelText()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    private func setupVision() {
        animalRecognitionRequest = VNRecognizeAnimalsRequest { (request, error) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNRecognizedObjectObservation] {
                    var detectionString = ""
                    for result in results {
                        let animals = result.labels
                        for animal in animals {
                            var animalLabel = ""
                            if animal.identifier == "Cat" {
                                animalLabel = "кот"
                                self.catAndDogImageView.image = #imageLiteral(resourceName: "cat-and-dog-select-cat")
                            } else {
                                animalLabel = "собака"
                                self.catAndDogImageView.image = #imageLiteral(resourceName: "cat-and-dog-select-dog")
                            }
                            // let string = "This is \(animal.identifier) \(animalLabel) confidence is \(animal.confidence)\n"
                            let string = "это \(animalLabel) "
                            detectionString = detectionString + string
                        }
                    }
                    
                    if detectionString.isEmpty {
                        detectionString = "Это не кот и не собака"
                    }
                    
                    self.resultLabel.text = detectionString
                    self.resultLabel.alpha = 1
                }
            }
        }
    }
    
    func processImage(_ image: UIImage) {
        selectedImageView.image = image
        animalClassifier(image)
    }
    
    private func animalClassifier(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        animalRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.animalRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.processImage(image)
            }
        }
    }
    
    private func mafeDefault() {
        catAndDogImageView.image = #imageLiteral(resourceName: "cat-and-dog-select-default")
        resultLabel.text = ""
        selectedImageView.image = nil
    }
}

// MARK: - Action

private extension ViewController {
    @objc
    func addButtonTapped() {
        mafeDefault()
        
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { [weak self] _ in
            self?.libraryButtonTapped()
        }))
        alert.addAction(UIAlertAction(title: "Unsplash", style: .default, handler: { [weak self] _ in
            self?.unsplashButtonTapped()
        }))
        alert.addAction(UIAlertAction(title: "Камера", style: .default, handler: { [weak self] _ in
            self?.cameraButtonTapped()
        }))
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc
    func dotsButtonTapped() {
        let vc = DotsViewController()
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    func libraryButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func unsplashButtonTapped() {
        let vc = PhotoCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let navigationVC = UINavigationController(rootViewController: vc)
        present(navigationVC, animated: true, completion: nil)
    }
    
    func cameraButtonTapped() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    private func setBoosterButtonAvailability() {
        
        let timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self] (Timer) in
            self?.boosterButton.shake()
        })
        
        if GlobalSetting.boosterIsActive {
            boosterButton.setImage(#imageLiteral(resourceName: "treasure-active"), for: .normal)
            boosterButton.isUserInteractionEnabled = true
        } else {
            boosterButton.setImage(#imageLiteral(resourceName: "treasuse-inactive"), for: .normal)
            boosterButton.isUserInteractionEnabled = false
            timer.invalidate()
        }
    }
    
    private func setBoosterLabelText() {
        
        boosterLabel.text = "Доступно через \(GlobalSetting.boosterTimerLeft)"
        
        if GlobalSetting.boosterIsActive == false {
            
            _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                GlobalSetting.boosterTimerLeft -= 1
                self.boosterLabel.text = "Доступно через \(GlobalSetting.boosterTimerLeft)"
                self.boosterLabel.textColor = #colorLiteral(red: 0.08396864682, green: 0.08843047172, blue: 0.2530170083, alpha: 1)
                
                if GlobalSetting.boosterTimerLeft <= 0 {
                    GlobalSetting.boosterIsActive = true
                    self.boosterLabel.text = "Получить награду"
                    self.boosterButton.setImage(#imageLiteral(resourceName: "treasure-active"), for: .normal)
                    self.setBoosterButtonAvailability()
                    self.boosterLabel.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                    timer.invalidate()
                }
            })
        }
    }
    
    @objc
    func arButtonTapped() {
        let vc = AirplaneAndRobotViewController()
        present(vc, animated: true)
    }
    
    @objc
    func boosterButtonTapped() {
        let vc = BoosterViewController()
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}

// MARK: - Layout

private extension ViewController {
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            resultLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultLabel.heightAnchor.constraint(equalToConstant: 20),
            
            catAndDogImageView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 0),
            catAndDogImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            catAndDogImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            catAndDogImageView.heightAnchor.constraint(equalToConstant: 220),
            
            selectedImageView.topAnchor.constraint(equalTo: catAndDogImageView.bottomAnchor, constant: 20),
            selectedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            selectedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            selectedImageView.heightAnchor.constraint(equalToConstant: 180),
            
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 80),
            addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor),
            
            arButton.bottomAnchor.constraint(equalTo: addButton.bottomAnchor),
            arButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            arButton.widthAnchor.constraint(equalToConstant: 80),
            arButton.heightAnchor.constraint(equalTo: addButton.widthAnchor),
            
            aboutLabel.topAnchor.constraint(equalTo: arButton.bottomAnchor, constant: 2),
            aboutLabel.widthAnchor.constraint(equalTo: arButton.widthAnchor),
            aboutLabel.heightAnchor.constraint(equalToConstant: 16),
            aboutLabel.leadingAnchor.constraint(equalTo: arButton.leadingAnchor),
            
            addLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 10),
            addLabel.heightAnchor.constraint(equalToConstant: 16),
            addLabel.leadingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -4),
            
            boosterButton.bottomAnchor.constraint(equalTo: addButton.bottomAnchor),
            boosterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            boosterButton.widthAnchor.constraint(equalToConstant: 70),
            boosterButton.heightAnchor.constraint(equalTo: boosterButton.widthAnchor),
            
            boosterLabel.topAnchor.constraint(equalTo: boosterButton.bottomAnchor),
            boosterLabel.widthAnchor.constraint(equalTo: boosterButton.widthAnchor, constant: 40),
            boosterLabel.heightAnchor.constraint(equalToConstant: 16),
            boosterLabel.leadingAnchor.constraint(equalTo: boosterButton.leadingAnchor, constant: -20),
            
            dotsButton.bottomAnchor.constraint(equalTo: boosterButton.topAnchor, constant: -40),
            dotsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            dotsButton.widthAnchor.constraint(equalToConstant: 75),
            dotsButton.heightAnchor.constraint(equalTo: dotsButton.widthAnchor),
            
            dotsLabel.topAnchor.constraint(equalTo: dotsButton.bottomAnchor, constant: 10),
            dotsLabel.heightAnchor.constraint(equalToConstant: 16),
            dotsLabel.leadingAnchor.constraint(equalTo: dotsButton.leadingAnchor, constant: -30),
            dotsLabel.trailingAnchor.constraint(equalTo: dotsButton.trailingAnchor, constant: 30)
        ])
    }
}

