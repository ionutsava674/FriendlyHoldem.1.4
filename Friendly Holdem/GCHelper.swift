//
//  GCHelper.swift
//  CardPlay
//
//  Created by Ionut on 07.11.2021.
//

import GameKit
import SwiftUI

class GCHelper: NSObject, ObservableObject {
    static let helper = GCHelper()
    private let MaxNumberOfOpenGames = 30
    static var msgCount:Int = 0
    func incMatchMsg() -> String {
        guard let match = currentMatch else {
            return "nil message"
        }
        Self.msgCount += 1
        return (match.localParticipant()?.player?.alias ?? "unknown") + "-\(Self.msgCount)"
    }
    //static let refreshSound: GameSound? = try? GameSound(soundFile: "sfx2/bottle_pop_2.wav", maxNrOfPlayers: 5)
    
    @Published var userCanPlay = UserCanPlay.notLogged
    @Published var authenticationState: AuthenticationState = .unAuthenticated
    func updateAuthd() -> Void {
        self.authenticationState = GKLocalPlayer.local.isAuthenticated ? .authenticated : .unAuthenticated
        
        userCanPlay = (authenticationState == .authenticated
        && !GKLocalPlayer.local.isUnderage
            && !GKLocalPlayer.local.isMultiplayerGamingRestricted)
        ? .yes
        : !GKLocalPlayer.local.isAuthenticated
        ? .notLogged
        : GKLocalPlayer.local.isUnderage
        ? .underAge
        : GKLocalPlayer.local.isMultiplayerGamingRestricted
        ? .noMulti
        : .other
    } //func
    private var handlerSet = false
    @MainActor func beginAuthentication() async -> Void {
        guard !handlerSet else {
            return
        }
        handlerSet = true
            authenticationState = .inProgress
        // GKLocalPlayer.local.register(self)
        GKLocalPlayer.local.authenticateHandler = { [weak self] gcAuthVC, error in
            //let en = error != nil ? 1 : 0
            //let vn = gcAuthVC != nil ? 1 : 0
            //debugMsg_("auth \(vn) \(en)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                GKAccessPoint.shared.isActive = true
            }
                guard error == nil else {
                    self?.updateAuthd()
                    return
                } //gua
            self?.updateAuthd()
        } //clo
        GKLocalPlayer.local.register(self)
    } //func
    @Published public private(set) var currentMatch: GKTurnBasedMatch? {
        didSet {
            currentGame = nil
            prepareForNewlyJoined = false
        }
    } //ds
    @Published public private(set) var currentGame: HoldemGame? {
        didSet {
            gameCtl.busy = 0
        } //ds
    } //curgame
    @Published var availableMatches: [GKTurnBasedMatch]?
    @Published var doneMatches: [GKTurnBasedMatch] = []
    @Published var retrievingAvailableMatches: Bool = false
    private var selectingMatch = false
    @Published public private(set) var findingNewGame = false
    private var prepareForNewlyJoined = false
    
    @Published var turnEventConfirmation: TurnEventConfirmation?
    
    let gameCtl = GameController()
    
    @Published var outMsg: String = ""
    
    @Published var showingQuitDialog = false
    @Published var errorDialog: ErrorMessageContainer?
    @Published var showingErrorDialog = false
    @MainActor func displayError( msg: String, title: String = "error") -> Void {
        self.errorDialog = ErrorMessageContainer( msg: msg, title: title)
        self.showingErrorDialog = true
    } //func

} //gch
extension GCHelper {
    @MainActor func ClearCurrentMatch() async -> Void {
        await loadMatchToCurrent( nil)
    } //func
    @MainActor func refreshCurrentMatch() async -> Bool {
        guard !selectingMatch,
              let chMatch = currentMatch
        else {
            return false
        }
        do {
            let newMatch = try await GKTurnBasedMatch.load( withID: chMatch.matchID)
            guard newMatch.differsDataOrExchanges( from: chMatch) else {
                return false
            }
            debugMsg_("updating")
            guard gameCtl.busy == 0 else {
                debugMsg_("sorry busy (refresh)")
                return false
            } //gua
            await self.loadMatchToCurrent( newMatch)
            //Self.refreshSound?.prepareAndPlay()
            return true
        } catch {
            return false
        }
    } //func
    @MainActor func FindNewGame( with numberOfPlayers: Int) async -> Void {
        guard !findingNewGame else {
            return
        }
        withAnimation {
            findingNewGame = true
        }
        defer {
            withAnimation {
                findingNewGame = false
            }
        } //defer
        //try? await Task.sleep(seconds: 10)
        //return
        let req = GKMatchRequest()
        req.minPlayers = numberOfPlayers
        req.maxPlayers = numberOfPlayers
        req.inviteMessage = "How about a friendly game of hold'em"
        req.defaultNumberOfPlayers = numberOfPlayers
        debugMsg_("n1")
        prepareForNewlyJoined = true
        guard let newMatch = try? await GKTurnBasedMatch.find( for: req) else {
            displayError( msg: "Couldnt find match")
            return
        }
        debugMsg_("n2")
        _ = selectAvailableMatch( matchID: newMatch.matchID, onError: { error in
            self.displayError( msg: "Couldnt load match")
        }) //clo
    } //func
    func selectAvailableMatch(matchID: String, onError: ((Error) -> Void)? = nil) -> Bool {
        if selectingMatch {
            return false
        }
        selectingMatch = true
        GKTurnBasedMatch.load( withID: matchID) { newMatch, error in
            if let newMatch = newMatch {
                self.selectAvailableMatchDirectly(match: newMatch)
            }
            if let error = error {
                self.selectingMatch = false
                onError?(error)
            }
        } //clo
        return true
    } //func
    private func selectAvailableMatchDirectly( match: GKTurnBasedMatch) -> Void {
        self.availableMatches = nil
        Task {
            await self.loadMatchToCurrent( match)
        } //tk
        self.selectingMatch = false
    } //func
    @MainActor func verifyNumberOfActiveMatches() async -> Bool {
        do {
            let matchList = try await GKTurnBasedMatch.loadMatches().filter({
                $0.isOpenOrMatching()
            })
            if matchList.count >= MaxNumberOfOpenGames {
                self.displayError(msg: "You have more than \(MaxNumberOfOpenGames) open games.")
            }
                                         return matchList.count < MaxNumberOfOpenGames
                                         } catch {
                                             self.displayError(msg: error.localizedDescription)
                return false
                                         } //try
    } //func
    @MainActor func downloadAvailableMatches() async -> Void {
        guard !retrievingAvailableMatches, !selectingMatch else {
            return
        }
        retrievingAvailableMatches = true
        do {
            let matchList = try await GKTurnBasedMatch.loadMatches()
            doneMatches = Array( matchList.filter({
                $0.status == .ended
                && !$0.hasUnknownMatchingParticipants()
            }).sorted(by: {
                $0.lastActionDate() > $1.lastActionDate()
            }).prefix(30))
            availableMatches = matchList.filter({
                $0.isOpenOrMatching()
            }).sorted(by: {
                let l0 = $0.isLocalPlayersTurn()
                let l1 = $1.isLocalPlayersTurn()
                if l0 != l1 {
                    return l0
                }
                //let a0 = $0.status == .open
                return $0.lastActionDate() > $1.lastActionDate()
            }) //sort
        } catch {
            availableMatches = nil
            self.displayError(msg: error.localizedDescription)
            debugMsg_(error.localizedDescription)
        }
        retrievingAvailableMatches = false
    } //func
}
extension GCHelper: GKTurnBasedEventListener {
    
} //ext
extension GCHelper: GKLocalPlayerListener {
    func player(_ player: GKPlayer, matchEnded match: GKTurnBasedMatch) {
        // debugMsg_("match ended for \(player.alias).")
    }
    public func player(_ player: GKPlayer, wantsToQuitMatch match: GKTurnBasedMatch) {
    } //wt quit
    func player(_ player: GKPlayer, didRequestMatchWithOtherPlayers playersToInvite: [GKPlayer]) {
    }
    func player(_ player: GKPlayer, receivedExchangeRequest exchange: GKTurnBasedExchange, for match: GKTurnBasedMatch) {
        //debugMsg_("ex  c exchanges count \(String(describing: match.completedExchanges?.count))")
        guard match.isLocalPlayersTurn() else {
            return
        }
        checkBusyAndContinue( player, receivedTurnEventFor: match, didBecomeActive: false, busyReason: "exchange")
    } //func
    func player(_ player: GKPlayer, receivedExchangeCancellation exchange: GKTurnBasedExchange, for match: GKTurnBasedMatch) {
        debugMsg_("cancelledEx  c exchanges count \(String(describing: match.completedExchanges?.count))")
        //self.player(player, receivedTurnEventFor: match, didBecomeActive: false)
    }
    func player(_ player: GKPlayer, receivedExchangeReplies replies: [GKTurnBasedExchangeReply], forCompletedExchange exchange: GKTurnBasedExchange, for match: GKTurnBasedMatch) {
        //debugMsg_("rep  c exchanges count \(String(describing: match.completedExchanges?.count))")
        //self.player(player, receivedTurnEventFor: match, didBecomeActive: false)
    }
    public func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        debugMsg_("t")
        checkBusyAndContinue( player, receivedTurnEventFor: match, didBecomeActive: didBecomeActive, busyReason: "turn")
    } //func
    private func checkBusyAndContinue( _ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool, busyReason: String) {
        guard gameCtl.busy == 0 else {
            debugMsg_("sorry busy \(self.gameCtl.busy), \(busyReason), not scheduling")
            gameCtl.wasBusyWhile = 1
            return
        } //gua
        checkShouldDisplayAndContinue( player, receivedTurnEventFor: match, didBecomeActive: didBecomeActive)
    } //func
    private enum CanSwitchToMatchDecision {
        case allow, ask, ignore
    } //enum
    private func canSwitchToNow( _ match: GKTurnBasedMatch, didBecomeActive: Bool) -> CanSwitchToMatchDecision {
        let hadOpenGame = currentMatch != nil
        let isSameAsOpen = match.matchID == currentMatch?.matchID
        let cameFromNewOrJoin = prepareForNewlyJoined
        
        switch (didBecomeActive, isSameAsOpen, hadOpenGame, cameFromNewOrJoin) {
        case (true, _, _, _):
            return .allow
        case (_, true, _, _):
            return .allow
        case (false, false, _, true):
            return .ignore
        default:
            return .ask
        } //swi
    } //func
    private func checkShouldDisplayAndContinue( _ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        switch canSwitchToNow( match, didBecomeActive: didBecomeActive) {
        case .ignore:
            return
        case .ask:
            self.turnEventConfirmation = TurnEventConfirmation( player: player, receivedFor: match, didBecomeActive: didBecomeActive)
            return
        case .allow:
            break
        }
        guard self.gameCtl.busy == 0 else {
            debugMsg_("sorry still busy")
            return
        } //gua
        Task {
            await loadMatchToCurrent( match)
        }
    } //turn func
    private func checkShouldDisplayAndContinue_o1( _ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        if player != GKLocalPlayer.local {
            debugMsg_("player mismatch")
        }
        if match.matchID != currentMatch?.matchID {
            if currentMatch != nil
                && !(match.isNewlyCreatedMatch()) {
                self.turnEventConfirmation = TurnEventConfirmation( player: player, receivedFor: match, didBecomeActive: didBecomeActive)
                return
            } //if had match
        } //if not same match
        guard self.gameCtl.busy == 0 else {
            debugMsg_("sorry still busy")
            return
        } //gua
        Task {
            await loadMatchToCurrent( match)
        }
    } //turn func
    @MainActor private func loadMatchToCurrent( _ match: GKTurnBasedMatch?) async -> Void {
        debugMsg_("setting match")
        currentMatch = match
        guard let wmatch = match else {
            return
        }
        //debugMsg_(match.printExchanges())
        //debugMsg_("size \(String(describing: match.matchData?.count))")
        if wmatch.isNewlyCreatedMatch() {
            _ = recreateGame()
        } else {
            _ = loadGameFromTransition( transitionData: wmatch.matchData)
        }
        await self.preEvaluateCurrentGameAsync()

    } //func
    @MainActor private func loadGameFromTransition( transitionData: Data?) -> Bool {
        guard let unwrappedData = transitionData,
              //gdebug("unwrapped \(unwrappedData.count)"),
              let tr = try? JSONDecoder().decode(GameTransition.self, from: unwrappedData)
        else {
            debugMsg_("no data")
            return false
        } //no data
        if !tr.shouldReEnact {
            guard let newGameData = tr.toState,
                  let newGame = try? JSONDecoder().decode(HoldemGame.self, from: newGameData)
            else {
                debugMsg_("no final data")
                return false
            }
            currentGame = newGame
            return true
    } //no reenact
        else {
            guard let oldGameData = tr.fromState,
                  let _ = tr.toState,
                  let oldGame = try? JSONDecoder().decode(HoldemGame.self, from: oldGameData)
            else {
                debugMsg_("no old data")
                return false
            }
            currentGame = oldGame
            return reEnactCurrentGame( trans: tr)
        }
    } //func
    @MainActor private func reEnactCurrentGame( trans: GameTransition) -> Bool {
        guard let _ = currentGame,
              let newGameData = trans.toState,
              let newGame = try? JSONDecoder().decode(HoldemGame.self, from: newGameData)
        else {
            debugMsg_("no cur game")
            return false
        }
        withAnimation(.easeInOut(duration: 2)) {
            self.currentGame = newGame
        }
        return true
    } //func
    @MainActor func recreateGame() -> Bool {
        guard let match = currentMatch,
              match.isLocalPlayersTurn(),
              match.participants.thatCanJoin( includingWaiting: true).count > 1,
              match.participants.thatCanJoin(includingWaiting: true).contains(where: {
                  $0.player == GKLocalPlayer.local
              })
        else {
            return false
        } //gua
        if let excs = match.completedExchanges {
            //todo task await
            //needtovisit
            match.saveMergedMatch(Data(), withResolvedExchanges: excs)
        }
        currentGame = HoldemGame(numberOfPlayers: match.participants.count)
        //debugMsg_("reseting outcomes")
        for part in match.participants.thatCanJoin( includingWaiting: false) {
            part.matchOutcome = .none
        }
        return true
    } //func
    @MainActor func sendGameTransitionBackAsync( _ transition: GameTransition, matchCheck: GKTurnBasedMatch, to participantsIndices: [ParticipantIndex], timeOut: TimeInterval) async -> Bool {
        guard let match = currentMatch,
              matchCheck.matchID == match.matchID,
              match.isLocalPlayersTurn()
        else {
            return false
        }
        let parts = match.participants.mapFromIndices( participantsIndices)
        return await sendGameTransitionBackAsync( trans: transition, to: parts, timeOut: timeOut)
    } //func
    @MainActor func sendGameTransitionBackAsync( trans: GameTransition, to participants: [GKTurnBasedParticipant], timeOut: TimeInterval) async -> Bool {
        guard let match = currentMatch else {
            debugMsg_("no match")
            return false
        }
        let newMsg = incMatchMsg()
        trans.customMessage = newMsg
        guard let td = trans.toJSON() else {
            debugMsg_("error coding tran")
            return false
        } //gua
        let finalParticipants = participants.filter({
            $0.status.meansStillInGame( includingWaiting: true)
        })
        do {
            if let completed = match.completedExchanges {
                try await match.saveMergedMatch( td, withResolvedExchanges: completed)
            }
            if finalParticipants.isEmpty {
                try await match.saveCurrentTurn( withMatch: td)
            } else if finalParticipants.first == match.localParticipant() {
                //try await match.saveCurrentTurn( withMatch: td)
                try await match.endTurn( withNextParticipants: finalParticipants, turnTimeout: timeOut, match: td)
            } else {
                //debugMsg_("giving turn to \(participants[0].player?.alias ?? "unknown"), by " + newMsg)
                try await match.endTurn( withNextParticipants: finalParticipants, turnTimeout: timeOut, match: td)
            } //else
        } catch {
            debugMsg_("end turn with error")
            debugMsg_(error.localizedDescription)
        } //catch
            return true
    } //func
    @MainActor func preEvaluateCurrentGameAsync() async -> Void {
        //debugMsg_("gc a eval")
        guard let game = currentGame,
              let match = currentMatch,
              match.participants.count == game.allPlayers.count,
              match.isLocalPlayersTurn() else {
            return
        }
        await gameCtl.actionEvaluateGame(game, and: match)
    } //eva func
} //ext
extension Notification.Name {
    static let presentGame = Notification.Name("presentGame")
} //ext
extension GCHelper: GameKit.GKTurnBasedMatchmakerViewControllerDelegate {
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFind match: GKTurnBasedMatch) {
        viewController.dismiss(animated: true)
    } //did find
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, playerQuitFor match: GKTurnBasedMatch) {
        //debugMsg_("I quitted")
    }
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        //debugMsg_("dismissed cancelled")
        viewController.dismiss(animated: true)
    } //canc
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        //debugMsg_("mmmk failed with error")
        //debugMsg_(error.localizedDescription)
        viewController.dismiss(animated: true)
    } //failed
} //ext
class ErrorMessageContainer: Identifiable {
    var id = UUID()
    var msg: String
    var title: String
    
