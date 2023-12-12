//
//  CoinRowView.swift
//  Crypto SwiftUI
//
//  Created by Mohamed Khaled Gomaa on 20/11/2023.
//

import SwiftUI

struct CoinRowView: View {
    let coin: CryptoCurrency
    @State var showHoldingsColums: Bool
    var body: some View {
        HStack{
            leftColum
            Spacer()
            
            if showHoldingsColums {
                centerColum
            }
            
            rightColum
        }.font(.subheadline)
    }
}

extension CoinRowView {
    private var leftColum: some View {
        HStack (spacing: 4){
            Text("\(coin.rank)")
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
                .frame(minWidth: 30)
            
            CoinsImageView(coin: coin)
                .frame(width: 30, height: 30)
            
            Text(coin.symbol.uppercased())
                .bold()
                .foregroundColor(Color.theme.accent)
        }
    }
    
    private var centerColum: some View {
        VStack(alignment: .trailing) {
            Text("\(coin.currentHoldingsValue.asCurrencyWith2Decimal()) ")
                .bold()
                .foregroundColor(Color.theme.accent)
            Text((coin.currentHoldings ?? 0).asNumberString())
                
        }.foregroundColor(Color.theme.accent)
    }
    
    private var rightColum: some View {
        VStack(alignment: .trailing) {
            Text("\(coin.currentPrice.asCurrencyWith2Decimal())")
                .bold()
                .foregroundColor(Color.theme.accent)
            Text(coin.priceChangePercentage24H?.asPercentString() ?? "")
                .foregroundColor(
                    (coin.priceChangePercentage24H ?? 0) >= 0 ?
                    Color.green : Color.red
                )
        }.frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
    }
}

struct CoinRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CoinRowView(coin: dev.coin, showHoldingsColums: true)
                .previewLayout(.sizeThatFits)

        }
        
    }
}
