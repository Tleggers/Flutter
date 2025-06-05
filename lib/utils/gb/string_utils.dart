String getImageFolder(String koreanName) {
  Map<String, String> folderMap = {
    '가지산': 'gajisan',
    '가리왕산': 'gariwangsan',
    '감악산': 'gamaksan',
    '가리산': 'garisan',
    '가야산': 'gayasan',

    // 필요한 산 이름과 폴더명 추가
  };
  return folderMap[koreanName] ?? koreanName;
}
