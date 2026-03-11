import Foundation

struct DhikrPhrase: Identifiable {
    let id: String
    let arabicText: String
    let transliteration: String
    let meaning: String
    let defaultCount: Int

    static let library: [DhikrPhrase] = [
        DhikrPhrase(
            id: "subhanallah",
            arabicText: "سُبْحَانَ اللّٰهِ",
            transliteration: "SubhanAllah",
            meaning: "Glory be to Allah",
            defaultCount: 33
        ),
        DhikrPhrase(
            id: "alhamdulillah",
            arabicText: "اَلْحَمْدُ لِلّٰهِ",
            transliteration: "Alhamdulillah",
            meaning: "All praise is for Allah",
            defaultCount: 33
        ),
        DhikrPhrase(
            id: "allahu_akbar",
            arabicText: "اَللّٰهُ أَكْبَرُ",
            transliteration: "Allahu Akbar",
            meaning: "Allah is the Greatest",
            defaultCount: 33
        ),
        DhikrPhrase(
            id: "la_ilaha_illallah",
            arabicText: "لَا إِلٰهَ إِلَّا اللّٰهُ",
            transliteration: "La ilaha illallah",
            meaning: "There is no god but Allah",
            defaultCount: 100
        ),
        DhikrPhrase(
            id: "astaghfirullah",
            arabicText: "أَسْتَغْفِرُ اللّٰهَ",
            transliteration: "Astaghfirullah",
            meaning: "I seek forgiveness from Allah",
            defaultCount: 100
        ),
        DhikrPhrase(
            id: "subhanallahi_wa_bihamdihi",
            arabicText: "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ",
            transliteration: "SubhanAllahi wa bihamdihi",
            meaning: "Glory and praise be to Allah",
            defaultCount: 100
        ),
        DhikrPhrase(
            id: "subhanallahil_azeem",
            arabicText: "سُبْحَانَ اللّٰهِ الْعَظِيمِ",
            transliteration: "SubhanAllahil Azeem",
            meaning: "Glory be to Allah the Magnificent",
            defaultCount: 33
        ),
        DhikrPhrase(
            id: "la_hawla",
            arabicText: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ",
            transliteration: "La hawla wa la quwwata illa billah",
            meaning: "There is no power except with Allah",
            defaultCount: 100
        ),
        DhikrPhrase(
            id: "hasbunallah",
            arabicText: "حَسْبُنَا اللّٰهُ وَنِعْمَ الْوَكِيلُ",
            transliteration: "HasbunAllahu wa ni'mal wakeel",
            meaning: "Allah is sufficient for us",
            defaultCount: 100
        ),
        DhikrPhrase(
            id: "allahumma_salli",
            arabicText: "اَللّٰهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ",
            transliteration: "Allahumma salli ala Muhammad",
            meaning: "O Allah, send blessings upon Muhammad",
            defaultCount: 100
        ),
        DhikrPhrase(
            id: "la_ilaha_illallahu_wahdahu",
            arabicText: "لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيكَ لَهُ",
            transliteration: "La ilaha illallahu wahdahu la sharika lah",
            meaning: "There is no god but Allah alone, no partner",
            defaultCount: 100
        ),
        DhikrPhrase(
            id: "four_tasbeeh",
            arabicText: "سُبْحَانَ اللّٰهِ وَالْحَمْدُ لِلّٰهِ وَلَا إِلٰهَ إِلَّا اللّٰهُ وَاللّٰهُ أَكْبَرُ",
            transliteration: "Subhanallahi wal hamdulillahi wa la ilaha illallahu wallahu akbar",
            meaning: "Glory be to Allah, praise be to Allah, there is no god but Allah, Allah is Greatest",
            defaultCount: 100
        ),
    ]
}
