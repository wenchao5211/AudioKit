//
//  AKFrequencyTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This is based on an algorithm originally created by Miller Puckette.
///
/// - Parameters:
///   - input: Input node to process
///   - hopSize: Hop size.
///   - peakCount: Number of peaks.
///
open class AKFrequencyTracker: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKFrequencyTrackerAudioUnit
    static let ComponentDescription = AudioComponentDescription(effect: "ptrk")

    // MARK: - Properties

    fileprivate var internalAU: AKAudioUnitType?
    fileprivate var token: AUParameterObserverToken?

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    /// Detected Amplitude (Use AKAmplitude tracker if you don't need frequency)
    open var amplitude: Double {
        return Double(self.internalAU!.getAmplitude()) / 2.0 // Stereo Hack
    }

    /// Detected frequency
    open var frequency: Double {
        return Double(self.internalAU!.getFrequency()) * 2.0 // Stereo Hack
    }

    // MARK: - Initialization

    /// Initialize this Pitch-tracker node
    ///
    /// - parameter input: Input node to process
    /// - parameter hopSize: Hop size.
    /// - parameter peakCount: Number of peaks.
    ///
    public init(
        _ input: AKNode,
        hopSize: Double = 512,
        peakCount: Double = 20) {

        _Self.register()

        super.init()
        AVAudioUnit.instantiate(with: _Self.ComponentDescription, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKAudioUnitType

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}
