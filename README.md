### PhotosUI

# iOS 13에서 SwiftUI & Combine 사용 제약사항
- App protocol을 사용한 App lifecycle 제어를 할 수 없어 SceneDelegate을 사용해야합니다.
- Combine publisher에 flatMap을 사용하여 component화 한 function composite을 할 수 없습니다.
