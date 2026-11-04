# Vino 🍷

A native SwiftUI iOS app for tracking, discovering and learning about wine. Built for two people, with no accounts and no backend. Everything is stored on-device with SwiftData.

## Features

- **Journal:** log wines (name, producer, vintage, grape, region, price, notes), rate 1–5 stars, mark who tasted it, and keep a wishlist.
- **Label scanning:** photograph a bottle's front label (or pick a photo) and Vino reads it on-device with Apple's Vision framework, then fills in producer, name, vintage, grape, region, country and style. It only fills blank fields, keeps the photo with the wine, and works offline. The simulator has no camera, so it only shows the photo-library option there. To test, drag a label image onto the simulator window and add it to Photos.
- **Discover:** a taste profile (body / acidity / tannin / sweetness) learned from your 4★+ wines, "try next" grape suggestions with reasons, per-person recommendations, and a "what are you eating?" pairing search.
- **Learn:** six short lessons with quizzes, a full quiz, a 22-grape guide and a glossary.

## Design

Dark navy and gold "wine bar" theme, forced dark mode. Colors, serif fonts, buttons and chips live in `Vino/Views/Theme.swift`, so the whole look can be tuned in one place. The app icon and launch color are in `Vino/Assets.xcassets`.

## Requirements

- Mac with Xcode 15+ (iOS 17 SDK)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the project: `brew install xcodegen`

## Run it

```bash
cd ios
xcodegen generate
open Vino.xcodeproj
```

Then pick an iPhone simulator (or your plugged-in iPhone) and press ⌘R. Run tests with ⌘U.

To run on your own iPhone: select the **Vino** target → *Signing & Capabilities* → choose your Apple ID as the Team. A free Apple ID works, and the app expires after 7 days until you reinstall it. A paid developer account ($99/yr) lasts a year and allows TestFlight, so your fiancée can install it too.

### No XcodeGen?

Create a new iOS App in Xcode named `Vino` (SwiftUI, SwiftData storage), delete its template files, and drag the `Vino/` and `VinoTests/` folders in.

## Layout

```
ios/
  project.yml              XcodeGen project definition
  Vino/
    VinoApp.swift          entry point + SwiftData container
    Models/                Wine (SwiftData), Grape + catalog
    Services/Recommender   taste profile, recommendations, food pairing
    Data/                  lessons, quiz questions, glossary
    Views/                 Journal, Discover, Learn, forms, shared components
  VinoTests/               recommender + data tests
```

## How recommendations work

Each grape in the catalog has a 1–5 score for body, acidity, tannin and sweetness. Your profile is the rating-weighted average of the grapes you liked. Untried grapes are ranked by how close their structure is to your favorites, with a small boost for styles you like and a penalty for being close to something you disliked. It's all on-device, with no network calls.

## Ideas for next

- Share one journal between two phones (SwiftData + CloudKit, which needs a paid developer account)
- Photo of the label (PhotosPicker), and barcode/label scanning
- Cellar inventory (bottles on hand, drink-by windows)
- Wine of the day, flashcards, and spaced-repetition quizzes
- Map of regions you've tried
