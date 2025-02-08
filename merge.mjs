import fs from 'fs'
import path from 'path'

const mainSchemaPath = path.join(process.cwd(), 'prisma', 'schema.prisma')
const extensionsPath = path.join(process.cwd(), 'prisma', 'extensions')

// Read the main schema
const mainSchemaContent = fs.readFileSync(mainSchemaPath, 'utf-8')

const extract = (content, pattern) => {
  const items = {}
  const matches = content.match(pattern) || []
  matches.forEach((item) => {
    const name = item.match(/(model|enum)\s+(\w+)/)[2]
    items[name] = item
  })
  return items
}

const addonFolders = fs
  .readdirSync(extensionsPath, { withFileTypes: true })
  .filter((dirent) => dirent.isDirectory())
  .map((dirent) => dirent.name)

let mergedSchema = mainSchemaContent
let hasUpdates = false
let summary = []

console.log('Merging Addons:')
addonFolders.forEach((folder) => {
  console.log(`- Processing folder: ${folder}`)
  const addonSchemaPath = path.join(extensionsPath, folder, 'schema.prisma')
  if (fs.existsSync(addonSchemaPath)) {
    const addonSchemaContent = fs.readFileSync(addonSchemaPath, 'utf-8')

    const patterns = {
      models: /model\s+\w+\s+\{[\s\S]+?\}/g,
      enums: /enum\s+\w+\s+\{[\s\S]+?\}/g,
    }

    for (const [type, pattern] of Object.entries(patterns)) {
      const mainItems = extract(mainSchemaContent, pattern)
      const addonItems = extract(addonSchemaContent, pattern)

      for (const [name, addonItem] of Object.entries(addonItems)) {
        if (mainItems[name]) {
          console.log(
            `  ${type} ${name} already exists. Updating with new content.`,
          )
          const mainItem = mainItems[name]
          mergedSchema = mergedSchema.replace(mainItem, addonItem)
          hasUpdates = true
          summary.push(`Updated ${type}: ${name}`)
        } else {
          mergedSchema += '\n' + addonItem
          hasUpdates = true
          summary.push(`Added new ${type}: ${name}`)
        }
      }
    }
  } else {
    console.log(`  No schema.prisma found in ${folder}. Skipping.`)
  }
})

if (hasUpdates) {
  fs.writeFileSync(mainSchemaPath, mergedSchema)
  console.log('Addons successfully installed!')
  console.log('Summary of changes:')
  summary.forEach((change) => console.log(`  ${change}`))
} else {
  console.log('No updates needed. Skipping installation.')
}
