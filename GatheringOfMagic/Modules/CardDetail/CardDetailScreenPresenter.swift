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
                self.delegate?.showMessage(error.error ?? "", okAction: nil)
                DispatchQueue.main.async {
                    completion()
                }
            }
    }
    
    func addToDeck(deck: CD_Deck) {
        if let card = currentCard, card.id != nil  {
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
    
    func favoriteCard() {
        guard let deck = DataManager.shared.getDeckByName(name: "Favorites") else { return }
        addToDeck(deck: deck)
        
        isFavorited = true
    }
    
    func unfavoriteCard() {
        if let card = currentCard, card.id != nil  {
            
            guard let deck = DataManager.shared.getDeckByName(name: "Favorites") else { return }
            let cards = DataManager.shared.getCards(deck: deck)
            
            let cardToUnfavorite = cards.filter { $0.id == card.id }.first
            guard let cardToUnfavorite = cardToUnfavorite else { return }
            
            DataManager.shared.deleteCard(card: cardToUnfavorite)
        }
        isFavorited = false
    }
    
    func createDeck() {
        if let card = currentCard, card.id != nil  {
            let deck = DataManager.shared.createDeck(
                name: card.name ?? "",
                coverId: card.imageUrl ?? "",
                format: DeckFormats.standard.rawValue)
            addToDeck(deck: deck)
            DataManager.shared.save()
            MDSnackBarHelper.shared.showSuccessMessage(message: CardDetailScreenTexts.newDeckCreated.localized())
        }
    }
    
    func navigateToAddToDeckScreen() {
        guard let card = currentCard else { return }
        router.navigateToAddToDeckScreen(card: card)
    }
}
