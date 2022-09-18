//
//  soundFX.swift
//  CardPlay
//
//  Created by Ionut on 19.08.2021.
//

import Foundation
//import SwiftUI
import AVFoundation

class GameSound {
    private let soundData: Data
    private let capacity: Int
    private(set) var players: [UpAudioPlayer]
    private let minInterval: Double = 0.01
    private var lastPlayTime: Date
    
    init(soundFile: String, maxNrOfPlayers: Int) throws {
        if let url = Bundle.main.url(forResource: soundFile, withExtension: nil, subdirectory: nil) {
            if let sd = try? Data(contentsOf: url) {
                soundData = sd
                players = []
                capacity = maxNrOfPlayers
                lastPlayTime = Date(timeIntervalSince1970: 0)
                return
            }
        }
            throw GSoundError.soundNotFound
    } //init
    func playSound(_ player: UpAudioPlayer?) -> Void {
        guard let player = player else {
            return
        }
        if lastPlayTime.addingTimeInterval(minInterval) > Date() {
            return
        }
        lastPlayTime = Date()
        _ = player.play()
    } //play
    func prepareAndPlay() -> Void {
        return playSound(prepareSound())
    }
    func prepareSound() -> UpAudioPlayer? {
        if let fi = players.firstIndex(where: { p in
            !(p.isPlaying || p.allocated)
        }) {
            print("playing free \(fi)")
            let player = players[fi]
            player.allocated = true
            player.prepareToPlay()
            players.move(fromOffsets: [fi], toOffset: 0)
            return player
        }
        if players.count < capacity {
            guard let player = try? UpAudioPlayer(data: soundData) else {
                return nil
            }
            print("playing new \(players.count)")
            player.allocated = true
            player.prepareToPlay()
            players.insert(player, at: 0)
            return player
        }
        if let li = players.lastIndex(where: { p in
            true//!p.allocated
        }) {
            print("playing use \(li)")
            let player = players[li]
            player.stop()
            player.allocated = true
            player.prepareToPlay()
            players.move(fromOffsets: [li], toOffset: 0)
            return player
        }
        return nil
    } //func
    enum GSoundError: Error {
        case soundNotFound
    }
} //gs
class UpAudioPlayer: AVAudioPlayer {
    var allocated: Bool = false
    /*
    override init(data: Data) throws {
        allocated = false
        try super.init(data: data)
    } //init
    override init(data: Data, fileTypeHint utiString: String?) throws {
        allocated = false
        try super.init(data: data, fileTypeHint: utiString)
    }
 */
    override func play() -> Bool {
        allocated = false
        return super.play()
    } //play
} //pla
