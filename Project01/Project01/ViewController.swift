import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    var soundPlayer: AVAudioPlayer?
    var elapsedTime: TimeInterval = 0
    
    var NEED_TO_WIN : Int = 4;
    
    var size : Int = 8
    
    // Switch for multi-player or single player
    @IBOutlet weak var multiPlayerSwitch: UISwitch!
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet var gridButtons: [UIButton]!
    
    @IBOutlet weak var p1ScoreLabel: UILabel!
    @IBOutlet weak var p2ScoreLabel: UILabel!
    
    @IBOutlet weak var winnerLabel: UILabel!
    
    // Declaring symbols for the game
    var img1 = UIImage(named: "cross")
    var img2 = UIImage(named: "nought")
    
    // Default 81 buttons of the grid
    var grid = [[0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0]
               ]

    var currentPlayer : Int = 1
    
    var gameStarted : Bool = false
    
    var lastWinner : Int = 1
    
    // Game history
    @IBOutlet weak var historyTextView: UITextView!
    
    // Current score
    var p1Score : Int = 0
    var p2Score : Int = 0
    
    // Start game function
    func start(){
        grid = [[0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0]
        ]
        
        // All buttons are empty when the game starts
        for button in gridButtons{
            button.setImage(nil, for: .normal)
        }
        
        
        currentPlayer = lastWinner == 1 ? 2 : 1
        
        winnerLabel.text = "Player \(currentPlayer) is on turn"
        
        gameStarted = false
        
    }
    
    // Choosing cross symbol to play as player 1
    @IBAction func btnX(_ sender: UIButton) {
        if (!gameStarted)
        {
            currentPlayer = 1
            winnerLabel.text = "Player 1 is on turn"
        }
    }
    
    // Choosing nought symbol to play as player 2
    @IBAction func btnO(_ sender: UIButton) {
        if (!gameStarted)
        {
            currentPlayer = 2
            winnerLabel.text = "Player 2 is on turn"
        }
    }
    
    // When pressing one of the buttons to play the game
    @IBAction func cellSelected(_ sender: UIButton) {
        
        gameStarted = true
        
        let rowIndex = sender.tag / 9
        let colIndex = sender.tag % 9
        
        if grid[rowIndex][colIndex] != 0 {return}
        
        // Get to know which player press on which cell
        grid[rowIndex][colIndex] = currentPlayer
        
        // Set cross symbol for player 1
        if currentPlayer == 1 {
            sender.setImage(img1, for: .normal)
            
            winnerLabel.text = "Player 2 is on turn"
        }
        // Set nought symbol for player 2
        else if currentPlayer == 2 {
            sender.setImage(img2, for: .normal)
            
            winnerLabel.text = "Player 1 is on turn"
        }
        
        // Get result from winlose function to variable winner
        let winner = winlose(playerIndex: currentPlayer)
        
        // Check who is the winner
        switch winner {
        case -1:
            alertTie()
            historyTextView.insertText("\nTIE")
            
        case 0:
            currentPlayer = (currentPlayer % 2) + 1
        case 1:
            // Winner label for player 1
            winnerLabel.text = "Player 1 is the winner!"
            
            // Alert message for player 1
            alertWinner(playerName: "Player 1")
            
            // Player 1's current score
            p1Score += 1
            
            // Plyaer 1 score label
            p1ScoreLabel.text = "Score: \(p1Score)"
            
            // Game history for player 1
            historyTextView.insertText("\nPlayer 1 won")
            
            lastWinner = 1
            
        case 2:
            winnerLabel.text = "Player 2 is the winner!"
            alertWinner(playerName: "Player 2")
            
            p2Score += 1
            p2ScoreLabel.text = "Score: \(p2Score)"
            historyTextView.insertText("\nPlayer 2 won")
            
            lastWinner = 2
            
        default:
            winnerLabel.text = "\(winner) is not matched"
        }
        
        // NOT used .. for singleplayer
        /*
        // AI mode to check if single player mode is enabled
        if multiPlayerSwitch.isOn == false{
            let (cellIndex, gridRowIndex, gridColIndex, p2Win) = whereToPlay()
            
            // Set symbol for player 2
            gridButtons[cellIndex].setImage(img2, for: .normal)
            
            // Set the grid to value 2
            grid[gridRowIndex][gridColIndex] = 2
            
            // Show alert if player 2 wins
            if p2Win == true {
                p2Score += 1
                alertWinner(playerName: "Player 2")
            }
            
            // Otherwise, player 1 can now play the game
            currentPlayer = 1
        }
         */
        
    
        // scroll history to bottom
        let stringLength:Int = self.historyTextView.text.count
        self.historyTextView.scrollRangeToVisible(NSMakeRange(stringLength-1, 0))
    }
    
    // Check if player 1 or 2 wins the match
    // 1 is player 1 wins, 2 is player 2 wins or 0 is no players win at all
    func winlose(playerIndex : Int) -> Int {
        
        var counter : Int = 0;
        // rows
        for row in 0 ... size{
            for col in 0 ... size {
                if (grid[row][col] == playerIndex)
                {
                    counter += 1
                    
                    if (counter >= NEED_TO_WIN)
                    {
                        return playerIndex;
                    }
                }
                else
                {
                    counter = 0;
                }
                
            }
        }
        
        counter = 0
        
        // cols
        for col in 0 ... size{
            for row in 0 ... size {
                if (grid[row][col] == playerIndex)
                {
                    counter += 1
                    
                    if (counter >= NEED_TO_WIN)
                    {
                        return playerIndex;
                    }
                }
                else
                {
                    counter = 0;
                }
            }
        }
        
        counter = 0

        // LEFT TO RIGHT
        
        // below diagonale with main
        for startRow in 0 ... size{
            for i in 0 ... size - 1{
                let row : Int = i + startRow
                let col : Int = i
                
                if (row > 8)
                {
                    counter = 0;
                    break
                }
                
                if (grid[row][col] == playerIndex)
                {
                    counter += 1
                    
                    if (counter >= NEED_TO_WIN)
                    {
                        return playerIndex;
                    }
                }
                else
                {
                    counter = 0;
                }
            }
        }
        
        
        // upper diagonale
        for startCol in 1 ... size{
            for i in 0 ... size - 1{
                let row : Int = i
                let col : Int = i + startCol
                
                if (col > 8)
                {
                    counter = 0;
                    break
                }
                
                if (grid[row][col] == playerIndex)
                {
                    counter += 1
                    
                    if (counter >= NEED_TO_WIN)
                    {
                        return playerIndex;
                    }
                }
                else
                {
                    counter = 0;
                }
            }
        }
        
        
        // RIGHT TO LEFT
        
        // below diagonale with main
        for startRow in 0 ... size{
            for i in 0 ... size - 1{
                let row : Int = i + startRow
                let col : Int = i
                
                if (row > 8)
                {
                    counter = 0;
                    break
                }

                if (grid[size - row][col] == playerIndex)
                {
                    counter += 1
                    
                    if (counter >= NEED_TO_WIN)
                    {
                        return playerIndex;
                    }
                }
                else
                {
                    counter = 0;
                }
            }
        }
        
        
        // upper diagonale
        for startCol in 1 ... size{
            for i in 0 ... size - 1{
                let row : Int = i
                let col : Int = i + startCol
                
                if (col > 8)
                {
                    counter = 0;
                    break
                }
                
                if (grid[size - row][col] == playerIndex)
                {
                    counter += 1
                    
                    if (counter >= NEED_TO_WIN)
                    {
                        return playerIndex;
                    }
                }
                else
                {
                    counter = 0;
                }
            }
        }
        
        
        // check if is still free cells
        for row in 0 ... size {
            for col in 0 ... size {
                if (grid[row][col] == 0)
                {
                    return 0;
                }
            }
        }
        
        return -1;
    }
    
    
    // Alert message shows who won the game
    func alertWinner(playerName : String){
        let alertController = UIAlertController(title: "Result", message: "\(playerName) Won!", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default){
            (action) -> Void in self.start()
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Alert message shows tie result
    func alertTie(){
        let alertController = UIAlertController(title: "Result", message: "TIE!", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default){
            (action) -> Void in self.start()
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // NOT USED
    // When single player mode is on
    /*
    func whereToPlay() -> (Int, Int, Int, Bool){
        var index = -1
        var draw = 0
        var gridRowIndex = 0
        var gridColIndex = 0
        
        for row in 0 ... 2 {
            for col in 0 ... 2 {
                index = index + 1
                
                // Check when none of the players have played the game
                if grid[row][col] == 0
                {
                    
                    // Set the cell to 2
                    grid[row][col] = 2
                    
                    // Get the result from winlose function
              //    var i = winlose()
                    var i = 0
                    
                    // If the value is actually 2, player 2 wins the game
                    if i == 2
                    {
                        return (index, row, col, true)
                    }
                    
                    // Check if the winner is player 1
                    grid[row][col] = 1
        //            i = winlose()
                    
                    // If so, this means player 2 did not win the match by returning the flag as false
                    if i == 1
                    {
                        return (index, row, col, false)
                    }
                    
                    // When no one wins and other cells are available, player can still play the game
                    draw = index
                    gridRowIndex = row
                    gridColIndex = col
                    
                    // Set the cell to empty
                    grid[row][col] = 0
                }
            }
        }
        
        // No winner then return as false
        return (draw, gridRowIndex, gridColIndex, false)
    }
 */
    
    // Reset game button
    @IBAction func btnReset(_ sender: UIButton) {
        start()
    }
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // disable screen rotation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
            
        }
    }

}

