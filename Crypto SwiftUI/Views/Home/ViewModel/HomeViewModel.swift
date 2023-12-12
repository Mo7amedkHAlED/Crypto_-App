//
//  HomeViewModel.swift
//  Crypto SwiftUI
//
//  Created by Mohamed Khaled Gomaa on 20/11/2023.
//

import Foundation
import Combine

// ObservableObject : to observe it from our view
class HomeViewModel: ObservableObject {
    @Published var statics: [StaticticModel] = []
    @Published var coins: [CryptoCurrency] = []
    @Published var protfolioCoins: [CryptoCurrency] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var sortOption: SortOption = .holdings
    @Published var marketData: MarketDataModel? = nil
    
    private let coindataServies = CoinDataServices()
    private let marketdataServies = MarkrtDataServices()
    private let protfolioDataService = ProtfolioDataService()
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        addSubscriber()
    }
    func reloadData() {
        isLoading = true
        coindataServies.getCoins()
        marketdataServies.getMarketData()
        // make vibration when data come
        HapticManager.notification(type: .success)
    }
    
    func addSubscriber() {
        $searchText
            .combineLatest(coindataServies.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main) // to delay map because we need to lowest requests number
            .map(filterAndSortingCoins)  // Assuming filterCoins is a method or closure you've defined
            .sink { [weak self] (coins) in
                self?.coins = coins
            }.store(in: &cancellable)
        
        $coins
            .combineLatest(protfolioDataService.$savedEntity)
            .map(mapAllCoinsToProtfolioCoins)
            .sink { [weak self](returnedValue) in
                guard let self else { return }
                self.protfolioCoins = sortingProtfolioCoinsIfNeeded(coins: returnedValue)
            }.store(in: &cancellable)
        
        marketdataServies.$marketData
            .combineLatest($protfolioCoins) // holding ( markrtData , protfolioCoins)
            .map(mapGlobelMarketData)
            .sink {[weak self] (retrunedStats) in
                self?.statics = retrunedStats
                self?.isLoading = false
            }.store(in: &cancellable)
    }
    
    private func mapAllCoinsToProtfolioCoins(allCoins: [CryptoCurrency], protfolioCoins: [ProtfolioEntity]) -> [CryptoCurrency] {
        allCoins.compactMap { (coin) -> CryptoCurrency? in
            guard let entity = protfolioCoins.first(where: {$0.coinID == coin.id}) else {
                return nil
            }
            return coin.updateHoldings(amount: entity.amount)
        }
    }
    
    func updateProtfolio(coin: CryptoCurrency, amount: Double) {
        protfolioDataService.updateProtfolio(coin: coin, amount: amount)
    }
    // map market data to Statictic Model // header in the top of screen
    private func mapGlobelMarketData(marketDataModel: MarketDataModel?, protfolioCoins: [CryptoCurrency]) -> [StaticticModel] {
        var stats : [StaticticModel] = []
        guard let data = marketDataModel else {
            return stats
        }
        
        let protfolioValue = protfolioCoins.map({$0.currentHoldingsValue})
            .reduce(0, +) //retrun sum of all values
        let marketCap = StaticticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUSD)
        
        let previousValue = protfolioCoins.map({ coin -> Double in
            let currentValue = coin.currentHoldingsValue
            let percentChange = coin.priceChangePercentage24H ?? 0 / 100
            let previousValue = currentValue / (1 + percentChange)
            return previousValue
        }).reduce(0, +)
        
        let percentChange = ((protfolioValue - previousValue) / previousValue) * 100
        
        let volume = StaticticModel(title: "24H Volume", value: data.volume)
        let btcDominance = StaticticModel(title: "BTC Dominace", value: data.btcDominance)
        let portfoloi = StaticticModel(title: "portfoloi value", value: protfolioValue.asCurrencyWith2Decimal() , percentageChange: percentChange)
        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominance,
            portfoloi
        ])
        return stats
    }
    
    private func sortingProtfolioCoinsIfNeeded(coins: [CryptoCurrency]) -> [CryptoCurrency] {
       // will be sorting according holdings if needed
        switch sortOption {

        case .holdings:
            return coins.sorted(by: {$0.currentHoldings ?? 0 < $1.currentHoldings ?? 0})
        case .holdingsReversed:
            return coins.sorted(by: {$0.currentHoldings ?? 0 > $1.currentHoldings ?? 0})
        default:
            return coins
        }
    }
    // filtter and sorting coins array according to search
    private func filterAndSortingCoins(text: String, coins: [CryptoCurrency], sort: SortOption) -> [CryptoCurrency] {
        var updateCoins = filterCoins(text: text, coins: coins)
         sorting(sort: sort, coins: &updateCoins)
        return updateCoins
    }
    // sort according to sort option
    // sorting(sort: SortOption , coin: [CryptoCurrency]) -> [CryptoCurrency]
    // when you enter same array and need to retrun samr array use in out
    private func sorting(sort: SortOption, coins: inout [CryptoCurrency]) {
        switch sort {
            //sort edit in same array as this
            //sorted edit in new array and retrun it
        case .rank, .holdings:
             coins.sort(by: {$0.rank < $1.rank})
        case .rankReversed, .holdingsReversed:
             coins.sort(by: {$0.rank > $1.rank})
        case .price:
             coins.sort(by: {$0.currentPrice < $1.currentPrice})
        case .priceReversed:
             coins.sort(by: {$0.currentPrice > $1.currentPrice})
        }
        
    }
    // filtter coins array according to search
    private func filterCoins(text: String, coins: [CryptoCurrency]) -> [CryptoCurrency] {
        guard !text.isEmpty else {
            return coins
        }
        let lowercasedText = text.lowercased()
        return coins.filter { coins -> Bool in
            return coins.name.lowercased().contains(lowercasedText) ||
            coins.symbol.lowercased().contains(lowercasedText) ||
            coins.id.lowercased().contains(lowercasedText)
        }
    }
}

// MARK: - Note
/* uiview (search bar ) ->
 take text ->
 bind and put text in vm ->
 bind date in ui view from vm
 */
