const fs = require('fs');

// Function to process the JSON data:
// 1. Group series by similar names
// 2. Remove all video_src fields
function processJsonData(data) {
  // Make a deep copy to avoid modifying the original data
  const processedData = JSON.parse(JSON.stringify(data));
  
  // Remove video_src from all episodes
  processedData.forEach(series => {
    if (series.episodes && Array.isArray(series.episodes)) {
      series.episodes.forEach(episode => {
        if (episode.hasOwnProperty('video_src')) {
          delete episode.video_src;
        }
      });
    }
  });
  
  // Sort series by name to group similar names together
  processedData.sort((a, b) => {
    // Get base name without season information
    const getBaseName = (name) => {
      // Remove season information (assumes it's at the end)
      return name.replace(/الموسم\s+\S+$/i, '').trim();
    };
    
    const baseNameA = getBaseName(a.name);
    const baseNameB = getBaseName(b.name);
    
    // First compare by base name
    if (baseNameA !== baseNameB) {
      return baseNameA.localeCompare(baseNameB, 'ar');
    }
    
    // If base names are the same, sort by full name
    return a.name.localeCompare(b.name, 'ar');
  });
  
  return processedData;
}

// Main function to read JSON file, process it, and write the result
function reorganizeJsonFile(inputFilePath, outputFilePath) {
  try {
    // Read the input JSON file
    const rawData = fs.readFileSync(inputFilePath, 'utf8');
    const jsonData = JSON.parse(rawData);
    
    // Process the data
    const processedData = processJsonData(jsonData);
    
    // Write the processed data to the output file
    fs.writeFileSync(
      outputFilePath,
      JSON.stringify(processedData, null, 2),
      'utf8'
    );
    
    console.log(`Successfully processed JSON data and saved to ${outputFilePath}`);
  } catch (error) {
    console.error('Error processing JSON file:', error.message);
  }
}

// Check for command line arguments
const args = process.argv.slice(2);
if (args.length < 2) {
  console.log('Usage: node script.js <inputFilePath> <outputFilePath>');
  process.exit(1);
}

// Run the script with command line arguments
reorganizeJsonFile(args[0], args[1]);