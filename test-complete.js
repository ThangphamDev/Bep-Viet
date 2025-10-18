#!/usr/bin/env node

const https = require('https');
const http = require('http');

// Configuration
const BASE_URL = 'http://localhost:8080/api';
const TEST_USER = {
  email: 'test@example.com',
  password: 'password123',
  name: 'Test User'
};

// Helper function to make HTTP requests
function makeRequest(url, options = {}) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const isHttps = urlObj.protocol === 'https:';
    const client = isHttps ? https : http;
    
    const requestOptions = {
      hostname: urlObj.hostname,
      port: urlObj.port || (isHttps ? 443 : 80),
      path: urlObj.pathname + urlObj.search,
      method: options.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      }
    };

    const req = client.request(requestOptions, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const jsonData = data ? JSON.parse(data) : {};
          resolve({
            status: res.statusCode,
            headers: res.headers,
            data: jsonData
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            headers: res.headers,
            data: data
          });
        }
      });
    });

    req.on('error', reject);
    
    if (options.body) {
      req.write(JSON.stringify(options.body));
    }
    
    req.end();
  });
}

// Test results storage
const results = {
  passed: 0,
  failed: 0,
  tests: []
};

// Helper function to run a test
async function runTest(name, testFn) {
  try {
    console.log(`\n🧪 Testing: ${name}`);
    const result = await testFn();
    if (result.success) {
      console.log(`✅ PASSED: ${name}`);
      results.passed++;
    } else {
      console.log(`❌ FAILED: ${name} - Status: ${result.status}`);
      results.failed++;
    }
    results.tests.push({ name, ...result });
  } catch (error) {
    console.log(`❌ ERROR: ${name} - ${error.message}`);
    results.failed++;
    results.tests.push({ name, success: false, error: error.message });
  }
}

// Get authentication token
let authToken = null;

async function getAuthToken() {
  if (authToken) return authToken;
  
  const response = await makeRequest(`${BASE_URL}/auth/login`, {
    method: 'POST',
    body: {
      email: TEST_USER.email,
      password: TEST_USER.password
    }
  });
  
  if (response.status === 200 && response.data.success) {
    authToken = response.data.data.accessToken;
    return authToken;
  }
  
  throw new Error('Failed to get auth token');
}

// Authentication tests
async function testAuthRegister() {
  const response = await makeRequest(`${BASE_URL}/auth/register`, {
    method: 'POST',
    body: {
      email: `test-${Date.now()}@example.com`,
      password: 'password123',
      name: 'Test User'
    }
  });
  
  return {
    success: response.status === 201 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testAuthLogin() {
  const response = await makeRequest(`${BASE_URL}/auth/login`, {
    method: 'POST',
    body: {
      email: TEST_USER.email,
      password: TEST_USER.password
    }
  });
  
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testAuthRefresh() {
  const token = await getAuthToken();
  const response = await makeRequest(`${BASE_URL}/auth/refresh`, {
    method: 'POST',
    body: {
      refreshToken: 'mock-refresh-token'
    }
  });
  
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testAuthLogout() {
  const response = await makeRequest(`${BASE_URL}/auth/logout`, {
    method: 'POST'
  });
  
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

// Public endpoints tests
async function testRegions() {
  const response = await makeRequest(`${BASE_URL}/regions`);
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testSeasons() {
  const response = await makeRequest(`${BASE_URL}/seasons`);
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testIngredients() {
  const response = await makeRequest(`${BASE_URL}/ingredients`);
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testRecipes() {
  const response = await makeRequest(`${BASE_URL}/recipes`);
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testSuggestions() {
  const response = await makeRequest(`${BASE_URL}/suggestions/search`, {
    method: 'POST',
    body: {
      region: 'BAC',
      season: 'XUAN',
      servings: 2,
      budget: 100000,
      cooking_time: 30
    }
  });
  return {
    success: (response.status === 200 || response.status === 201) && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testCommunity() {
  const response = await makeRequest(`${BASE_URL}/community/recipes`);
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

// Protected endpoints tests
async function testUsersMe() {
  const token = await getAuthToken();
  const response = await makeRequest(`${BASE_URL}/users/me`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testShoppingLists() {
  const token = await getAuthToken();
  const response = await makeRequest(`${BASE_URL}/shopping/lists`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testPantry() {
  const token = await getAuthToken();
  const response = await makeRequest(`${BASE_URL}/pantry`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testMealPlans() {
  const token = await getAuthToken();
  const response = await makeRequest(`${BASE_URL}/meal-plans`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testFamilyProfiles() {
  const token = await getAuthToken();
  const response = await makeRequest(`${BASE_URL}/family/profiles`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testAdvisory() {
  const token = await getAuthToken();
  const response = await makeRequest(`${BASE_URL}/advisory`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testAnalytics() {
  const token = await getAuthToken();
  const response = await makeRequest(`${BASE_URL}/analytics/user`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testModeration() {
  const token = await getAuthToken();
  const response = await makeRequest(`${BASE_URL}/moderation/pending`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

async function testSubscriptions() {
  const token = await getAuthToken();
  const response = await makeRequest(`${BASE_URL}/subscriptions`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return {
    success: response.status === 200 && response.data.success,
    status: response.status,
    data: response.data
  };
}

// Main test runner
async function runAllTests() {
  console.log('🚀 Starting Bếp Việt API Tests (Complete)');
  console.log(`📍 Base URL: ${BASE_URL}`);
  console.log('='.repeat(50));

  // Authentication tests
  console.log('\n🔐 AUTHENTICATION TESTS');
  await runTest('POST /auth/register', testAuthRegister);
  await runTest('POST /auth/login', testAuthLogin);
  await runTest('POST /auth/refresh', testAuthRefresh);
  await runTest('POST /auth/logout', testAuthLogout);

  // Public endpoints tests
  console.log('\n🌐 PUBLIC ENDPOINTS TESTS');
  await runTest('GET /regions', testRegions);
  await runTest('GET /seasons', testSeasons);
  await runTest('GET /ingredients', testIngredients);
  await runTest('GET /recipes', testRecipes);
  await runTest('POST /suggestions/search', testSuggestions);
  await runTest('GET /community/recipes', testCommunity);

  // Protected endpoints tests
  console.log('\n🔒 PROTECTED ENDPOINTS TESTS');
  await runTest('GET /users/me', testUsersMe);
  await runTest('GET /shopping/lists', testShoppingLists);
  await runTest('GET /pantry', testPantry);
  await runTest('GET /meal-plans', testMealPlans);
  await runTest('GET /family/profiles', testFamilyProfiles);
  await runTest('GET /advisory', testAdvisory);
  await runTest('GET /analytics/user', testAnalytics);
  await runTest('GET /moderation/pending', testModeration);
  await runTest('GET /subscriptions', testSubscriptions);

  // Summary
  console.log('\n' + '='.repeat(50));
  console.log('📊 TEST SUMMARY');
  console.log(`✅ Passed: ${results.passed}`);
  console.log(`❌ Failed: ${results.failed}`);
  console.log(`📈 Success Rate: ${((results.passed / (results.passed + results.failed)) * 100).toFixed(1)}%`);
  
  if (results.failed > 0) {
    console.log('\n❌ FAILED TESTS:');
    results.tests
      .filter(test => !test.success)
      .forEach(test => {
        console.log(`  - ${test.name}: Status ${test.status}`);
      });
  }
  
  console.log('\n🎯 Test completed!');
}

// Run tests
runAllTests().catch(console.error);
