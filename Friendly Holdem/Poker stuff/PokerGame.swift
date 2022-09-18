//
//  PokerGame.swift
//  CardPlay
//
//  Created by Ionut on 03.08.2021.
//

import SwiftUI
import GameKit
import Algorithms

class HoldemGame: ObservableObject, Codable {
    static private let allCards: [Card] = newPokerDeck()

    @Published var gspStructureVariants: [GameStartParameters]
    var smallBlind: ChipsCountType
    var bigBlind: ChipsCountType
    internal var minRaise: ChipsCountType
    internal var turnTimeout: TimeInterval
    var timeoutToUse: TimeInterval {
        if gameState.isRoundState() {
            return turnTimeout
        }
        return GKTurnTimeoutNone
    } //cv
    var minRaiseTarget: ChipsCountType { currentBetSize + minRaise }
    @Published var dealerStack: CardStack
    @Published var allPlayers: [PokerPlayer]
    var joiningPlayers: [PokerPlayer] { allPlayers.stillJoiningGame }
    var joiningNotDropped: [PokerPlayer] { allPlayers.stillJoiningGame.stillHasntDropped }
    var playersWhoCanJoinNextDeal: [PokerPlayer] {
        joiningPlayers.filter({
            playerCanJoinNextDeal($0)
        }) //filt
    } //cv
    @Published var flop: CardStack
    @Published var gameState: GameStateType
    { didSet { debugMsg_( gameState.longDescription ) } } //ds
    @Published var actAsDealer: PokerPlayer.IndexType
    @Published public internal(set) var actingOrder: [PokerPlayer.IndexType] {
        didSet {
            ActingPlayaMenu = []
        }
    } //ds
    @Published var ActingPlayaMenu: [PokerPlayerAction]
    @Published var currentBetSize: ChipsCountType
    @Published var roundBettingStarted: Bool
    //private var roundBettingStarted: Bool {
        //allPlayers.contains(where: {
            //$0.actedInRound
        //})
    //}
    
    @Published var dealerStackVisible: Bool = true
    var totalPotSize: ChipsCountType {
        allPlayers.map({
            $0.placedInBet
        }).reduce( 0, { partial, current in
            partial + current
        })
    } //cv
    @Published var gameLog: [GameLogEntry] = []
    @Published var lastShowdownStatus:  DealShowdownStatus
    lazy var endStatus: GameEndStatus = updateEndStatus()
    
    static let cardMoveSound: GameSound? = try? GameSound(soundFile: "sfx2/deal1.mp3", maxNrOfPlayers: 5)
    static let cardTurnSound: GameSound? = try? GameSound(soundFile: "sfx2/swush1.mp3", maxNrOfPlayers: 5)
    static let smallBlindSound: GameSound? = try? GameSound(soundFile: "sfx2/coins/Bag-of-Coins-A.mp3", maxNrOfPlayers: 5)
    static let bigBlindSound: GameSound? = try? GameSound(soundFile: "sfx2/coins/Bag-of-Coins-B.mp3", maxNrOfPlayers: 5)
    static let regularBetSound: GameSound? = try? GameSound(soundFile: "sfx2/coins/Bag-of-coins-D.mp3", maxNrOfPlayers: 5)
    
