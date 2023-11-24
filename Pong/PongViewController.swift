/// Importing a library of UI components (interface elements)
import UIKit
import AVFoundation

/// This is the class for our application's only screen
///
/// The class contains game display elements:
/// - `ballView` - ball
/// - `userPaddleView` - user paddle
/// - `enemyPaddleView` - enemy paddle
///
/// Also in the class of this screen the physics of interaction of elements is configured
/// in a function `enableDynamics()`
///
/// This class also implements processing of finger movement on the screen,
/// by processing this gesture the player can move his platform and push the ball
///
class PongViewController: UIViewController {

    // MARK: - Overriden Properties

    /// This overridden variable defines valid screen orientations
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    // MARK: - Subviews

    /// This is the ball display variable
    @IBOutlet var ballView: UIView!

    /// This is the player platform display variable
    @IBOutlet var userPaddleView: UIView!

    /// This is the opponent's platform display variable
    @IBOutlet var enemyPaddleView: UIView!

    /// This is the dividing line display variable
    @IBOutlet var lineView: UIView!

    /// This is a variable displaying the label with the player's score
    @IBOutlet var userScoreLabel: UILabel!
    
    // This is a variable displaying the label with the opponent's score
    @IBOutlet private var enemyScoreLabel: UILabel!
    
    @IBOutlet private var resultLabel: UILabel!

    // MARK: - Instance Properties

    /// This is the finger gesture handler variable
    var panGestureRecognizer: UIPanGestureRecognizer?

    /// This is a variable in which we will remember the last position of the user's platform,
    /// before the user starts moving his finger across the screen
    var lastUserPaddleOriginLocation: CGFloat = 0

    /// This is a timer variable that will update the position of the opponent's platform
    var enemyPaddleUpdateTimer: Timer?

    /// This is a flag `Bool`, has two possible meanings:
    /// - `true` - can be interpreted as "yes"
    /// - `false` - can be interpreted as "no"
    ///
    /// He is responsible for the need to launch the ball upon the next tap on the screen
    ///
    var shouldLaunchBallOnNextTap: Bool = false

    /// This is a flag `Bool`, which indicates "whether the ball was launched"
    var hasLaunchedBall: Bool = false

    var enemyPaddleUpdatesCounter: UInt8 = 0

    // NOTE: All variables below up to line 77 are needed for physics settings
    // We will not go into details of what it is and how it works
    var dynamicAnimator: UIDynamicAnimator?
    var ballPushBehavior: UIPushBehavior?
    var ballDynamicBehavior: UIDynamicItemBehavior?
    var userPaddleDynamicBehavior: UIDynamicItemBehavior?
    var enemyPaddleDynamicBehavior: UIDynamicItemBehavior?
    var collisionBehavior: UICollisionBehavior?

    // NOTE: All variables up to line 85 are used for reacting
    // for ball collisions - playing the collision sound and vibration response
    var audioPlayers: [AVAudioPlayer] = []
    var audioPlayersLock = NSRecursiveLock()
    var softImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    var lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    var rigidImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)

    /// This player variable is designed to repeatedly play background music in the game
    var backgroundSoundAudioPlayer: AVAudioPlayer? = {
        guard
            let backgroundSoundURL = Bundle.main.url(forResource: "background", withExtension: "wav"),
            let audioPlayer = try? AVAudioPlayer(contentsOf: backgroundSoundURL)
        else { return nil }

        audioPlayer.volume = 0.5
        audioPlayer.numberOfLoops = -1

        return audioPlayer
    }()

    /// This variable stores the user's score
    var userScore: Int = 0 {
        didSet {
            /// Every time the value of a variable is updated, we update the text in the label
            updateUserScoreLabel()
            checkWinOrLose()
        }
    }

    /// This variable stores the opponent's score
    var enemyScore: Int = 0 {
        didSet {
            /// Every time the value of a variable is updated, we update the text in the label
            updateEnemyScoreLabel()
            checkWinOrLose()
        }
    }

    // MARK: - Instance Methods

    /// This function is run 1 time when the screen view has loaded
    /// and is about to appear in the display window
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        NOTE: 👨‍💻 A note on customizing the game screen 👨‍💻
        
        Sets up everything you need for the game.
        Function `configurePongGame()` run the project to make the game work!
        */

        configurePongGame()
    }

    /// Эта функция вызывается, когда экран PongViewController повяился на экране телефона
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // NOTE: Turning on the dynamics of interaction
        self.enableDynamics()
    }

    /// This function is called when the screen has rendered its entire interface for the first time.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        ballView.layer.cornerRadius = ballView.bounds.size.height / 2
    }

    /// This function handles the start of all screen touches
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)

        // NOTE: If you need to launch the ball and the ball has not yet been launched - launching the ball
        if shouldLaunchBallOnNextTap, !hasLaunchedBall {
            hasLaunchedBall = true

            launchBall()
        }
    }

    // MARK: - Private Methods

    /// This function performs all configuration (setting) of the screen
    ///
    /// - enables processing of the gesture of moving a finger across the screen
    /// - turns on the dynamics of interaction of elements
    /// - indicates that the next press should launch the ball
    ///
    private func configurePongGame() {
        // NOTE: Setting up labels with player and opponent scores
        updateUserScoreLabel()
        updateEnemyScoreLabel()

        // NOTE: Enable processing of the gesture of moving a finger across the screen
        self.enabledPanGestureHandling()

        // NOTE: We enable the logic of the enemy platform “follow the sword”
        self.enableEnemyPaddleFollowBehavior()

        // NOTE: We indicate that the next time you press the screen you need to launch the ball
        self.shouldLaunchBallOnNextTap = true

        // NOTE: Let's start playing music
        self.backgroundSoundAudioPlayer?.prepareToPlay()
        self.backgroundSoundAudioPlayer?.play()
    }

    private func updateUserScoreLabel() {
        userScoreLabel.text = "\(userScore)"
    }

    private func updateEnemyScoreLabel() {
        enemyScoreLabel.text = "\(enemyScore)"
    }
    
    private func checkWinOrLose() {
        // NOTE: Checking win or lose
        if enemyScore == 5 || userScore == 5 {
            handleGameResult()
        }
    }
    
    private func handleGameResult() {
        // NOTE: Show a visual indication of victory or defeat
        resultLabel.text = (userScore == 5) ? "You Win!" : "Enemy Win!"
        resultLabel.isHidden = false
        
        // NOTE: Hide result label after 1 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.resultLabel.isHidden = true
            
            // NOTE: Reset the score
            self.userScore = 0
            self.enemyScore = 0
        }
    }
}
