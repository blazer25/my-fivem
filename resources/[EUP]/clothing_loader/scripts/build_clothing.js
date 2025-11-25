#!/usr/bin/env node

/**
 * FiveM Clothing/EUP Auto-Builder
 * Automatically scans, detects, and builds clothing packs
 * Generates unified metadata and organizes assets
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

class ClothingBuilder {
    constructor() {
        this.config = {
            // Folders to scan for clothing
            scanFolders: [
                'ef_clothes',
                'ef_clothes_new',
                'Male-EUP',
                'Female-EUP',
                'cfx_onx_gov_clothing',
                'cfx_onx_gov_clothing_pack',
                'onx-evp-a-shared.pack',
                'onx-evp-b-wheels.pack',
                'onx-evp-c-pack.pack',
                'ensart_sonsof'
            ],
            
            // File extensions to process
            clothingExtensions: ['.ytd', '.ydd', '.yft', '.ytf'],
            metaExtensions: ['.meta'],
            
            // Output directories
            outputDir: path.join(__dirname, '..'),
            streamDir: path.join(__dirname, '..', 'stream'),
            dataDir: path.join(__dirname, '..', 'data'),
            
            // Base directories to search
            baseDirs: [
                path.join(__dirname, '..', '..', '..', '..', 'resources'),
                path.join(__dirname, '..', '..', '..', '..', 'resources', '[EUP]'),
                path.join(__dirname, '..', '..', '..', '..', 'resources', '[standalone]'),
                path.join(__dirname, '..', '..', '..', '..', 'resources', '[assets]'),
                // Also search within [EUP] subdirectories
                path.join(__dirname, '..', '..', '[onx_peds]')
            ]
        };
        
        this.buildStats = {
            startTime: Date.now(),
            filesProcessed: 0,
            clothingItems: 0,
            metaFiles: 0,
            errors: [],
            duplicatesRemoved: 0,
            totalSize: 0
        };
        
        this.foundFiles = {
            clothing: new Map(),
            meta: new Map()
        };
        
        this.metaData = {
            shopPedApparel: [],
            componentSets: [],
            pedAccessories: []
        };
    }

    // Main build process
    async build() {
        console.log('🚀 Starting FiveM Clothing/EUP Auto-Builder...\n');
        
        try {
            // Step 1: Scan for clothing folders
            await this.scanForClothingFolders();
            
            // Step 2: Process found files
            await this.processFoundFiles();
            
            // Step 3: Generate metadata
            await this.generateMetadata();
            
            // Step 4: Copy assets to stream folder
            await this.copyAssetsToStream();
            
            // Step 5: Generate build report
            await this.generateBuildReport();
            
            console.log('✅ Build completed successfully!\n');
            this.printBuildSummary();
            
        } catch (error) {
            console.error('❌ Build failed:', error.message);
            this.buildStats.errors.push(error.message);
            process.exit(1);
        }
    }

    // Scan for clothing folders in all base directories
    async scanForClothingFolders() {
        console.log('🔍 Scanning for clothing folders...');
        
        for (const baseDir of this.config.baseDirs) {
            if (!fs.existsSync(baseDir)) continue;
            
            for (const scanFolder of this.config.scanFolders) {
                const fullPath = path.join(baseDir, scanFolder);
                
                if (fs.existsSync(fullPath)) {
                    console.log(`   Found: ${fullPath}`);
                    await this.scanDirectory(fullPath);
                }
            }
        }
        
        console.log(`   📁 Found ${this.foundFiles.clothing.size} clothing files`);
        console.log(`   📄 Found ${this.foundFiles.meta.size} meta files\n`);
    }

    // Recursively scan directory for clothing and meta files
    async scanDirectory(dirPath) {
        try {
            const entries = fs.readdirSync(dirPath, { withFileTypes: true });
            
            for (const entry of entries) {
                const fullPath = path.join(dirPath, entry.name);
                
                if (entry.isDirectory()) {
                    await this.scanDirectory(fullPath);
                } else if (entry.isFile()) {
                    const ext = path.extname(entry.name).toLowerCase();
                    
                    if (this.config.clothingExtensions.includes(ext)) {
                        const hash = this.getFileHash(fullPath);
                        const fileInfo = {
                            path: fullPath,
                            name: entry.name,
                            size: fs.statSync(fullPath).size,
                            hash: hash,
                            type: this.determineClothingType(entry.name)
                        };
                        
                        // Check for duplicates
                        if (this.foundFiles.clothing.has(hash)) {
                            this.buildStats.duplicatesRemoved++;
                            console.log(`   ⚠️  Duplicate removed: ${entry.name}`);
                        } else {
                            this.foundFiles.clothing.set(hash, fileInfo);
                        }
                    } else if (this.config.metaExtensions.includes(ext)) {
                        const fileInfo = {
                            path: fullPath,
                            name: entry.name,
                            content: fs.readFileSync(fullPath, 'utf8')
                        };
                        
                        this.foundFiles.meta.set(fullPath, fileInfo);
                    }
                }
            }
        } catch (error) {
            this.buildStats.errors.push(`Error scanning ${dirPath}: ${error.message}`);
        }
    }

    // Determine clothing type from filename
    determineClothingType(filename) {
        const name = filename.toLowerCase();
        
        if (name.includes('_u_') || name.includes('uppr')) return 'upper';
        if (name.includes('_l_') || name.includes('lowr')) return 'lower';
        if (name.includes('_feet_') || name.includes('shoes')) return 'shoes';
        if (name.includes('_head_') || name.includes('hat')) return 'hat';
        if (name.includes('_hand_') || name.includes('glove')) return 'gloves';
        if (name.includes('_acc_') || name.includes('accessory')) return 'accessory';
        if (name.includes('_decl_') || name.includes('decal')) return 'decal';
        if (name.includes('_jbib_') || name.includes('shirt')) return 'shirt';
        if (name.includes('_task_') || name.includes('vest')) return 'vest';
        if (name.includes('_berd_') || name.includes('beard')) return 'beard';
        if (name.includes('_hair_')) return 'hair';
        
        return 'unknown';
    }

    // Get file hash for duplicate detection
    getFileHash(filePath) {
        const fileBuffer = fs.readFileSync(filePath);
        return crypto.createHash('md5').update(fileBuffer).digest('hex');
    }

    // Process found files and extract metadata
    async processFoundFiles() {
        console.log('⚙️  Processing found files...');
        
        // Process meta files first
        for (const [filePath, fileInfo] of this.foundFiles.meta) {
            try {
                await this.processMetaFile(fileInfo);
                this.buildStats.metaFiles++;
            } catch (error) {
                this.buildStats.errors.push(`Error processing meta ${fileInfo.name}: ${error.message}`);
            }
        }
        
        // Process clothing files
        for (const [hash, fileInfo] of this.foundFiles.clothing) {
            try {
                await this.processClothingFile(fileInfo);
                this.buildStats.clothingItems++;
                this.buildStats.totalSize += fileInfo.size;
            } catch (error) {
                this.buildStats.errors.push(`Error processing clothing ${fileInfo.name}: ${error.message}`);
            }
        }
        
        this.buildStats.filesProcessed = this.buildStats.metaFiles + this.buildStats.clothingItems;
        console.log(`   ✅ Processed ${this.buildStats.filesProcessed} files\n`);
    }

    // Process individual meta file
    async processMetaFile(fileInfo) {
        const content = fileInfo.content;
        
        // Parse different types of meta files
        if (fileInfo.name.includes('shop_ped_apparel') || fileInfo.name.includes('componentsets')) {
            this.parseShopPedApparel(content);
        } else if (fileInfo.name.includes('pedaccessories')) {
            this.parsePedAccessories(content);
        }
    }

    // Parse shop_ped_apparel.meta content
    parseShopPedApparel(content) {
        // Extract component entries from XML-like meta content
        const componentRegex = /<Item type="CComponentInfo">([\s\S]*?)<\/Item>/g;
        let match;
        
        while ((match = componentRegex.exec(content)) !== null) {
            const componentData = match[1];
            
            // Extract component details
            const component = {
                expressionMods: this.extractValue(componentData, 'expressionMods'),
                componentFlags: this.extractValue(componentData, 'componentFlags'),
                inclusions: this.extractValue(componentData, 'inclusions'),
                exclusions: this.extractValue(componentData, 'exclusions'),
                multiColorExpressions: this.extractValue(componentData, 'multiColorExpressions')
            };
            
            this.metaData.shopPedApparel.push(component);
        }
    }

    // Parse ped accessories meta content
    parsePedAccessories(content) {
        const accessoryRegex = /<Item>([\s\S]*?)<\/Item>/g;
        let match;
        
        while ((match = accessoryRegex.exec(content)) !== null) {
            const accessoryData = match[1];
            
            const accessory = {
                audioId: this.extractValue(accessoryData, 'audioId'),
                expressionMods: this.extractValue(accessoryData, 'expressionMods'),
                inclusions: this.extractValue(accessoryData, 'inclusions'),
                exclusions: this.extractValue(accessoryData, 'exclusions')
            };
            
            this.metaData.pedAccessories.push(accessory);
        }
    }

    // Extract value from meta content
    extractValue(content, tagName) {
        const regex = new RegExp(`<${tagName}[^>]*>(.*?)<\/${tagName}>`, 's');
        const match = content.match(regex);
        return match ? match[1].trim() : '';
    }

    // Process individual clothing file
    async processClothingFile(fileInfo) {
        // Add clothing file info to metadata if needed
        // This is where you could add specific processing for different clothing types
    }

    // Generate unified metadata files
    async generateMetadata() {
        console.log('📝 Generating metadata files...');
        
        // Ensure data directory exists
        if (!fs.existsSync(this.config.dataDir)) {
            fs.mkdirSync(this.config.dataDir, { recursive: true });
        }
        
        // Generate shop_ped_apparel.meta
        await this.generateShopPedApparelMeta();
        
        // Generate componentsets.meta if needed
        await this.generateComponentSetsMeta();
        
        // Generate pedaccessories.meta if needed
        await this.generatePedAccessoriesMeta();
        
        console.log('   ✅ Metadata files generated\n');
    }

    // Generate shop_ped_apparel.meta
    async generateShopPedApparelMeta() {
        const metaContent = `<?xml version="1.0" encoding="UTF-8"?>
<CShopPedApparelMetaFile>
  <residentTxd>shop_ped_apparel</residentTxd>
  <hasGlobalTextureList value="false" />
  <globalTextures />
  <characterCloth>
    <Unk_2834549053>
${this.metaData.shopPedApparel.map((component, index) => `      <Item>
        <Unk_2806194106 value="${index}" />
        <Unk_532864754>
          <expressionMods />
          <componentFlags value="0" />
          <inclusions />
          <exclusions />
          <multiColorExpressions />
        </Unk_532864754>
      </Item>`).join('\n')}
    </Unk_2834549053>
  </characterCloth>
  <pedOutfits />
  <dlcName>clothing_loader</dlcName>
</CShopPedApparelMetaFile>`;

        const outputPath = path.join(this.config.dataDir, 'shop_ped_apparel.meta');
        fs.writeFileSync(outputPath, metaContent, 'utf8');
    }

    // Generate componentsets.meta
    async generateComponentSetsMeta() {
        const metaContent = `<?xml version="1.0" encoding="UTF-8"?>
<CComponentSetsFile>
  <componentSets />
</CComponentSetsFile>`;

        const outputPath = path.join(this.config.dataDir, 'componentsets.meta');
        fs.writeFileSync(outputPath, metaContent, 'utf8');
    }

    // Generate pedaccessories.meta
    async generatePedAccessoriesMeta() {
        const metaContent = `<?xml version="1.0" encoding="UTF-8"?>
<CPedAccessoriesFile>
  <accessories>
${this.metaData.pedAccessories.map((accessory, index) => `    <Item>
      <audioId value="${index}" />
      <expressionMods />
      <inclusions />
      <exclusions />
    </Item>`).join('\n')}
  </accessories>
</CPedAccessoriesFile>`;

        const outputPath = path.join(this.config.dataDir, 'pedaccessories.meta');
        fs.writeFileSync(outputPath, metaContent, 'utf8');
    }

    // Copy assets to stream folder
    async copyAssetsToStream() {
        console.log('📦 Copying assets to stream folder...');
        
        // Ensure stream directory exists
        if (!fs.existsSync(this.config.streamDir)) {
            fs.mkdirSync(this.config.streamDir, { recursive: true });
        }
        
        // Clear existing files in stream directory
        const existingFiles = fs.readdirSync(this.config.streamDir);
        for (const file of existingFiles) {
            const filePath = path.join(this.config.streamDir, file);
            if (fs.statSync(filePath).isFile()) {
                fs.unlinkSync(filePath);
            }
        }
        
        // Copy clothing files
        let copiedCount = 0;
        for (const [hash, fileInfo] of this.foundFiles.clothing) {
            try {
                const destPath = path.join(this.config.streamDir, fileInfo.name);
                fs.copyFileSync(fileInfo.path, destPath);
                copiedCount++;
            } catch (error) {
                this.buildStats.errors.push(`Error copying ${fileInfo.name}: ${error.message}`);
            }
        }
        
        console.log(`   ✅ Copied ${copiedCount} files to stream folder\n`);
    }

    // Generate build report
    async generateBuildReport() {
        const buildInfo = {
            version: "1.0.0",
            lastBuild: new Date().toISOString(),
            totalFiles: this.buildStats.filesProcessed,
            totalClothing: this.buildStats.clothingItems,
            totalMeta: this.buildStats.metaFiles,
            duplicatesRemoved: this.buildStats.duplicatesRemoved,
            totalSize: this.buildStats.totalSize,
            buildTime: Date.now() - this.buildStats.startTime,
            errors: this.buildStats.errors,
            clothingTypes: this.getClothingTypeStats()
        };
        
        const reportPath = path.join(this.config.outputDir, 'build_info.json');
        fs.writeFileSync(reportPath, JSON.stringify(buildInfo, null, 2), 'utf8');
        
        // Also create a human-readable report
        const readableReport = this.generateReadableReport(buildInfo);
        const readableReportPath = path.join(this.config.outputDir, 'build_report.txt');
        fs.writeFileSync(readableReportPath, readableReport, 'utf8');
    }

    // Get clothing type statistics
    getClothingTypeStats() {
        const stats = {};
        
        for (const [hash, fileInfo] of this.foundFiles.clothing) {
            const type = fileInfo.type;
            stats[type] = (stats[type] || 0) + 1;
        }
        
        return stats;
    }

    // Generate human-readable report
    generateReadableReport(buildInfo) {
        return `
FiveM Clothing/EUP Auto-Builder Report
=====================================

Build Date: ${buildInfo.lastBuild}
Build Time: ${buildInfo.buildTime}ms

Files Processed:
- Total Files: ${buildInfo.totalFiles}
- Clothing Files: ${buildInfo.totalClothing}
- Meta Files: ${buildInfo.totalMeta}
- Duplicates Removed: ${buildInfo.duplicatesRemoved}

Total Size: ${(buildInfo.totalSize / 1024 / 1024).toFixed(2)} MB

Clothing Types:
${Object.entries(buildInfo.clothingTypes).map(([type, count]) => `- ${type}: ${count}`).join('\n')}

${buildInfo.errors.length > 0 ? `
Errors (${buildInfo.errors.length}):
${buildInfo.errors.map(error => `- ${error}`).join('\n')}
` : 'No errors encountered.'}

Build completed successfully!
        `.trim();
    }

    // Print build summary to console
    printBuildSummary() {
        console.log('📊 Build Summary:');
        console.log(`   Files Processed: ${this.buildStats.filesProcessed}`);
        console.log(`   Clothing Items: ${this.buildStats.clothingItems}`);
        console.log(`   Meta Files: ${this.buildStats.metaFiles}`);
        console.log(`   Duplicates Removed: ${this.buildStats.duplicatesRemoved}`);
        console.log(`   Total Size: ${(this.buildStats.totalSize / 1024 / 1024).toFixed(2)} MB`);
        console.log(`   Build Time: ${Date.now() - this.buildStats.startTime}ms`);
        
        if (this.buildStats.errors.length > 0) {
            console.log(`   ⚠️  Errors: ${this.buildStats.errors.length}`);
        }
        
        console.log('\n🎉 Ready to use! Restart your FiveM server to load the new clothing.');
    }
}

// Run the builder if this script is executed directly
if (require.main === module) {
    const builder = new ClothingBuilder();
    builder.build().catch(error => {
        console.error('Fatal error:', error);
        process.exit(1);
    });
}

module.exports = ClothingBuilder;