    func toJSON() -> Data? {
        try? JSONEncoder().encode(self)
    } //func
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        //try container.encode(allCards, forKey: .allCards)
        try container.encode( smallBlind, forKey: .smallBlind)
        try container.encode( bigBlind, forKey: .bigBlind)
        try container.encode( turnTimeout, forKey: .turnTimeout)
        try container.encode(minRaise, forKey: .minRaise)
        try container.encode(dealerStack, forKey: .dealerStack)
        try container.encode(allPlayers, forKey: .allPlayers)
        try container.encode(flop, forKey: .flop)
        try container.encode(gameState, forKey: .gameState)
        try container.encode(actAsDealer, forKey: .actAsDealer)
        try container.encode( actingOrder, forKey: .actingOrder)
        try container.encode(ActingPlayaMenu, forKey: .ActingPlayaMenu)
        try container.encode(currentBetSize, forKey: .currentBetSize)
        try container.encode(roundBettingStarted, forKey: .roundBettingStarted)
        try container.encode(gspStructureVariants, forKey: .gspStructureVariants)
        try container.encode( lastShowdownStatus, forKey: .lastShowdownStatus)
        try container.encode( gameLog, forKey: .gameLog)
    } //enc
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        smallBlind = try container.decode(ChipsCountType.self, forKey: .smallBlind)
        bigBlind = try container.decode(ChipsCountType.self, forKey: .bigBlind)
        turnTimeout = try container.decode(TimeInterval.self, forKey: .turnTimeout)
        minRaise = try container.decode(ChipsCountType.self, forKey: .minRaise)
        dealerStack = try container.decode(CardStack.self, forKey: .dealerStack)
        allPlayers = try container.decode([PokerPlayer].self, forKey: .allPlayers)
        flop = try container.decode(CardStack.self, forKey: .flop)
        gameState = try container.decode(GameStateType.self, forKey: .gameState)
        actAsDealer = try container.decode(PokerPlayer.IndexType.self, forKey: .actAsDealer)
        actingOrder = try container.decode( [PokerPlayer.IndexType].self, forKey: .actingOrder)
        ActingPlayaMenu = try container.decode([PokerPlayerAction].self, forKey: .ActingPlayaMenu)
        currentBetSize = try container.decode(ChipsCountType.self, forKey: .currentBetSize)
        roundBettingStarted = try container.decode(Bool.self, forKey: .roundBettingStarted)
        gspStructureVariants = try container.decode([GameStartParameters].self, forKey: .gspStructureVariants)
        lastShowdownStatus = try container.decode( DealShowdownStatus.self, forKey: .lastShowdownStatus)
        gameLog = try container.decode( [GameLogEntry].self, forKey: .gameLog)
        
        putStaticCards()
        syncLastShowdownStatusPlayers()
    } //init dec
    func syncLastShowdownStatusPlayers() -> Void {
        let newShowdownWinners: [[PokerPlayer]] = lastShowdownStatus.winners.map({ eachPlace in
            eachPlace.map({ eachPlayer in
                self.allPlayers.get( by: eachPlayer.matchParticipantIndex) ?? eachPlayer
            })
        })
        self.lastShowdownStatus.winners = newShowdownWinners
    } //func
    init( numberOfPlayers: Int) {
        self.smallBlind = 1//smallBlind
        self.bigBlind = 1//max(bigBlind, self.smallBlind)
        self.minRaise = 1//max(minRaise, 0)
        self.turnTimeout = 0
        self.gspStructureVariants = []
        self.lastShowdownStatus = DealShowdownStatus(winners: [], pots: [], numberOfPlayers: numberOfPlayers)
        
        self.dealerStack = CardStack(cards: [], ownerIndex: nil, whoCanSee: .noOne)
        self.flop = CardStack(cards: [], ownerIndex: nil, whoCanSee: .everyOne)
        
        currentBetSize = 0
        gameState = .fresh
            roundBettingStarted = false
        actAsDealer = 0
        actingOrder = []
        ActingPlayaMenu = []

        allPlayers = []

        for ip in 0 ..< numberOfPlayers {
            allPlayers.append(PokerPlayer(index: ip, initialChips: 0))
        }
    } //init
    public func putStaticCards() -> Void {
        dealerStack.putStaticCards(from: Self.allCards)
        flop.putStaticCards(from: Self.allCards)
        for p in allPlayers {
            p.hand.putStaticCards(from: Self.allCards)
        }
    } //func
    func stillNeedsToBet( _ player: PokerPlayer) -> Bool {
        player.joiningGame
        && !player.dropped
        && !player.isAllIn
        && player.placedInBet < currentBetSize
    } //func
    func generalNextPlayers( after playerIdx: PokerPlayer.IndexType) -> [PokerPlayer] {
        if gameState == .negotiatingStructure {
            return negotiatingActingOrder( after: playerIdx)
        }
        else if GameStateType.roundStates.contains( gameState) {
            return inRoundActingOrder( after: playerIdx) ?? allPlayers.stillJoiningGame.stillHasntDropped
        }
        else if gameState == .presentingShowdown {
            return forShowdownActingOrder( after: playerIdx)
        }
        else {
            return (allPlayers.nextOthersOf( mpIndex: playerIdx, includeAtEnd: false) ?? allPlayers ).stillJoiningGame
        }
    } //func
    func compileActingMenu() -> Void {
        guard let firstActor = actingOrder.first else {
            return
        }
        ActingPlayaMenu = []
        if canCheck() {
            ActingPlayaMenu.append(.check())
        }
        if canBet( by: firstActor) {
            ActingPlayaMenu.append( roundBettingStarted ? .raise() : .bet() )
        }
        if canBetAllIn( by: firstActor) {
            ActingPlayaMenu.append( .allInBet())
        }
            if canCall( by: firstActor) {
            ActingPlayaMenu.append( .call())
        }
        if canStayAllIn( by: firstActor) {
            ActingPlayaMenu.append(.stayAllIn())
        }
        ActingPlayaMenu.append(.drop())
    } //func
    var smallBlinder: PokerPlayer? {
        shouldBeNextActing(after: actAsDealer)
    } //cv
    var bigBlinder: PokerPlayer? {
        shouldBeNextActing(after: smallBlinder?.matchParticipantIndex)
    } //cv
    func setRandomDealer() -> Void {
        if !joiningPlayers.isEmpty {
            let ndIdx = Int.random(in: 0 ..< joiningPlayers.count)
            actAsDealer = joiningPlayers[ ndIdx ].matchParticipantIndex
        }
    } //func
    func setNextDealer() -> Void {
        actAsDealer = shouldBeNextDealer()?.matchParticipantIndex ?? actAsDealer
    } //func
    private func shouldBeNextDealer() -> PokerPlayer? {
        allPlayers.nextStillJoining(after: actAsDealer)
    } //func
    func shouldBeNextActing(after playerIdx: PokerPlayer.IndexType?) -> PokerPlayer? {
        guard let old = playerIdx else {
            return nil
        }
        return allPlayers.nextOthersOf( mpIndex: old, includeAtEnd: true)?.stillJoiningGame.stillHasntDropped.first
    } //func
    func isActingPlayer(_ playerIdx: PokerPlayer.IndexType) -> Bool {
        return actingOrder.first == playerIdx
    } //func
    func isActingPlayer(_ player: PokerPlayer) -> Bool {
        return isActingPlayer( player.matchParticipantIndex)
    } //func
    func inRoundActingOrder( after playerIdx: PokerPlayer.IndexType) -> [PokerPlayer]? {
        guard let nextPlayer = shouldBeNextActing(after: playerIdx) else {
            return nil
        }
        return inRoundActingOrder( startingFrom: nextPlayer.matchParticipantIndex)
    } //func
    func inRoundActingOrder( startingFrom playerIdx: PokerPlayer.IndexType) -> [PokerPlayer]? {
        allPlayers.cycleFrom( first: {
            $0.matchParticipantIndex == playerIdx
        })?.stillJoiningGame.stillHasntDropped
    } //func
    @MainActor func setInRoundActingOrder( startingWith playerIdx: PokerPlayer.IndexType?, andCompileMenu: Bool) -> Bool {
        // returns true if success
        guard let starter = playerIdx,
              let nextPls = inRoundActingOrder(startingFrom: starter)
        else {
            return false
        }
        actingOrder = nextPls.mapToIndices
        if andCompileMenu {
            compileActingMenu()
        }
        return true
    } //func
    @MainActor func setInRoundNextActingOrder( after playerIdx: PokerPlayer.IndexType?, andCompileMenu: Bool) -> Bool {
        //returns true if success
        guard let nextPlayer = shouldBeNextActing(after: playerIdx) else {
            return false
        }
        return setInRoundActingOrder(startingWith: nextPlayer.matchParticipantIndex, andCompileMenu: andCompileMenu)
    } //func
    func negotiatingActingOrder( after playerIdx: PokerPlayer.IndexType) -> [PokerPlayer] {
        guard let player = allPlayers.get( by: playerIdx) else {
            return allPlayers.stillJoiningGame
        }
        return joiningPlayers.sortedByAgreeingStage( butBefore: player)
    } //func
    private func forShowdownActingOrder( after playerIdx: PokerPlayer.IndexType) -> [PokerPlayer] {
        let ordered = forShowdownActingOrder( startingWith: playerIdx)
        return ordered.cycleFrom( arrayIdx: 1) ?? ordered
    } //func
        private func forShowdownActingOrder( startingWith playerIdx: PokerPlayer.IndexType) -> [PokerPlayer] {
        var continuers = playersWhoCanJoinNextDeal
        if continuers.isEmpty {
            continuers = joiningPlayers
        }
        let ordered = continuers.cycleFrom( first: {
            $0.matchParticipantIndex == playerIdx
        }) ?? continuers
        return ordered
    } //func
    @MainActor private func setForShowdownActingOrder( startingWith playerIdx: PokerPlayer.IndexType) -> Void {
        actingOrder = forShowdownActingOrder(startingWith: playerIdx).mapToIndices
    } //func
    @MainActor func playerJustQuit(player: PokerPlayer) -> Void {
        /*
        if let firstAct = actingOrder.first,
           firstAct == player.matchParticipantIndex {
            _ = setInRoundNextActingOrder( after: player.matchParticipantIndex, andCompileMenu: true)
        }
         */
    } //func
    func enterNegotiating() -> Void {
        setRandomDealer()
        gameState = .negotiatingStructure
    } //func
    func playerCanJoinNextDeal(_ player: PokerPlayer) -> Bool {
        player.chips >= bigBlind
        && player.chips > 0
    } //func
    @MainActor func setWhoCantContinue() -> Void {
        for player in joiningPlayers {
            if !playerCanJoinNextDeal( player) {
                debugMsg_("\(player.matchParticipantIndex) cant continue")
                player.setNotJoining( reason: .lost)
            }
        } //for
    } //func
    func putSmallBlind() -> Bool {
        guard let toPutSmall = smallBlinder else {
            return false
        } //gua
        gameLog.append(.init(gameAction: .smallBlind, actors: [toPutSmall.matchParticipantIndex], amount: smallBlind))
        return setBet( for: toPutSmall.matchParticipantIndex, to: smallBlind, ignoreMinRaise: true)
    } //small func
    func putBigBlind() -> Bool {
        guard let toPutBig = bigBlinder else {
            return false
        } //gua
        gameLog.append(.init(gameAction: .bigBlind, actors: [toPutBig.matchParticipantIndex], amount: bigBlind))
        return setBet( for: toPutBig.matchParticipantIndex, to: bigBlind, ignoreMinRaise: true)
    } //small func
    func computePotsFromJoining() -> [PokerPot] {
        let pots: [PokerPot] = pot_getCutPointsFromJoining().map { cp in
            let p = PokerPot()
            p.cutPoint = cp
            return p
        } //map
        for i in 1 ..< pots.count {
            pots[ i].fromPoint = pots[ i - 1].cutPoint
        } //for
        for pot in pots {
            for p in joiningPlayers {
                if p.placedInBet >= pot.cutPoint {
                    pot.contributers.append( p)
                } //if
            } //for
        } //for
        return pots
    } //func
    func computePots() -> [PokerPot] {
        let pots: [PokerPot] = pot_getCutPoints().map { cutPoint in
            let p = PokerPot()
            p.cutPoint = cutPoint
            return p
        } //map
        for i in 1 ..< pots.count {
            pots[ i].fromPoint = pots[ i - 1].cutPoint
        } //for
        for pot in pots {
            for p in allPlayers {
                if p.placedInBet >= pot.cutPoint {
                    pot.contributers.append( p)
                } //if
            } //for
        } //for
        return pots
    } //func
    private func pot_getCutPointsFromJoining() -> [ChipsCountType] {
        var r = [currentBetSize]
        for player in joiningPlayers {
            let pib = player.placedInBet
            if pib > 0 && pib < currentBetSize && !r.contains(pib) {
                r.append(pib)
            } //if
        } //for
        return r.sorted()
    } //func
    private func pot_getCutPoints() -> [ChipsCountType] {
        var r = [currentBetSize]
        for player in allPlayers {
            let pib = player.placedInBet
            if pib > 0 && pib < currentBetSize && !r.contains(pib) {
                r.append(pib)
            } //if
        } //for
        return r.sorted()
    } //func
    func shouldGoToShowdown() -> Bool {
        if GameStateType.roundStates.contains( gameState) && !canContinueDeal() {
            return true
        }
        if !(GameStateType.finalStates.contains( gameState)) && !stillCanPlay() {
            return true
        }
        return false
    } //func
    func canContinueDeal() -> Bool {
        joiningNotDropped.count > 1
    } //func
    func shouldContinueDeal() -> Bool {
        GameStateType.roundStates.contains( gameState)
    } //func
    func stillCanPlay() -> Bool {
        joiningPlayers.count > 1
    } //func
    func roundEnded() -> Bool {
        if !canContinueDeal() {
            return true
        }
        let needToPut = joiningNotDropped.filter({
            //printPlayer(p: $0)
            return !(
                (($0.placedInBet == currentBetSize) || $0.isAllIn)
                && !$0.stillNeedToAct)
        })
        if needToPut.isEmpty {
            return true
        }
        return false
    }
    enum canSetBetResult: String {
    case raiseBet, call, allIn
        case dontHaveEnough, lessThanMin, someOtherError, invalidPlayer
        
        var succeeded: Bool {
            [Self.raiseBet, Self.call, Self.allIn].contains(self)
        } //cv
    } //enum
    func canSetBet(for playerIdx: PokerPlayer.IndexType, to amount: ChipsCountType, ignoreMinRaise: Bool = false) -> canSetBetResult {
        guard let p = joiningPlayers.get( by: playerIdx) else {
            return .invalidPlayer
        }
        if amount == p.chips {
            return .allIn
        }
        if amount == currentBetSize && p.chips >= amount {
            return .call
        }
        let minTargetToCompare = ignoreMinRaise ? currentBetSize : minRaiseTarget
        if amount >= minTargetToCompare && p.chips >= amount {
            return .raiseBet
        }
        if amount > p.chips {
            return .dontHaveEnough
        }
        if amount < minTargetToCompare {
            return .lessThanMin
        }
        return .someOtherError
    } //func
    func setBet( for playerIdx: PokerPlayer.IndexType, to amount: ChipsCountType, ignoreMinRaise: Bool = false) -> Bool {
        guard let p = joiningPlayers.get( by: playerIdx) else {
            return false
        }
        if canSetBet(for: playerIdx, to: amount, ignoreMinRaise: ignoreMinRaise).succeeded {
            p.placedInBet = amount
            p.actedInRound = true
            currentBetSize = max( currentBetSize, p.placedInBet)
            roundBettingStarted = true
            return true
        }
        return false
    }
    func canRaise( byPlayer playerIdx: PokerPlayer.IndexType, to amount: ChipsCountType) -> Bool {
        canSetBet(for: playerIdx, to: amount) == .raiseBet
    } //func
    func canCall( by playerIdx: PokerPlayer.IndexType) -> Bool {
        guard let player = joiningPlayers.get( by: playerIdx) else {
            return false
        }
        return roundBettingStarted
            && !player.isAllIn
        && player.chips >= currentBetSize
    } //func
    func canStayAllIn( by playerIdx: PokerPlayer.IndexType) -> Bool {
        guard let player = joiningPlayers.get( by: playerIdx) else {
            return false
        }
        return player.isAllIn
        && roundBettingStarted
    } //func
    func canBet( by playerIdx: PokerPlayer.IndexType) -> Bool {
        guard let player = joiningPlayers.get( by: playerIdx) else {
            return false
        }
        return player.chips >= minRaiseTarget
    } //func
    func canBetAllIn( by playerIdx: PokerPlayer.IndexType) -> Bool {
        guard let player = joiningPlayers.get( by: playerIdx) else {
            return false
        }
        return !player.isAllIn
    } //func
    func canCheck() -> Bool {
        !roundBettingStarted
    } //func
    @MainActor private func retrieveAllCards() -> Void {
        dealerStack = CardStack( cards: HoldemGame.allCards.shuffled(), ownerIndex: nil, whoCanSee: .noOne)
        for p in allPlayers {
            p.hand.clearCards()
        }
        flop.clearCards()
    } //retrieve
    
    @MainActor private func enterShowDownAndPresent( orderStartingWith: PokerPlayer.IndexType) async -> Void {
        _ = await enterShowDownAsync()
        setForShowdownActingOrder( startingWith: orderStartingWith)
        gameState = .presentingShowdown
    } //func
    @MainActor private func enterShowDownAsync() async -> Bool {
        gameState = .computingShowdown
        gameLog.append(.init(gameAction: .wentToShowdown))
        return await computeShowdown()
    } //func
    @MainActor func exitPresentingShowdown() async -> Void {
        setWhoCantContinue()
        if stillCanPlay() {
            await beginNewDealAsync()
        } else {
            goToFinalShow()
        }
    } //func
    private func isThereMoneyInGame() -> Bool {
        allPlayers.contains( where: {
            $0.chips > 0
        })
    } //func
    func updateEndStatus() -> GameEndStatus {
        let fin = GameEndStatus()
        //guard gameState == .finalShow else {
            //return fin
        //}
        let winners = allPlayers.sortedByChipsAndOuted()
        fin.finishOrder = winners.chunked( by: {
            $0.chips == $1.chips
            && $0.notJoiningReason.quitOrOuted() == $1.notJoiningReason.quitOrOuted()
        }).map({
            Array($0)
        })
        return fin
    } //func
    @MainActor private func goToFinalShow() -> Void {
        debugMsg_("going to final")
        let fin = updateEndStatus()
        fin.setOutcomes()
        for player in allPlayers {
            if player.notJoiningReason == .none {
                player.notJoiningReason = .lost
            }
        } //for
        endStatus = fin
        gameState = .finalShow
        gameLog.append(.init(gameAction: .gameEnded))
    } //func
    @MainActor func enterRound0Async() -> Void {
        retrieveAllCards()
        currentBetSize = 0
        _ = setInRoundActingOrder( startingWith: actAsDealer, andCompileMenu: false)
        roundBettingStarted = false
        for p in allPlayers {
            p.resetForGame()
            p.resetForRound()
        }
    } //reset
    @MainActor func enterRoundAsync(_ newState: GameStateType) -> Bool {
        var actAfter: PokerPlayer.IndexType? = actAsDealer
        switch newState {
        case .fresh, .negotiatingStructure, .startingGame, .startingDeal, .dealinghands, .dealingFlop, .dealingTurn, .dealingRiver, .computingShowdown, .presentingShowdown, .finalShow:
            return false
        case .round1:
            actAfter = bigBlinder?.matchParticipantIndex
        case .round2, .round3, .round4:
            actAfter = actAsDealer
        } //swi
        guard setInRoundNextActingOrder( after: actAfter, andCompileMenu: false) else {
            return false
        }
        gameState = newState
        if newState != .round1 {
            roundBettingStarted = false
            for player in allPlayers {
                player.resetForRound()
            } //for p
        } //if 2 3 4
        compileActingMenu()
        return true
    } //func
    @MainActor func beginNewDealAsync() async -> Void {
        gameState = .startingDeal
        gameLog.append(.init(gameAction: .startedGame))
        setNextDealer()
        enterRound0Async()
        await placeBlindsAndDealHandsAsync(moneyInterval: 1, cardInterval: 0.7)
        _ = enterRoundAsync(.round1)
    } //func
    @MainActor private func placeBlindsAndDealHandsAsync(moneyInterval: Double, cardInterval: Double) async -> Void {
        _ = self.putSmallBlind()
        Self.smallBlindSound?.prepareAndPlay()
        try? await Task.sleep( seconds: moneyInterval)
        _ = self.putBigBlind()
        Self.bigBlindSound?.prepareAndPlay()
        try? await Task.sleep( seconds: moneyInterval)
        let next = allPlayers.nextOthersOf( mpIndex: actAsDealer, includeAtEnd: true)?.stillJoiningGame ?? []
        for _ in 1...2 {
            for p in next {
                Self.cardMoveSound?.prepareAndPlay()
                withAnimation {
                    _ = self.dealerStack.giveLastCard(to: p.hand)
                } //wa
                try? await Task.sleep( seconds: cardInterval)
            } //for p
        } //for c
    } // func
    @MainActor private func dealFlopAsync( interval: Double = 0.7) async -> Void {
        gameState = .dealingFlop
        gameLog.append(.init(gameAction: .dealtFlop))
        var cardsDealt = 0
        for _ in 0..<3 {
            Self.cardMoveSound?.prepareAndPlay()
            withAnimation {
                _ = self.dealerStack.giveLastCard(to: self.flop)
            } //flop
            cardsDealt += 1
            try? await Task.sleep( seconds: interval)
        } //for
    } //func
    @MainActor private func dealTurnAsync() -> Void {
        gameState = .dealingTurn
        gameLog.append(.init(gameAction: .dealtTurn))
        Self.cardMoveSound?.prepareAndPlay()
        withAnimation {
            _ = self.dealerStack.giveLastCard(to: self.flop)
        } //turn
    } //func
    @MainActor private func dealRiverAsync() -> Void {
        gameState = .dealingRiver
        gameLog.append(.init(gameAction: .dealtRiver))
        Self.cardMoveSound?.prepareAndPlay()
        withAnimation {
            _ = dealerStack.giveLastCard( to: flop)
        } //river
    } //func
    @MainActor func drop3(  for player: PokerPlayer) -> Void {
        player.dropped = true
        player.actedInRound = true
        gameLog.append(.init(gameAction: .dropped, actors: [player.matchParticipantIndex], amount: player.placedInBet))
    } //func
    @MainActor func check3( for player: PokerPlayer) -> Bool {
        guard canCheck() else {
            debugMsg_("no check condition")
            return false
        }
        player.actedInRound = true
        gameLog.append(.init(gameAction: .checked, actors: [player.matchParticipantIndex]))
        return true
    } //func
    @MainActor func call3( for player: PokerPlayer) -> Bool {
        guard canCall( by: player.matchParticipantIndex) else {
        debugMsg_("cant call")
        return false
    }
        guard setBet( for: player.matchParticipantIndex, to: currentBetSize) else {
        debugMsg_("model bet set error")
        return false
    }
        Self.regularBetSound?.prepareAndPlay()
        gameLog.append(.init(gameAction: .called, actors: [player.matchParticipantIndex], amount: player.placedInBet))
        return true
} //func
    @MainActor func stay3( for player: PokerPlayer) -> Bool {
        guard canStayAllIn( by: player.matchParticipantIndex) else {
            debugMsg_("no stay condition")
            return false
        }
        player.actedInRound = true
        gameLog.append(.init(gameAction: .stayed, actors: [player.matchParticipantIndex], amount: player.placedInBet))
        return true
    } //func
    @MainActor func allInBet3( for player: PokerPlayer) -> Bool {
        guard canBetAllIn( by: player.matchParticipantIndex) else {
            debugMsg_("can not go all in")
            return false
        }
        guard setBet( for: player.matchParticipantIndex, to: player.chips) else {
            debugMsg_("model bet set error")
            return false
        }
        Self.regularBetSound?.prepareAndPlay()
        gameLog.append(.init(gameAction: .wentAllIn, actors: [player.matchParticipantIndex], amount: player.placedInBet))
        return true
    } //func
    @MainActor func raise3( by player: PokerPlayer, to amount: ChipsCountType) -> Bool {
        guard canRaise( byPlayer: player.matchParticipantIndex, to: amount) else {
            debugMsg_("cant raise to this")
            return false
        }
        guard setBet( for: player.matchParticipantIndex, to: amount) else {
            debugMsg_("model bet set error")
            return false
        }
        Self.regularBetSound?.prepareAndPlay()
        gameLog.append(.init(gameAction: .raised, actors: [player.matchParticipantIndex], amount: player.placedInBet))
        return true
    } //raise
    @MainActor func afterActionCheck3( actedBy: PokerPlayer.IndexType, advanceActingOrderIfInRound: Bool) async -> Bool {
        //returns true if changes game
        if shouldContinueDeal() && !canContinueDeal() {
            await enterShowDownAndPresent( orderStartingWith: actedBy)
            return true
        } //gua
        if !([GameStateType.presentingShowdown, .finalShow].contains( gameState))
            && !stillCanPlay() {
            await enterShowDownAndPresent( orderStartingWith: actedBy)
            return true
        }
        guard GameStateType.roundStates.contains( gameState) else {
            return false
        } //gua
        guard roundEnded() else {
            //still in round
            if advanceActingOrderIfInRound {
                _ = setInRoundNextActingOrder(after: actingOrder.first, andCompileMenu: true)
                return true
            }
            return false
        } //gua
        switch gameState {
        case .round1:
            await dealFlopAsync( interval: 0.7)
                _ = enterRoundAsync(.round2)
            return true
        case .round2:
            dealTurnAsync()
            _ = enterRoundAsync(.round3)
            return true
        case .round3:
            dealRiverAsync()
            _ = enterRoundAsync(.round4)
            return true
        case .round4:
            await enterShowDownAndPresent( orderStartingWith: actedBy)
            return true
        default:
            //error
            debugMsg_("game state error")
            break
        } //swi
        return false
    } //func
    func shouldNotBeMyTurn( for player: PokerPlayer) -> Bool {
        actingOrder.first != player.matchParticipantIndex
    } //func
    @MainActor func adjustActingOrder( from player: PokerPlayer) -> Void {
        //actingOrder = joiningPlayers.sortedByAgreeingStage( butBefore: player).mapToIndices
        if GameStateType.roundStates.contains( gameState) {
            _ = setInRoundActingOrder(startingWith: player.matchParticipantIndex, andCompileMenu: GameStateType.roundStates.contains( gameState))
        }
        else {
            actingOrder = allPlayers.cycleFrom( first: {
                $0.matchParticipantIndex == player.matchParticipantIndex
            })?.stillJoiningGame.mapToIndices ?? joiningPlayers.mapToIndices
        } //else
    } //func
    @MainActor func evaluateGame( by localPlayer: PokerPlayer) async -> Bool {
        //return true if need to send back
        //guard canContinueDeal() else {
            //await enterShowDownAndPresent( orderStartingWith: localPlayer.matchParticipantIndex)
            //return true
        //}
        var changed = false
        if shouldNotBeMyTurn( for: localPlayer) {
            debugMsg_("me \(localPlayer.matchParticipantIndex)")
            debugMsg_("old order " + actingOrder.map({ "\($0)" }).joined(separator: ", ") )
            debugMsg_("old order " + actingOrder.map({ GameController.LocalizednoJoinReason(for: allPlayers[$0], in: nil, withName: false, isLocal: false) }).joined(separator: ", ") )
            adjustActingOrder( from: localPlayer)
            debugMsg_("new order " + actingOrder.map({ "\($0)" }).joined(separator: ", ") )
            changed = true
        }
        guard !(await afterActionCheck3(actedBy: localPlayer.matchParticipantIndex, advanceActingOrderIfInRound: false)) else {
            return true
        } //gua
        switch gameState {
        case .fresh:
            enterNegotiating()
            if await evaluateGame( by: localPlayer) {
                return true
            }
            break
        case .negotiatingStructure:
            //for player in allPlayers {
                //player.chose = false
            //}
            break
        case .presentingShowdown:
                if allJoiningAcknowledged( in: lastShowdownStatus) {
                await exitPresentingShowdown()
                return true
            }
            break
        default:
            break
        } //swi
        return changed
    } //func

    static func newPokerDeck() -> [Card] {
        var deck = [Card]()
        for suit in RawCardSuit.allSuits {
            for i in 0..<PokerRules.suitSymbols.count {
                deck.append(Card(rawCard: RawCard(suit: suit, symbol: PokerRules.suitSymbols[ i]), actSuits: [suit], actValues: PokerRules.suitActValues[ i]))
            }
        } //for suits
        //deck.append(Card(rawCard: RawCard(suit: .red, symbol: .joker), actSuits: RawCardSuit.allSuits, actValues: PokerRules.jokerActValues))
        //deck.append(Card(rawCard: RawCard(suit: .black, symbol: .joker), actSuits: RawCardSuit.allSuits, actValues: PokerRules.jokerActValues))
        return deck
    } //sta func
    enum CodingKeys: CodingKey {
             case smallBlind,
        bigBlind,
                  minRaise,
                  turnTimeout,
        dealerStack,
        allPlayers,
        flop,
        gameState,
        actAsDealer,
        actingOrder,
        ActingPlayaMenu,
        currentBetSize,
        roundBettingStarted,
                  gspStructureVariants,
                  lastShowdownStatus,
                  gameLog
    } //codingKeys
} //game

