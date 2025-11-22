#!/usr/bin/env python3

"""
FiveM Clothing/EUP Auto-Builder (Python Version)
Automatically scans, detects, and builds clothing packs
Generates unified metadata and organizes assets
"""

import os
import json
import shutil
import hashlib
import re
import xml.etree.ElementTree as ET
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Set, Tuple, Optional

class ClothingBuilder:
    def __init__(self):
        self.script_dir = Path(__file__).parent
        self.base_dir = self.script_dir.parent
        
        self.config = {
            # Folders to scan for clothing
            'scan_folders': [
                'ef_clothes',
                'ef_clothes_new',
                'Male-EUP',
                'Female-EUP',
                'cfx_onx_gov_clothing_pack',
                'onx-evp-a-shared.pack',
                'onx-evp-b-wheels.pack',
                'onx-evp-c-pack.pack'
            ],
            
            # File extensions to process
            'clothing_extensions': {'.ytd', '.ydd', '.yft', '.ytf'},
            'meta_extensions': {'.meta'},
            
            # Output directories
            'output_dir': self.base_dir,
            'stream_dir': self.base_dir / 'stream',
            'data_dir': self.base_dir / 'data',
            
            # Base directories to search
            'base_dirs': [
                self.base_dir.parent.parent.parent / 'resources',
                self.base_dir.parent.parent.parent / 'resources' / '[EUP]',
                self.base_dir.parent.parent.parent / 'resources' / '[standalone]',
                self.base_dir.parent.parent.parent / 'resources' / '[assets]'
            ]
        }
        
        self.build_stats = {
            'start_time': datetime.now(),
            'files_processed': 0,
            'clothing_items': 0,
            'meta_files': 0,
            'errors': [],
            'duplicates_removed': 0,
            'total_size': 0
        }
        
        self.found_files = {
            'clothing': {},  # hash -> file_info
            'meta': {}       # path -> file_info
        }
        
        self.meta_data = {
            'shop_ped_apparel': [],
            'component_sets': [],
            'ped_accessories': []
        }

    def build(self):
        """Main build process"""
        print('🚀 Starting FiveM Clothing/EUP Auto-Builder (Python)...\n')
        
        try:
            # Step 1: Scan for clothing folders
            self.scan_for_clothing_folders()
            
            # Step 2: Process found files
            self.process_found_files()
            
            # Step 3: Generate metadata
            self.generate_metadata()
            
            # Step 4: Copy assets to stream folder
            self.copy_assets_to_stream()
            
            # Step 5: Generate build report
            self.generate_build_report()
            
            print('✅ Build completed successfully!\n')
            self.print_build_summary()
            
        except Exception as error:
            print(f'❌ Build failed: {error}')
            self.build_stats['errors'].append(str(error))
            raise

    def scan_for_clothing_folders(self):
        """Scan for clothing folders in all base directories"""
        print('🔍 Scanning for clothing folders...')
        
        for base_dir in self.config['base_dirs']:
            if not base_dir.exists():
                continue
                
            for scan_folder in self.config['scan_folders']:
                full_path = base_dir / scan_folder
                
                if full_path.exists():
                    print(f'   Found: {full_path}')
                    self.scan_directory(full_path)
        
        print(f'   📁 Found {len(self.found_files["clothing"])} clothing files')
        print(f'   📄 Found {len(self.found_files["meta"])} meta files\n')

    def scan_directory(self, dir_path: Path):
        """Recursively scan directory for clothing and meta files"""
        try:
            for item in dir_path.rglob('*'):
                if item.is_file():
                    ext = item.suffix.lower()
                    
                    if ext in self.config['clothing_extensions']:
                        file_hash = self.get_file_hash(item)
                        file_info = {
                            'path': str(item),
                            'name': item.name,
                            'size': item.stat().st_size,
                            'hash': file_hash,
                            'type': self.determine_clothing_type(item.name)
                        }
                        
                        # Check for duplicates
                        if file_hash in self.found_files['clothing']:
                            self.build_stats['duplicates_removed'] += 1
                            print(f'   ⚠️  Duplicate removed: {item.name}')
                        else:
                            self.found_files['clothing'][file_hash] = file_info
                            
                    elif ext in self.config['meta_extensions']:
                        file_info = {
                            'path': str(item),
                            'name': item.name,
                            'content': item.read_text(encoding='utf-8', errors='ignore')
                        }
                        
                        self.found_files['meta'][str(item)] = file_info
                        
        except Exception as error:
            self.build_stats['errors'].append(f'Error scanning {dir_path}: {error}')

    def determine_clothing_type(self, filename: str) -> str:
        """Determine clothing type from filename"""
        name = filename.lower()
        
        type_mapping = {
            ('_u_', 'uppr'): 'upper',
            ('_l_', 'lowr'): 'lower',
            ('_feet_', 'shoes'): 'shoes',
            ('_head_', 'hat'): 'hat',
            ('_hand_', 'glove'): 'gloves',
            ('_acc_', 'accessory'): 'accessory',
            ('_decl_', 'decal'): 'decal',
            ('_jbib_', 'shirt'): 'shirt',
            ('_task_', 'vest'): 'vest',
            ('_berd_', 'beard'): 'beard',
            ('_hair_',): 'hair'
        }
        
        for keywords, clothing_type in type_mapping.items():
            if any(keyword in name for keyword in keywords):
                return clothing_type
                
        return 'unknown'

    def get_file_hash(self, file_path: Path) -> str:
        """Get file hash for duplicate detection"""
        hash_md5 = hashlib.md5()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()

    def process_found_files(self):
        """Process found files and extract metadata"""
        print('⚙️  Processing found files...')
        
        # Process meta files first
        for file_path, file_info in self.found_files['meta'].items():
            try:
                self.process_meta_file(file_info)
                self.build_stats['meta_files'] += 1
            except Exception as error:
                self.build_stats['errors'].append(f'Error processing meta {file_info["name"]}: {error}')
        
        # Process clothing files
        for file_hash, file_info in self.found_files['clothing'].items():
            try:
                self.process_clothing_file(file_info)
                self.build_stats['clothing_items'] += 1
                self.build_stats['total_size'] += file_info['size']
            except Exception as error:
                self.build_stats['errors'].append(f'Error processing clothing {file_info["name"]}: {error}')
        
        self.build_stats['files_processed'] = self.build_stats['meta_files'] + self.build_stats['clothing_items']
        print(f'   ✅ Processed {self.build_stats["files_processed"]} files\n')

    def process_meta_file(self, file_info: Dict):
        """Process individual meta file"""
        content = file_info['content']
        
        # Parse different types of meta files
        if 'shop_ped_apparel' in file_info['name'] or 'componentsets' in file_info['name']:
            self.parse_shop_ped_apparel(content)
        elif 'pedaccessories' in file_info['name']:
            self.parse_ped_accessories(content)

    def parse_shop_ped_apparel(self, content: str):
        """Parse shop_ped_apparel.meta content"""
        # Extract component entries from XML-like meta content
        component_pattern = r'<Item type="CComponentInfo">(.*?)</Item>'
        matches = re.findall(component_pattern, content, re.DOTALL)
        
        for match in matches:
            component = {
                'expressionMods': self.extract_value(match, 'expressionMods'),
                'componentFlags': self.extract_value(match, 'componentFlags'),
                'inclusions': self.extract_value(match, 'inclusions'),
                'exclusions': self.extract_value(match, 'exclusions'),
                'multiColorExpressions': self.extract_value(match, 'multiColorExpressions')
            }
            
            self.meta_data['shop_ped_apparel'].append(component)

    def parse_ped_accessories(self, content: str):
        """Parse ped accessories meta content"""
        accessory_pattern = r'<Item>(.*?)</Item>'
        matches = re.findall(accessory_pattern, content, re.DOTALL)
        
        for match in matches:
            accessory = {
                'audioId': self.extract_value(match, 'audioId'),
                'expressionMods': self.extract_value(match, 'expressionMods'),
                'inclusions': self.extract_value(match, 'inclusions'),
                'exclusions': self.extract_value(match, 'exclusions')
            }
            
            self.meta_data['ped_accessories'].append(accessory)

    def extract_value(self, content: str, tag_name: str) -> str:
        """Extract value from meta content"""
        pattern = f'<{tag_name}[^>]*>(.*?)</{tag_name}>'
        match = re.search(pattern, content, re.DOTALL)
        return match.group(1).strip() if match else ''

    def process_clothing_file(self, file_info: Dict):
        """Process individual clothing file"""
        # Add clothing file info to metadata if needed
        pass

    def generate_metadata(self):
        """Generate unified metadata files"""
        print('📝 Generating metadata files...')
        
        # Ensure data directory exists
        self.config['data_dir'].mkdir(parents=True, exist_ok=True)
        
        # Generate shop_ped_apparel.meta
        self.generate_shop_ped_apparel_meta()
        
        # Generate componentsets.meta if needed
        self.generate_component_sets_meta()
        
        # Generate pedaccessories.meta if needed
        self.generate_ped_accessories_meta()
        
        print('   ✅ Metadata files generated\n')

    def generate_shop_ped_apparel_meta(self):
        """Generate shop_ped_apparel.meta"""
        components_xml = '\n'.join([
            f'''      <Item>
        <Unk_2806194106 value="{index}" />
        <Unk_532864754>
          <expressionMods />
          <componentFlags value="0" />
          <inclusions />
          <exclusions />
          <multiColorExpressions />
        </Unk_532864754>
      </Item>''' for index, component in enumerate(self.meta_data['shop_ped_apparel'])
        ])
        
        meta_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<CShopPedApparelMetaFile>
  <residentTxd>shop_ped_apparel</residentTxd>
  <hasGlobalTextureList value="false" />
  <globalTextures />
  <characterCloth>
    <Unk_2834549053>
{components_xml}
    </Unk_2834549053>
  </characterCloth>
  <pedOutfits />
  <dlcName>clothing_loader</dlcName>
