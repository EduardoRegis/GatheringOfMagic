//
//  CardDetailScreenPresenter.swift
//  GatheringOfMagic
//
//  Created by Eduardo Oliveira on 05/10/22.
//

import UIKit
import CoreData

protocol CardDetailScreenPresenterDelegate: BasePresenterDelegate {
}

class CardDetailScreenPresenter {
    
    // MARK: - Variables
    let cardId: String?
    weak var delegate: CardDetailScreenPresenterDelegate?
    let router: CardDetailScreenRouter
    var currentCard: CardDetail?
    var isFavorited: Bool?
    
    
    init(cardId: String, isFavorited: Bool?, delegate: CardDetailScreenPresenterDelegate, router: CardDetailScreenRouter) {
        self.cardId = cardId
        self.delegate = delegate
        self.router = router
        self.isFavorited = isFavorited
        currentCard = CardDetail()
    }
    
    func didLoad() {
    }
    
    func willAppear() {
    }
    
    func didAppear() {
    }
    
    func backToList() {
        router.backToList()
    }
    
    func loadCard(completion: @escaping () -> Void) {
        delegate?.showLoader()
        
        guard let cardId = cardId else { return }
        
        VehicleDAO.getCardById(
            cardId: cardId,
            success: { card in
                self.currentCard = card
                self.delegate?.hideLoader()
                completion()
                
            }) { error in
                self.delegate?.hideLoader()
                self.delegate?.showMessage("erro, localized")
                DispatchQueue.main.async {
                    completion()
                }
            }
    }
    
    func favoriteCard() {
        if let card = currentCard, card.id != nil  {
            
            guard let deck = DataManager.shared.getDeckByName(name: "Favorites") else { return }
        
            var cards = DataManager.shared.getCards(deck: deck)
            
            let cardDetail = DataManager.shared.createCard(
                artist: card.artist ?? "",
                cmc: Int32(card.cmc ?? 0),
                id: card.id ?? "",
                imageUrl: card.imageUrl ?? "",
                manaCost: card.manaCost ?? "",
                name: card.name ?? "",
                power: card.power ?? "",
                rarity: card.rarity ?? "",
                toughness: card.toughness ?? "",
                type: card.type ?? "",
                deck: deck)
            
            cards.append(cardDetail)
            
            DataManager.shared.save()
        }
        
        
    }
}
