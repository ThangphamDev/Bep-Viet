class AppConstants {
  // Regions
  static const String regionBac = 'BAC';
  static const String regionTrung = 'TRUNG';
  static const String regionNam = 'NAM';
  
  static const Map<String, String> regionNames = {
    regionBac: 'Miền Bắc',
    regionTrung: 'Miền Trung',
    regionNam: 'Miền Nam',
  };
  
  // Seasons
  static const String seasonXuan = 'XUAN';
  static const String seasonHa = 'HA';
  static const String seasonThu = 'THU';
  static const String seasonDong = 'DONG';
  
  static const Map<String, String> seasonNames = {
    seasonXuan: 'Mùa Xuân',
    seasonHa: 'Mùa Hạ',
    seasonThu: 'Mùa Thu',
    seasonDong: 'Mùa Đông',
  };
  
  // Meal Types
  static const String mealBreakfast = 'BREAKFAST';
  static const String mealLunch = 'LUNCH';
  static const String mealDinner = 'DINNER';
  static const String mealSnack = 'SNACK';
  
  static const Map<String, String> mealTypeNames = {
    mealBreakfast: 'Sáng',
    mealLunch: 'Trưa',
    mealDinner: 'Tối',
    mealSnack: 'Xế',
  };
  
  // Difficulty Levels
  static const int difficultyEasy = 1;
  static const int difficultyMedium = 3;
  static const int difficultyHard = 5;
  
  static const Map<int, String> difficultyNames = {
    1: 'Dễ',
    2: 'Trung bình',
    3: 'Trung bình',
    4: 'Khó',
    5: 'Rất khó',
  };
  
  // Spice Levels
  static const int spiceNone = 0;
  static const int spiceMild = 1;
  static const int spiceMedium = 2;
  static const int spiceHot = 3;
  static const int spiceVeryHot = 4;
  static const int spiceExtreme = 5;
  
  static const Map<int, String> spiceLevelNames = {
    0: 'Không cay',
    1: 'Ít cay',
    2: 'Vừa cay',
    3: 'Cay',
    4: 'Rất cay',
    5: 'Cực cay',
  };
  
  // User Roles
  static const String roleUser = 'USER';
  static const String roleAdmin = 'ADMIN';
  
  // Subscription Plans
  static const String planFree = 'FREE';
  static const String planPremium = 'PREMIUM';
  
  // Recipe Status
  static const String statusPending = 'PENDING';
  static const String statusApproved = 'APPROVED';
  static const String statusFeatured = 'FEATURED';
  static const String statusRejected = 'REJECTED';
  
  // Store Sections
  static const String sectionProduce = 'PRODUCE';
  static const String sectionMeat = 'MEAT';
  static const String sectionSeafood = 'SEAFOOD';
  static const String sectionDryGoods = 'DRY_GOODS';
  static const String sectionDairy = 'DAIRY';
  static const String sectionSauce = 'SAUCE';
  static const String sectionSpice = 'SPICE';
  static const String sectionOther = 'OTHER';
  
  static const Map<String, String> storeSectionNames = {
    sectionProduce: 'Rau củ, trái cây',
    sectionMeat: 'Thịt',
    sectionSeafood: 'Hải sản',
    sectionDryGoods: 'Gạo & khô',
    sectionDairy: 'Sữa & chế phẩm',
    sectionSauce: 'Nước chấm',
    sectionSpice: 'Gia vị',
    sectionOther: 'Khác',
  };
  
  // Units
  static const String unitGram = 'g';
  static const String unitKilogram = 'kg';
  static const String unitMilliliter = 'ml';
  static const String unitLiter = 'l';
  static const String unitTeaspoon = 'tsp';
  static const String unitTablespoon = 'tbsp';
  static const String unitPiece = 'pcs';
  static const String unitBundle = 'bó';
  
  static const Map<String, String> unitNames = {
    unitGram: 'gram',
    unitKilogram: 'kilogram',
    unitMilliliter: 'milliliter',
    unitLiter: 'liter',
    unitTeaspoon: 'thìa cà phê',
    unitTablespoon: 'thìa canh',
    unitPiece: 'cái',
    unitBundle: 'bó',
  };
  
  // Error Messages
  static const String errorNetworkConnection = 'Không có kết nối mạng';
  static const String errorServerError = 'Lỗi máy chủ';
  static const String errorUnauthorized = 'Không có quyền truy cập';
  static const String errorNotFound = 'Không tìm thấy dữ liệu';
  static const String errorValidation = 'Dữ liệu không hợp lệ';
  static const String errorUnknown = 'Có lỗi xảy ra';
  
  // Success Messages
  static const String successLogin = 'Đăng nhập thành công';
  static const String successRegister = 'Đăng ký thành công';
  static const String successLogout = 'Đăng xuất thành công';
  static const String successSave = 'Lưu thành công';
  static const String successDelete = 'Xóa thành công';
  static const String successUpdate = 'Cập nhật thành công';
  
  // Loading Messages
  static const String loadingLogin = 'Đang đăng nhập...';
  static const String loadingRegister = 'Đang đăng ký...';
  static const String loadingSave = 'Đang lưu...';
  static const String loadingDelete = 'Đang xóa...';
  static const String loadingUpdate = 'Đang cập nhật...';
  static const String loadingData = 'Đang tải dữ liệu...';
  
  // Default Values
  static const int defaultServings = 2;
  static const int defaultBudget = 50000;
  static const int defaultMaxTime = 45;
  static const int defaultSpicePreference = 2;
  static const int defaultHouseholdSize = 2;
  
  // Limits
  static const int maxServings = 20;
  static const int maxBudget = 1000000;
  static const int maxTimeMinutes = 300;
  static const int maxNameLength = 255;
  static const int maxDescriptionLength = 1000;
  static const int maxCommentLength = 500;
}
