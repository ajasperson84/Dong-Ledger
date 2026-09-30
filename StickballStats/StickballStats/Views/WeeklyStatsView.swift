//
//  WeeklyStatsView.swift
//  Dong Country Ledger 5000
//
//  Weekly stats entry and viewing
//

import SwiftUI

struct WeeklyStatsView: View {
    @EnvironmentObject var statsService: StatsService
    @EnvironmentObject var adminService: AdminService
    @State private var showingPlayerSelection = false
    @State private var showingBatchEntry = false
    @State private var showingSchedule = false
    @State private var selectedPlayer: Player?

    // Players who have stats for current week (i.e., were selected to play)
    var playersThisWeek: [Player] {
        let weekStats = statsService.getWeeklyStatsForWeek(statsService.currentWeek)
        let playerIds = Set(weekStats.map { $0.playerId })
        return statsService.players.filter { playerIds.contains($0.id ?? "") }
    }

    // Weekly totals
    var weeklyTotals: (dongs: Int, drops: Int, doublePlays: Int, salamies: Int) {
        let weekStats = statsService.getWeeklyStatsForWeek(statsService.currentWeek)
        let totalDongs = weekStats.reduce(0) { $0 + $1.dongs }
        let totalDrops = weekStats.reduce(0) { $0 + $1.drops }
        let totalDPs = weekStats.reduce(0) { $0 + $1.doublePlays }
        let totalSalamies = weekStats.reduce(0) { $0 + $1.salamies }
        return (totalDongs, totalDrops, totalDPs, totalSalamies)
    }

