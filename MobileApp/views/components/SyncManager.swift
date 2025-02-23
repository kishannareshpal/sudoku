class SyncManager: ObservableObject {
  enum SyncStatus {
    case idle, syncing, completed(result: SyncResult)
  }

  @Published var status: SyncStatus = .idle
  
  
  func sync() async {
    self.status = .syncing
    
    let syncResult = await DataManager.default.saveGamesService.sync()
    self.status = .completed(result: syncResult)
  }
}