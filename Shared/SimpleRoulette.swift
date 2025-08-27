import Foundation

public final class SimpleRoulette {
    // American wheel order (clockwise)
    public static let wheel: [String] = [
        "0","28","9","26","30","11","7","20","32","17",
        "5","22","34","15","3","24","36","13","1","00",
        "27","10","25","29","12","8","19","31","18","6",
        "21","33","16","4","23","35","14","2"
    ]

    public let pocketDeg = 360.0 / 38.0
    public var artOffsetDeg: Double      // calibrate once for your artwork
    public var direction: Double         // +1 if positive spin is CW on screen, else -1

    public init(artOffsetDeg: Double = 0, direction: Double = 1) {
        self.artOffsetDeg = artOffsetDeg
        self.direction    = direction
    }

    // Normalize angle to [0, 360)
    @inline(__always) public func norm(_ a: Double) -> Double {
        let x = a.truncatingRemainder(dividingBy: 360.0)
        return x < 0 ? x + 360.0 : x
    }

    // Core: compute final angles for wheel and ball
    // riggedNumber: pass nil for random; otherwise "12", "00", etc.
    public struct SpinPlan {
        public let targetIndex: Int
        public let landingWorldDeg: Double
        public let finalWheelDeg: Double
        public let finalBallDeg: Double
        public let resultNumber: String
    }

    public func planSpin(
        riggedNumber: String?,                // nil = random
        currentWheelDeg: Double,              // current wheel world angle
        extraTurnsWheel: Int = 10,            // 8–16 looks nice
        extraTurnsBall: Int  = 14,            // ball can spin more
        landingWorldDeg: Double? = nil        // nil = random [0, 360)
    ) -> SpinPlan {
        // 1) choose target index
        let idx: Int = {
            if let n = riggedNumber, let i = Self.wheel.firstIndex(of: n) {
                return i
            } else {
                return Int.random(in: 0..<Self.wheel.count)
            }
        }()

        // 2) choose landing angle in world space (where the ball will visually stop)
        let land = landingWorldDeg.map(norm) ?? Double.random(in: 0..<360)

        // 3) pocket local angle in wheel space
        let targetLocal = artOffsetDeg + Double(idx) * pocketDeg

        // 4) solve for base wheel angle so target pocket lands at `land`
        // world(target) = direction * wheelFinal + targetLocal ≡ land (mod 360)
        var base = (direction > 0) ? (land - targetLocal) : (targetLocal - land)
        base = norm(base)

        // 5) choose final wheel angle: from current → base + full spins, minimal positive delta in spin direction
        let curDirected = norm(direction * currentWheelDeg)
        let baseDirected = norm(base)
        let deltaToBase = norm(baseDirected - curDirected)
        let finalDirected = curDirected + Double(max(0, extraTurnsWheel)) * 360.0 + deltaToBase
        let finalWheel = finalDirected / direction

        // 6) ball final angle: same world landing angle, but allow its own extra spins during animation
        let finalBall = land + Double(max(0, extraTurnsBall)) * 360.0 * direction

        return SpinPlan(
            targetIndex: idx,
            landingWorldDeg: norm(land),
            finalWheelDeg: finalWheel,
            finalBallDeg: finalBall,
            resultNumber: Self.wheel[idx]
        )
    }

    // Optional sanity check: given a final wheel angle, what index is under a given world angle?
    public func indexAt(worldAngleDeg: Double, wheelAngleDeg: Double) -> Int {
        // Convert world angle to wheel-local
        let local = norm(worldAngleDeg - direction*wheelAngleDeg - artOffsetDeg)
        let idx = Int(floor((local + pocketDeg/2.0)/pocketDeg)) % Self.wheel.count
        return idx
    }

    // One-shot calibration helper (if you know what pocket is visually at a world angle)
    // Example: pointer at 0°, wheel at 87.63°, you *see* index 9 there → compute artOffsetDeg.
    public func calibratedArtOffset(
        observedIndex: Int,
        worldAngleDeg: Double,       // e.g., pointer or visual landing angle
        wheelAngleDeg: Double
    ) -> Double {
        // world(pocket observedIndex) = direction * wheel + (artOffset + idx*pocket)
        // → artOffset = world - direction*wheel - idx*pocket
        let off = norm(worldAngleDeg - direction*wheelAngleDeg - Double(observedIndex)*pocketDeg)
        return off
    }
} 