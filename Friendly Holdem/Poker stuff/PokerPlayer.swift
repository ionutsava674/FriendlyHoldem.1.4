//
//  PokerPlayer.swift
//  CardPlay
//
//  Created by Ionut on 03.08.2021.
//

import Foundation
import GameKit

typealias ChipsCountType = Int

struct FinishingSituation: Codable {
let bestCombo: CardStack
    //let hand: InterpretationHand
    var didGetOverall: ChipsCountType = 0
    var didPlaceInBet: ChipsCountType = 0
    var didGetAfterBet: ChipsCountType { didGetOverall + didPlaceInBet }
    
    init( stack: CardStack) {
        self.bestCombo = stack
    } //init
        init( stack: CardStack, hand: InterpretationHand) {
    self.bestCombo = stack
    self.comboBestHand = hand
    } //init
    lazy var comboBestHand: InterpretationHand = {
        bestCombo.getBestInterpretationHand()
    }()
    lazy var rank: PokerHandRank = {
        PokerHandRank.getBestRank( of: comboBestHand)
    }() //cv
} //class

class PokerPlayer: ObservableObject, Codable {
    typealias IndexType = Array<GKTurnBasedParticipant>.Index
    enum CodingKeys: CodingKey {
        case matchParticipantIndex//: IndexType
        case agreeingStage//: StructureAgreeingStage = .stage1CanSuggest
        case chosenStructureVariant//: GameStartParameters?
        //case chose// = false
        case joiningGame
        case notJoiningReason
        case chips//: ChipsCountType = 0
        case placedInBet//: ChipsCountType = 0
        //case toTransfer//: ChipsCountType = 0
        case dropped//: Bool = false
        case actedInRound//: Bool = false
        case hand//: CardStack
        case lastFinishingResult//: fini?
    } //enum

    let matchParticipantIndex: IndexType
    @Published var agreeingStage: StructureAgreeingStage = .stage1CanSuggest
    @Published var chosenStructureVariant: GameStartParameters?
    @Published var volaChose = false
    
    @Published public private(set) var joiningGame: Bool = true
    @Published var notJoiningReason: NoJoinReason = .none {
        didSet {
            //debugMsg_("\(matchParticipantIndex) njr went to \(notJoiningReason.rawValue)")
        }
    }
    @Published var chips: ChipsCountType = 0
    @Published var placedInBet: ChipsCountType = 0
    var leftWithChips: ChipsCountType { chips - placedInBet }
    var isAllIn: Bool {
        placedInBet >= chips
    }
    @Published var dropped: Bool = false
    @Published var actedInRound: Bool = false
    var stillNeedToAct: Bool {
        !(actedInRound/* || isAllIn*/ || dropped)
    }
    @Published var hand: CardStack
    @Published var lastFinishingResult: FinishingSituation?
    
    func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode( matchParticipantIndex, forKey: .matchParticipantIndex)
        try container.encode( agreeingStage, forKey: .agreeingStage)
        try container.encode( chosenStructureVariant, forKey: .chosenStructureVariant)
        //try container.encode( chose, forKey: .chose)
        try container.encode( joiningGame, forKey: .joiningGame)
        try container.encode( notJoiningReason, forKey: .notJoiningReason)
        try container.encode( chips, forKey: .chips)
        try container.encode( placedInBet, forKey: .placedInBet)
        //try container.encode( toTransfer, forKey: .toTransfer)
        try container.encode( dropped, forKey: .dropped)
        try container.encode( actedInRound, forKey: .actedInRound)
        try container.encode( hand, forKey: .hand)
        try container.encode( lastFinishingResult, forKey: .lastFinishingResult)
} //enc
required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    matchParticipantIndex = try container.decode( IndexType.self, forKey: .matchParticipantIndex)
    agreeingStage = try container.decode( StructureAgreeingStage.self, forKey: .agreeingStage)
    chosenStructureVariant = try container.decode( GameStartParameters?.self, forKey: .chosenStructureVariant)
    //chose = try container.decode( Bool.self, forKey: .chose)
    joiningGame = try container.decode( Bool.self, forKey: .joiningGame)
    notJoiningReason = try container.decode( NoJoinReason.self, forKey: .notJoiningReason)
    chips = try container.decode( ChipsCountType.self, forKey: .chips)
    placedInBet = try container.decode( ChipsCountType.self, forKey: .placedInBet)
    //toTransfer = try container.decode( ChipsCountType.self, forKey: .toTransfer)
    dropped = try container.decode( Bool.self, forKey: .dropped)
    actedInRound = try container.decode( Bool.self, forKey: .actedInRound)
    hand = try container.decode( CardStack.self, forKey: .hand)
    lastFinishingResult = try container.decode( FinishingSituation?.self, forKey: .lastFinishingResult)
} //init dec
    init(index: IndexType, initialChips: ChipsCountType) {
        self.matchParticipantIndex = index
        self.hand = CardStack(cards: [], ownerIndex: index, whoCanSee: .ownerOnly)
        self.chips = initialChips
    }
    @MainActor func setNotJoining(reason: NoJoinReason) -> Void {
        joiningGame = false
        notJoiningReason = reason
    }
    func resetForRound() -> Void {
        actedInRound = false
    }
    func resetForGame() -> Void {
        placedInBet = 0
        actedInRound = false
        dropped = false
        hand.clearCards()
        lastFinishingResult = nil
    }
    func applyTransfer( from transferAmounts: inout [PokerPlayer.IndexType: ChipsCountType]) -> Void {
        chips += (transferAmounts[matchParticipantIndex] ?? 0)
        lastFinishingResult?.didGetOverall = (transferAmounts[matchParticipantIndex] ?? 0)
        transferAmounts[matchParticipantIndex] = 0
    } //func
    
    enum NoJoinReason: Int, CaseIterable, Codable, Equatable {
        case none, quit, lost, timeOut, tied, first, won
        func quitOrOuted() -> Bool {
            [Self.quit, Self.timeOut].contains( self)
        } //func
    } //enum
        enum StructureAgreeingStage: Int, CaseIterable, Codable, Equatable {
    case stage1CanSuggest = 1
        case stage2CanOnlyChoose
        case stage3YesOrNo
        case stage4JoiningGame
        case gotOut
        static func naturalAfter(_ state: StructureAgreeingStage) -> StructureAgreeingStage {
            switch state {
            case .stage1CanSuggest:
                    return .stage2CanOnlyChoose
            case .stage2CanOnlyChoose:
                    return .stage3YesOrNo
            case .stage3YesOrNo:
                    return .stage4JoiningGame
            case .stage4JoiningGame:
                    return .stage4JoiningGame
            case .gotOut:
                    return .gotOut
            } //swi
        } //func
    } //enum
} //class player


