import SwiftUI

// MARK: - Tab

enum MainTab {
    case discover, saved, profile
}

// MARK: - MainTabView

struct MainTabView: View {
    @Environment(\.appTheme) private var theme
    @State private var tab: MainTab = .discover
    @State private var vm = HomeViewModel()

    var body: some View {
        ZStack {
            switch vm.phase {
            case .loading:
                LoadingView(query: vm.prompt)
                    .transition(.opacity)
            case .results(let cards):
                SwipeFeedView(cards: cards, onBack: { vm.reset() }, vm: vm)
                    .transition(.opacity)
            default:
                VStack(spacing: 0) {
                    tabContent
                    BottomNavBar(tab: $tab, theme: theme)
                }
                .transition(.opacity)
            }
        }
        .animation(.shaukFade, value: isOverlay)
        .task { await vm.onAppear() }
    }

    private var isOverlay: Bool {
        switch vm.phase {
        case .idle, .error: return false
        default:            return true
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .discover: HomeView(vm: vm)
        case .saved:    SavedView()
        case .profile:  ProfileView()
        }
    }
}

// MARK: - BottomNavBar

private struct BottomNavBar: View {
    @Binding var tab: MainTab
    let theme: AppTheme

    private var c: ThemeColors { theme.colors }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(c.navBorder)
            HStack(spacing: 0) {
                navItem(icon: "✦", label: "Discover", targetTab: .discover)
                navItem(icon: "♡", label: "Saved",    targetTab: .saved)
                navItem(icon: "◎", label: "Profile",  targetTab: .profile)
            }
            .padding(.top, 10)
            .padding(.bottom, 24)
            .background(c.navBg)
        }
    }

    @ViewBuilder
    private func navItem(icon: String, label: String, targetTab: MainTab) -> some View {
        let isActive = tab == targetTab
        Button {
            withAnimation(.shaukSnap) { tab = targetTab }
        } label: {
            VStack(spacing: 4) {
                Text(icon)
                    .font(.system(size: 18))
                    .foregroundColor(isActive ? c.accent : c.t3)
                Text(label)
                    .font(DesignFonts.dmSans(size: 10, weight: .medium))
                    .foregroundColor(isActive ? c.accent : c.t3)
            }
            .frame(maxWidth: .infinity)
            .opacity(isActive ? 1.0 : 0.5)
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.appTheme, .light)
}
