//
//  HomeStatsView.swift
//  Crypto SwiftUI
//
//  Created by Mohamed Khaled Gomaa on 24/11/2023.
//

import SwiftUI

struct HomeStatsView: View {
    @EnvironmentObject private var vm: HomeViewModel
    @Binding var showProtfolio: Bool
    var body: some View {
        HStack{
            ForEach(vm.statics) { stat in
                StatisticView(stat: stat)
                    .frame(width: UIScreen.main.bounds.width / 3)
            }
        }
        .frame(width: UIScreen.main.bounds.width,
               alignment: showProtfolio ? .trailing : .leading)

    }
}

struct HomeStatsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStatsView(showProtfolio: .constant(false))
            .environmentObject(dev.homeVM)
    }
}
