***

# English Expression Cards Ecosystem

This project creates and manages English expression JSON cards hosted on GitHub Pages, with accompanying macOS and iOS apps for creation, viewing, and learning.

***

## Project Overview

- Each English expression is stored as a separate JSON file in the root of the GitHub repository.
- `expressionsPage.json` holds an array of all card objects currently available.
- The iOS app fetches `expressionsPage.json` to display the list of available cards.
- Users can select a card to view detailed information fetched from the corresponding JSON file.
- GitHub Pages hosts these JSON files, allowing dynamic updates without app re-release.

***

## Project Structure

- **expressionsPage.json**: JSON array of card objects available for learning.
- **Individual JSON card files**: e.g., `Test.json`, `Test02.json` in the root repository.
- **macOS/iOS Apps**: SwiftUI-based apps using the GitHub Pages URLs to fetch and display cards.

***

## JSON Card Example

```json
{
  "id": "D3570420-9C46-4795-95D2-3E02DFC641DE",
  "expression": "Test",
  "meaning": "테스트",
  "example": "Test it",
  "createdAt": "2025-09-29T14:55:52Z"
}
```

***

## ExpressionsPage.json Example

```json
[
  {
    "id": "D3570420-9C46-4795-95D2-3E02DFC641DE",
    "expression": "Test",
    "meaning": "테스트",
    "example": "Test it",
    "createdAt": "2025-09-29T14:55:52Z"
  },
  {
    "id": "B5B88622-4430-4B9C-834B-26997F0C17EE",
    "expression": "Test02",
    "meaning": "두번째",
    "example": "Test twice",
    "createdAt": "2025-09-29T14:56:23Z"
  }
]
```

***

## App Usage

- The app fetches `expressionsPage.json` from GitHub Pages URL.
- Displays a list of expressions based on the fetched JSON array.
- When a user selects an expression, the app displays full details of the expression.
- The app supports offline viewing if JSON data is cached (future enhancement).

***

## Development Environment

- macOS Sonoma 14.7.1, Xcode 15.4, Swift 5+
- Target platforms: macOS 14.5+, iOS 16.6+
- SwiftUI framework used for UI development

***

## Future Enhancements

- Add editing and updating cards via the app, syncing to GitHub.
- Text-to-Speech on expressions and examples.
- Offline support with local caching.
- User favorites and deck creation for custom learning.
- Multi-language support and phonetic/intonation training.

***

## Getting Started

1. Clone the repository.
2. Open the Xcode project.
3. Edit `ContentView.swift` to configure your GitHub Pages URL if needed.
4. Build and run the app on macOS or iOS devices.
5. Ensure `expressionsPage.json` and card JSON files are correctly hosted on GitHub Pages.

***

## Contact

For questions or contributions, please contact [Your Contact Info].

***
