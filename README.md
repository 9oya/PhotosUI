### PhotosUI

# iOS 13에서 SwiftUI & Combine 사용 제약사항
- App protocol을 사용한 App lifecycle 제어를 할 수 없어 SceneDelegate을 사용해야합니다.
- iOS 14 보다 낮을 경우 Combine publisher에 flatMap기능이 제한된다.
