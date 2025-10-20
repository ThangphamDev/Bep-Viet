// Test script for Gemini API
const https = require('https');

// Configuration
const GEMINI_API_KEY = 'AIzaSyBZ4UVKR8pzfvVV3STOf411cP3lSlgIluc';
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

// Test function
async function testGeminiAPI() {
    console.log('🚀 Testing Gemini API...');
    console.log('API Key:', GEMINI_API_KEY.substring(0, 10) + '...');
    console.log('Model: gemini-2.0-flash');
    console.log('URL:', GEMINI_API_URL);
    console.log('');

    const testMessage = 'Xin chào! Bạn có thể giúp tôi tư vấn về dinh dưỡng không?';
    
    const requestData = JSON.stringify({
        contents: [
            {
                parts: [
                    {
                        text: testMessage
                    }
                ]
            }
        ],
        generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 1000,
            topP: 0.8,
            topK: 10
        }
    });

    const options = {
        hostname: 'generativelanguage.googleapis.com',
        port: 443,
        path: `/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}`,
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(requestData)
        }
    };

    return new Promise((resolve, reject) => {
        const req = https.request(options, (res) => {
            console.log('📡 Response Status:', res.statusCode);
            console.log('📡 Response Headers:', res.headers);
            console.log('');

            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });

            res.on('end', () => {
                try {
                    const response = JSON.parse(data);
                    
                    if (res.statusCode === 200) {
                        console.log('✅ SUCCESS!');
                        console.log('📝 Response:', JSON.stringify(response, null, 2));
                        
                        if (response.candidates && response.candidates[0]) {
                            const text = response.candidates[0].content.parts[0].text;
                            console.log('');
                            console.log('🤖 AI Response:');
                            console.log('─'.repeat(50));
                            console.log(text);
                            console.log('─'.repeat(50));
                        }
                    } else {
                        console.log('❌ ERROR!');
                        console.log('📝 Error Response:', JSON.stringify(response, null, 2));
                    }
                    
                    resolve(response);
                } catch (error) {
                    console.log('❌ Parse Error:', error.message);
                    console.log('📝 Raw Response:', data);
                    reject(error);
                }
            });
        });

        req.on('error', (error) => {
            console.log('❌ Request Error:', error.message);
            reject(error);
        });

        req.write(requestData);
        req.end();
    });
}

// Test different models
async function testMultipleModels() {
    const models = [
        'gemini-2.0-flash',
        'gemini-1.5-flash',
        'gemini-1.5-pro'
    ];

    console.log('🔄 Testing multiple models...\n');

    for (const model of models) {
        console.log(`Testing model: ${model}`);
        console.log('─'.repeat(30));
        
        try {
            const response = await testGeminiAPI();
            console.log(`✅ ${model} - Working!`);
        } catch (error) {
            console.log(`❌ ${model} - Error: ${error.message}`);
        }
        
        console.log('\n');
    }
}

// Test different prompts
async function testDifferentPrompts() {
    const prompts = [
        'Xin chào! Bạn có thể giúp tôi tư vấn về dinh dưỡng không?',
        'Tôi bị cao huyết áp, nên ăn gì?',
        'Cách giảm cân an toàn?',
        'Trẻ em cần dinh dưỡng gì?',
        'Gợi ý thực đơn tuần cho gia đình 4 người'
    ];

    console.log('🍽️ Testing different nutrition prompts...\n');

    for (const prompt of prompts) {
        console.log(`Prompt: "${prompt}"`);
        console.log('─'.repeat(50));
        
        try {
            const response = await testGeminiAPI();
            console.log('✅ Response received!');
        } catch (error) {
            console.log('❌ Error:', error.message);
        }
        
        console.log('\n');
    }
}

// Main execution
async function main() {
    console.log('🧪 GEMINI API TEST SCRIPT');
    console.log('='.repeat(50));
    console.log('');

    try {
        // Test basic functionality
        await testGeminiAPI();
        
        console.log('\n' + '='.repeat(50));
        console.log('🎉 Test completed successfully!');
        
    } catch (error) {
        console.log('\n' + '='.repeat(50));
        console.log('💥 Test failed:', error.message);
        process.exit(1);
    }
}

// Run the test
if (require.main === module) {
    main();
}

module.exports = {
    testGeminiAPI,
    testMultipleModels,
    testDifferentPrompts
};


