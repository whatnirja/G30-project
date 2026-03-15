import SwiftUI

struct DashboardView: View {

    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {

        NavigationStack {

            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 14) {

                    header

                    searchBar

                    previewSection

                    savedCitiesSection

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

extension DashboardView {

    // MARK: Header
    var header: some View {
        HStack {

            Text("Weather")
                .font(.system(size: 28, weight: .bold))

            Spacer()

            Button {

            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 38, height: 38)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
    }

    // MARK: Search Bar
    var searchBar: some View {

        HStack(spacing: 10) {

            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search for a city or airport", text: $viewModel.searchText)
                .font(.system(size: 16, weight: .medium))
                .onSubmit {
                    Task {
                        await viewModel.searchAndPreviewCity()
                    }
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    viewModel.previewItem = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 18)
        
    
    }

    // MARK: Preview Section
    var previewSection: some View {

        Group {

            if let previewItem = viewModel.previewItem {

                VStack(spacing: 12) {

                    HStack {

                        Text("Search Result")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            viewModel.savePreviewToDashboard()
                        } label: {
                            Text("Add to Dashboard")
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 18)

                    NavigationLink {
                        CityDeepDive(data: previewItem.data)
                    } label: {

                        CityRiskCardView(
                            temp: previewItem.data.temperature,
                            highLow: previewItem.data.highLow,
                            city: previewItem.data.city,
                            country: "Canada",
                            risk: previewItem.riskLabel,
                            symbol: previewItem.icon
                        ){
                            viewModel.removeCity(previewItem)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 18)
                }
            }
        }
    }

    // MARK: Saved Cities
    var savedCitiesSection: some View {

        ScrollView(showsIndicators: false) {

            VStack(spacing: 16) {

                ForEach(viewModel.dashboardItems) { item in

                    NavigationLink {
                        CityDeepDive(data: item.data)
                    } label: {

                        CityRiskCardView(
                            temp: item.data.temperature,
                            highLow: item.data.highLow,
                            city: item.data.city,
                            country: "Canada",
                            risk: item.riskLabel,
                            symbol: item.icon
                        ){
                            viewModel.removeCity(item)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 24)
        }
    }
}

