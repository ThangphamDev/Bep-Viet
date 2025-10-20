// Quick Gemini API Test
const https = require('https');

const API_KEY = 'AIzaSyBZ4UVKR8pzfvVV3STOf411cP3lSlgIluc';
const MODEL = 'gemini-2.0-flash';

function testGemini() {
    const data = JSON.stringify({
        contents: [{
            parts: [{ text: 'Xin chào! Bạn có thể giúp tôi tư vấn về dinh dưỡng không?' }]
        }],
        generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 500
        }
    });

    const options = {
        hostname: 'generativelanguage.googleapis.com',
        port: 443,
        path: `/v1beta/models/${MODEL}:generateContent?key=${API_KEY}`,
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(data)
        }
    };

    console.log('🚀 Testing Gemini API...');
    console.log('Model:', MODEL);
    console.log('API Key:', API_KEY.substring(0, 10) + '...');
    console.log('');

    const req = https.request(options, (res) => {
        console.log('Status:', res.statusCode);
        
        let responseData = '';
        res.on('data', (chunk) => responseData += chunk);
        
        res.on('end', () => {
            try {
                const response = JSON.parse(responseData);
                
                if (res.statusCode === 200) {
                    console.log('✅ SUCCESS!');
                    if (response.candidates && response.candidates[0]) {
                        const text = response.candidates[0].content.parts[0].text;
                        console.log('\n🤖 AI Response:');
                        console.log(text);
                    }
                } else {
                    console.log('❌ ERROR:', res.statusCode);
                    console.log('Response:', JSON.stringify(response, null, 2));
                }
            } catch (error) {
                console.log('❌ Parse Error:', error.message);
                console.log('Raw Response:', responseData);
            }
        });
    });

    req.on('error', (error) => {
        console.log('❌ Request Error:', error.message);
    });

    req.write(data);
    req.end();
}

testGemini();