    init( msg: String, title: String) {
        self.msg = msg
        self.title = title
    }
} //class
class TurnEventConfirmation: Identifiable {
    var id = UUID()
    var receivedFor: GKTurnBasedMatch
    var receivedBy: GKPlayer
    var didBecomeActive: Bool
    
    init(player: GKPlayer, receivedFor: GKTurnBasedMatch, didBecomeActive: Bool) {
        self.receivedBy = player
        self.receivedFor = receivedFor
        self.didBecomeActive = didBecomeActive
    }
} //class
enum AuthenticationState {
case authenticated, unAuthenticated, inProgress
} //enum
enum UserCanPlay {
    case yes, notLogged, underAge, noMulti, other
} //enum
extension GKTurnBasedMatch {
    func differsDataOrExchanges( from match: GKTurnBasedMatch) -> Bool {
        if status != match.status {
            debugMsg_("dif status")
            return true
        }
        if participants.map({ $0.status }) != match.participants.map({ $0.status }) {
            debugMsg_("differs part statuses")
            return true
        }
        if participants.map({ $0.matchOutcome }) != match.participants.map({ $0.matchOutcome }) {
            debugMsg_("differs part outcomes")
            return true
        }
        //matchID != match.matchID
        //false
        //|| matchData != match.matchData
        if matchData != match.matchData {
            debugMsg_("diff match data")
            return true
        }
        //|| !exchanges.mostlySameAs(match.exchanges)
        if !exchanges.mostlySameAs(match.exchanges) {
            debugMsg_("diff exchange list")
            return true
        }
        //|| !activeExchanges.mostlySameAs(match.activeExchanges)
        if !activeExchanges.mostlySameAs(match.activeExchanges) {
            debugMsg_("diff active exchanges")
            return true
        }
        //|| !completedExchanges.mostlySameAs(match.completedExchanges)
        if !completedExchanges.mostlySameAs(match.completedExchanges) {
            debugMsg_("diff comp exchanges")
            return true
        }
        return false
    } //func
} //ext
extension Optional where Wrapped == [GKTurnBasedExchange] {
    func mostlySameAs( _ exchanges: Self) -> Bool {
        switch (self, exchanges) {
        case (.none, .none):
            return true
        case (.none, .some),
            (.some, .none):
            return false
        case let (w1?, w2?):
            guard w1.count == w2.count else {
                return false
            }
            for i in w1.indices {
                guard w1[i].mostlySameAs( w2[i])  else {
                    return false
                } //gua
            } //for
            return true
        } //swi
    }
} //ext

extension GKTurnBasedExchange {
    func mostlySameAs( _ exchange: GKTurnBasedExchange) -> Bool {
        guard self.exchangeID == exchange.exchangeID,
              self.data == exchange.data,
              self.status == exchange.status,
              (self.replies?.count) == (exchange.replies?.count)
        else {
            return false
        } //gua
        return true
    } //func
} //ext
