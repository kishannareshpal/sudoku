struct DurationView: View {
  @ObservedObject var gameDuration: GameDuration

  private let currentColorScheme: ColorScheme = StyleManager.current.colorScheme
  
  var body: some View {
    Text(GameDurationHelper.format(self.gameDuration.seconds))
      .font(.system(size: 24, weight: .bold).monospaced())
      .foregroundStyle(Color(self.currentColorScheme.ui.game.nav.text))
  }
}