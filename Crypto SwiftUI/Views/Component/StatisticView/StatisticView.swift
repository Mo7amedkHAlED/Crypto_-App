//
//  StatisticView.swift
//  Crypto SwiftUI
//
//  Created by Mohamed Khaled Gomaa on 24/11/2023.
//

import SwiftUI

struct StatisticView: View {
    let stat: StaticsModel
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.title)
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
                Text(stat.value)
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                
                HStack {
                    Image(systemName: "triangle.fill")
                        .rotationEffect(
                            Angle(degrees: stat.percentageChange ?? 0 >= 0 ? 0 : 180)
                        )
                    Text(stat.percentageChange?.asPercentString() ?? "")
                        .font(.caption)
                        .bold()
                }
                .foregroundColor(stat.percentageChange ?? 0 >= 0 ? Color.theme.green : Color.theme.red )
                .opacity(stat.percentageChange == nil ? 0.0 : 1.0)
            }
        }
    }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView(stat: dev.stat1)
    }
}
