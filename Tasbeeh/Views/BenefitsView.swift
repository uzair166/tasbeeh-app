import SwiftUI

struct BenefitsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private var theme: TasbeehTheme { TasbeehTheme(for: colorScheme) }

    private struct BenefitItem: Identifiable {
        let id = UUID()
        let arabicText: String
        let translation: String
        let source: String
        let sourceURL: String
        let isQuran: Bool
    }

    private let quranVerses: [BenefitItem] = [
        BenefitItem(
            arabicText: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
            translation: "Verily, in the remembrance of Allah do hearts find rest.",
            source: "Ar-Ra'd 13:28",
            sourceURL: "https://quran.com/13/28",
            isQuran: true
        ),
        BenefitItem(
            arabicText: "فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ",
            translation: "So remember Me; I will remember you. And be grateful to Me and do not deny Me.",
            source: "Al-Baqarah 2:152",
            sourceURL: "https://quran.com/2/152",
            isQuran: true
        ),
        BenefitItem(
            arabicText: "يَا أَيُّهَا الَّذِينَ آمَنُوا اذْكُرُوا اللَّهَ ذِكْرًا كَثِيرًا وَسَبِّحُوهُ بُكْرَةً وَأَصِيلًا",
            translation: "O you who believe! Remember Allah with much remembrance. And glorify Him morning and evening.",
            source: "Al-Ahzab 33:41-42",
            sourceURL: "https://quran.com/33/41",
            isQuran: true
        ),
        BenefitItem(
            arabicText: "الَّذِينَ يَذْكُرُونَ اللَّهَ قِيَامًا وَقُعُودًا وَعَلَىٰ جُنُوبِهِمْ",
            translation: "Those who remember Allah while standing, sitting, and lying on their sides.",
            source: "Aal-Imran 3:191",
            sourceURL: "https://quran.com/3/191",
            isQuran: true
        ),
    ]

    private let hadithItems: [BenefitItem] = [
        BenefitItem(
            arabicText: "كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ ثَقِيلَتَانِ فِي الْمِيزَانِ حَبِيبَتَانِ إِلَى الرَّحْمَنِ سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ",
            translation: "Two words which are light on the tongue, heavy on the Scale, and beloved to the Most Merciful: SubhanAllahi wa bihamdihi, SubhanAllahil Azeem.",
            source: "Sahih al-Bukhari 6406",
            sourceURL: "https://sunnah.com/bukhari:6406",
            isQuran: false
        ),
        BenefitItem(
            arabicText: "مَنْ قَالَ سُبْحَانَ اللَّهِ وَبِحَمْدِهِ فِي يَوْمٍ مِائَةَ مَرَّةٍ حُطَّتْ خَطَايَاهُ وَإِنْ كَانَتْ مِثْلَ زَبَدِ الْبَحْرِ",
            translation: "Whoever says SubhanAllahi wa bihamdihi 100 times a day, his sins will be forgiven even if they were as much as the foam of the sea.",
            source: "Sahih al-Bukhari 6405",
            sourceURL: "https://sunnah.com/bukhari:6405",
            isQuran: false
        ),
        BenefitItem(
            arabicText: "أَحَبُّ الْكَلَامِ إِلَى اللَّهِ أَرْبَعٌ سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ",
            translation: "The most beloved words to Allah are four: SubhanAllah, Alhamdulillah, La ilaha illallah, and Allahu Akbar.",
            source: "Sahih Muslim 2137",
            sourceURL: "https://sunnah.com/muslim:2137a",
            isQuran: false
        ),
        BenefitItem(
            arabicText: "أَلَا أُنَبِّئُكُمْ بِخَيْرِ أَعْمَالِكُمْ وَأَزْكَاهَا عِنْدَ مَلِيكِكُمْ وَأَرْفَعِهَا فِي دَرَجَاتِكُمْ وَخَيْرٍ لَكُمْ مِنْ إِنْفَاقِ الذَّهَبِ وَالْوَرِقِ",
            translation: "Shall I not inform you of the best of your deeds, the purest in the sight of your Master, that which raises your ranks the highest, and is better for you than spending gold and silver, and better than meeting your enemy and striking their necks? The remembrance of Allah.",
            source: "Jami at-Tirmidhi 3377",
            sourceURL: "https://sunnah.com/tirmidhi:3377",
            isQuran: false
        ),
    ]

    var body: some View {
        let t = theme

        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Gradient header
                    VStack(spacing: 8) {
                        Text("Benefits of Dhikr")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(t.primaryText)
                        Text("From the Quran & Sunnah")
                            .font(.system(size: 14))
                            .foregroundColor(t.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(t.headerGradient)

                    VStack(spacing: 24) {
                        // Quran section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("From the Quran")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(t.secondaryText)
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .padding(.horizontal, 20)

                            ForEach(quranVerses) { item in
                                benefitCard(item, theme: t)
                            }
                        }

                        // Hadith section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("From the Hadith")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(t.secondaryText)
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .padding(.horizontal, 20)

                            ForEach(hadithItems) { item in
                                benefitCard(item, theme: t)
                            }
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
            }
            .background(t.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(t.accentStart)
                }
            }
        }
    }

    private func benefitCard(_ item: BenefitItem, theme t: TasbeehTheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.arabicText)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(t.primaryText.opacity(0.9))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)

            Text(item.translation)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(t.secondaryText)
                .lineSpacing(3)

            HStack(spacing: 8) {
                Text(item.source)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(t.sourceBadgeText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(t.sourceBadgeBg)
                    .cornerRadius(6)

                if let url = URL(string: item.sourceURL) {
                    Link(destination: url) {
                        HStack(spacing: 3) {
                            Text("Read")
                                .font(.system(size: 11, weight: .medium))
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 8, weight: .bold))
                        }
                        .foregroundColor(t.accentEnd)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(t.accentEnd.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }
        }
        .padding(16)
        .background(t.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(t.surfaceBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}
