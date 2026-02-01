struct RootView: View {

    @StateObject private var session = SessionManager()

    var body: some View {
        Group {
            if session.isLoading {
                ProgressView()
            } else if session.user == nil {
                AuthView()
            } else {
                MainAppView()
            }
        }
        .environmentObject(session)
    }
}
