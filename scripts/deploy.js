/* global ethers hre */

const diamondUtils = require('./lib/diamond-util/src/index')
const deployUtils = require('./lib/deploy-utils')

let totalGasUsed = ethers.BigNumber.from('0')

const main = async (scriptName) => {
  console.log('Script Name: ', scriptName)

  let tx, receipt
  const accounts = await ethers.getSigners()
  const account = await accounts[0].getAddress()
  const gasLimit = 12300000
  const name = 'Snowdrops'
  const symbol = 'SNOWDROPS'
  const snowdropsAddress = '0xE7635787CB5B41C47E08107087290e996e60464c'
  // Chainlink Variables (Set for Mumbai)
  const chainlinkKeyHash = '0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4'
  const chainlinkFee = ethers.utils.parseEther('0.0001')
  const vrfCoordinator = '0x8C7382F9D8f56b33781fE506E897a4F1e2d17255'
  let linkAddress = ''

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
      args: [[name, symbol, snowdropsAddress, chainlinkKeyHash, chainlinkFee, vrfCoordinator, linkAddress]]
    })

    console.log('Snowdrops diamond address:' + snowdropsDiamond.address)
    
    // Get Transaction Info
    tx = snowdropsDiamond.deployTransaction
    receipt = await tx.wait()
    console.log('Snowdrops diamond deploy gas used:' + deployUtils.strDisplay(receipt.gasUsed))
    totalGasUsed = totalGasUsed.add(receipt.gasUsed)

    // Get Diamond Facets
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', snowdropsDiamond.address)
    snowdropFacet = await ethers.getContractAt('SnowdropFacet', snowdropsDiamond.address)
    itemFacet = await ethers.getContractAt('ItemFacet', snowdropsDiamond.address)
    metaTransactionFacet = await ethers.getContractAt('MetaTransactionFacet', snowdropsDiamond.address)
    vrfFacet = await ethers.getContractAt('VRFFacet', snowdropsDiamond.address)

    console.log('Total gas used: ' + deployUtils.strDisplay(totalGasUsed))

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
    
    let tx = facetInstance.deployTransaction
    let receipt = await tx.wait()

    console.log(`${facet} deploy gas used:` + deployUtils.strDisplay(receipt.gasUsed))
    totalGasUsed = totalGasUsed.add(receipt.gasUsed)
    instances.push(facetInstance)
  }

  return instances
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