const axios = require('axios');

// Test data for creating a recipe
const testRecipe = {
  title: "Phở Bò Hà Nội",
  region: "BAC",
  descriptionMd: "Món phở truyền thống của Hà Nội với nước dùng đậm đà và thịt bò tươi ngon",
  difficulty: "TRUNG_BINH",
  timeMin: 45,
  costHint: 50000,
  imageBase64: null, // Skip image for now
  ingredients: [
    {
      name: "Bánh phở",
      quantity: "200g",
      note: "Loại tươi"
    },
    {
      name: "Thịt bò",
      quantity: "150g",
      note: "Thịt bò tái"
    },
    {
      name: "Hành tây",
      quantity: "1 củ",
      note: ""
    },
    {
      name: "Gừng",
      quantity: "1 củ",
      note: ""
    },
    {
      name: "Quế",
      quantity: "1 thanh",
      note: ""
    },
    {
      name: "Hoa hồi",
      quantity: "2 cái",
      note: ""
    }
  ],
  steps: [
    {
      orderNo: 1,
      contentMd: "Rửa sạch thịt bò và cắt thành lát mỏng"
    },
    {
      orderNo: 2,
      contentMd: "Nướng hành tây và gừng cho thơm"
    },
    {
      orderNo: 3,
      contentMd: "Nấu nước dùng với quế, hoa hồi trong 30 phút"
    },
    {
      orderNo: 4,
      contentMd: "Trần bánh phở qua nước sôi"
    },
    {
      orderNo: 5,
      contentMd: "Cho bánh phở vào tô, thêm thịt bò và chan nước dùng nóng"
    },
    {
      orderNo: 6,
      contentMd: "Thêm hành lá, ngò gai và thưởng thức"
    }
  ]
};

// JWT Token (you need to replace this with a real token)
const JWT_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

async function testCreateRecipe() {
  try {
    console.log('🚀 Testing create recipe API...');
    console.log('📝 Recipe data:', JSON.stringify(testRecipe, null, 2));
    
    const response = await axios.post(
      'https://gullably-nonpsychological-leisha.ngrok-free.dev/api/community/recipes',
      testRecipe,
      {
        headers: {
          'Authorization': `Bearer ${JWT_TOKEN}`,
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        }
      }
    );
    
    console.log('✅ Success! Recipe created:');
    console.log('📊 Response:', JSON.stringify(response.data, null, 2));
    
  } catch (error) {
    console.error('❌ Error creating recipe:');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
    } else {
      console.error('Error:', error.message);
    }
  }
}

// Run the test
testCreateRecipe();
