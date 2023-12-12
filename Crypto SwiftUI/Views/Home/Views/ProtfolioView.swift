//
//  ProtfolioView.swift
//  Crypto SwiftUI
//
//  Created by Mohamed Khaled Gomaa on 27/11/2023.
//

import SwiftUI

struct ProtfolioView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var vm: HomeViewModel
    @State private var selectedCoin: CryptoCurrency? = nil
    @State private var quantityText: String = ""
    @State private var showCheckMark: Bool = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SearchBarView(searchText: $vm.searchText)
                    coinLogoView
                    if selectedCoin != nil {
                        protfolioInputSection
                    }
                }
            }
            .navigationTitle("Edit Protfolio")
            .navigationBarTitleDisplayMode(.large)
            //in ios 14
            //.navigationBarItems(leading: XMarkButton())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    XMarkButton(dismiss: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingNavBarButton
                }
            }
            .onChange(of: vm.searchText) { value in
                if value == "" {
                    removeSelectionCoin()
                }
            }
        }
    }
}

extension ProtfolioView {
    
    private var coinLogoView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(vm.searchText.isEmpty ? vm.protfolioCoins : vm.coins) { coin in
                    CoinsLogoView(coin: coin)
                        .frame(width: 75, height: 75)
                        .padding(4)
                        .onTapGesture {
                            withAnimation(.easeIn) {
                                updateSelectedCoin(coin: coin)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedCoin?.id == coin.id ?  Color.theme.green :Color.clear, lineWidth: 1)
                            
                        )
                }
            }
            .frame(height: 120)
            .padding(.leading)
        }
    }
    
    private var protfolioInputSection: some View {
            VStack(spacing: 20){
                HStack{
                    Text("Current price of \(selectedCoin?.symbol.uppercased() ?? "") :")
                    Spacer()
                    Text(selectedCoin?.currentPrice.asCurrencyWith2Decimal() ?? "")
                }
                
                Divider()
                
                HStack {
                    Text("Amount Holding: ")
                    Spacer()
                    TextField("EX : 1.4",text: $quantityText)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
                
                Divider()
                
                HStack {
                    Text("Current Value")
                    Spacer()
                    Text(getCurrentValue().asCurrencyWith2Decimal())
                }
            }
            .padding()
            .font(.headline)
    }
    
    private var trailingNavBarButton: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .opacity(showCheckMark ? 1.0 : 0.0)
            
            Button {
                saveButtonPressed()
            } label: {
                Text("Save".uppercased())
            }.opacity(selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantityText) ? 1.0 : 0.0)
        }.font(.headline)
    }
    
    private func getCurrentValue() -> Double {
        if let quantity = Double(quantityText) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
      return 0
    }
    
    private func saveButtonPressed() {
        guard let savedcoin = selectedCoin, let amount = Double(quantityText) else { return }
        // save to portfolio
        vm.updateProtfolio(coin: savedcoin, amount: amount )
        // show checkmark
        withAnimation {
            showCheckMark = true
            removeSelectionCoin()
        }
        // hiden keyboard
        UIApplication.shared.endEditing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            withAnimation {
                showCheckMark = false
            }
        })
    }
    
    private func removeSelectionCoin() {
        selectedCoin = nil
        vm.searchText = ""
    }
    
    private func updateSelectedCoin(coin: CryptoCurrency) {
        selectedCoin = coin
        if let protfolioCoin = vm.protfolioCoins.first(where: {$0.id == coin.id}),
            let amount = protfolioCoin.currentHoldings {
                quantityText = "\(amount)"
        } else {
            quantityText = ""
        }
    }
    
}

struct ProtfolioView_Previews: PreviewProvider {
    static var previews: some View {
        ProtfolioView()
            .environmentObject(dev.homeVM)
    }
}

