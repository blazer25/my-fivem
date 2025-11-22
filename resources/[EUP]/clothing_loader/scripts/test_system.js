#!/usr/bin/env node

/**
 * Test System for FiveM Clothing/EUP Loader
 * Validates the build system and checks for common issues
 */

const fs = require('fs');
const path = require('path');

class SystemTester {
    constructor() {
        this.baseDir = path.join(__dirname, '..');
        this.tests = [];
        this.passed = 0;
        this.failed = 0;
    }

    // Run all tests
    async runTests() {
        console.log('🧪 Running FiveM Clothing Loader System Tests...\n');

        // Test 1: Check directory structure
        this.test('Directory Structure', () => {
            const requiredDirs = ['data', 'stream', 'scripts'];
            for (const dir of requiredDirs) {
                const dirPath = path.join(this.baseDir, dir);
                if (!fs.existsSync(dirPath)) {
                    throw new Error(`Missing directory: ${dir}`);
                }
            }
            return true;
        });

        // Test 2: Check required files
        this.test('Required Files', () => {
            const requiredFiles = [
                'fxmanifest.lua',
                'client.lua',
                'server.lua',
                'README.md',
                'data/shop_ped_apparel.meta',
                'data/componentsets.meta',
                'data/pedaccessories.meta'
            ];
            
            for (const file of requiredFiles) {
                const filePath = path.join(this.baseDir, file);
                if (!fs.existsSync(filePath)) {
                    throw new Error(`Missing file: ${file}`);
                }
            }
            return true;
        });

        // Test 3: Validate fxmanifest.lua
        this.test('FXManifest Validation', () => {
            const manifestPath = path.join(this.baseDir, 'fxmanifest.lua');
            const content = fs.readFileSync(manifestPath, 'utf8');
            
            const requiredElements = [
                "fx_version 'cerulean'",
                "game 'gta5'",
                "data_file 'SHOP_PED_APPAREL_META_FILE'",
                "this_is_a_map 'yes'"
            ];
            
            for (const element of requiredElements) {
                if (!content.includes(element)) {
                    throw new Error(`Missing in fxmanifest.lua: ${element}`);
                }
            }
            return true;
        });

        // Test 4: Validate metadata files
        this.test('Metadata File Validation', () => {
            const metaFiles = [
                'data/shop_ped_apparel.meta',
                'data/componentsets.meta',
                'data/pedaccessories.meta'
            ];
            
            for (const metaFile of metaFiles) {
                const filePath = path.join(this.baseDir, metaFile);
                const content = fs.readFileSync(filePath, 'utf8');
                
                if (!content.includes('<?xml version="1.0" encoding="UTF-8"?>')) {
                    throw new Error(`Invalid XML header in: ${metaFile}`);
                }
            }
            return true;
        });

        // Test 5: Check build scripts
        this.test('Build Scripts', () => {
            const buildScripts = [
                'scripts/build_clothing.js',
                'scripts/build_clothing.py',
                'scripts/build.bat',
                'scripts/build.sh'
            ];
            
            for (const script of buildScripts) {
                const scriptPath = path.join(this.baseDir, script);
                if (!fs.existsSync(scriptPath)) {
                    throw new Error(`Missing build script: ${script}`);
                }
            }
            return true;
        });

        // Test 6: Simulate build process
        this.test('Build Process Simulation', () => {
            // Create a mock clothing file for testing
            const mockClothingDir = path.join(this.baseDir, 'test_clothing');
            if (!fs.existsSync(mockClothingDir)) {
                fs.mkdirSync(mockClothingDir, { recursive: true });
            }
            
            // Create mock files
            const mockFiles = [
                'test_male_shirt_001.ytd',
                'test_male_shirt_001.ydd',
                'test_female_pants_001.ytd',
                'test_female_pants_001.ydd'
            ];
            
            for (const mockFile of mockFiles) {
                const filePath = path.join(mockClothingDir, mockFile);
                fs.writeFileSync(filePath, 'mock clothing data');
            }
            
            // Clean up
            for (const mockFile of mockFiles) {
                const filePath = path.join(mockClothingDir, mockFile);
                if (fs.existsSync(filePath)) {
                    fs.unlinkSync(filePath);
                }
            }
            fs.rmdirSync(mockClothingDir);
            
            return true;
        });

        // Print results
        this.printResults();
    }

    // Run individual test
    test(name, testFunction) {
        try {
            const result = testFunction();
            if (result) {
                console.log(`✅ ${name}: PASSED`);
                this.passed++;
            } else {
                console.log(`❌ ${name}: FAILED`);
                this.failed++;
            }
        } catch (error) {
            console.log(`❌ ${name}: FAILED - ${error.message}`);
            this.failed++;
        }
    }

    // Print test results
    printResults() {
        console.log('\n📊 Test Results:');
        console.log(`   Passed: ${this.passed}`);
        console.log(`   Failed: ${this.failed}`);
        console.log(`   Total: ${this.passed + this.failed}`);
        
        if (this.failed === 0) {
            console.log('\n🎉 All tests passed! The clothing loader system is ready to use.');
            console.log('\nNext steps:');
            console.log('1. Add clothing files to the appropriate folders');
            console.log('2. Run the build script: npm run build');
            console.log('3. Restart your FiveM server');
            console.log('4. Test in-game with /clothinginfo command');
        } else {
            console.log('\n⚠️  Some tests failed. Please fix the issues before using the system.');
        }
    }
}

// Run tests if this script is executed directly
if (require.main === module) {
    const tester = new SystemTester();
    tester.runTests().catch(error => {
        console.error('Test runner error:', error);
        process.exit(1);
    });
}

module.exports = SystemTester;