extension Array where Element == PokerPlayer {
    func mapToParticipants( in match: GKTurnBasedMatch) -> [GKTurnBasedParticipant] {
        self.map({
            match.participants[$0.matchParticipantIndex]
        }) //map
    } //func
    func sortedByChipsAndOuted() -> Self {
        sorted( by: {
            if $0.notJoiningReason.quitOrOuted() == $1.notJoiningReason.quitOrOuted() {
                return $0.chips > $1.chips
            }
            return $1.notJoiningReason.quitOrOuted()
        })
    } //func
    func sortedByAgreeingStage(butBefore player: Element) -> [Element] {
        sorted(by: {
            if $0.agreeingStage.rawValue == $1.agreeingStage.rawValue {
                if player.matchParticipantIndex == $0.matchParticipantIndex {
                    return false
                }
                if player.matchParticipantIndex == $1.matchParticipantIndex {
                    return true
                }
                return $0.matchParticipantIndex < $1.matchParticipantIndex
            }
            return $0.agreeingStage.rawValue < $1.agreeingStage.rawValue
            // ($0.agreeingStage.rawValue < $1.agreeingStage.rawValue)
            //|| ( ($0.agreeingStage.rawValue == $1.agreeingStage.rawValue) && ($0.matchParticipantIndex < $1.matchParticipantIndex) && ($0.matchParticipantIndex != player.matchParticipantIndex) )
        }) //sort
    } //func
} //ext
extension Array where Element == PokerPlayer {
    var computedId: String {
        "pl" + self.map({
            "_\($0.matchParticipantIndex)"
        }).joined(separator: "_")
    } //cv
} //ext
extension Array where Element == PokerPlayer {
    var mapToIndices: [PokerPlayer.IndexType] {
        map({
            $0.matchParticipantIndex
        }) //map
    } //cv
    var stillHasntDropped: [PokerPlayer] {
        filter {
            !($0.dropped)
        }
    } //sig
    var stillJoiningGame: [PokerPlayer] {
        filter({
            $0.joiningGame
        })
    } //sjg
    func get( by mpIndex: PokerPlayer.IndexType) -> PokerPlayer? {
        first(where: {
            $0.matchParticipantIndex == mpIndex
        })
    } //func
    func nextOthersOf( mpIndex: PokerPlayer.IndexType, includeAtEnd: Bool) -> [PokerPlayer]? {
        nextOthers(ofFirst: {
            $0.matchParticipantIndex == mpIndex
        }, includeAtEnd: includeAtEnd)
    }
    func circularNext( after mpIndex: PokerPlayer.IndexType) -> PokerPlayer? {
        nextOthersOf( mpIndex: mpIndex, includeAtEnd: true)?.first
    } //next func
    func nextStillJoining( after mpIndex: PokerPlayer.IndexType) -> PokerPlayer? {
        nextOthersOf( mpIndex: mpIndex, includeAtEnd: true)?.stillJoiningGame.first
    } //func
    func nextNotDropped( after mpIndex: PokerPlayer.IndexType) -> PokerPlayer? {
        nextOthersOf( mpIndex: mpIndex, includeAtEnd: true)?.stillHasntDropped.first
    } //func
    func intersection(with other: Self) -> Self {
        filter({ eachPlayer in
            other.contains(where: {otherPlayer in
                eachPlayer.matchParticipantIndex == otherPlayer.matchParticipantIndex
            })
        })
    } //func
    
} //ext
