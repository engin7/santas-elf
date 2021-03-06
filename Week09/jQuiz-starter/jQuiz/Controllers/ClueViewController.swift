//
//  ViewController.swift
//  jQuiz
//
//  Created by Jay Strawn on 7/17/20.
//  Copyright © 2020 Jay Strawn. All rights reserved.
//

import UIKit

class ClueViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var clueLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var clues: [Clue] = []
    
    var game = ClueGameModel()
    let networkHandler = Networking.sharedInstance
    let defaults = UserDefaultsPersistence(userDefaults: UserDefaults.standard)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        game.delegate = self
        
        SoundManager.shared.toggleSoundPreference()
        setUpSound()
        
        getClues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        showSpinner(onView: view)
        logoImageView.loadImage(urlString: networkHandler.imageURL)
    }
    
    func setUpView() {
        categoryLabel.text = game.correctAnswerClue.category.title
        clueLabel.text = game.correctAnswerClue.question
        self.scoreLabel.text = "\(game.score)"
        
        tableView.reloadData()
        removeSpinner()
    }
    
    func setUpTableViewCellDesign(for cell: UITableViewCell) {
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.purple.cgColor
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true
    }
    
    func getClues() {
        networkHandler.getRandomCategory(completion: { (categoryId) in
            guard let id = categoryId else {
                return
            }
            self.networkHandler.getAllCluesInCategory(categoryId: id) { (clues) in
                self.clues = clues
                DispatchQueue.main.async {
                    self.game.correctAnswerClue = clues.randomElement()
                    //print("Correct clue: \(self.game.correctAnswerClue!)")
                    self.setUpView()
                }
                //print("All 4 with correct one clues: \(clues)")
            }
        })
    }
    
    func setUpSound() {
        if SoundManager.shared.isSoundEnabled == false {
            soundButton.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
            defaults.save(value: true, key: "sound")
        } else {
            soundButton.setImage(UIImage(systemName: "speaker"), for: .normal)
            defaults.save(value: false, key: "sound")
        }
    }
    
    @IBAction func didPressVolumeButton(_ sender: Any) {
        SoundManager.shared.toggleSoundPreference()
        setUpSound()
    }
    
}

extension ClueViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clues.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "clueAnswerCell", for: indexPath) as? ClueAnswerCell
            else { return UITableViewCell() }
        
        setUpTableViewCellDesign(for: cell)
        
        let clue = clues[indexPath.row]
        cell.answerLabel.text = clue.answer?
            .replacingOccurrences(of: "<i>", with: "")
            .replacingOccurrences(of: "</i>", with: "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        let clue = clues[indexPath.row]
        game.calculatePoints(clue: clue)
    }
}

extension ClueViewController: NetworkingErrorDelegate {
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Loading Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
        removeSpinner()
    }
}

extension ClueViewController: ClueGameModelDelegate {
    func willShowGameInfo(answer: Answer) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: answer.title, message: answer.message + "\(self.game.correctAnswerClue.value ?? 100) points!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Acknowledged", style: .default, handler: {
                action in
                self.showSpinner(onView: self.view)
                self.getClues()
            })
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
}
