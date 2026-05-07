import SwiftUI

// NOTE: Add Lottie via Swift Package Manager:
//   https://github.com/airbnb/lottie-ios.git (minimum version 4.4.0)
//
// In Xcode: File → Add Package Dependencies → paste the URL above.
// Once added, uncomment the import below and the body implementation.

// import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let speed: CGFloat

    init(name: String, loopMode: LottieLoopMode = .loop, speed: CGFloat = 1.0) {
        self.name = name
        self.loopMode = loopMode
        self.speed = speed
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        // Uncomment after adding Lottie SPM dependency:
        //
        // let animationView = LottieAnimationView(name: name)
        // animationView.loopMode = loopMode
        // animationView.animationSpeed = speed
        // animationView.play()
        // animationView.translatesAutoresizingMaskIntoConstraints = false
        // view.addSubview(animationView)
        //
        // NSLayoutConstraint.activate([
        //     animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
        //     animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        // ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

enum LottieLoopMode {
    case playOnce
    case loop
    case autoReverse
}