</CShopPedApparelMetaFile>'''

        output_path = self.config['data_dir'] / 'shop_ped_apparel.meta'
        output_path.write_text(meta_content, encoding='utf-8')

    def generate_component_sets_meta(self):
        """Generate componentsets.meta"""
        meta_content = '''<?xml version="1.0" encoding="UTF-8"?>
<CComponentSetsFile>
  <componentSets />
</CComponentSetsFile>'''

        output_path = self.config['data_dir'] / 'componentsets.meta'
        output_path.write_text(meta_content, encoding='utf-8')

    def generate_ped_accessories_meta(self):
        """Generate pedaccessories.meta"""
        accessories_xml = '\n'.join([
            f'''    <Item>
      <audioId value="{index}" />
      <expressionMods />
      <inclusions />
      <exclusions />
    </Item>''' for index, accessory in enumerate(self.meta_data['ped_accessories'])
        ])
        
        meta_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<CPedAccessoriesFile>
  <accessories>
{accessories_xml}
  </accessories>
</CPedAccessoriesFile>'''

        output_path = self.config['data_dir'] / 'pedaccessories.meta'
        output_path.write_text(meta_content, encoding='utf-8')

    def copy_assets_to_stream(self):
        """Copy assets to stream folder"""
        print('📦 Copying assets to stream folder...')
        
        # Ensure stream directory exists
        self.config['stream_dir'].mkdir(parents=True, exist_ok=True)
        
        # Clear existing files in stream directory
        for item in self.config['stream_dir'].iterdir():
            if item.is_file():
                item.unlink()
        
        # Copy clothing files
        copied_count = 0
        for file_hash, file_info in self.found_files['clothing'].items():
            try:
                source_path = Path(file_info['path'])
                dest_path = self.config['stream_dir'] / file_info['name']
                shutil.copy2(source_path, dest_path)
                copied_count += 1
            except Exception as error:
                self.build_stats['errors'].append(f'Error copying {file_info["name"]}: {error}')
        
        print(f'   ✅ Copied {copied_count} files to stream folder\n')

    def generate_build_report(self):
        """Generate build report"""
        build_time = datetime.now() - self.build_stats['start_time']
        
        build_info = {
            'version': '1.0.0',
            'lastBuild': datetime.now().isoformat(),
            'totalFiles': self.build_stats['files_processed'],
            'totalClothing': self.build_stats['clothing_items'],
            'totalMeta': self.build_stats['meta_files'],
            'duplicatesRemoved': self.build_stats['duplicates_removed'],
            'totalSize': self.build_stats['total_size'],
            'buildTime': int(build_time.total_seconds() * 1000),
            'errors': self.build_stats['errors'],
            'clothingTypes': self.get_clothing_type_stats()
        }
        
        # Save JSON report
        report_path = self.config['output_dir'] / 'build_info.json'
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(build_info, f, indent=2)
        
        # Save human-readable report
        readable_report = self.generate_readable_report(build_info)
        readable_report_path = self.config['output_dir'] / 'build_report.txt'
        readable_report_path.write_text(readable_report, encoding='utf-8')

    def get_clothing_type_stats(self) -> Dict[str, int]:
        """Get clothing type statistics"""
        stats = {}
        
        for file_hash, file_info in self.found_files['clothing'].items():
            clothing_type = file_info['type']
            stats[clothing_type] = stats.get(clothing_type, 0) + 1
        
        return stats

    def generate_readable_report(self, build_info: Dict) -> str:
        """Generate human-readable report"""
        clothing_types_str = '\n'.join([
            f'- {clothing_type}: {count}' 
            for clothing_type, count in build_info['clothingTypes'].items()
        ])
        
        errors_str = ''
        if build_info['errors']:
            errors_str = f'''
Errors ({len(build_info['errors'])}):
{chr(10).join([f'- {error}' for error in build_info['errors']])}
'''
        else:
            errors_str = 'No errors encountered.'
        
        return f'''
FiveM Clothing/EUP Auto-Builder Report (Python)
===============================================

Build Date: {build_info['lastBuild']}
Build Time: {build_info['buildTime']}ms

Files Processed:
- Total Files: {build_info['totalFiles']}
- Clothing Files: {build_info['totalClothing']}
- Meta Files: {build_info['totalMeta']}
- Duplicates Removed: {build_info['duplicatesRemoved']}

Total Size: {build_info['totalSize'] / 1024 / 1024:.2f} MB

Clothing Types:
{clothing_types_str}

{errors_str}

Build completed successfully!
        '''.strip()

    def print_build_summary(self):
        """Print build summary to console"""
        build_time = datetime.now() - self.build_stats['start_time']
        
        print('📊 Build Summary:')
        print(f'   Files Processed: {self.build_stats["files_processed"]}')
        print(f'   Clothing Items: {self.build_stats["clothing_items"]}')
        print(f'   Meta Files: {self.build_stats["meta_files"]}')
        print(f'   Duplicates Removed: {self.build_stats["duplicates_removed"]}')
        print(f'   Total Size: {self.build_stats["total_size"] / 1024 / 1024:.2f} MB')
        print(f'   Build Time: {int(build_time.total_seconds() * 1000)}ms')
        
        if self.build_stats['errors']:
            print(f'   ⚠️  Errors: {len(self.build_stats["errors"])}')
        
        print('\n🎉 Ready to use! Restart your FiveM server to load the new clothing.')


def main():
    """Main entry point"""
    builder = ClothingBuilder()
    try:
        builder.build()
    except Exception as error:
        print(f'Fatal error: {error}')
        exit(1)


if __name__ == '__main__':
    main()
