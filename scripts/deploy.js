/* global ethers hre */

const diamondUtils = require('./lib/diamond-util/src/index')

function addCommas(nStr) {
  nStr += ''
  const x = nStr.split('.')
  let x1 = x[0]
  const x2 = x.length > 1 ? '.' + x[1] : ''
  var rgx = /(\d+)(\d{3})/
  while (rgx.test(x1)) {
    x1 = x1.replace(rgx, '$1' + ',' + '$2')
  }
  return x1 + x2
}

function strDisplay (str) {
  return addCommas(str.toString())
}

const main = async (scriptName) => {
  console.log('Script Name: ', scriptName)

  const gasLimit = 12300000
  const name = 'Snowdrops'
  const symbol = 'SNOWDROPS'
  let totalGasUsed = ethers.BigNumber.from('0')
  let tx, receipt, fee

  const accounts = await ethers.getSigners()
  const account = await accounts[0].getAddress()

  const deployFacets = async (...facets) => {
    const instances = []
  
    for (let facet of facets) {
      let constructorArgs = []
  
      if (Array.isArray(facet)) {
        ;[facet, constructorArgs] = facet
      }
  
      const factory = await ethers.getContractFactory(facet)
      const facetInstance = await factory.deploy(...constructorArgs)
      await facetInstance.deployed()
      
      tx = facetInstance.deployTransaction
      receipt = await tx.wait()
  
      console.log(`${facet} deploy gas used:` + strDisplay(receipt.gasUsed))
      totalGasUsed = totalGasUsed.add(receipt.gasUsed)
      instances.push(facetInstance)
  
    }
  
    return instances
  }

  if (hre.network.name === 'hardhat') {
    let [snowdropsFacet] = await deployFacets('SnowdropsFacet')
    const snowdropsDiamond = await diamondUtils.deploy({
      diamondName: 'SnowdropsDiamond',
      initDiamond: 'InitDiamond',
      facets: [
        ['SnowdropsFacet', snowdropsFacet]
      ],
      owner: account,
      args: [[name, symbol]]
    })

    console.log('Snowdrops diamond address:' + snowdropsDiamond.address)
    
    // Get Transaction Info
    tx = snowdropsDiamond.deployTransaction
    receipt = await tx.wait()
    console.log('Snowdrops diamond deploy gas used:' + strDisplay(receipt.gasUsed))
    totalGasUsed = totalGasUsed.add(receipt.gasUsed)

    // Get Diamond Facets
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', snowdropsDiamond.address)
    snowdropsFacet = await ethers.getContractAt('SnowdropsFacet', snowdropsDiamond.address)

    console.log('Total gas used: ' + strDisplay(totalGasUsed))

    return {
      account: account,
      snowdropsDiamond: snowdropsDiamond,
      diamondLoupeFacet: diamondLoupeFacet,
      snowdropsFacet: snowdropsFacet
    }
  } else {
    //void
    console.log('Network should only be Hardhat')
  }
}

if (require.main === module) {
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployDiamond = main