# PhotosUI

### iOS 13에서 SwiftUI & Combine 사용 제약사항 😭
- App protocol을 사용한 App lifecycle 제어를 할 수 없어 SceneDelegate을 사용해야합니다.
- flatMap 기능 제한으로 Upstream data type 에 Failure type 이포함되어야 합니다.
- TabView에 tabViewStyle(.page) 를 사용할 수 없어 pagination이 제공되지 않습니다.
- full screen modal present 를 하기 위한 fullScreenCover(::)가 제공되지 않습니다.
- List를 programmatically하게 scroll to position하기 위한 ScrollViewReader가 없습다.
🥲...
