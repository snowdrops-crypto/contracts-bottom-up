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

  // Chainlink Variables (Set for Mumbai)
  const chainlinkKeyHash = '0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4'
  const chainlinkFee = ethers.utils.parseEther('0.0001')
  const vrfCoordinator = '0x8C7382F9D8f56b33781fE506E897a4F1e2d17255'
  let linkAddress = ''

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
    // Mock Link Token for Local Testing
    const LinkTokenMock = await ethers.getContractFactory('LinkTokenMock')
    linkContract = await LinkTokenMock.deploy()
    await linkContract.deployed()
    console.log(`Mock Link Contract Address: ${linkContract.address}`)
    linkAddress = linkContract.address

    let [snowdropFacet, itemFacet, metaTransactionFacet, vrfFacet] = await deployFacets('SnowdropFacet', 'ItemFacet', 'MetaTransactionFacet', 'VRFFacet')

    const snowdropsDiamond = await diamondUtils.deploy({
      diamondName: 'SnowdropsDiamondTest1',
      initDiamond: 'InitDiamond',
      facets: [
        ['SnowdropFacet', snowdropFacet],
        ['ItemFacet', itemFacet],
        ['MetaTransactionFacet', metaTransactionFacet],
        ['VRFFacet', vrfFacet]
      ],
      owner: account,
      args: [[name, symbol, chainlinkKeyHash, chainlinkFee, vrfCoordinator, linkAddress]]
    })

    console.log('Snowdrops diamond address:' + snowdropsDiamond.address)
    
    // Get Transaction Info
    tx = snowdropsDiamond.deployTransaction
    receipt = await tx.wait()
    console.log('Snowdrops diamond deploy gas used:' + strDisplay(receipt.gasUsed))
    totalGasUsed = totalGasUsed.add(receipt.gasUsed)

    // Get Diamond Facets
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', snowdropsDiamond.address)
    snowdropFacet = await ethers.getContractAt('SnowdropFacet', snowdropsDiamond.address)
    itemFacet = await ethers.getContractAt('ItemFacet', snowdropsDiamond.address)
    metaTransactionFacet = await ethers.getContractAt('MetaTransactionFacet', snowdropsDiamond.address)
    vrfFacet = await ethers.getContractAt('VRFFacet', snowdropsDiamond.address)

    console.log('Total gas used: ' + strDisplay(totalGasUsed))

    return {
      account: account,
      snowdropsDiamond: snowdropsDiamond,
      diamondLoupeFacet: diamondLoupeFacet,
      snowdropFacet: snowdropFacet,
      itemFacet: itemFacet,
      metaTransactionFacet: metaTransactionFacet,
      vrfFacet: vrfFacet
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