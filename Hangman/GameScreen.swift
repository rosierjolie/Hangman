//
//  GameScreen.swift
//  Hangman
//
//  Created by Jerry Turcios on 1/12/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import UIKit

enum GameStatus {
    case victory
    case failure
}

class GameScreen: UIViewController {

    // MARK: - Controller properties

    var scoreLabel: UILabel!
    var imageView: UIImageView!
    var descriptionLabel1: UILabel!
    var descriptionLabel2: UILabel!
    var hiddenWordLabel: UILabel!
    var containerStackView: UIStackView!
    var letterButtons = [UIButton]()

    let alphabetList = [
        "a", "b", "c", "d", "e", "f", "g",
        "h", "i", "j", "k", "l", "m", "n",
        "o", "p", "q", "r", "s", "t", "u",
        "v", "w", "x", "y", "z"
    ]

    var allWordsFromFile = [String]()
    var hiddenWord = ""

    var amountGuessedIncorrectly = 0 {
        didSet {
            imageView.image = UIImage(named: "Hangman\(amountGuessedIncorrectly)")
        }
    }

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    // MARK: - Lifecycle methods

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        setupUserInterface()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let file = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let words = try? String(contentsOf: file) {
                allWordsFromFile = words.components(separatedBy: "\n")
            }
        }

        loadGame()
    }

    // MARK: - Defined methods

    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonLetter = sender.titleLabel?.text else { return }
        guard let hiddenWordLabelText = hiddenWordLabel.text else { return }

        sender.isEnabled = false

        if hiddenWord.contains(buttonLetter) {
            var newGuessedWord = ""

            for letter in hiddenWord {
                if String(letter) == buttonLetter {
                    // If the selected letter is in the hidden word, add that letter
                    // to the new guessed word
                    newGuessedWord.append(letter)
                } else if hiddenWordLabelText.contains(letter) {
                    // If the selected letter is already in the new guessed word, re-add
                    // that letter to it
                    newGuessedWord.append(letter)
                } else {
                    newGuessedWord.append("?")
                }
            }

            // The newly built guessed word is assigned to the hidden word text label
            hiddenWordLabel.text = newGuessedWord

            // Checks to see if the player guessed all the letters
            if hiddenWord == hiddenWordLabel.text {
                endGame(for: .victory)
            }
        } else {
            amountGuessedIncorrectly += 1

            if amountGuessedIncorrectly == 7 {
                endGame(for: .failure)
            }
        }
    }

    func loadGame() {
        guard let randomWord = allWordsFromFile.randomElement() else { return }

        hiddenWord = randomWord
        hiddenWordLabel.text = ""
        amountGuessedIncorrectly = 0

        for button in letterButtons {
            button.isEnabled = true
        }

        for _ in hiddenWord {
            hiddenWordLabel.text?.append("?")
        }
    }

    func endGame(for gameStatus: GameStatus) {
        var title = ""
        var message = ""

        if gameStatus == .victory {
            title = "You won!"
            message = "You managed to guess the word \"\(hiddenWord)\""
        } else {
            title = "Game over!"
            message = "You ran out of tries to guess the word \"\(hiddenWord)\""
        }

        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let endGameAction = UIAlertAction(title: "Play again", style: .default) {
            [weak self] _ in

            // Increments or decrements the score based on the game status
            if gameStatus == .victory {
                self?.score += 1
            } else {
                self?.score -= 1
            }

            self?.loadGame()
        }

        ac.addAction(endGameAction)
        present(ac, animated: true)
    }
}

// MARK: - User interface code

extension GameScreen {
    func setupUserInterface() {
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "Score: 0"
        scoreLabel.font = .boldSystemFont(ofSize: 20)

        imageView = UIImageView(image: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        descriptionLabel1 = UILabel()
        descriptionLabel1.text = "Hidden word"
        descriptionLabel1.font = .boldSystemFont(ofSize: 24)

        hiddenWordLabel = UILabel()
        hiddenWordLabel.textAlignment = .center

        descriptionLabel2 = UILabel()
        descriptionLabel2.text = "Tap the letters to guess the word"
        descriptionLabel2.textColor = .gray
        descriptionLabel2.font = .boldSystemFont(ofSize: 20)

        let textStackView = UIStackView(arrangedSubviews: [descriptionLabel1, hiddenWordLabel, descriptionLabel2])
        textStackView.axis = .vertical
        textStackView.distribution = .fill
        textStackView.alignment = .center
        textStackView.spacing = 8

        containerStackView = UIStackView(arrangedSubviews: [scoreLabel, imageView, textStackView])
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.axis = .vertical
        containerStackView.distribution = .equalSpacing
        containerStackView.alignment = .center
        view.addSubview(containerStackView)

        let firstRowStackView = createLetterRowStackView(for: 0..<7, distribution: .equalSpacing)
        let secondRowStackView = createLetterRowStackView(for: 7..<14, distribution: .equalSpacing)
        let thirdRowStackView = createLetterRowStackView(for: 14..<21, distribution: .equalSpacing)
        let fourthRowStackView = createLetterRowStackView(for: 21..<26, distribution: .fill)
        // Adds empty view to fourth stack view to line up the letters
        fourthRowStackView.addArrangedSubview(UIView())

        let letterStackView = UIStackView(arrangedSubviews: [
            firstRowStackView,
            secondRowStackView,
            thirdRowStackView,
            fourthRowStackView
        ])
        letterStackView.axis = .vertical
        containerStackView.addArrangedSubview(letterStackView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }

    func createLetterRowStackView(for range: Range<Int>, distribution: UIStackView.Distribution) -> UIStackView {
        let width = 59
        let height = 59

        let letterRowStackView = UIStackView()
        letterRowStackView.axis = .horizontal
        letterRowStackView.distribution = distribution
        letterRowStackView.spacing = 8

        for letter in range {
            let button = UIButton(type: .system)
            button.titleLabel?.font = .boldSystemFont(ofSize: 30)
            button.setTitle(alphabetList[letter], for: .normal)
            button.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)

            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            button.frame = frame

            letterRowStackView.addArrangedSubview(button)
            letterButtons.append(button)
        }

        return letterRowStackView
    }
}
