//
//  HomeView.swift
//  Crypto SwiftUI
//
//  Created by Mohamed Khaled Gomaa on 19/11/2023.
//

import SwiftUI

struct HomeView: View {
    
    @State private var shownPortfolio: Bool = false
    @State private var shownPortfolioView: Bool = false
    @EnvironmentObject private var vm: HomeViewModel
    
    var body: some View {
        ZStack {
            //background
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $shownPortfolioView, content: {
                    ProtfolioView()
                        .environmentObject(vm)
                })
            //contentLayer
            VStack {
                homeHeader
                
                HomeStatsView(showProtfolio: $shownPortfolio)
                // search bar
                SearchBarView(searchText: $vm.searchText)
                
                // header tabel list
                columTitles
                
                if !shownPortfolio {
                    allCoinsList
                        .transition(.move(edge: .leading))
                } else{
                    protfolioCoinsList
                        .transition(.move(edge: .trailing))
                    
                }
                Spacer(minLength: 0)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .navigationBarHidden(true)
        }
        .environmentObject(dev.homeVM)
    }
}

extension HomeView {
    
    private var homeHeader: some View {
        HStack {
            withAnimation(.none) {
                CircleButtonView(iconName: shownPortfolio ? "plus" : "info")
                    .onTapGesture {
                        if shownPortfolio {
                            shownPortfolioView.toggle()
                        }
                    }
                    .background(// animation when $shownPortfolio change
                        CircleButtonAnimation(animation: $shownPortfolio)
                    )
            }
            Spacer()
            
            withAnimation(.none) {
                Text(shownPortfolio ? "Portfolio" : "Live Prices")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.theme.accent)
            }
            Spacer()
            
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: shownPortfolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()){
                        shownPortfolio.toggle()
                    }
                }
        }.padding(.horizontal)
    }
    
    private var allCoinsList: some View {
        List {
            ForEach(vm.coins) { coin in
                CoinRowView(coin: coin, showHoldingsColums: false)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
            }
        }
        .listStyle(.plain)
    }
    
    private var protfolioCoinsList: some View {
        List {
            ForEach(vm.protfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColums: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
            }
        }
        .listStyle(.plain)
    }
    
    private var columTitles: some View {
        HStack{
            HStack {
                Text("Coin")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .rank || vm.sortOption == .rankReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .rank ? 0 : 180))
            }
            .onTapGesture {
                withAnimation(.default) {
                    vm.sortOption = vm.sortOption == .rank ? .rankReversed : .rank
                }
            }
            Spacer()
            
            HStack {
                Text( shownPortfolio ? "Holdings" : "")
                Image(systemName:  shownPortfolio ? "chevron.down" : "")
                    .opacity((vm.sortOption == .holdings || vm.sortOption == .holdingsReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .holdings ? 0 : 180))

            }
            .onTapGesture {
                withAnimation(.default) {
                    vm.sortOption = vm.sortOption == .holdings ? .holdingsReversed : .holdings
                }
            }
            
            HStack {
                Text("Price")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .price || vm.sortOption == .priceReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .price ? 0 : 180))

            }
            .onTapGesture {
                withAnimation(.default) {
                    vm.sortOption = vm.sortOption == .price  ? .priceReversed : .price
                }
            }
            .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
            Button {
                withAnimation(.linear(duration: 2.0)){
                    vm.reloadData()
                }
            } label: {
                Image(systemName: "goforward")
            }.rotationEffect(Angle(degrees: vm.isLoading ? 360 : 0 ),anchor: .center)
        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryText)
        .padding(.horizontal)
    }
}
