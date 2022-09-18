//
//  tester1.swift
//  CardPlay
//
//  Created by Ionut on 03.07.2022.
//

import Foundation

class Tester1: ObservableObject {
    static let getInstance = Tester1()
    @Published var game: HoldemGame = HoldemGame(numberOfPlayers: 2)
    @MainActor func setFor3out1( for game: HoldemGame, nextActive: Int) -> Void {
        let bet: ((Int) -> ChipsCountType) = { idx in
            return idx == nextActive ? 400 : 480
        } //clo
        _ = setupExisting( game,
                   flopCards: ["c8", "sK", "sQ", "h6", "c7"],
                   playersCards: [ ["d10", "d8"],
                                   ["h10", "h8"],
                                   ["d4", "s9"] ],
                  betAmounts: [[1500, 400], [1000, 400], [500, 400]],
                  dropped: [false, false, false])
        game.bigBlind = 50
        game.smallBlind = 30
        _ = putBetsNoReset( in: game, betAmounts: [bet(0), bet(1), bet(2)], dropped: [false, false, false])
        _ = game.enterRoundAsync(.round4)
        _ = game.setInRoundActingOrder(startingWith: nextActive, andCompileMenu: true)
        game.allPlayers[0].setNotJoining(reason: .quit)
        for p in game.allPlayers {
            p.actedInRound = true
        }
        game.roundBettingStarted = true
        game.compileActingMenu()
    } //func
    @MainActor func setFor3( for game: HoldemGame, nextActive: Int) -> Void {
        let bet: ((Int) -> ChipsCountType) = { idx in
            return idx == nextActive ? 400 : 480
        } //clo
        _ = setupExisting( game,
                   flopCards: ["c8", "sK", "sQ", "h6", "c7"],
                   playersCards: [ ["d10", "d8"],
                                   ["h10", "h8"],
                                   ["d4", "s9"] ],
                  betAmounts: [[1500, 400], [1000, 400], [500, 400]],
                  dropped: [false, false, false])
        game.bigBlind = 50
        game.smallBlind = 30
        _ = putBetsNoReset( in: game, betAmounts: [bet(0), bet(1), bet(2)], dropped: [false, false, false])
        _ = game.enterRoundAsync(.round4)
        _ = game.setInRoundActingOrder(startingWith: nextActive, andCompileMenu: true)
        for p in game.allPlayers {
            p.actedInRound = true
        }
        game.compileActingMenu()
    } //func
    @MainActor func testShowdown1() {
        var g = HoldemGame(numberOfPlayers: 3)
        _ = setup(gm: &g,
                   flopCards: ["c8", "sK", "sQ", "h6", "c7"],
                   playersCards: [ ["d10", "d8"],
                                   ["h10", "h8"],
                                   ["d4", "s9"] ],
                  betAmounts: [[100, 50], [200, 50], [50, 50]],
                  dropped: [false, false, false])
        
        _ = putBets(gm: g, betAmounts: [[100, 20], [100, 50], [100, 50]], dropped: [true, false, false])
        
    } //func
    func testDataCoding(_ game: inout HoldemGame) -> Bool {
        if let d1 = game.toJSON() {
            if let gg = try? JSONDecoder().decode(HoldemGame.self, from: d1) {
                game = gg
                return true
            }
        }
        return false
    } //func
    func resetBets(in game: HoldemGame) -> Void {
        game.currentBetSize = 0
        for player in game.allPlayers {
            player.placedInBet = 0
        }
    } //func
    func putBets( gm: HoldemGame, betAmounts: [[Int]], dropped: [Bool]) -> Bool {
        resetBets( in: gm)
        guard betAmounts.count == gm.allPlayers.count else {
            return false
        }
        for i in betAmounts.indices {
            guard betAmounts[i].count == 2 else {
                return false
            }
            gm.allPlayers[i].chips = betAmounts[i][0]
            _ = gm.setBet(for: gm.allPlayers[i].matchParticipantIndex, to: betAmounts[i][1], ignoreMinRaise: true)
        } //for
        guard dropped.count == gm.allPlayers.count else {
                        return false
                    }
        for i in dropped.indices {
            gm.allPlayers[i].dropped = dropped[i]
        } //for
        return true
    } //func
    func putBetsNoReset( in gm: HoldemGame, betAmounts: [Int], dropped: [Bool]) -> Bool {
        guard betAmounts.count == gm.allPlayers.count else {
            return false
        }
        for i in betAmounts.indices {
            _ = gm.setBet(for: gm.allPlayers[i].matchParticipantIndex, to: betAmounts[i], ignoreMinRaise: true)
        } //for
        guard dropped.count == gm.allPlayers.count else {
                        return false
                    }
        for i in dropped.indices {
            gm.allPlayers[i].dropped = dropped[i]
        } //for
        return true
    } //func
    @MainActor func setupExisting( _ gm: HoldemGame, flopCards: [String], playersCards: [[String]], betAmounts: [[Int]]? = nil, dropped: [Bool]? = nil) -> Bool {
        guard 3...5 ~= flopCards.count,
              //2...8 ~= playersCards.count
              gm.allPlayers.count == playersCards.count
        else {
            return false
        }
        for hand in playersCards {
            if hand.count != 2 {
                return false
            }
        } //for
gm.enterRound0Async()
        if let betAmounts = betAmounts {
            guard betAmounts.count == playersCards.count else {
                return false
            }
            for i in betAmounts.indices {
                guard betAmounts[i].count == 2 else {
                    return false
                }
                gm.allPlayers[i].chips = betAmounts[i][0]
                _ = gm.setBet(for: gm.allPlayers[i].matchParticipantIndex, to: betAmounts[i][1])
            } //for
        } //if let
        if let dropped = dropped {
            guard dropped.count == playersCards.count else {
                return false
            }
            for i in dropped.indices {
                gm.allPlayers[i].dropped = dropped[i]
            }
        } //if let
        gm.dealerStack.giveBy(shortIds: flopCards, to: gm.flop)
        for i in playersCards.indices {
            gm.dealerStack.giveBy(shortIds: playersCards[ i], to: gm.allPlayers[ i].hand)
        }
        return true
    } //func
    @MainActor func setup( gm: inout HoldemGame, flopCards: [String], playersCards: [[String]], betAmounts: [[Int]]? = nil, dropped: [Bool]? = nil) -> Bool {
        guard 3...5 ~= flopCards.count,
              2...8 ~= playersCards.count else {
            return false
        }
        for hand in playersCards {
            if hand.count != 2 {
                return false
            }
        } //for
        gm = HoldemGame(numberOfPlayers: playersCards.count)
gm.enterRound0Async()
        if let betAmounts = betAmounts {
            guard betAmounts.count == playersCards.count else {
                return false
            }
            for i in betAmounts.indices {
                guard betAmounts[i].count == 2 else {
                    return false
                }
                gm.allPlayers[i].chips = betAmounts[i][0]
                _ = gm.setBet(for: gm.allPlayers[i].matchParticipantIndex, to: betAmounts[i][1])
            } //for
        } //if let
        if let dropped = dropped {
            guard dropped.count == playersCards.count else {
                return false
            }
            for i in dropped.indices {
                gm.allPlayers[i].dropped = dropped[i]
            }
        } //if let
        gm.dealerStack.giveBy(shortIds: flopCards, to: gm.flop)
        for i in playersCards.indices {
            gm.dealerStack.giveBy(shortIds: playersCards[ i], to: gm.allPlayers[ i].hand)
        }
        return true
    } //func
} //class

extension CardStack {
    func giveBy(shortIds: [String], to dst: CardStack) -> Void {
        for eachId in shortIds {
            guard let foundCard = cards.findBy(shortId: eachId) else {
                continue
            } //gua
            _ = give( card: foundCard, to: dst)
        } //for
    } //func
} //ext
extension Array where Element == Card {
    func findBy(shortId: String) -> Element? {
        first { eachCard in
            eachCard.rawCard.isBy(shortId)
        }
    } //func
} //ext
extension RawCard {
    func isBy(_ shortId: String) -> Bool {
        guard shortId.count > 1 else {
            return false
        }
        if shortId.prefix(1) != suit.id.lowercased().prefix(1) {
            return false
        }
        //let rest = shortId.substring(from: shortId.index(after: shortId.startIndex) ).uppercased()
        let rest = shortId[shortId.index(shortId.startIndex, offsetBy: 1)...].uppercased()
        return rest == symbol.display
    }
}
