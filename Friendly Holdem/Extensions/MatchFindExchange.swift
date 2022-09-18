//
//  MatchFindExchange.swift
//  CardPlay
//
//  Created by Ionut on 13.08.2022.
//

import Foundation
import GameKit

extension GKTurnBasedMatch {
    func findExchange( from srcIdx: PokerPlayer.IndexType, with showdownId: UUID) -> GKTurnBasedExchange? {
        guard let srcPart = self.participants.get( index: srcIdx) else {
            return nil
        } //gua
        let ex = self.exchanges?.first(where: {
            guard let hasData = $0.data,
                  $0.sender == srcPart,
                  // $0.recipients.contains( destPart),
                  // $0.recipients.contains(where: { part in
                      //part.player == destPart.player
                  //}),
                  let decodedId = try? JSONDecoder().decode(UUID.self, from: hasData) else {
                return false
            } //gua
            return decodedId == showdownId
        }) //first
        //print(ex == nil ? "exchange not found" : "exchange found")
        return ex
    } //func
    func findExchange2( from srcIdx: PokerPlayer.IndexType, to dstPartO: GKTurnBasedParticipant?, with showdownId: UUID) -> GKTurnBasedExchange? {
        print("finding")
        guard let destPart = dstPartO,
              let srcPart = self.participants.get( index: srcIdx) else {
            print("nopart")
            return nil
        } //gua
        let ex = self.exchanges?.first(where: {
            guard let hasData = $0.data,
                  $0.sender == srcPart,
                  //$0.sender.player == srcPart.player,
                  $0.recipients.contains( destPart),
                  //$0.recipients.contains(where: { part in
                      //part.player == destPart.player
                  //}),
                  let decodedId = try? JSONDecoder().decode(UUID.self, from: hasData) else {
                return false
            } //gua
            return decodedId == showdownId
        }) //first
        print(ex == nil ? "exchange not found" : "exchange found")
        return ex
    } //func
    func findActiveExchanges( with showdownId: UUID?) -> [GKTurnBasedExchange] {
        guard let active = self.activeExchanges else {
            return []
        }
        guard let showdownId = showdownId else {
            return active
        }
        return active.filter({
            guard let hasData = $0.data,
                  let decodedId = try? JSONDecoder().decode(UUID.self, from: hasData) else {
                return false
            } //gua
            return decodedId == showdownId
        }) //filt
    } //func
} //ext