    // Player of the Week calculation
    var playerOfTheWeek: (player: Player, score: Double, dongs: Int, doublePlays: Int, wins: Int, drops: Int)? {
        let weekStats = statsService.getWeeklyStatsForWeek(statsService.currentWeek)
        guard !weekStats.isEmpty else { return nil }

        var bestPlayer: Player?
        var bestScore: Double = -Double.infinity
        var bestStats: WeeklyStats?

        for stats in weekStats {
            let score = AchievementsCalculator.calculateWeeklyScore(
                dongs: stats.dongs,
                doublePlays: stats.doublePlays,
                wins: stats.wins,
                drops: stats.drops
            )
            if score > bestScore {
                bestScore = score
                bestStats = stats
                bestPlayer = statsService.players.first { $0.id == stats.playerId }
            }
        }

        guard let player = bestPlayer, let stats = bestStats, bestScore > 0 else { return nil }
        return (player, bestScore, stats.dongs, stats.doublePlays, stats.wins, stats.drops)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SRBackground()

                ScrollView {
                    VStack(spacing: 8) {
                        weeklyHeader

                        WeekNavigationHeader(onShowSchedule: { showingSchedule = true })
                            .environmentObject(statsService)
                            .environmentObject(adminService)

                        // Content based on state
                        if let gameWeek = statsService.currentGameWeek, gameWeek.isBlockedOut {
                            BlockedOutWeekView(gameWeek: gameWeek)
                                .padding(.vertical, 24)
                        } else if statsService.isViewingFutureWeek, let gameWeek = statsService.currentGameWeek {
                            UpcomingWeekView(gameWeek: gameWeek)
                                .environmentObject(statsService)
                                .padding(.vertical, 24)
                        } else if playersThisWeek.isEmpty {
                            noPlayersYet
                        } else {
                            // Top Baller (player of the week)
                            if let potw = playerOfTheWeek {
                                TopBallerCallout(playerName: potw.player.name)
                                    .padding(.horizontal, 12)
                            }

                            WeeklyStatsTable(
                                rows: playersThisWeek.compactMap { player in
                                    currentWeekStats(for: player).map { WeeklyTableRow(player: player, stats: $0) }
                                },
                                isAdminMode: adminService.isAdminMode,
                                onSelect: { selectedPlayer = $0 }
                            )
                            .padding(.horizontal, 10)
                        }

                        SRFooterLogo()
                    }
                    .padding(.bottom, 12)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingPlayerSelection) {
                WeeklyPlayerSelectionView()
                    .environmentObject(statsService)
            }
            .sheet(item: $selectedPlayer) { player in
                PlayerStatsEntryView(player: player)
                    .environmentObject(statsService)
            }
            .sheet(isPresented: $showingBatchEntry) {
                BatchStatsEntryView()
                    .environmentObject(statsService)
            }
            .sheet(isPresented: $showingSchedule) {
                SeasonScheduleView()
                    .environmentObject(statsService)
            }
        }
    }

    private var showsAdminButtons: Bool {
        adminService.isAdminMode && statsService.canEnterStatsForCurrentWeek
    }

    /// Title and WEEKLY banner, flanked by the admin add-players and edit-week buttons
    private var weeklyHeader: some View {
        SRHeader(banner: "SR_Weekly_Banner", bannerWidth: 0.62)
            .overlay(alignment: .bottom) {
                if showsAdminButtons {
                    HStack {
                        Button(action: { showingPlayerSelection = true }) {
                            Color.clear
                        }
                        .buttonStyle(.srImage("Add_Player_Icon_Button"))
                        .frame(width: 62, height: 62)
                        .accessibilityLabel("Add players for this week")

                        Spacer()

                        if !playersThisWeek.isEmpty {
                            Button(action: { showingBatchEntry = true }) {
                                Color.clear
                            }
                            .buttonStyle(.srImage("Edit_Week_Icon_Button"))
                            .frame(width: 62, height: 62)
                            .accessibilityLabel("Edit this week's stats")
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                }
            }
    }

    private var noPlayersYet: some View {
        SRArtPlate("SR_Player_Row_Empty") { _ in
            VStack(spacing: 4) {
                Text("NO PLAYERS ADDED")
                    .font(SRFont.display(18))
                    .foregroundColor(SRColors.text)
                Text(adminService.isAdminMode ? "Tap + to select who played" : "Admin mode required to add players")
                    .font(SRFont.mono(11))
                    .foregroundColor(SRColors.gold)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func currentWeekStats(for player: Player) -> WeeklyStats? {
        guard let playerId = player.id else { return nil }
        return statsService.weeklyStats.first {
            $0.playerId == playerId &&
            $0.weekNumber == statsService.currentWeek &&
            $0.year == statsService.currentYear &&
            $0.seasonNumber == statsService.currentSeason
        }
    }
}

// MARK: - Top Baller Callout
/// Player of the week on the TOP BALLER plaque
struct TopBallerCallout: View {
    let playerName: String

    var body: some View {
        SRArtPlate("SR_Top_Baller_Callout_Blank") { size in
            Text(playerName.uppercased())
                .font(SRFont.display(size.height * 0.24))
                .foregroundStyle(
                    LinearGradient(colors: [.white, Color(white: 0.78), .white], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: .black, radius: 1, x: 0, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(width: size.width * 0.66)
                .position(x: size.width * 0.57, y: size.height * 0.60)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Top baller: \(playerName)")
    }
}

// MARK: - Weekly Stats Table
struct WeeklyTableRow: Identifiable {
    let player: Player
    let stats: WeeklyStats
    var id: String { player.id ?? stats.playerId }
}

/// Gold-ruled table of this week's stats (Dongs, Drops, Double Plays, Salamies, Wins)
struct WeeklyStatsTable: View {
    let rows: [WeeklyTableRow]
    let isAdminMode: Bool
    let onSelect: (Player) -> Void

    private let nameWidth: CGFloat = 0.30
    private static let columns = ["DONGS", "DROPS", "DBL PLAY", "SALAMIES", "WINS"]

    var body: some View {
        GeometryReader { geo in
            let nameColumn = geo.size.width * nameWidth
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 0) {
                    Text("PLAYER")
                        .frame(width: nameColumn)
                    ForEach(Self.columns, id: \.self) { title in
                        goldDivider
                        Text(title)
                            .frame(maxWidth: .infinity)
                    }
                }
                .font(SRFont.display(12))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .srGoldText()
                .frame(height: 34)

                ForEach(rows) { row in
                    goldRule
                    Button(action: { onSelect(row.player) }) {
                        HStack(spacing: 0) {
                            Text(row.player.name.uppercased())
                                .font(SRFont.display(15))
                                .foregroundColor(SRColors.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.55)
                                .frame(width: nameColumn - 8, alignment: .leading)
                                .padding(.leading, 8)
                            ForEach(values(for: row.stats), id: \.offset) { item in
                                goldDivider
                                Text("\(item.element)")
                                    .font(SRFont.display(18))
                                    .foregroundColor(item.element > 0 ? SRColors.text : SRColors.text.opacity(0.45))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 36)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!isAdminMode)
                    .accessibilityLabel("\(row.player.name): \(row.stats.dongs) dongs, \(row.stats.drops) drops, \(row.stats.doublePlays) double plays, \(row.stats.salamies) salamies, \(row.stats.wins) wins")
                }
            }
        }
        .frame(height: 34 + CGFloat(rows.count) * 37)
        .srPlate(glow: SRColors.purple, cornerRadius: 6)
    }

    private func values(for stats: WeeklyStats) -> [(offset: Int, element: Int)] {
        Array([stats.dongs, stats.drops, stats.doublePlays, stats.salamies, stats.wins].enumerated())
            .map { (offset: $0.offset, element: $0.element) }
    }

    private var goldDivider: some View {
        Rectangle()
            .fill(SRColors.goldGradient)
            .frame(width: 1.5)
    }

    private var goldRule: some View {
        Rectangle()
            .fill(SRColors.goldGradient)
            .frame(height: 1)
    }
}

// MARK: - Week Navigation Header
struct WeekNavigationHeader: View {
    @EnvironmentObject var statsService: StatsService
    @EnvironmentObject var adminService: AdminService
    var onShowSchedule: () -> Void = {}
    @State private var showingFieldPicker = false

    var body: some View {
        VStack(spacing: 6) {
            // Special event name
            if let event = statsService.currentGameWeek?.specialEvent {
                VStack(spacing: 2) {
                    Text(event.rawValue.uppercased())
                        .font(SRFont.display(18))
                        .srGoldText()
                    if let subtitle = event.subtitle {
                        Text(subtitle.uppercased())
                            .font(SRFont.mono(10))
                            .foregroundColor(SRColors.pink)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 16)
            }

            // Arrows and date panel
            HStack(spacing: 4) {
                Button(action: { statsService.previousWeek() }) { Color.clear }
                    .buttonStyle(.srImage("Week_Arrow_Left"))
                    .frame(width: 58, height: 58)
                    .opacity(statsService.canGoPrevious() ? 1 : 0.4)
                    .disabled(!statsService.canGoPrevious())
                    .accessibilityLabel("Previous week")

                Button(action: onShowSchedule) {
                    SRArtPlate("SR_Weekly_Date_Panel_Blank") { size in
                        VStack(spacing: 0) {
                            Text(statsService.currentGameWeek?.dayTitle ?? "")
                                .font(SRFont.display(size.height * 0.24))
                                .foregroundColor(SRColors.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            HStack(spacing: 6) {
                                if !(statsService.currentGameWeek?.isBlockedOut ?? false) {
                                    Text("WEEK \(statsService.currentWeekNumber)")
                                }
                                if statsService.isViewingFutureWeek {
                                    Text("· UPCOMING")
                                }
                            }
                            .font(SRFont.display(size.height * 0.15))
                            .srGoldText()
                        }
                        .padding(.horizontal, size.width * 0.08)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityHint("Shows the season schedule")

                Button(action: { statsService.nextWeek() }) { Color.clear }
                    .buttonStyle(.srImage("Week_Arrow_Right"))
                    .frame(width: 58, height: 58)
                    .opacity(statsService.canGoNext() ? 1 : 0.4)
                    .disabled(!statsService.canGoNext())
                    .accessibilityLabel("Next week")
            }
            .padding(.horizontal, 8)

            // Field plate (tappable for admins) with night game badge
            if !(statsService.currentGameWeek?.isBlockedOut ?? false) {
                FieldSelectorButton(
                    weekNumber: statsService.currentWeekNumber,
                    isAdminMode: adminService.isAdminMode,
                    isOpen: showingFieldPicker,
                    onTap: { showingFieldPicker = true }
                )
                .environmentObject(statsService)
                .padding(.horizontal, 12)
                .sheet(isPresented: $showingFieldPicker) {
                    FieldPickerSheet(weekNumber: statsService.currentWeekNumber)
                        .environmentObject(statsService)
                }

                if statsService.gameWeekInfos[statsService.currentWeekNumber]?.gameField?.isNightGame ?? false {
                    NightGameBadge()
                }
            }

            // Shortcut back to this week's game when browsing other weeks
            if statsService.currentWeekIndex != statsService.schedule.currentWeekIndex() {
                Button(action: { statsService.goToCurrentWeek() }) {
                    Text("BACK TO THIS WEEK")
                        .font(SRFont.mono(11))
                        .foregroundColor(SRColors.pink)
                        .underline()
                }
            }
        }
    }
}

// MARK: - Field Selector Button
struct FieldSelectorButton: View {
    @EnvironmentObject var statsService: StatsService
    let weekNumber: Int
    var isAdminMode: Bool = true
    var isOpen: Bool = false
    let onTap: () -> Void

    var currentField: GameField? {
        statsService.gameWeekInfos[weekNumber]?.gameField
    }

    var body: some View {
        // Force dependency on lastFieldUpdate to ensure refresh
        let _ = statsService.lastFieldUpdate

        Button(action: onTap) {
            SRArtPlate(isOpen ? "SR_Weekly_Field_Selector_Selected" : "SR_Weekly_Field_Selector_Unselected") { size in
                ZStack {
                    HStack(spacing: 8) {
                        if let field = currentField {
                            Image(systemName: field.icon)
                                .font(.system(size: size.height * 0.22))
                                .srGoldText()
                        }
                        Text(currentField?.rawValue.uppercased() ?? "NO FIELD SET")
                            .font(SRFont.display(size.height * 0.26))
                            .foregroundColor(currentField != nil ? SRColors.text : SRColors.gold.opacity(0.7))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }

                    // Chevron only for admins; read-only plate otherwise
                    if isAdminMode {
                        HStack {
                            Spacer()
                            Image(isOpen ? "SR_Field_Chevron_Up" : "SR_Field_Chevron_Down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size.height * 0.36)
                        }
                        .padding(.trailing, size.width * 0.07)
                    }
                }
                .padding(.horizontal, size.width * 0.08)
            }
        }
        .buttonStyle(.plain)
        .disabled(!isAdminMode)
    }
}

// MARK: - Field Picker Sheet
struct FieldPickerSheet: View {
    @EnvironmentObject var statsService: StatsService
    @Environment(\.dismiss) var dismiss
    let weekNumber: Int

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 20) {
                    Text("SELECT FIELD")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                        .neonGlow(color: TronColors.cyan, radius: 5)
                        .padding(.top, 20)

                    VStack(spacing: 12) {
                        ForEach(GameField.allCases, id: \.self) { field in
                            FieldOptionRow(
                                field: field,
                                isSelected: statsService.getFieldForWeek(weekNumber) == field,
                                onSelect: {
                                    Task {
                                        try? await statsService.updateGameWeekField(weekNumber: weekNumber, field: field)
                                        dismiss()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TronColors.orange)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Field Option Row
struct FieldOptionRow: View {
    let field: GameField
    let isSelected: Bool
    let onSelect: () -> Void

    var fieldIcon: String {
        return field.icon
    }

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: fieldIcon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? TronColors.green : TronColors.secondaryText)
                    .frame(width: 32)

                Text(field.rawValue.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? TronColors.green : TronColors.primaryText)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(TronColors.green)
                        .neonGlow(color: TronColors.green, radius: 5)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? TronColors.green.opacity(0.1) : TronColors.cardBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? TronColors.green.opacity(0.5) : TronColors.gridLine.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Night Game Badge
struct NightGameBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 10))
            Text("NIGHT GAME")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
        }
        .foregroundColor(TronColors.yellow)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(TronColors.yellow.opacity(0.12))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(TronColors.yellow.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Upcoming Week
struct UpcomingWeekView: View {
    @EnvironmentObject var statsService: StatsService
    let gameWeek: GameWeek

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 56))
                .foregroundColor(TronColors.cyan.opacity(0.5))

            Text("UPCOMING GAME")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(TronColors.secondaryText)

            Text(gameWeek.formattedDate.uppercased())
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(TronColors.cyan)

            if gameWeek.specialEvent?.includesPortland ?? false {
                Text("PORTLAND CHAPTER IN TOWN")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.magenta)
            }

            Text("Stats open on game day")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(TronColors.dimText)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Blocked Out Week
struct BlockedOutWeekView: View {
    let gameWeek: GameWeek

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "flag.2.crossed.fill")
                .font(.system(size: 56))
                .foregroundColor(TronColors.magenta)
                .neonGlow(color: TronColors.magenta, radius: 10)

            Text((gameWeek.specialEvent?.rawValue ?? "Blocked Out").uppercased())
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(TronColors.magenta)
                .neonGlow(color: TronColors.magenta, radius: 6)

            if let subtitle = gameWeek.specialEvent?.subtitle {
                Text(subtitle.uppercased())
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(TronColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Text("NO LEAGUE GAME THIS WEEKEND")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(TronColors.dimText)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Season Schedule
struct SeasonScheduleView: View {
    @EnvironmentObject var statsService: StatsService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        let _ = statsService.lastFieldUpdate
        let thisWeekIndex = statsService.schedule.currentWeekIndex()

        NavigationStack {
            ZStack {
                TronGridBackground()

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(Array(statsService.schedule.gameWeeks.enumerated()), id: \.element.id) { index, week in
                                Button(action: {
                                    statsService.goToWeek(index: index)
                                    dismiss()
                                }) {
                                    ScheduleRow(
                                        week: week,
                                        field: statsService.gameWeekInfos[week.weekNumber]?.gameField,
                                        isThisWeek: index == thisWeekIndex,
                                        isUpcoming: statsService.schedule.isFutureWeek(index: index)
                                    )
                                }
                                .buttonStyle(.plain)
                                .id(index)
                            }
                        }
                        .padding(16)
                    }
                    .onAppear {
                        proxy.scrollTo(thisWeekIndex, anchor: .center)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SEASON SCHEDULE")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(TronColors.cyan)
                }
            }
        }
    }
}

// MARK: - Schedule Row
struct ScheduleRow: View {
    let week: GameWeek
    let field: GameField?
    let isThisWeek: Bool
    let isUpcoming: Bool

    private var accent: Color {
        if week.isBlockedOut || week.specialEvent != nil { return TronColors.magenta }
        return isUpcoming ? TronColors.secondaryText : TronColors.cyan
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(week.shortFormattedDate)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(accent)
                .frame(width: 48, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(week.isBlockedOut ? week.displayTitle.uppercased() : "WEEK \(week.weekNumber)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.primaryText)

                if let event = week.specialEvent, !week.isBlockedOut {
                    Text(event.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.magenta)
                }

                if week.isBlockedOut {
                    Text("BLOCKED OUT · NO LEAGUE GAME")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.magenta.opacity(0.8))
                } else if let field = field {
                    HStack(spacing: 4) {
                        Image(systemName: field.icon)
                        Text(field.rawValue.uppercased())
                        if field.isNightGame {
                            Text("· NIGHT GAME")
                                .foregroundColor(TronColors.yellow)
                        }
                    }
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(field.isNightGame ? TronColors.yellow : TronColors.green)
                }
            }

            Spacer()

            if isThisWeek {
                Text("NOW")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.darkBackground)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(TronColors.cyan)
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(week.isBlockedOut ? TronColors.magenta.opacity(0.12) : TronColors.cardBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isThisWeek ? TronColors.cyan : (week.specialEvent != nil ? TronColors.magenta.opacity(0.5) : TronColors.gridLine.opacity(0.3)), lineWidth: isThisWeek ? 2 : 1)
        )
        .opacity(isUpcoming || isThisWeek ? 1 : 0.7)
    }
}

// MARK: - Player of the Week Card
struct PlayerOfTheWeekCard: View {
    let playerName: String
    let dongs: Int
    let doublePlays: Int
    let wins: Int
    let drops: Int

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(TronColors.yellow)
                Text("PLAYER OF THE WEEK")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.yellow)
                Image(systemName: "star.fill")
                    .foregroundColor(TronColors.yellow)
            }

            // Player name
            Text(playerName.uppercased())
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(TronColors.primaryText)
                .neonGlow(color: TronColors.yellow, radius: 5)

            // Stats breakdown
            HStack(spacing: 16) {
                MiniStatBadge(value: dongs, label: "D", color: TronColors.cyan)
                MiniStatBadge(value: doublePlays, label: "DP", color: TronColors.magenta)
                MiniStatBadge(value: wins, label: "W", color: TronColors.yellow)
                MiniStatBadge(value: drops, label: "DR", color: TronColors.orange, negative: true)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(TronColors.yellow.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(TronColors.yellow.opacity(0.5), lineWidth: 2)
        )
        .neonGlow(color: TronColors.yellow, radius: 5)
    }
}

// MARK: - Mini Stat Badge (for POTW)
struct MiniStatBadge: View {
    let value: Int
    let label: String
    let color: Color
    var negative: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(negative && value > 0 ? color : (value > 0 ? color : TronColors.dimText))

            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(color.opacity(0.7))
        }
    }
}

// MARK: - Weekly Totals Summary
struct WeeklyTotalsSummary: View {
    let dongs: Int
    let drops: Int
    let doublePlays: Int
    let salamies: Int

    var body: some View {
        HStack(spacing: 0) {
            TotalStatCell(value: dongs, label: "DONGS", color: TronColors.cyan)
            Divider()
                .frame(height: 30)
                .background(TronColors.gridLine.opacity(0.3))
            TotalStatCell(value: drops, label: "DROPS", color: TronColors.orange)
            Divider()
                .frame(height: 30)
                .background(TronColors.gridLine.opacity(0.3))
            TotalStatCell(value: doublePlays, label: "DBL PLY", color: TronColors.magenta)
            Divider()
                .frame(height: 30)
                .background(TronColors.gridLine.opacity(0.3))
            TotalStatCell(value: salamies, label: "SALAMIES", color: TronColors.green)
        }
        .padding(.vertical, 10)
        .background(TronColors.cardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(TronColors.cyan.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Total Stat Cell
struct TotalStatCell: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .neonGlow(color: color, radius: 4)

            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(color.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(TronColors.cyan.opacity(0.5))

            Text(title)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(TronColors.secondaryText)

            Text(message)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(TronColors.dimText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WeeklyStatsView()
        .environmentObject(StatsService())
        .environmentObject(AdminService.shared)
}
